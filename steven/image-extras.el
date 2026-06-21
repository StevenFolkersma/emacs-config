;;; -*- lexical-binding: t -*-

(defun steven-image--images-dir ()
  "Return (and create) the images/ dir.
Uses the project root when inside a project, otherwise the current file's directory."
  (unless buffer-file-name (user-error "Buffer has no associated file"))
  (let* ((project (project-current))
         (base (if project
                   (project-root project)
                 (file-name-directory buffer-file-name)))
         (dir (expand-file-name "images" base)))
    (make-directory dir t)
    dir))

(defun steven-image--insert-link (dest)
  "Insert an Org file link for DEST relative to the current file, then refresh."
  (insert (format "[[file:%s]]"
                  (file-relative-name dest (file-name-directory buffer-file-name))))
  (when (fboundp 'org-display-inline-images)
    (org-display-inline-images)))

;; This function basically just inserts a relative path, but also copies the  ;; file to the /images folder 
;;;###autoload
(defun steven-image-insert-local (src)
  "Copy SRC to the images/ folder and insert an Org link at point."
  (interactive
   (list (read-file-name "Image: " nil nil t nil
                         (lambda (f)
                           (string-match-p
                            "\\.\\(png\\|jpg\\|jpeg\\|gif\\|webp\\|svg\\)\\'" f)))))
  (let* ((dir (steven-image--images-dir))
         (dest (expand-file-name (file-name-nondirectory src) dir)))
    (copy-file src dest t)
    (steven-image--insert-link dest)))

(defun steven-image--parse-wikimedia-link (str)
  "Extract the bare filename from a Wikimedia reference STR.
Handles full page URLs, [[File:NAME|ALT]] wikitext, and bare filenames."
  (cond
   ((string-match "wikimedia\\.org/wiki/File:\\([^?#]+\\)" str)
    (url-unhex-string (match-string 1 str)))
   ((string-match "\\[\\[File:\\([^|\\]]+\\)" str)
    (match-string 1 str))))

;;;###autoload
(defun steven-image-insert-wikimedia (link)
  "Download a Wikimedia Commons image from LINK and insert as an Org link.
LINK can be a full Commons page URL, [[File:Foo.jpg|Alt]] wikitext, or bare filename."
  (interactive "sWikimedia link or filename: ")
  (let* ((filename (or (steven-image--parse-wikimedia-link link)
                       (string-trim link)))
         (encoded  (url-hexify-string (string-replace " " "_" filename)))
         (url      (concat "https://commons.wikimedia.org/wiki/Special:FilePath/" encoded))
         (dest     (expand-file-name (file-name-nondirectory filename)
                                     (steven-image--images-dir))))
    (message "Downloading %s …" filename)
    (url-copy-file url dest t)
    (steven-image--insert-link dest)))

(defun steven-image--eww-wikimedia-url (text)
  "Return a Wikimedia Commons file page URL from eww text properties of TEXT, or nil.
Checks shr-url (set on hyperlinks) and help-echo (set on unloaded image placeholders)."
  (or (let ((url (get-text-property 0 'shr-url text)))
        (when (and (stringp url)
                   (string-match-p "wikimedia\\.org/wiki/File:" url))
          url))
      (when-let* ((echo (get-text-property 0 'help-echo text))
                  (_ (stringp echo))
                  (_ (string-match "https://commons\\.wikimedia\\.org/wiki/File:[^ )#?]+" echo)))
        (match-string 0 echo))))

(defun steven-image--clipboard-file ()
  "Return a local image file path from the system clipboard, or nil.
Checks the text/uri-list clipboard target for a file:// URI pointing to an image."
  (when (fboundp 'gui-get-selection)
    (when-let* ((raw (ignore-errors
                       (gui-get-selection 'CLIPBOARD (intern "text/uri-list"))))
                (_ (stringp raw)))
      (cl-some (lambda (uri)
                 (let ((uri (string-trim uri)))
                   (when (string-prefix-p "file://" uri)
                     (let ((path (url-unhex-string (substring uri 7))))
                       (when (and (file-exists-p path)
                                  (string-match-p "\\.\\(png\\|jpg\\|jpeg\\|gif\\|webp\\|svg\\)\\'" path))
                         path)))))
               (split-string raw "[\r\n]+" t)))))

;;;###autoload
(defun steven-image-wikimedia-search (query)
  "Search Wikimedia Commons for QUERY in eww (MediaSearch)."
  (interactive "sSearch Wikimedia Commons: ")
  (eww (concat "https://commons.wikimedia.org/w/index.php?search="
               (url-hexify-string query)
               "&title=Special:MediaSearch&type=image")))

(defvar steven-image--thumb-cache (make-hash-table :test 'equal)
  "Cache of thumbnail URL -> Emacs image object, persists across picks.")

(defun steven-image--wikimedia-search-results (query)
  "Return alist of (FILENAME . THUMBURL) for QUERY via the Commons API."
  (let* ((url  (concat "https://commons.wikimedia.org/w/api.php?"
                       "action=query&generator=search"
                       "&gsrsearch=FILE:" (url-hexify-string query)
                       "&gsrnamespace=6&gsrlimit=20"
                       "&prop=imageinfo&iiprop=url&iiurlwidth=200"
                       "&format=json"))
         (buf  (url-retrieve-synchronously url t t 10))
         (json (with-current-buffer buf
                 (goto-char (point-min))
                 (re-search-forward "\n\n")
                 (json-parse-buffer :object-type 'alist :array-type 'list)))
         (pages (alist-get 'pages (alist-get 'query json))))
    (kill-buffer buf)
    (delq nil
          (mapcar (lambda (entry)
                    (let* ((page     (cdr entry))
                           (title    (alist-get 'title page))
                           (thumburl (alist-get 'thumburl (car (alist-get 'imageinfo page))))
                           (name     (string-remove-prefix "File:" title)))
                      (when (and name thumburl)
                        (cons name thumburl))))
                  pages))))

(defun steven-image--fetch-thumb (url)
  "Return a cached Emacs image for thumbnail URL, fetching on first call."
  (or (gethash url steven-image--thumb-cache)
      (when-let ((buf (ignore-errors (url-retrieve-synchronously url t t 5))))
        (unwind-protect
            (with-current-buffer buf
              (set-buffer-multibyte nil)
              (goto-char (point-min))
              (when (re-search-forward "\r?\n\r?\n" nil t)
                (let ((img (create-image (buffer-substring (point) (point-max)) nil t)))
                  (puthash url img steven-image--thumb-cache)
                  img)))
          (kill-buffer buf)))))

;;;###autoload
(defun steven-image-wikimedia-pick (query)
  "Search Wikimedia Commons for QUERY and pick an image with live preview."
  (interactive "sSearch Wikimedia Commons: ")
  (require 'consult)
  (let* ((results  (steven-image--wikimedia-search-results query))
         (prev-buf (get-buffer-create " *steven-image-preview*"))
         (prev-win nil)
         (state    (lambda (action cand)
                     (pcase action
                       ('preview
                        (when cand
                          (with-current-buffer prev-buf
                            (let ((inhibit-read-only t))
                              (erase-buffer)
                              (if-let ((img (steven-image--fetch-thumb
                                             (cdr (assoc cand results)))))
                                  (insert-image img)
                                (insert "fetching…"))))
                          (unless (window-live-p prev-win)
                            (setq prev-win
                                  (display-buffer
                                   prev-buf
                                   '(display-buffer-in-side-window
                                     (side . right) (window-width . 35)))))))
                       ('exit
                        (when (window-live-p prev-win)
                          (delete-window prev-win))
                        (when (buffer-live-p prev-buf)
                          (kill-buffer prev-buf))))))
         (pick     (consult--read
                    (mapcar #'car results)
                    :prompt (format "Image [%s]: " query)
                    :state state
                    :require-match t)))
    (when pick
      (steven-image-insert-wikimedia pick))))

;;;###autoload
(defun steven-image-yank ()
  "Insert an image from the kill ring or clipboard as an Org link.

Three cases are handled:
- Kill ring entry has a `display' property containing image data (e.g. copied
  from eww): saves that data to images/ and prompts for a filename.
- System clipboard has a file:// URI pointing to a local image (e.g. copied
  from a file manager): copies the file to images/ and inserts a link.
- Kill ring entry is a plain string that looks like a Wikimedia URL or filename:
  downloads it from Commons."
  (interactive)
  (let* ((text      (current-kill 0 t))
         (display   (get-text-property 0 'display text))
         (img-spec  (and (listp display) (eq (car display) 'image) display))
         (eww-url   (unless img-spec (steven-image--eww-wikimedia-url text)))
         (clip-file (unless (or img-spec eww-url) (steven-image--clipboard-file))))
    (cond
     (img-spec
      (let* ((type (plist-get (cdr img-spec) :type))
             (data (plist-get (cdr img-spec) :data))
             (file (plist-get (cdr img-spec) :file))
             (ext  (if type (symbol-name type) "jpg"))
             (name (read-string (format "Filename (default: image.%s): " ext)
                                nil nil (concat "image." ext)))
             (name (if (string-match-p "\\.[a-zA-Z]\\{2,4\\}\\'" name)
                       name
                     (concat name "." ext)))
             (dir  (steven-image--images-dir))
             (dest (expand-file-name name dir)))
        (cond
         (data (with-temp-buffer
                 (set-buffer-multibyte nil)
                 (insert data)
                 (write-region (point-min) (point-max) dest)))
         (file (copy-file file dest t))
         (t    (user-error "Cannot extract image data from kill ring")))
        (steven-image--insert-link dest)))
     (eww-url
      (steven-image-insert-wikimedia eww-url))
     (clip-file
      (let* ((dir  (steven-image--images-dir))
             (dest (expand-file-name (file-name-nondirectory clip-file) dir)))
        (copy-file clip-file dest t)
        (steven-image--insert-link dest)))
     ((and (stringp text)
           (string-match-p "\\.[a-zA-Z]\\{2,4\\}\\'" (string-trim text)))
      (steven-image-insert-wikimedia (string-trim text)))
     (t
      (user-error "Kill ring does not contain image data or a recognisable filename")))))

;;;###autoload
(defun steven-image-convert-to-jpg ()
  "Convert marked Dired image(s) to JPEG using ImageMagick."
  (interactive)
  (dwim-shell-command-on-marked-files
   "Convert to JPEG"
   "convert <<f>> <<fne>>.jpg"
   :utils "convert"))

;;;###autoload
(defun steven-image-convert-to-png ()
  "Convert marked Dired image(s) to PNG using ImageMagick."
  (interactive)
  (dwim-shell-command-on-marked-files
   "Convert to PNG"
   "convert <<f>> <<fne>>.png"
   :utils "convert"))

;;;###autoload
(defun steven-image-resize (max-px)
  "Resize marked Dired image(s) to fit within MAX-PX × MAX-PX.
Keeps aspect ratio and never upscales. Appends _<max-px> to the filename."
  (interactive "nMax dimension (px): ")
  (dwim-shell-command-on-marked-files
   (format "Resize to %dpx" max-px)
   (format "convert <<f>> -resize '%dx%d>' <<fne>>_%d.<<e>>" max-px max-px max-px)
   :utils "convert"))

(provide 'image-extras)
;;; image-extras.el ends here
