;;; -*- lexical-binding: t -*-

(defvar steven-icons-symbolic
  '((dired-mode "  " steven-icons-directory)
    (archive-mode "  " steven-icons-directory)
    (diff-mode " ⇄ " steven-icons-yellow)
    (prog-mode " ⨍ " steven-icons-magenta)
    (org-mode "  " steven-icons-gray)
    (help-mode "   " steven-icons-gray)
    (info-mode "   " steven-icons-gray)
    (conf-mode "  " steven-icons-gray)
    (text-mode "  " steven-icons-green)
    (comint-mode "  " steven-icons-gray)
    (pdf-view-mode " PDF " steven-icons-gray)
    (eww-mode "  " steven-icons-gray)
    (read-only "" steven-icons-red)
    (dedicated "" steven-icons-red)
    (document "󰷈" steven-icons-red)
    (audio "𝅘𝅥𝅮" steven-icons-cyan)
    (image "𜷻" steven-icons-yellow)
    (video "▶" steven-icons-blue)
    (frame "" steven-icons-gray)
    (git "⇅" steven-icons-gray)
    (t " " steven-icons-gray))
  "Same as `steven-icons-alphabetic' with Unicode symbols.")

(defun steven-icons--get (thing)
  "Return `steven-icons' representation of THING."
  (unless (symbolp thing)
    (error "The thing `%s' is not a symbol" thing))
  (let ((icons steven-icons-symbolic)
        icon)
    (while (and thing (not icon))
      (setq icon (alist-get thing icons))
      (unless icon
        (setq thing (get thing 'derived-mode-parent))))
    (or icon (alist-get t icons))))

;;;###autoload
(defun steven-icons-get-icon (thing &optional face)
  "Return propertized icon THING."
  (pcase-let ((`(,icon ,inherent-face) (steven-icons--get thing)))
    (let ((face (or face inherent-face)))
      (concat
 (propertize icon 'face face)
 (propertize " " 'display '(space :width 0.5) 'face face)))))

(provide 'steven-icons)
;;; steven-icons.el ends here
