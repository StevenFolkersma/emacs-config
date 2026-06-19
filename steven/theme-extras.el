;;; -*- lexical-binding: t -*-
;; Here I set some custom overrides for the modus and doric themes. They
;; are added to the after load theme hook. Note that I do not change the
;; headerfline look here,that is done in the corresponding setup in setup-modeline.el 

(defun steven--modus-themes-custom-faces (&rest _)
  (modus-themes-with-colors
    (custom-set-faces
     ;`(fringe ((t :background ,bg-main :foreground ,bg-main)))
     ;`(window-divider ((t :background ,bg-main :foreground ,bg-main)))
     ;`(window-divider-first-pixel ((t :background ,bg-main :foreground ,bg-main)))
     ;`(window-divider-last-pixel ((t :background ,bg-main :foreground ,bg-main)))
     )))

(defun steven--doric-themes-custom-faces (&rest _)
  (doric-themes-with-colors
    (custom-set-faces
     `(region ((t :extend nil))) ; extend region bg only untill fill column width
     ;`(fringe ((t :background ,bg-main :foreground ,bg-main)))
     `(orderless-match-face-0 ((t :inherit bold :foreground ,fg-shadow-subtle)))
     `(orderless-match-face-1 ((t :inherit bold :foreground ,fg-neutral)))
     `(orderless-match-face-2 ((t :inherit bold :foreground ,fg-shadow-intense)))
     `(orderless-match-face-3 ((t :inherit bold :foreground ,fg-shadow-subtle)))
     )))

(add-hook 'modus-themes-after-load-theme-hook
          #'steven--modus-themes-custom-faces)

(add-hook 'doric-themes-after-load-theme-hook
          #'steven--doric-themes-custom-faces)

(provide 'theme-extras)
;;theme-extras ends here
