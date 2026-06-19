;;; -*- lexical-binding: t -*-
;; Simple version of olivetti mode, from Systemcrafters

(defvar center-document-desired-width 80
  "The desired width of a document centered in the window.")

(defun center-document--adjust-margins ()
  ;; Reset margins first before recalculating
  (set-window-parameter nil 'min-margins nil)
  (set-window-margins nil nil)

  ;; Adjust margins if the mode is on
(when center-document-mode
    (let ((margin-width (max 0
                             (truncate
                              (/ (- (window-width)
                                    center-document-desired-width)
                                 2.0)))))
      (when (> margin-width 0)
        (set-window-parameter nil 'min-margins '(0 . 0))
        (set-window-margins nil margin-width margin-width)))))

(define-minor-mode center-document-mode
  "Toggle centered text layout in the current buffer."
  :lighter " Centered"
  :group 'editing
  (if center-document-mode
      (add-hook 'window-configuration-change-hook #'center-document--adjust-margins 'append 'local)
    (remove-hook 'window-configuration-change-hook #'center-document--adjust-margins 'local))
  (center-document--adjust-margins))

;;small helper to adjust window after font change
;;;###autoload
(defun center-document-refresh ()
  (interactive)
  (when center-document-mode
    (center-document--adjust-margins)))

(provide 'center-document-mode)
;;center-document-mode ends here
