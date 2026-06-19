;;; -*- lexical-binding: t -*-

;;;###autoload
(defun steven-org-export-pdf ()
  (interactive)
  (org-latex-export-to-pdf)) ; t mean async export (not working)

;;;###autoload
(defun steven-org-export-pdf-and-open-ext ()
  (interactive)
  (let ((output (org-latex-export-to-pdf)))
    (when output
      (org-open-file output))))

;;;###autoload
(defun steven-org-export-pdf-and-open ()
  (interactive)
  (let ((output (org-latex-export-to-pdf)))
    (when output
      (let ((buf (find-file-noselect output)))
        (with-current-buffer buf
          (pdf-view-mode))
        (switch-to-buffer-other-window buf)))))

(setq pdf-view-midnight-colors
        (cons (face-attribute 'default :foreground)
              (face-attribute 'default :background)))

;;;###autoload
(defun steven--pdf-set-dark-background ()
  (interactive)
  (if pdf-view-midnight-minor-mode
      (pdf-view-midnight-minor-mode -1)
    (pdf-view-midnight-minor-mode 1)))

(provide 'pdf-extras)
;;pdf-extras.el ends here
