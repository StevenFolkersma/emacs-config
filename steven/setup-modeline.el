;;; -*- lexical-binding: t -*-

(require 'mode-line-maker)
(require 'steven-headerline)
(require 'steven-icons)
(require 'modus-themes)
(require 'doric-themes)

;;;###autoload
(defun steven-headerline-minimal ()
  "Install a modeline using modeline maker"
  (interactive)
  (let* (
         (left  '(
                  (:eval (steven-headerline-buffer-name))
                  " "
                  (:eval (steven-headerline-context))
                  " "))
         (right `((:eval (steven-header-line-right)) "")))
        (setq-default mode-line-format "")
        (setq header-line-format 
              (mode-line-maker left right '(fringe . fringe)))
        (setq-default header-line-format 
                      (mode-line-maker left right '(fringe . fringe)))
        ))

;; This one might work, but I need to have a seperate face for the
;; header-line, e.g. steven-header-line so the :box draws correctly.
;;;###autoload
(defun steven-headerline-todo ()
  "Install a modeline using modeline maker - not working yet"
  (interactive)
  (let* (
         (left  '((:eval (steven-modeline-major-mode-icon))
                  (:eval (propertize " " 'display '(raise +0.25)))
                  (:eval (steven-headerline-buffer-name))
                  (:eval (propertize " " 'display '(raise -0.25)))
                  (:eval (steven-headerline-context)))
                  )
         (right `((:eval (steven-header-line-right)) "")))
        (setq-default mode-line-format "")
        (setq header-line-format 
              (mode-line-maker left right '(fringe . fringe) t))
        (setq-default header-line-format 
                      (mode-line-maker left right '(fringe . fringe) t))
        ))

;;;###autoload
(defun steven-headerline-default()
  "Install a headerline using modeline maker. This is my default one"
  (interactive)
    (setq-default mode-line-format "")
    (setq-default header-line-format 
          '(
           (:eval (steven-modeline-major-mode-icon))
           (:eval (propertize " " 'display '(raise -0.25)))
           (:eval (steven-headerline-buffer-name))
           (:eval (propertize " " 'display '(raise +0.25)))
           (:eval (steven-headerline-context))
           (:eval (steven-header-line-align-right))
           (:eval (steven-header-line-right)))))

;;;; Also toggle modeline
;;;###autoload
(defun steven-modeline-minimal ()
  "Install a modeline using modeline maker, no content"
  (interactive)
  (setq mode-line-format 
      (mode-line-maker "" "" '(window . window) t))
  (setq-default mode-line-format 
      (mode-line-maker "" "" '(window . window) t)))  

;;;###autoload
(defun steven-modeline-default ()
  "Install a modeline using modeline maker - full version"
  (interactive)
  (let* (
         (left  '((:eval (steven-headerline-major-mode-name))
                  " "
                  (:eval (steven--headerline-git-info))
                  ))

         (right `("( "
                  (:eval (steven--header-line-language))
                  (:eval (steven--modeline-input-method))
                  ;(:eval (steven--modeline-file-size))
                  (:eval (steven-header-line-ispell-dict))
                  ") "
                  (:eval (steven--modeline-cursor-position))
                  )))

        (setq mode-line-format 
              (mode-line-maker left right '(window . window) t))
        (setq-default mode-line-format 
              (mode-line-maker left right '(window . window) t))
        ))

(defvar steven-headerline-style 'default
  "Current header line style.
Can be either 'default or 'minimal.")

(defvar steven-modeline-style 'default
  "Current modeline style.
Can be either 'default or 'minimal.")

;;;###autoload
(defun steven-apply-headerline ()
  "Apply the current header line style to all buffers."
  (cond
    ((eq steven-headerline-style 'default)
     (steven-headerline-default)
     (steven-apply-spacious-padding-minimal))
    ((eq steven-headerline-style 'minimal)
     (steven-headerline-minimal)
     (steven-apply-spacious-padding-default)))

  (dolist (buf (buffer-list))
     (with-current-buffer buf
       (kill-local-variable 'header-line-format)))
   (force-mode-line-update t)
   (redraw-display))

;;;###autoload
(defun steven-apply-modeline ()
  "Apply the current modeline style to all buffers."
  (cond
    ((eq steven-modeline-style 'default)
     (steven-modeline-default))
    ((eq steven-modeline-style 'minimal)
     (steven-modeline-minimal))))

;;; Toggle function
;;;###autoload
(defun steven-toggle-headerline ()
  "Toggle between default and minimal header line styles."
  (interactive)
  (setq steven-headerline-style
        (if (eq steven-headerline-style 'default)
            'minimal
          'default))
  (steven-apply-headerline)
  (message "Headerline style: %s"
           steven-headerline-style))

;;;###autoload
(defun steven-toggle-modeline ()
  "Toggle between default and minimal modeline styles."
  (interactive)
  (setq steven-modeline-style
        (if (eq steven-modeline-style 'default)
            'minimal
          'default))
  (steven-apply-modeline)
  (message "Modeline style: %s"
           steven-modeline-style))

;; This part takes care of the styling of the headerline. It is important
;; to turn on spacious padding after the set-custom-face is done, otherwise
;; it does not work as expected. I just leave spacious padding off by
;; default and turn it on with a toggle.

(defun steven--modus-headerline-faces (&rest _)
  (modus-themes-with-colors
    (custom-set-faces
     `(mode-line-active ((t :underline nil
                            :overline ,fg-main
                            :foreground ,fg-main
                            :box nil
                            :background ,bg-mode-line-inactive
                            :height 1.0)))
     `(mode-line-inactive ((t :underline nil
                              :overline ,fg-main
                              :foreground ,bg-main
                              :box nil
                              :background ,bg-main
                              :height 1.0)))
     `(mode-line-maker-padding-face ((t 
                              :underline nil
                              :foreground ,bg-main
                              :box nil
                              :background ,bg-main)))
     `(header-line ((t 
                            :foreground ,fg-mode-line-active
                            :background ,bg-mode-line-active
                            :box (:line-width 1 :color ,fg-mode-line-active))))
     `(header-line-inactive ((t 
                            :foreground ,fg-mode-line-inactive
                            :background ,bg-mode-line-inactive
                            :box (:line-width 1 :color ,fg-mode-line-inactive))))
     `(header-line-status ((t 
                            :foreground ,fg-mode-line-active
                            :background ,bg-hl-line
                            :box (:line-width 1 :color ,fg-mode-line-active))))
     `(header-line-status-inactive ((t 
                            :foreground ,fg-mode-line-inactive
                            :background ,bg-mode-line-inactive
                            :box (:line-width 1 :color ,fg-mode-line-inactive))))
     )))

(defun steven--doric-headerline-faces (&rest _)
  (doric-themes-with-colors
    (custom-set-faces
     `(mode-line-active ((t :underline nil
                            :overline ,fg-main
                            :foreground ,fg-main
                            :box nil
                            :background ,bg-shadow-subtle
                            :height 1.0)))
     `(mode-line-inactive ((t :underline nil
                              :overline ,bg-main
                              :foreground ,bg-main
                              :box nil
                              :background ,bg-main
                              :height 1.0)))
     `(mode-line-maker-padding-face ((t 
                         :underline nil
                         :foreground ,bg-main
                         :box nil
                         :background ,bg-main)))
     `(steven-header-line ((t 
                            :foreground ,fg-main
                            :background ,bg-shadow-subtle
                            :box (:line-width 1 :color ,fg-main))))
     `(steven-header-line-inactive ((t 
                            :foreground ,fg-shadow-subtle
                            :background ,bg-main
                            :box (:line-width 1 :color ,fg-shadow-subtle))))
     `(header-line ((t 
                            :foreground ,fg-main
                            :background ,bg-shadow-subtle
                            :box (:line-width 1 :color ,fg-main))))
     `(header-line-inactive ((t 
                            :foreground ,bg-neutral
                            :background ,bg-main
                             :box (:line-width 1 :color ,fg-shadow-subtle))))
     `(header-line-status ((t 
                            :foreground ,fg-main
                            :background ,bg-shadow-intense
                            :box (:line-width 1 :color ,fg-main))))
     `(header-line-status-inactive ((t 
                            :foreground ,fg-shadow-subtle
                            :background ,bg-shadow-subtle
                            :box (:line-width 1 :color ,fg-shadow-subtle))))
     )))



(provide 'setup-modeline)
;;setup-modeline.el ends here
