;;; -*- lexical-binding: t -*-

(defvar steven-dired--limit-hist '()
  "Minibuffer history for `prot-dired-limit-regexp'.")

;;;###autoload
(defun steven-dired-limit-regexp (regexp omit)
  "Limit Dired to keep files matching REGEXP.

With optional OMIT argument as a prefix (\\[universal-argument]),
exclude files matching REGEXP.

Restore the buffer with \\<dired-mode-map>`\\[revert-buffer]'."
  (interactive
   (list
    (read-regexp
     (concat "Files "
             (when current-prefix-arg
               (propertize "NOT " 'face 'warning))
             "matching PATTERN: ")
     nil 'steven-dired--limit-hist)
    current-prefix-arg))
  (dired-mark-files-regexp regexp)
  (unless omit (dired-toggle-marks))
  (dired-do-kill-lines)
  (add-to-history 'steven-dired--limit-hist regexp))

;;;###autoload
(defun steven-dired-here-side-left ()
  "Open Dired for current buffer's directory in a left side window."
  (interactive)
  (let* ((dir (or (and (buffer-file-name)
                       (file-name-directory (buffer-file-name)))
                  default-directory))
         (buffer (dired-noselect dir)))
    (display-buffer
     buffer
     '((display-buffer-in-direction)
      (direction . left)
      (window-width . 0.25)))))

(provide 'dired-extras)
;;dired-extras.el end here
