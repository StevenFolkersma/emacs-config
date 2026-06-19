;;; -*- lexical-binding: t -*-

(defvar embark-consult-location-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "l") #'steven-org-link-heading-here)
    map)
  "Keymap for consult-location actions.") 

(defvar steven-embark-file-link-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "l") #'embark-insert-link)
    (define-key map (kbd "r") #'embark-insert-relative-link)
    (define-key map (kbd "o") #'steven-embark-store-org-link)
    map)
  "Keymap for note-related Embark actions on files.") 

;;;###autoload
(defun steven-embark-copy-file-or-directory (path)
  "Copy file or directory PATH."
  (interactive "fCopy: ")
  (let ((dest (read-file-name "Copy to: ")))
    (if (file-directory-p path)
        (copy-directory path dest nil nil t)
      (copy-file path dest t))))

;;;###autoload
(defun embark-insert-relative-link (file)
  "Insert a relative Org link without a description to TARGET file"
  (interactive "fFile: ")
  (let* ((relative (file-relative-name file default-directory)))
    (insert (format "[[file:%s]]" relative))))

;;;###autoload
(defun embark-insert-link (file)
  "Insert a relative Org link without a description to TARGET file"
  (interactive "fFile: ")
  (let* ((name (file-name-nondirectory file)))
    (insert (format "[[file:%s][%s]]" file name))))

;;;###autoload
(cl-defun steven-org-link-heading-here (cand)
  "Store link to consult-location"
  (when-let* ((marker (or (get-text-property 0 'consult--candidate cand)
                         (car (get-text-property 0 'consult-location cand)))))
    (save-excursion
      (goto-char marker)
      (org-store-link nil t))
    (org-insert-all-links 1 "" " ")))

;; For files, the default action is find-file:
;;;###autoload
(defun steven-embark-store-org-link-from-file (cand)
  "Store an Org link for file CAND and insert it at origin."
  (interactive "sFile: ")
  (let ((origin-buffer (current-buffer))
        (origin-point (point-marker)))
    (with-current-buffer (find-file-noselect cand)
      (call-interactively #'org-store-link))
    (with-current-buffer origin-buffer
      (goto-char origin-point)
      (org-insert-last-stored-link 1))))

;; Stolen from kathinks
;; Embark actions for this buffer/file
;;;###autoload
(defun embark-target-this-buffer-file ()
      (cons 'this-buffer-file (buffer-name)))

;; Commands to act on current file or buffer.
(defvar this-buffer-file-map
      (let ((map (make-sparse-keymap)))
        (pcase-dolist
            (`(,key ,command) 
             '(("l" load-file)
               ("b" byte-compile-file)
               ("S" sudo-find-file)
               ("r" rename-file-and-buffer)
               ("o" org-babel-tangle)
               ("=" ediff-buffers)
               ("C-=" ediff-files)
               ("!" shell-command)
               ("&" async-shell-command)
               ("x" embark-open-externally)
               ("C-a" embark-attach-file)
               ("c" copy-file)
               ("4" clone-indirect-buffer-other-window)
               ("k" kill-buffer)
               ;; ("l" org-store-link)
               ("#" recover-this-file)
               ("z" bury-buffer)
               ("|" embark-shell-command-on-buffer)
               ("g" revert-buffer-quick)
               ("u" rename-uniquely)
               ("n" clone-buffer)
               ("t" toggle-truncate-lines)))
          (define-key map (kbd key) command))
        map))


;; (defun embark-act-with-completing-read (&optional arg)
;;       (interactive "P")
;;       (let* ((embark-prompter 'embark-completing-read-prompter)
;;              (embark-indicators '(embark-minimal-indicator)))
;;         (embark-act arg)))

(provide 'embark-extras)
;;embark-extras.el ends here
