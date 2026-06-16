;;; -*- lexical-binding: t -*-

;;;###autoload
(defun steven-frame-recenter (&optional frame)
  "Center FRAME on the screen.
FRAME can be a frame name, a terminal name, or a frame.
If FRAME is omitted or nil, use currently selected frame."
  (interactive)
  (unless (eq 'maximised (frame-parameter nil 'fullscreen))
    (modify-frame-parameters
     frame '((user-position . t) (top . 0.5) (left . 0.5)))))

;;;###autoload
(defun steven-toggle-frame-width ()
  "Toggle between maximized and a fixed pixel-sized frame."
  (interactive)
  (let* ((frame (selected-frame))
         (width 800)
         (height 800)
         (is-maximized
          (eq (frame-parameter frame 'fullscreen) 'maximized)))

    (if is-maximized
        ;; Switch to fixed pixel size
        (progn
          (set-frame-parameter frame 'fullscreen nil)

          ;; t => pixelwise
          (set-frame-size frame width height t)

          (delete-other-windows)
          (message "Switched to %dx%d pixels" width height))

      ;; Switch to maximized
      (progn
        (set-frame-parameter frame 'fullscreen 'maximized)
        (message "Switched to MAXIMIZED mode")))))

(provide 'setup-frame)
;;setup-frame.el end here
