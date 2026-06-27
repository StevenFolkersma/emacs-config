;;; -*- lexical-binding: t -*-

(defun steven--get-frame-by-name (name)
  "Return frame with NAME or nil."
  (seq-find
   (lambda (frame)
     (string= (frame-parameter frame 'name) name))
   (frame-list)))

(defun steven--get-or-create-frame (name)
  "Return (FRAME . CREATED-P)."
  (let ((frame (steven--get-frame-by-name name)))
    (if frame
        (cons frame nil)
      (cons (make-frame `((name . ,name))) t))))

;;;###autoload
(defun steven-switch-to-home-frame ()
  "Switch to the frame named \"home\"."
  (interactive)
  (let ((frame (seq-find
                (lambda (f)
                  (string= (frame-parameter f 'name) "Home"))
                (frame-list))))
    (when frame
      (select-frame-set-input-focus frame))))

;;;###autoload
(defun steven-switch-to-wiki-frame ()
  "Switch to Wiki frame; create it if missing, and only initialize once."
  (interactive)
  (pcase-let ((`(,frame . ,created)
               (steven--get-or-create-frame "Wiki")))

    
    (select-frame-set-input-focus frame)
    (set-frame-name "Wiki")    
    ;; Only initialize on creation
    (when created
      (with-selected-frame frame
        (dired "~/Documents/Wiki/")))))

;;;###autoload
(defun steven-select-frame ()
  "Select a frame from a list of existing frames."
  (interactive)
  (let* ((frames (frame-list))
         (names (mapcar (lambda (f)
                          (cons (frame-parameter f 'name) f))
                        frames))
         (choice (completing-read "Frame: " (mapcar #'car names)))
         (frame (cdr (assoc choice names))))
    (when frame
      (select-frame-set-input-focus frame))))

(provide 'frame-extras)
;;frame-extras ends here
