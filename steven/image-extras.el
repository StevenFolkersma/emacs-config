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
  "Extract the filename from a Wikimedia [[File:NAME|ALT]] string."
  (when (string-match "\\[\\[File:\\([^|\\]]+\\)" str)
    (match-string 1 str)))

;;;###autoload
(defun steven-image-insert-wikimedia (link)
  "Download a Wikimedia Commons image from LINK and insert as an Org link.
LINK is wikitext format: [[File:Foo.jpg|Alt]] or just the bare filename."
  (interactive "sWikimedia wikitext link: ")
  (let* ((filename (or (steven-image--parse-wikimedia-link link)
                       (string-trim link)))
         (encoded  (url-hexify-string (string-replace " " "_" filename)))
         (url      (concat "https://commons.wikimedia.org/wiki/Special:FilePath/" encoded))
         (dest     (expand-file-name (file-name-nondirectory filename)
                                     (steven-image--images-dir))))
    (message "Downloading %s …" filename)
    (url-copy-file url dest t)
    (steven-image--insert-link dest)))

;;;###autoload
(defun steven-image-wikimedia-search (query)
  "Search Wikimedia Commons for QUERY in eww (MediaSearch)."
  (interactive "sSearch Wikimedia Commons: ")
  (eww (concat "https://commons.wikimedia.org/w/index.php?search="
               (url-hexify-string query)
               "&title=Special:MediaSearch&type=image")))

;;;###autoload
(defun steven-image-yank ()
  "Insert an image from the kill ring as an Org link.

Two cases are handled:
- Kill ring entry has a `display' property containing image data (e.g. copied
  from eww): saves that data to images/ and prompts for a filename.
- Kill ring entry is a plain string that looks like a Wikimedia filename
  (e.g. \"Belo Horizonte Skyline.jpg\"): downloads it from Commons."
  (interactive)
  (let* ((text     (current-kill 0 t))
         (display  (get-text-property 0 'display text))
         (img-spec (and (listp display) (eq (car display) 'image) display)))
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
