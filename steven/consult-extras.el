;;; -*- lexical-binding: t -*-

;;;###autoload
(defun steven-consult-file-containing (pattern)
  "Find files containing PATTERN with rg and read a matching file with preview."
  (interactive "sSearch string: ")
  (let* ((files (process-lines "rg" "-l" pattern))
         (file (consult--read
                files
                :prompt (format "Files (%s): " pattern)
                :sort nil
                :state (consult--file-preview)
                :category 'file
                :require-match t)))
    (find-file file)))


;(defun steven--consult-wrapper-denote ()
;    (interactive)
;    (call-interactively #'steven-consult-find-notes)

;; obsolete
;(defun steven-consult-dir-denote ()
;  "Choose a directory and run ’denote’ on it."
;  (interactive)
;  (let ((denote-directory (consult-dir--pick "In directory: ")))
;      (call-interactively #'denote)))

(provide 'consult-extras)
;;; consult-extras.el ends here
