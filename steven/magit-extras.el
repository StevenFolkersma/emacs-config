;;; -*- lexical-binding: t -*-

;;;###autoload
(defun steven-magit-add-all-and-commit ()
  "Run git add -A and start a Magit commit."
  (interactive)
  (require 'magit)

  (unless (magit-toplevel)
    (user-error "Not inside a Git repository"))

  ;; Equivalent to: git add -A
  (magit-call-git "add" "-A")

  ;; Refresh Magit status if open
  (magit-refresh)

  ;; Open commit buffer
  (magit-commit-create))

(provide 'magit-extras)
;;magit-extras ends here
