;;; steven-templates.el --- Simple text templates  -*- lexical-binding: t -*-

(require 'consult)

;;; Custom variables

(defcustom steven-templates '()
  "Alist of (NAME . TEMPLATE) pairs for `steven-template-insert'.
NAME is a short descriptive string.  TEMPLATE is the text to insert."
  :type '(repeat (cons string string))
  :group 'steven)

;;; Macro

(defmacro steven-template-define (name template)
  "Add a template entry with NAME and TEMPLATE to `steven-templates'.
Both NAME and TEMPLATE must be strings.  Entries are appended so the
list reflects definition order."
  `(add-to-list 'steven-templates (cons ,name ,template) t))

;;; Internal preview state

(defun steven--template-preview (start end candidates)
  "Return a consult state function that previews the template body.
The preview is shown as an overlay between START and END using the
`consult-preview-insertion' face.  The template body is looked up by
matching the (property-stripped) candidate name against CANDIDATES."
  (unless (or (minibufferp)
              (not (eq (window-buffer) (current-buffer))))
    (let (ov)
      (lambda (action cand)
        (cond
         ((and (not cand) ov)
          (delete-overlay ov)
          (setq ov nil))
         ((and (eq action 'preview) cand)
          ;; cand has been stripped of text properties by consult, so look up
          ;; the original candidate from the list to retrieve steven--body.
          (let* ((original (car (member cand candidates)))
                 (body (and original (get-text-property 0 'steven--body original))))
            (when body
              (unless ov
                (setq ov (consult--make-overlay start end
                                                'invisible t
                                                'window (selected-window))))
              (let ((disp (copy-sequence body)))
                (add-face-text-property 0 (length disp)
                                        'consult-preview-insertion t disp)
                (overlay-put ov 'before-string disp))))))))))

;;; Interactive command

;;;###autoload
(defun steven-template-insert ()
  "Select a template by name with live preview and insert it at point."
  (interactive)
  (let* ((start (point))
         (candidates
          (mapcar (lambda (pair)
                    (let ((name (copy-sequence (car pair))))
                      (put-text-property 0 1 'steven--body (cdr pair) name)
                      name))
                  steven-templates))
         (selected
          (consult--read
           candidates
           :prompt "Insert template: "
           :sort nil
           :require-match t
           :category 'steven-template
           :lookup #'consult--lookup-member
           :annotate (lambda (cand)
                       (when-let* ((body (get-text-property 0 'steven--body cand)))
                         (concat "  "
                                 (truncate-string-to-width
                                  (replace-regexp-in-string "\n" "↵" body)
                                  60 nil nil t))))
           :state (steven--template-preview start start candidates))))
    (when selected
      (insert (get-text-property 0 'steven--body selected)))))

(provide 'steven-templates)
;;; steven-templates.el ends here

