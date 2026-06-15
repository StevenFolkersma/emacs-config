;;; -*- lexical-binding: t -*-
(require 'elfeed)

(defun nano-elfeed-entry (title subtitle date tags unread &optional
 no-newline)
    (let* ((foreground-color (if unread
                                 (face-foreground 'default)
                               (face-foreground 'font-lock-comment-face nil t)))
           (background-color (face-background 'highlight))
           (border-color     (face-background 'default))
           (face-upper    `(:foreground ,foreground-color
                            :background ,background-color
                            :overline ,border-color))
           (face-title    `(:foreground ,foreground-color
                            :background ,background-color
                            :weight ,'bold
                            :overline ,border-color))
           (face-subtitle `(:foreground ,foreground-color
                            :background ,background-color
                            :family "Roboto Mono"
                            :height 170
                            :underline nil
                            ))
           (face-lower    `(:foreground ,foreground-color
                            :background ,background-color
                            :underline nil
                            ))
           (window-width (window-width))
           (title-max-width (- window-width 10))
           (indicator  (if unread "  " "  ")))
      (insert
              (propertize indicator 'face face-title)
              (propertize (truncate-string-to-width subtitle title-max-width nil nil "...") 'face face-title 'elfeed-entry t)
              (propertize " " 'display "\n"))
      (insert "   " 
              (propertize title 'face face-upper)
              " | "
              (propertize date 'face face-subtitle)
              " | "
              (propertize (string-join tags " ") 'face 'elfeed-search-tag-face))
       ))

(defun nano-elfeed-search-print-entry (entry)
    "Alternative printing of elfeed entries using SVG tags."

    (let* ((date (elfeed-search-format-date (elfeed-entry-date entry)))
           (title (or (elfeed-meta entry :title)
                      (elfeed-entry-title entry) ""))
           (unread (member 'unread (elfeed-entry-tags entry)))
           (tags (mapcar #'symbol-name (elfeed-entry-tags entry)))
           (feed (elfeed-entry-feed entry))
           (feed-title (when feed
                         (or (elfeed-meta feed :title)
                             (elfeed-feed-title feed)))))

      (nano-elfeed-entry feed-title title date tags  unread t)) )

(defun nano-elfeed-search-mode ()
    (setq left-fringe-width 0
          right-fringe-width 0
          left-margin-width 0
          right-margin-width 0)
    (set-window-buffer nil (current-buffer))

    (setq hl-line-overlay-priority 100)
    (hl-line-mode -1)
    (setq cursor-type nil)
    (face-remap-add-relative 'hl-line :inherit 'nano-faded-i)
    (hl-line-mode t))

;  (defun nano-elfeed-show-mode () ;; (setq truncate-lines t) (let ((inhibit-read-only t) (inhibit-modification-hooks t)) (setq-local truncate-lines nil) ;; (setq header-line-format nil) ;; (face-remap-set-base 'default '(:height 140)) (set-buffer-modified-p nil)))

;;;###autoload
(defun nano-elfeed-next-entry ()
    (interactive)
    (text-property-search-forward 'elfeed-entry t))

;;;###autoload
(defun nano-elfeed-prev-entry ()
    (interactive)
    (text-property-search-backward 'elfeed-entry t))

;;;###autoload
(defun nano-elfeed-show-next ()
    "Show the next item in the elfeed-search buffer."
    (interactive)
    (funcall elfeed-show-entry-delete)
    (with-current-buffer (elfeed-search-buffer)
      (when elfeed-search-remain-on-entry
        (nano-elfeed-next-entry))
      (call-interactively #'elfeed-search-show-entry)))

;;;###autoload
(defun nano-elfeed-show-prev ()
    "Show the previous item in the elfeed-search buffer."
    (interactive)
    (funcall elfeed-show-entry-delete)
    (with-current-buffer (elfeed-search-buffer)
      (when elfeed-search-remain-on-entry (forward-line 1))
      (nano-elfeed-prev-entry)
      (call-interactively #'elfeed-search-show-entry)))

(setq elfeed-search-filter "@12-hours-ago +unread +news"          
        elfeed-search-print-entry-function
             #'nano-elfeed-search-print-entry)

(bind-key "<down>" #'nano-elfeed-next-entry 'elfeed-search-mode-map)
(bind-key "n" #'nano-elfeed-next-entry 'elfeed-search-mode-map)

(bind-key "<up>" #'nano-elfeed-prev-entry 'elfeed-search-mode-map)
(bind-key "p" #'nano-elfeed-prev-entry 'elfeed-search-mode-map)

(bind-key "p" #'elfeed-show-prev 'elfeed-show-mode-map)
(bind-key "n" #'nano-elfeed-show-next 'elfeed-show-mode-map)


  ;(add-hook 'elfeed-search-mode-hook #'nano-elfeed-search-mode) (add-hook 'elfeed-show-mode-hook #'nano-elfeed-show-mode)

;;;###autoload
(defun steven-elfeed-eww-readable ()
   "Open current elfeed entry in eww with readable mode."
   (interactive)
   (let ((link (elfeed-entry-link (elfeed-search-selected :single))))
     (eww link)
     (add-hook 'eww-after-render-hook #'eww-readable nil t)))

;; (define-key elfeed-search-mode-map (kbd "e") 'steven/elfeed-eww-readable)

;;;###autoload
(defun steven-elfeed-play-with-mpv ()
     "Play entry link with mpv."
     (interactive)
     (let ((entry (if (eq major-mode  'elfeed-show-mode) elfeed-show-entry (elfeed-search-selected :ignore-region))))
          (when entry 
             (message "Opening %s with mpv..." (elfeed-entry-link entry))
             (start-process "elfeed-mpv" nil "mpv" (elfeed-entry-link entry)))))

;; (define-key elfeed-search-mode-map (kbd "v") 'steven/elfeed-play-with-mpv) (define-key elfeed-show-mode-map (kbd "v") 'steven/elfeed-play-with-mpv)

(provide 'steven-elfeed-nano)
;;; steven-elfeed-nano.el ends here
