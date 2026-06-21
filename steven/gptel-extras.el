;;; -*- lexical-binding: t -*-
(defvar gptel-lookup--history nil)

(defun steven--gptel-read-prompt (file)
    "Helper function to read gptel prompt files"
    (with-temp-buffer
      (insert-file-contents file)
      (buffer-string)))

(setf (alist-get 'default gptel-directives)
        (steven--gptel-read-prompt
         (expand-file-name "~/.config/emacs/prompts/default-lisp.txt")))
(setf (alist-get 'word-etmologist gptel-directives)
        (steven--gptel-read-prompt
         (expand-file-name "~/.config/emacs/prompts/word-etmologist-en.txt")))
(setf (alist-get 'woord-professor gptel-directives)
      (steven--gptel-read-prompt
       (expand-file-name "~/.config/emacs/prompts/word-etmologist-nl.txt")))
(setf (alist-get 'photography-assistant gptel-directives)
      (steven--gptel-read-prompt
       (expand-file-name "~/.config/emacs/prompts/photography-assistant.txt")))
(setf (alist-get 'writing-assistant gptel-directives)
        (steven--gptel-read-prompt
         (expand-file-name "~/.config/emacs/prompts/writing-assistant-en.txt")))
(setf (alist-get 'default-linux-short gptel-directives)
        "You are an expert in linux and fedora systems. Answer the user in org mode syntax only. Never use in-line code and use org source blocks. Use full sentences and paragraphs and avoid using lists.")
(setf (alist-get 'default-emacs-short gptel-directives)
        "You are an expert in emacs lisp. Answer the user in org mode syntax only. Use org source blocks for code, never use in-line code. Use full sentences and paragraphs and avoid using lists")
(setf (alist-get 'default-lisp-short gptel-directives)
        "You are an emacs expert. The user is describing an emacs function. Reply with an existing emacs lisp function. ONLY reply with the function, no text, mark-up or anything.")
(setf (alist-get 'default-writing-short gptel-directives)
        "You are an helpful writing assisant and historian philosopher. Anser the user clearly and professionally. Answer the user in org mode syntax only. Use full sentences and paragraphs and avoid using lists.")
(setf (alist-get 'default-photo-short gptel-directives)
        "You are an expert in photography. Answer questions consicely and with technical depth. Answer the user in org mode syntax only. Never use in-line code and use org source blocks when needed. Use full sentences and paragraphs and avoid using lists. The user has an Fujifilm X-E3")
(setf (alist-get 'default-lisp-function gptel-directives)
        "You are an expert in emacs lisp. Answer only in lisp code, no explanations needed")

;;;###autoload
;;;###autoload
(defun steven-gptel-define (text)
  "Define TEXT using gptel — works on a word, phrase, name, or longer passage.
Without a region, falls back to the word at point."
  (interactive
   (list
    (if (use-region-p)
        (prog1 (buffer-substring-no-properties (region-beginning) (region-end))
          (deactivate-mark))
      (or (thing-at-point 'word t)
          (read-string "Define: ")))))
  (let ((trimmed (string-trim text)))
    (when (string-empty-p trimmed) (user-error "Nothing to define"))
    (message "Defining "%s"…"
             (truncate-string-to-width trimmed 50 nil nil "…"))
    (gptel-request
     trimmed
     :system (steven--gptel-read-prompt
              (expand-file-name "~/.config/emacs/prompts/define-this.txt"))
     :callback
     (lambda (response info)
       (if (not (stringp response))
           (message "gptel-define failed: %s" (plist-get info :status))
         (with-current-buffer (get-buffer-create "*Definition*")
           (let ((inhibit-read-only t))
             (erase-buffer)
             (insert response)
             (goto-char (point-min))
             (org-mode)
             (visual-line-mode)
             (read-only-mode 1))
           (display-buffer
            (current-buffer)
            '((display-buffer-in-side-window)
              (side . right)
              (window-width . 0.5)
              (slot . 0)))))))))

(defun steven-gptel-switch-backend ()
  (interactive)
  (let* ((choice
          (completing-read
           "Backend: "
           (mapcar #'car steven-gptel-profiles)
           nil t))
         (profile (assoc choice steven-gptel-profiles)))
    (setq gptel-backend (plist-get (cdr profile) :backend))
    (setq gptel-model   (plist-get (cdr profile) :model))
    (message "Using %s (%s)"
             choice
             gptel-model)))

;;;###autoload
(defun steven-gptel-lookup (word)
  (interactive
   (list
    (or (thing-at-point 'word t)
        (read-string "Word: " nil gptel-lookup--history))))
  (when (string= word "") (user-error "A word is required."))
  (let* ((profile    (cdr (assoc "mistral" steven-gptel-profiles)))
         (gptel-backend  (plist-get profile :backend))
         (gpt-model      (plist-get profile :model))
         (prompt-file (if (eq steven--current-language 'dutch)
                          "~/.config/emacs/prompts/word-etmologist-nl.txt"
                        "~/.config/emacs/prompts/word-etmologist-en.txt"))
         (buf (get-buffer-create "*Word Definition*")))
    (message "Collecting the One True Definition of **%s**...." word)
    (gptel-request
     word
     :system  (steven--gptel-read-prompt (expand-file-name prompt-file))
     :callback
     (lambda (response info)
       (if (not response)
           (message "gptel-prompt-and-respond failed: %s" (plist-get info :status))
         (with-current-buffer (get-buffer-create "*Word Definition*")
           (let ((inhibit-read-only t))
             (erase-buffer)
             (insert response)
             (goto-char (point-min))
             (org-mode)
             (visual-line-mode)
             (read-only-mode 1))
           (display-buffer
            (current-buffer)
            '((display-buffer-in-side-window)
              (side . right)
              (window-width . 0.5)
              (slot . 0)))))))))

;;;###autoload
(defun steven-gptel-quick (region-text)
  "Send REGION-TEXT with an instruction to gptel and display the response.
REGION-TEXT is the sole interactive argument so Embark can supply it as the
target; the instruction is always read from the minibuffer inside the body."
  (interactive
   (list
    (if (use-region-p)
        (prog1 (buffer-substring-no-properties (region-beginning) (region-end))
          (deactivate-mark))
      "")))
  (let* ((instruction (read-string "Instruction: "))
         (system-prompt (alist-get
                         (if (derived-mode-p 'text-mode)
                             'default-writing-short
                           'default-emacs-short)
                         gptel-directives))
         (prompt (if (string-empty-p region-text)
                     instruction
                   (format "%s\n\n%s" instruction region-text))))
    (message "Collecting information, entangling a response")
    (gptel-request
     prompt
     :system system-prompt
     :callback
     (lambda (response info)
       (if (not (stringp response))
           (message "gptel-quick failed: %s" (plist-get info :status))
         (with-current-buffer (get-buffer-create "*The Response*")
           (let ((inhibit-read-only t))
             (erase-buffer)
             (insert response)
             (goto-char (point-min))
             (org-mode)
             (visual-line-mode)
             (read-only-mode 1))
           (display-buffer
            (current-buffer)
            '((display-buffer-in-side-window)
              (side . right)
              (window-width . 0.5)
              (slot . 0)))))))))

(provide 'gptel-extras)
;;gptel-extras.el ends here
