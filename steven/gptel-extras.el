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

  (gptel-request
   word
   :system (steven--gptel-read-prompt
            (expand-file-name "~/.config/emacs/prompts/word-etmologist-en.txt"))
   :callback
   (lambda (response info)
     (if (not response)
         (message "gptel-lookup failed with message: %s"
                  (plist-get info :status))
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
                 `((display-buffer-in-side-window)
                   (side . right)
                   (window-width . 0.5)
                   (slot . 0))))))))

;;;###autoload 
(defun steven-gptel-prompt-and-respond ()
  "Prompt for an instruction, optionally include the active region,
   open an Org scratch buffer for the response, and set the directive
   based on the current major mode."
  (interactive)
  (let ((instruction (read-string "Instruction: "))
        (region-text (when (use-region-p)
                       (buffer-substring-no-properties (region-beginning) (region-end))))
        (directive (if (derived-mode-p 'text-mode)
                       "default-writing-short"
                     "default-emacs-short"))
        (response-buffer (get-buffer-create "*GPTel Response*")))

    ;; Prepare the prompt with the instruction and optional region
    (let ((prompt (if region-text
                      (format "Instruction: %s\n\nSelected text:\n%s" instruction region-text)
                    instruction)))

      ;; Insert the prompt into the response buffer with appropriate directive
      (with-current-buffer response-buffer
        (org-mode)
        (erase-buffer)
        (insert (format "#+BEGIN_SRC :directive %s\n%s\n#+END_SRC\n\n" directive prompt))
        (goto-char (point-max))
        (insert "# Response will appear below:\n\n")
        (display-buffer response-buffer)))))

(provide 'gptel-extras)
;;gptel-extras.el ends here
