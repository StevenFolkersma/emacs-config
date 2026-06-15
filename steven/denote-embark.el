;;; -*- lexical-binding: t -*-
(defvar steven-embark-notes-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n") #'embark-denote-create)
    (define-key map (kbd "o") #'embark-denote-open-or-create)
    (define-key map (kbd "b") #'embark-denote-backlink)
    (define-key map (kbd "r") #'embark-denote-rename-file)
    (define-key map (kbd "i") #'denote-link)
    (define-key map (kbd "l") #'embark-denote-link-newline)
    (define-key map (kbd "L") #'embark-denote-link-list)
    map)
  "Keymap for note-related Embark actions on files.") 

(defvar steven-embark-link-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "b") #'embark-denote-backlink-id)
    (define-key map (kbd "e") #'steven-consult-file-containing)
    (define-key map (kbd "n") #'denote-region)
    (define-key map (kbd "g") #'denote-grep-files-referenced-in-region)
    map)
  "Keymap for note-related Embark actions on links.") 

;;;###autoload
(defun embark-denote-create (target)
  "Run Denote using TARGET's directory.
TARGET can be a file, directory, or bookmark."
  (interactive "fTarget: ")
  (let* ((path
          (cond
           ;; If it's a bookmark name, resolve it
           ((and (stringp target)
                 (bookmark-get-bookmark target 'noerror))
            (bookmark-get-filename target))
           ;; Otherwise assume it's already a path
           ((stringp target) target)
           (t nil)))
         (dir
          (cond
           ((null path) default-directory)
           ((file-directory-p path) path)
           (t (file-name-directory path)))))
    (let ((denote-directory dir))
      (call-interactively #'denote))))

;;;###autoload
(defun embark-denote-open-or-create (target)
  "Run Denote open-or-create using TARGET's directory.
TARGET can be a file, directory, or bookmark."
  (interactive "fTarget: ")
  (let* ((path
          (cond
           ;; If it's a bookmark name, resolve it
           ((and (stringp target)
                 (bookmark-get-bookmark target 'noerror))
            (bookmark-get-filename target))
           ;; Otherwise assume it's already a path
           ((stringp target) target)
           (t nil)))
         (dir
          (cond
           ((null path) default-directory)
           ((file-directory-p path) path)
           (t (file-name-directory path)))))

    (let ((denote-directory dir))
      (call-interactively #'denote-open-or-create))))

;;;###autoload
(defun embark-denote-rename-file (file title keywords signature
 date identifier)
  "Rename file but only accept TARGET, adapted from denote-rename file"
  (interactive
   (let* ((file (expand-file-name 
                (read-file-name "File: " nil nil t))))
     (unless (file-regular-p file)
       (user-error "Not a regular file: %s" file))
   (pcase-let* ((`(,title ,keywords ,signature ,date ,identifier)
                 (denote--rename-get-file-info-from-prompts-or-existing file)))
     (list file title keywords signature date identifier))))
  (let* ((file-type (denote-filetype-heuristics file))
         (title (if (eq title 'keep-current)
                    (or (denote-retrieve-title-or-filename file file-type) "")
                  title))
         (keywords (if (eq keywords 'keep-current)
                       (denote-extract-keywords-from-path file)
                     keywords))
         (signature (if (eq signature 'keep-current)
                        (or (denote-retrieve-filename-signature file) "")
                      signature))
         (date (if (eq date 'keep-current)
                   (denote-retrieve-filename-identifier file)
                 date))
         (identifier (if (eq identifier 'keep-current)
                         (or (denote-retrieve-filename-identifier file) "")
                       identifier))
         ;; Make the data valid
         (date (denote-valid-date-p date))
         (new-name (denote--rename-file file title keywords signature date identifier)))
    (denote-update-dired-buffers)
    new-name))

;;;###autoload
(defun embark-denote-backlink (file)
  "Run `denote-backlinks' for FILE."
  (interactive "fFile: ")
  (let ((buf (find-file-noselect file)))
    (with-current-buffer buf
      (denote-backlinks))))

;;;###autoload
(defun embark-denote-link-newline (file)
  "Insert Denote link with a newline afterwards. Useful for combining with embark-act-all."
  (interactive "fDenote file: ")
  (let* ((file-type (denote-filetype-heuristics buffer-file-name))
         (description (when (file-exists-p file)
                        (denote-get-link-description file))))
    (denote-link file file-type description))
  (unless (bolp)
    (insert "\n")))

;;;###autoload
(defun embark-denote-link-list (file)
  "Insert Denote link as list item. Usefull for combining with embark-act-all"
  (insert "- ")
  (interactive "fDenote file: ")
  (let* ((file-type (denote-filetype-heuristics buffer-file-name))
         (description (when (file-exists-p file)
                        (denote-get-link-description file))))
    (denote-link file file-type description))
  (unless (bolp)
    (insert "\n")))

;;;###autoload
(defun embark-denote-backlink-id (id)
  "Run `denote-backlinks' for the file identified by ID."
  (interactive "sDenote ID: ")
  (let* ((id (string-remove-prefix "denote:" id))
         (file (denote-get-path-by-id id)))
    (unless file
      (user-error "No file found for Denote ID: %s" id))
    (with-current-buffer (find-file-noselect file)
      (denote-backlinks))))

(provide 'denote-embark)
;;; denote-embark.el ends here
