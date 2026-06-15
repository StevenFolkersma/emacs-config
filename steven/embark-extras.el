;;; -*- lexical-binding: t -*-

(defun steven-embark-copy-file-or-directory (path)
  "Copy file or directory PATH."
  (interactive "fCopy: ")
  (let ((dest (read-file-name "Copy to: ")))
    (if (file-directory-p path)
        (copy-directory path dest nil nil t)
      (copy-file path dest t))))

(cl-defun steven-org-link-heading-here (cand)
  (when-let* ((marker (or (get-text-property 0 'consult--candidate cand)
                         (car (get-text-property 0 'consult-location cand)))))
    (save-excursion
      (goto-char marker)
      (org-store-link nil t))
    (org-insert-all-links 1 "" " ")))

;; For files, the default action is find-file:
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

(defvar-keymap embark-consult-outline-map
  :doc "Keymap for operating on org headings in consult-outline"
  :parent embark-general-map
  "L" #'steven-org-link-heading-here)

;; does this need embark-consult?
(add-to-list 'embark-keymap-alist '(consult-location . embark-consult-outline-map))

;; Stolen from kathinks
;; Embark actions for this buffer/file
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

(defun embark-act-with-completing-read (&optional arg)
      (interactive "P")
      (let* ((embark-prompter 'embark-completing-read-prompter)
             (embark-indicators '(embark-minimal-indicator)))
        (embark-act arg)))

(provide 'embark-extras)
;;embark-extras.el ends here
