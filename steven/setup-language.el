;;; -*- lexical-binding: t -*-

(defvar steven--current-language 'english
  "Current system language.")

;;;###autoload
(defun steven--apply-language-settings ()
  "Apply settings for `my/current-language`."
  (pcase steven--current-language

    ('english
     ;; Spell checking
     (setq jinx-languages "en_GB")
     (when (bound-and-true-p jinx-mode) (jinx-reload))
     (setq wiktionary-bro-language "en")
     (setq whisper-language "en")
     (message "Language set to English"))

    ('dutch
     ;; Spell checking
     (setq jinx-languages "nl_NL")
     (when (bound-and-true-p jinx-mode) (jinx-reload))
     (setq wiktionary-bro-language "nl")
     (setq whisper-language "nl")
     (message "Language set to Dutch"))))

;;;###autoload
(defun steven-toggle-language ()
  "Toggle between English and Dutch."
  (interactive)
  (setq steven--current-language
        (if (eq steven--current-language 'english)
            'dutch
          'english))

  (steven--apply-language-settings))

;obsolete
(defun steven-toggle-spell-language ()
  "Toggle between English and Dutch Hunspell dictionaries."
  (interactive)
  (let ((current-dict ispell-current-dictionary))
    (cond
     ((string= current-dict "en_GB")
      (ispell-change-dictionary "nl_NL")
      (message "Switched dictionary to Dutch (nl_NL)"))
     ((string= current-dict "nl_NL")
      (ispell-change-dictionary "en_GB")
      (message "Switched dictionary to English (en_GB)"))
     (t
      (ispell-change-dictionary "en_GB")
      (message "Defaulted dictionary to English (en_GB)")))))

(provide 'setup-language)
;;setup-languages.el ends here
