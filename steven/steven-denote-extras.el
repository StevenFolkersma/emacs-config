;;; -*- lexical-binding: t -*-

;;;###autoload
(defun steven-denote-create-note-in-any-directory ()
  "Create new Denote note in any directory.
Prompt for the directory using minibuffer completion."
  (declare (interactive-only t))
  (interactive)
  (let ((denote-directory (read-directory-name "New note in: " nil nil :must-match)))
    (call-interactively 'denote)))

;;;###autoload
(defun steven-denote-notes ()
  "Like `denote' but always use the ~/Documents/Notes/ directory."
  (interactive)
  (let ((denote-use-directory "~/Documents/Notes")
        (denote-use-prompts '(title keywords)))
    (call-interactively 'denote)))

;;;###autoload
(defun steven-denote-wiki ()
  "Like `denote' but always use the ~/Documents/Wiki/ directory."
  (interactive)
  (let ((denote-directory "~/Documents/Wiki")
        (denote-use-prompts '(title keywords)))
    (call-interactively 'denote)))

;;;###autoload
(defun steven-insert-relative-link ()
  "Use `denote-find` to select a Denote file, then insert a relative Org
link without a description."
  (interactive)
  (let* ((file (denote-file-prompt))
         (relative (file-relative-name file default-directory)))
    (insert (format "[[file:%s]]" relative))))

(provide 'steven-denote-extras)
;;steven-denote-extras.el ends here
