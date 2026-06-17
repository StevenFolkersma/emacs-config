(use-package scratch
  :ensure t
  :config
  (defun my/scratch-buffer-setup ()
    "Add contents to `scratch' buffer and name it accordingly.
If region is active, add its contents to the new buffer."
    (unless (derived-mode-p
             'text-mode 'prog-mode 'conf-mode 'tex-mode)
      (condition-case nil
          (let ((pick
                 (read-multiple-choice
                  "Switch major mode?"
                  '((?o "org") (?m "markdown")
                    (?l "lisp-interaction") (?e "elisp")
                    (?  "Continue")))))
            (pcase (car pick)
              (?o (org-mode)) (?m (markdown-mode))
              (?l (lisp-interaction-mode)) (?e (emacs-lisp-mode)))
            (read-only-mode 0))
        (quit nil)))
    (when (derived-mode-p 'emacs-lisp-mode)
      (message "Auto-switching to `lisp-interaction-mode'")
      (lisp-interaction-mode))
    (let* ((mode major-mode))
      (rename-buffer (format "*Scratch for %s*" mode) t)))
  (setf (alist-get "\\*Scratch for" display-buffer-alist nil nil #'equal)
        '((display-buffer-same-window)))
  :hook (scratch-create-buffer . my/scratch-buffer-setup)
  :bind ("C-c s" . scratch))
