;;; -*- lexical-binding: t -*-

;;;###autoload
(defun steven-scroll--quarter-screen-lines ()
  (max 1 (/ (window-body-height) 4)))

;;;###autoload
(defun steven-move-down-quarter-screen ()
  (interactive)
  (line-move (steven-scroll--quarter-screen-lines) t))

;;;###autoload
(defun steven-move-up-quarter-screen ()
  (interactive)
  (line-move (- (steven-scroll--quarter-screen-lines)) t))

;;;###autoload
(defun steven-scroll-down-quarter-screen ()
  (interactive)
  (scroll-up-command (steven-scroll--quarter-screen-lines)))

;;;###autoload
(defun steven-scroll-up-quarter-screen ()
  (interactive)
  (scroll-down-command (steven-scroll--quarter-screen-lines)))

;;;###autoload
(defun my-recenter-after-jump (window new-win-start)
  "Recenter the point after a non-scroll command brings it out of view.
This function is meant to be called from the hook ‘window-scroll-functions’."
  (interactive)
  (with-selected-window window
    (let* ((new-start-line (line-number-at-pos new-win-start))
           (old-start-line (or (bound-and-true-p last-start-line-memo)
                               (line-number-at-pos (point))))
           (distance (abs (- old-start-line new-start-line))))
      (when (and (> distance 5)
                 (not isearch-mode)
                 (not (get last-command 'scroll-command)))
        (recenter))
      (setq-local last-start-line-memo new-start-line))))
(add-hook 'window-scroll-functions #'my-recenter-after-jump)

;;;###autoload
(defun my-unfill-paragraph ()
  "Replace newline chars in current paragraph by single spaces.
This command does the inverse of `fill-paragraph'"
  (interactive)
  (let ((fill-column most-positive-fixnum))
    (fill-paragraph)))

;;;###autoload
(defun my-fill-paragraph-semlf-long ()
  (interactive)
  (let ((fill-column most-positive-fixnum))
    (fill-paragraph-semlf)))

;; It might be nice to figure out what state we're in and then cycle to the next one if we're just working with a single paragraph. In the meantime, just going by repeats is fine.
(defvar my-cycle-functions
  '(fill-paragraph
    my-unfill-paragraph
    my-fill-paragraph-semlf-long)
  "Functions to cycle through.")

(defvar my-cycle-index 0
  "Current position in `my-cycle-functions`.")

;;;###autoload
(defun my-cycle-paragraph ()
  "Cycle through paragraph formatting functions on repeated calls."
  (interactive)
  (unless (eq last-command this-command)
    (setq my-cycle-index 0))
  (let ((fn (nth my-cycle-index my-cycle-functions)))
    (when fn
      (call-interactively fn)
      (message "Ran: %s" fn)))
  (setq my-cycle-index
        (mod (1+ my-cycle-index)
             (length my-cycle-functions))))

(defun steven-org-content-start ()
  "Return position after Org front matter (#+ lines)."
  (save-excursion
    (goto-char (point-min))
    (while (looking-at-p "^#\\+")
      (forward-line 1))
    (point)))

;;;###autoload
(defun steven-unfill-buffer ()
  "Unfill the buffer, excluding Org front matter."
  (interactive)
  (let ((fill-column most-positive-fixnum))
    (fill-region (steven-org-content-start) (point-max))))

;;;###autoload
(defun steven-fill-buffer-semlf ()
  "Apply `fill-paragraph-semlf` to all paragraphs after front matter."
  (interactive)
  (save-excursion
    (let ((fill-column most-positive-fixnum))
      (goto-char (steven-org-content-start))
      (while (< (point) (point-max))
        ;; Skip headings and empty lines
        (cond
         ((org-at-heading-p)
          (forward-line 1))
         ((looking-at-p "^\\s-*$")
          (forward-line 1))
         (t
          ;; Now we're in actual paragraph content
          (fill-paragraph-semlf)
          (forward-paragraph 1)))))))

(define-minor-mode OSPV-mode
  "One Sentence Per Visual-line mode (Org buffers only)."
  :lighter " OSPV"
  (unless (derived-mode-p 'org-mode)
    (user-error "OSPV-mode only works in org-mode"))
  (if OSPV-mode
      (steven-fill-buffer-semlf)
    (steven-unfill-buffer)))

;; Set to t (non-nil) when entering org, not toggle DO NOT turn this on globablly, only in /Notes via .dir-locals
;(add-hook 'org-mode-hook (lambda () (OSPV-mode t)))

(provide 'text-extras)
;;text-extras.el ends here
