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

;; (setq elfeed-search-filter "@12-hours-ago +unread +news"          
;;         elfeed-search-print-entry-function
;;              #'nano-elfeed-search-print-entry)

;; (bind-key "<down>" #'nano-elfeed-next-entry 'elfeed-search-mode-map)
;; (bind-key "n" #'nano-elfeed-next-entry 'elfeed-search-mode-map)

;; (bind-key "<up>" #'nano-elfeed-prev-entry 'elfeed-search-mode-map)
;; (bind-key "p" #'nano-elfeed-prev-entry 'elfeed-search-mode-map)

;; (bind-key "p" #'elfeed-show-prev 'elfeed-show-mode-map)
;; (bind-key "n" #'nano-elfeed-show-next 'elfeed-show-mode-map)

(defun steven-elfeed-eww-readable ()
   "Open current elfeed entry in eww with readable mode."
   (interactive)
   (let ((link (elfeed-entry-link (elfeed-search-selected :single))))
     (eww link)
     (add-hook 'eww-after-render-hook #'eww-readable nil t)))

;; This is a function to open some feeds in eww readable mode, I found that for
;; example with the Guardian and NRC this works quite well. *Not implemented yet*.
;; This now only works from the 'search' mode in elfeed, not during 'show' mode.
;; Not sure what is better. *Note:* define-key causes and error during init since
;; when this is run 'elfeed-search-mode-map' is not yet available!

;;;###autoload
(defun steven-elfeed-play-with-mpv ()
     "Play entry link with mpv."
     (interactive)
     (let ((entry (if (eq major-mode  'elfeed-show-mode) elfeed-show-entry (elfeed-search-selected :ignore-region))))
          (when entry 
             (message "Opening %s with mpv..." (elfeed-entry-link entry))
             (start-process "elfeed-mpv" nil "mpv" (elfeed-entry-link entry)))))

(define-key elfeed-search-mode-map (kbd "v") 'steven/elfeed-play-with-mpv) 
(define-key elfeed-show-mode-map (kbd "v") 'steven/elfeed-play-with-mpv)

;; search by day functions from Karthinks
(defun my/elfeed-search-by-day (dir)
    (lambda (&optional arg)
      (interactive "p")
      (let* ((entry (elfeed-search-selected :ignore-region))
             (this-day (or (and (string-match-p ".*@\\(.+\\)--.*" elfeed-search-filter)
                                (time-to-seconds
                                 (encode-time 
                                  (parse-time-string
                                   (concat (replace-regexp-in-string
                                            ".*@\\([^[:space:]]+?\\)--.*" "\\1"
                                            elfeed-search-filter)
                                           " 00:00:00 Z")))))
                           (and entry
                                (elfeed-entry-date entry))
                           (time-to-seconds
                            (current-time))))
             (next-day (time-add this-day (days-to-time (or arg 1))))
             (next-next-day (time-add next-day (days-to-time (or arg 1))))
             (next-next-next-day (time-add next-next-day (days-to-time (or arg 1))))
             (prev-day (time-subtract this-day (days-to-time (or arg 1))))
             from to)
        (pcase dir
          ('next (setq from next-next-day
                       to   next-next-next-day))
          ('prev (setq from this-day
                       to   next-day))
          (_     (setq from next-day
                       to   next-next-day)))
        (let ((elfeed-search-date-format '("%Y-%m-%d" 10 :left)))
          (setq elfeed-search-filter (concat (replace-regexp-in-string
                                              " @[^[:space:]]*" ""
                                              elfeed-search-filter)
                                             " @"  (elfeed-search-format-date from)
                                             "--" (elfeed-search-format-date to))))
        (elfeed-search-update :force))))
  
(defun my/elfeed-random-date ()
    (interactive)
    (let* ((from
            (time-to-seconds
             (encode-time 
              (parse-time-string
               (format "%d-%02d-%02d 00:00:00 Z"
                       (+ 2012 (cl-random 10))
                       (1+ (cl-random 11))
                       (1+ (cl-random 30)))))))
           (to (time-add from (days-to-time 5)))
           (date-string
            (concat " @" (elfeed-search-format-date from)
                    "--" (elfeed-search-format-date to))))
      (setq elfeed-search-filter
            (concat (replace-regexp-in-string
                     " @[^[:space:]]*" ""
                     elfeed-search-filter)
                    date-string)))
    (elfeed-search-update :force))
  
  (define-key elfeed-search-mode-map (kbd ".") (my/elfeed-search-by-day 'this))
  (define-key elfeed-search-mode-map (kbd "b") (my/elfeed-search-by-day 'next))
  (define-key elfeed-search-mode-map (kbd "f") (my/elfeed-search-by-day 'prev))
  (define-key elfeed-search-mode-map (kbd "`") 'my/elfeed-random-date)

;; setup of more minimal elfeed-show-mode
(defvar steven-elfeed-enclosure-max-height 300
  "Maximum pixel height for inline enclosure images in elfeed-show.")

(defun steven--elfeed-image-url-p (url enc-type)
  "Return non-nil if ENC-TYPE or URL extension indicates an image."
  (or (and enc-type (string-prefix-p "image/" enc-type))
      (string-match-p "\\.\\(jpe?g\\|png\\|gif\\|webp\\|svg\\|avif\\)\\(?:[?#].*\\)?\\'"
                      (downcase url))))

(defun steven--elfeed-insert-image (url)
  "Fetch URL synchronously and insert image capped at `steven-elfeed-enclosure-max-height'.
Falls back to a clickable link on fetch or decode failure."
  (let* ((buf (ignore-errors (url-retrieve-synchronously url t t 5)))
         (image (when (and buf (buffer-live-p buf))
                  (unwind-protect
                      (with-current-buffer buf
                        ;; url-http-end-of-headers is a buffer-local set by url.el;
                        ;; it points to the last header byte, so body starts at +1.
                        (let ((body-start (when (bound-and-true-p url-http-end-of-headers)
                                            (1+ url-http-end-of-headers))))
                          (when body-start
                            (ignore-errors
                              (create-image
                               (buffer-substring-no-properties body-start (point-max))
                               nil t
                               :max-height steven-elfeed-enclosure-max-height)))))
                    (kill-buffer buf)))))
    (if image
        (insert-image image url)
      (elfeed-insert-link url))))

(defun steven-elfeed-show-refresh ()
  "Display the current elfeed entry with a minimal header (Title, Date, Feed only).
Enclosures are rendered inline if they are images, otherwise shown as clickable links."
  (interactive)
  (let* ((inhibit-read-only t)
         (title      (elfeed-entry-title elfeed-show-entry))
         (date       (seconds-to-time (elfeed-entry-date elfeed-show-entry)))
         (nicedate   (format-time-string "%a, %e %b %Y %T %Z" date))
         (content    (elfeed-deref (elfeed-entry-content elfeed-show-entry)))
         (type       (elfeed-entry-content-type elfeed-show-entry))
         (feed       (elfeed-entry-feed elfeed-show-entry))
         (feed-title (elfeed-feed-title feed))
         (base       (and feed (elfeed-compute-base (elfeed-feed-url feed))))
         (enclosures (elfeed-entry-enclosures elfeed-show-entry)))
    (erase-buffer)
    (insert (format (propertize "Title: %s\n" 'face 'message-header-name)
                    (propertize title 'face 'message-header-subject)))
    (insert (format (propertize "Date: %s\n" 'face 'message-header-name)
                    (propertize nicedate 'face 'message-header-other)))
    (insert (format (propertize "Feed: %s\n" 'face 'message-header-name)
                    (propertize feed-title 'face 'message-header-other)))
    (insert "\n")
    (cl-loop for enclosure in enclosures
             do (let ((enc-url  (car enclosure))
                      (enc-type (cadr enclosure)))
                  (if (steven--elfeed-image-url-p enc-url enc-type)
                      (steven--elfeed-insert-image enc-url)
                    (elfeed-insert-link enc-url))
                  (insert "\n")))
    (when enclosures (insert "\n"))
    (if content
        (if (eq type 'html)
            (elfeed-insert-html content base)
          (insert content))
      (insert (propertize "(empty)\n" 'face 'italic)))
    (goto-char (point-min))))

(setq elfeed-show-refresh-function #'steven-elfeed-show-refresh)

(provide 'steven-elfeed-extras)
;;; steven-elfeed-extras.el ends here
