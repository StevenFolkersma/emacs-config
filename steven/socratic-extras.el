;;; -*- lexical-binding: t -*-

(defun steven--socratic-ask (text)
  "Send TEXT to Claude Code CLI and display Socratic questions."
  (let* ((emacs-dir user-emacs-directory)
         (ctx-file (expand-file-name "personal/prompts/steven-context.txt" emacs-dir))
         (sys-file (expand-file-name "prompts/socratic-questioner.txt" emacs-dir))
         (context (when (file-exists-p ctx-file)
                    (with-temp-buffer
                      (insert-file-contents ctx-file)
                      (buffer-string))))
         (system-prompt (with-temp-buffer
                          (insert-file-contents sys-file)
                          (buffer-string)))
         (full-prompt (if context
                          (concat "WRITER CONTEXT:\n" context "\n\n---\n\n" text)
                        text))
         (buf (get-buffer-create "*Socratic Questions*")))
    (with-current-buffer buf
      (erase-buffer)
      (org-mode)
      (insert "* Questions\nGenerating...\n"))
    (pop-to-buffer buf)
    (let ((proc (start-process "socratic-claude" buf
                               "claude" "-p" full-prompt
                               "--system-prompt" system-prompt
                               "--output-format" "text")))
      (set-process-sentinel proc
        (lambda (p _)
          (when (eq (process-status p) 'exit)
            (with-current-buffer (process-buffer p)
              (save-excursion
                (goto-char (point-min))
                (when (re-search-forward "^Generating\\.\\.\\.$" nil t)
                  (delete-region (line-beginning-position)
                                 (1+ (line-end-position))))))))))))

(defun steven-socratic-current-note ()
  "Ask Claude for Socratic questions about the current buffer."
  (interactive)
  (steven--socratic-ask (buffer-string)))

(defun steven-socratic-region ()
  "Ask Claude for Socratic questions about the selected region."
  (interactive)
  (unless (use-region-p)
    (user-error "No region selected"))
  (steven--socratic-ask
   (buffer-substring-no-properties (region-beginning) (region-end))))

(provide 'socratic-extras)
;;; socratic-extras.el ends here
