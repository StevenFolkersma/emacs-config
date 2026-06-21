;;; -*- lexical-binding: t -*-
(setq package-archives
      '(("gnu-elpa" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))

;; Highest number gets priority (what is not mentioned has priority 0)
(setq package-archive-priorities
      '(("gnu-elpa" . 3)
        ("melpa" . 2)
        ("nongnu" . 1)))

;; Make native compilation silent.
(when (native-comp-available-p)
  (setq native-comp-async-report-warnings-errors 'silent))

(dolist (path '("~/.config/emacs/personal"
                "~/.config/emacs/steven"))
  (add-to-list 'load-path path))

  (setq make-backup-files nil)
  (setq backup-inhibited nil) ; Not sure if needed, given `make-backup-files'
  (setq create-lockfiles nil)

  ;; Disable the damn thing by making it disposable.
  (setq custom-file (make-temp-file "emacs-custom-"))
  (load custom-file :no-error-if-file-is-missing)

(setq epg-pinentry-mode 'loopback)

(setq custom-safe-themes t)

(use-package exec-path-from-shell
  :ensure t
  :demand t)

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; Prefer lexical binding by default
(set-default-toplevel-value 'lexical-binding t)
(winner-mode 1)
(set-default-coding-systems 'utf-8)

(setq help-window-select t)
(setq save-interprogram-paste-before-kill t)
(setq-default indent-tabs-mode nil
              select-enable-clipboard t)  


;; below are default settings needed on macOS
(if (eq system-type 'darwin)
    (progn
      (setq dired-use-ls-dired t)
      (setq insert-directory-program "/usr/local/bin/gls")
      (setq with-editor-emacsclient-executable
            "/usr/local/bin/emacsclient")))

(use-package bind-key
  :bind (:map help-map ("y" . describe-personal-keybindings)))

(use-package setup-basic
  :bind (("C-g" . steven--keyboard-quit-dwim)
         ("C-a" . back-to-indentation-or-beginning)
         ("C-x C-c" . steven-close)))

(bind-key "C-x C-r" #'recentf-open)
(bind-key "C-x k" #'kill-current-buffer)
(bind-key "M-n" #'make-frame)
(bind-key "C-z"  nil) ;; No suspend frame, used for vertico suspend

;; This has to be C-<up> but has issue on macOS.
(bind-key "C-<up>" #'previous-logical-line)
(bind-key "C-<down>" #'next-logical-line)
(bind-key "C-<wheel-up>" nil) ;; No text resize via mouse scroll
(bind-key "C-<wheel-down>" nil) ;; No text resize via mouse scroll
(bind-key "<f2>" #'toggle-input-method)  ; F2 overrides that two-column gimmick.  Sorry, but no!

(bind-key "M-o" #'delete-blank-lines) ; alias for C-x C-o
(bind-key "M-SPC" #'cycle-spacing)
(bind-key "M-z" #'zap-up-to-char) ; NOT `zap-to-char'
(bind-key "M-c" #'capitalize-dwim)
(bind-key "M-l" #'downcase-dwim) ; "lower" case
(bind-key "M-u" #'upcase-dwim) 
(bind-key "M-=" #'count-words)

;;Execute extened command M-x additions
(bind-key "C-x C-m" #'execute-extended-command)
(bind-key "C-c C-m" #'execute-extended-command)
(bind-key "C-x m" nil)

;; C-x o → switch to other window (standard)
(global-set-key (kbd "C-x o") #'other-frame)

;; M-o → switch to other window
(global-set-key (kbd "M-o") #'other-window)

;; One my annoyances
(with-eval-after-load 'lisp-mode
  (keymap-unset lisp-interaction-mode-map "C-c C-b"))
(with-eval-after-load 'elisp-mode
  (keymap-unset emacs-lisp-mode-map "C-c C-b" nil))

(setq scroll-conservatively 101 ; affects `scroll-step'
      scroll-margin 3
      auto-window-vscroll t
      scroll-preserve-screen-position t)

(pixel-scroll-precision-mode 1)

(set-fontset-font t 'symbol (font-spec :family "Symbols Nerd Font Mono"))

(use-package fontaine
  :ensure t
;  :bind
;    (("C-c t f" . fontaine-set-preset))
  :config
   (setq fontaine-latest-state-file
         (locate-user-emacs-file "fontaine-latest-state.eld"))

   ;; Aporetic is Prot’s highly customised build of Iosevka:
   ;; <https://github.com/protesilaos/aporetic>.
   (setq fontaine-presets
         '((medium
            :default-family "Roboto Mono"
            :default-weight normal
            :default-height 180
            :line-spacing 2
            :header-line-height 1.0
            :mode-line-active-height 1.0
            :mode-line-inactive-height 1.0
            :variable-pitch-family "Roboto Slab")
           (medium-aporetic
            :default-family "Aporetic Sans Mono"
            :default-height 180
            :line-spacing 2
            :header-line-height 1.0
            :mode-line-active-height 1.0
            :mode-line-inactive-height 1.0
            :variable-pitch-family "Roboto Slab")
           (small-aporetic
            :inherit medium-aporetic
            :default-height 135)
           (small
            :default-family "Roboto Mono"
            :default-height 135
            :default-weight thin
            :line-spacing 2
            :header-line-height 1.0
            :mode-line-active-height 1.0
            :mode-line-inactive-height 1.0
            :variable-pitch-family "Roboto Slab")
           (regular) ; like this it uses all the fallback values and is named `regular'
           (medium-thin
            :inherit medium
            :default-weight thin
            :default-height 180
            :line-spacing 2)
           (large
            :inherit medium
            :default-height 200
            :header-line-height 1.0)
           (writing
            :default-family "Roboto Slab"
            :default-weight thin
            :default-height 220
            :header-line-height 1.05
            :mode-line-active-height 1
            :mode-line-inactive-height 1
            :variable-pitch-family "Roboto Slab")
           (t
            ;; I keep all properties for didactic purposes, but most can be
            ;; omitted.  See the fontaine manual for the technicalities:
            ;; <https://protesilaos.com/emacs/fontaine>.
            :default-family "Aporetic Sans Mono"
            :default-weight regular
            :default-height 100

            :fixed-pitch-family nil ; falls back to :default-family
            :fixed-pitch-weight nil ; falls back to :default-weight
            :fixed-pitch-height 1.0

            :fixed-pitch-serif-family nil ; falls back to :default-family
            :fixed-pitch-serif-weight nil ; falls back to :default-weight
            :fixed-pitch-serif-height 1.0

            :variable-pitch-family "Aporetic Serif"
            :variable-pitch-weight nil
            :variable-pitch-height 1.0

            :mode-line-active-family nil ; falls back to :default-family
            :mode-line-active-weight nil ; falls back to :default-weight
            :mode-line-active-height 0.9

            :mode-line-inactive-family nil ; falls back to :default-family
            :mode-line-inactive-weight nil ; falls back to :default-weight
            :mode-line-inactive-height 0.9

            :header-line-family nil ; falls back to :default-family
            :header-line-weight nil ; falls back to :default-weight
            :header-line-height 0.9

            :line-number-family nil ; falls back to :default-family
            :line-number-weight nil ; falls back to :default-weight
            :line-number-height 1.0

            :tab-bar-family nil ; falls back to :default-family
            :tab-bar-weight nil ; falls back to :default-weight
            :tab-bar-height 1.0

            :tab-line-family nil ; falls back to :default-family
            :tab-line-weight nil ; falls back to :default-weight
            :tab-line-height 1.0

            :bold-family nil ; use whatever the underlying face has
            :bold-weight bold

            :italic-family nil
            :italic-slant italic

            :line-spacing nil)))

   ;; Set the last preset or fall back to desired style from `fontaine-presets'
   ;; (the `regular' in this case).
   (fontaine-set-preset (or (fontaine-restore-latest-preset) 'medium-thin))

   ;; Persist the latest font preset when closing/starting Emacs and
   ;; while switching between themes.
   (fontaine-mode 1))

(fontaine-mode 1)

(use-package modus-themes
  :ensure t)

(use-package ef-themes
    :ensure t
    :demand t
    :init
    ;; This makes the Modus commands listed below consider only the Ef
    ;; themes.  For an alternative that includes Modus and all
    ;; derivative themes (like Ef), enable the
    ;; `modus-themes-include-derivatives-mode' instead.  The manual of
    ;; the Ef themes has a section that explains all the possibilities:
    ;;
    ;; - Evaluate `(info "(ef-themes) Working with other Modus themes or taking over Modus")'
    ;; - Visit <https://protesilaos.com/emacs/ef-themes#h:6585235a-5219-4f78-9dd5-6a64d87d1b6e>
    (modus-themes-include-derivatives-mode 1)
    :bind
    (("<f5>" . modus-themes-rotate)
     ("C-<f5>" . modus-themes-select)
     ("M-<f5>" . modus-themes-load-random))
    :config
    ;; All customisations here.
    (setq modus-themes-mixed-fonts t)
    (setq modus-themes-italic-constructs t))

(use-package doric-themes
  :ensure t
  :demand t
  :config
  ;; These are the default values.
  (setq doric-themes-to-toggle '(doric-light doric-dark))
  (setq doric-themes-to-rotate doric-themes-collection))

(use-package spacious-padding
  :ensure t
  :demand t
  :config
  (defvar steven-spacious-padding-default-widths
    '(:internal-border-width 20
      :header-line-width 4
      :mode-line-width 1
      :custom-button-width 0
      :tab-width 4
      :right-divider-width 30
      :scroll-bar-width 8
      :fringe-width 0))

  (defvar steven-spacious-padding-default-lines
    '(:mode-line-active header-line
      :mode-line-inactive header-line-inactive
      :header-line-active header-line
      :header-line-inactive header-line-inactive))

  (defvar steven-spacious-padding-minimal-widths
    '(:internal-border-width 20
      :header-line-width 0
      :mode-line-width 0
      :custom-button-width 0
      :tab-width 4
      :right-divider-width 30
      :scroll-bar-width 8
      :fringe-width 0))

  (defvar steven-spacious-padding-minimal-lines
    nil)

  (defun steven-apply-spacious-padding-default ()
    "Apply the default spacious padding style."
    (interactive)
    (setq spacious-padding-widths
          steven-spacious-padding-default-widths)
    (setq spacious-padding-subtle-frame-lines
          steven-spacious-padding-default-lines)
    (spacious-padding-mode -1)
    (spacious-padding-mode 1))

  (defun steven-apply-spacious-padding-minimal ()
    "Apply the minimal spacious padding style."
    (interactive)
    (setq spacious-padding-widths
          steven-spacious-padding-minimal-widths)
    (setq spacious-padding-subtle-frame-lines
          steven-spacious-padding-minimal-lines)
    (spacious-padding-mode -1)
    (spacious-padding-mode 1)))

(steven-apply-spacious-padding-default)

;(steven-apply-spacious-padding)

;(global-set-key (kbd "C-c t p")
;                #'steven-toggle-spacious-padding)

;(define-key global-map (kbd "<f8>") #'spacious-padding-mode)

(use-package setup-modeline
  :demand t ;;make sure it always load and config is ran
  :bind (("<f10>" . steven-toggle-headerline)
         ("<f8>" . steven-toggle-modeline))
  :hook ((doric-themes-after-load-theme . steven--doric-headerline-faces)
         (modus-themes-after-load-theme . steven--modus-headerline-faces))
  :config
  (setq steven-modeline-style 'default
        steven-headerline-style 'default)
  (steven-apply-headerline)
  (steven-apply-modeline))

(use-package theme-extras
  :demand t
  :config
  (doric-themes-load-theme 'doric-oak))

(defvar steven--context-var nil
  "Buffer-local context variable set via dir-locals, this is purely for the
   modeline to show a context location for my notes folders. This could
   be handled via a directory, but this is a quick fix.")

;(add-to-list 'safe-local-variable-values
;             '((steven--context-var . "Notes")
;               (steven--context-var . "Personal Wiki")))

(progn
  (put 'steven--context-var 'safe-local-variable #'stringp)
  (put 'visual-line-mode 'safe-local-variable #'booleanp)
  (put 'auto-fill-mode 'safe-local-variable #'booleanp))

;;loading the .el file
(use-package setup-frame)

(bind-keys :prefix-map toggle-map
           :prefix "C-c t"
           :prefix-docstring "Keymap for commands that toggle settings."
           ("n" . column-number-mode)
           ("d" . toggle-debug-on-error)
           ("f" . fontaine-set-preset)
           ("m" . steven-toggle-modeline)
           ("h" . steven-toggle-headerline)
           ("p" . spacious-padding-mode)
           ("a" . auto-fill-mode)
           ("o" . olivetti-mode)
           ("w" . steven-toggle-frame-width)
           ("i" . whitespace-mode)
           ("v" . visual-line-mode)
           ("i" . visual-fill-column-mode)
           ("c" . center-document-mode)
           ("r" . variable-pitch-mode)
           ("s" . visible-mode))

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

(setq initial-buffer-choice t)
(setq initial-major-mode 'lisp-interaction-mode)
(setq initial-scratch-message  ";; -*- lexical-binding: t; -*-\n")

(use-package scratch
  :ensure t
  :config
  (defun my/scratch-buffer-setup ()
    "Add contents to `scratch' buffer and name it accordingly.
If region is active, add its contents to the new buffer."
    (unless (derived-mode-p
             'text-mode 'prog-mode 'conf-mode 'tex-mode)
      (condition-case nil
          (let ((pick
                 (read-multiple-choice
                  "Switch major mode?"
                  '((?o "org") (?m "markdown")
                    (?l "lisp-interaction") (?e "elisp")
                    (?  "Continue")))))
            (pcase (car pick)
              (?o (org-mode)) (?m (markdown-mode))
              (?l (lisp-interaction-mode)) (?e (emacs-lisp-mode)))
            (read-only-mode 0))
        (quit nil)))
    (when (derived-mode-p 'emacs-lisp-mode)
      (message "Auto-switching to `lisp-interaction-mode'")
      (lisp-interaction-mode))
    (let* ((mode major-mode))
      (rename-buffer (format "*Scratch for %s*" mode) t)))
  (setf (alist-get "\\*Scratch for" display-buffer-alist nil nil #'equal)
        '((display-buffer-same-window)))
  :hook (scratch-create-buffer . my/scratch-buffer-setup)
  :bind ("C-c s" . scratch))

(setq default-input-method "latin-prefix")
(setq-default fill-column 78)

(setq display-line-numbers-type t)
(setq-default truncate-lines nil)
(global-hl-line-mode 1)

;; turn on truncation in prog mode
(use-package text-mode
  :ensure nil
  :hook
  ((text-mode . visual-line-mode)
   (prog-mode . (lambda ()
               (setq-local truncate-lines t)
               (setq-local sentence-end-double-space t))))
  :config
  (setq sentence-end-double-space nil)
  (setq sentence-end-without-period nil)
  (setq colon-double-space nil)
  (setq use-hard-newlines nil)
  (setq adaptive-fill-mode t))

(use-package text-extras
  :bind
  (("C-v" . steven-scroll-down-quarter-screen)
   ("M-v" . steven-scroll-up-quarter-screen)
   ("M-q" . steven-cycle-paragraph)
   :map org-mode-map
   ("<f6>" . OSPV-mode)))

(use-package visual-fill-column
  :ensure t)

(setq split-window-preferred-direction 'horizontal) ; Emacs 31
;;(setq window-combination-resize t)
;;(setq even-window-sizes 'height-only)
;;(setq window-sides-vertical nil)
;;(setq switch-to-buffer-in-dedicated-window 'pop)
(setq split-height-threshold 85)
(setq split-width-threshold 100)
(setq window-min-height 3)
(setq window-min-width 30)

(add-to-list 'display-buffer-alist
             '("\\*e?shell\\*"
               (display-buffer-in-side-window)
               (side . bottom)
               (slot . -1) ;; -1 == L  0 == Mid 1 == R
               (window-height . 0.33) ;; take 2/3 on bottom left
               (window-parameters
                (no-delete-other-windows . nil))))
(add-to-list 'display-buffer-alist
             '("\\*\\(Backtrace\\|Compile-log\\|Messages\\|Warnings\\)\\*"
               (display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.33)
               (window-parameters
                (no-delete-other-windows . nil))))

(add-to-list 'display-buffer-alist
           '("\\*\\(Org \\(Select\\|Note\\)\\|Agenda Commands\\)\\*" ; the `org-capture' key selection and `org-add-log-note'
           (display-buffer-in-side-window)
           (dedicated . t)
           (side . bottom)
           (slot . 0)
           (window-parameters . ((mode-line-format . none)))))
             
;(add-to-list 'display-buffer-alist
;             '("\\*\\([Hh]elp\\|Command History\\|command-log\\)\\*"
;               (display-buffer-in-side-window)
;               (side . right)
;               (slot . 0)
;               (window-parameters
;                (no-delete-other-windows . nil))))

(setq help-window-select t)  ;; automatically focus help window

(add-to-list 'display-buffer-alist
             '("\\*TeX errors\\*"
               (display-buffer-in-side-window)
               (side . bottom)
               (slot . 3)
               (window-height . shrink-window-if-larger-than-buffer)
               (dedicated . t)))

(add-to-list 'display-buffer-alist
             '("\\*TeX Help\\*"
               (display-buffer-in-side-window)
               (side . bottom)
               (slot . 4)
               (window-height . shrink-window-if-larger-than-buffer)
               (dedicated . t)))

(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)))


(add-to-list 'display-buffer-alist
             '("\\*Word Etymology\\*"
               (display-buffer-in-side-window)
               (side . right)
               (window-width . 0.4    )
               (dedicated . t)))

(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

(use-package goto-chg
  :ensure t
  :bind (("C-(" . goto-last-change)
         ("C-)" . goto-last-change-reverse)))

(use-package trashed
  :ensure t
  :commands (trashed)
  :config
  (setq trashed-action-confirmer 'y-or-n-p)
  (setq trashed-use-header-line t)
  (setq trashed-sort-key '("Date deleted" . t))
  (setq trashed-date-format "%Y-%m-%d %H:%M:%S"))

(setq search-whitespace-regexp ".*?")
(setq isearch-lax-whitespace t)
(setq isearch-regexp-lax-whitespace nil)
(setq isearch-wrap-pause t) ; `no-ding' makes keyboard macros never quit
(setq isearch-repeat-on-direction-change t)
(setq search-highlight t)
(setq isearch-lazy-highlight t)
(setq lazy-highlight-initial-delay 0.5)
(setq lazy-highlight-no-delay-length 4)
(setq isearch-lazy-count t)
(setq lazy-count-prefix-format "(%s/%s) ")
(setq lazy-count-suffix-format nil)

(use-package dired
    :ensure nil
    :commands (dired)
    :hook
    ((dired-mode . dired-hide-details-mode)
     (dired-mode . hl-line-mode)
     (dired-mode . dired-omit-mode))
    :config
    (setq dired-free-space nil)
    (setq dired-hide-details-hide-information-lines t)
    (setq dired-recursive-copies 'always)
    (setq dired-recursive-deletes 'always)
    (setq delete-by-moving-to-trash t)
    (setq dired-dwim-target t)
    (setq dired-listing-switches "-alh --group-directories-first")
    (defun steven--dired-layout ()
       "Custom behaviors for dired layout."
       (setq truncate-lines t))
    (add-hook 'dired-mode-hook #'steven--dired-layout t)
    (defun steven--dired-rename-buffer ()
      "Rename Dired buffers to their directory name."
      (when (derived-mode-p 'dired-mode)
        (rename-buffer
         (abbreviate-file-name
          (expand-file-name dired-directory))
         t)))
    ;(add-hook 'dired-mode-hook #'steven--dired-rename-buffer)
    (use-package dired-x
       :ensure nil  ;; also built-in
       :config
       (setq dired-omit-files
            (concat dired-omit-files
             "\\|^\\.DS_Store$"
             "\\|^\\.stfolder$"
             "\\|^\\.localized$"))))

(use-package dired-extras)

(use-package dired-subtree
  :ensure t
  :after dired
  :bind
  ( :map dired-mode-map
    ("<tab>" . dired-subtree-toggle)
    ("TAB" . dired-subtree-toggle)
    ("<backtab>" . dired-subtree-remove)
    ("S-TAB" . dired-subtree-remove))
  :config
  (setq dired-subtree-use-backgrounds nil))

(use-package dired-preview
    :ensure t
    :config
    (setq dired-preview-delay 0.3)
    (setq dired-preview-inline t)
    (setq dired-preview-image-types '("png" "jpg" "jpeg" "gif"))
    (define-key dired-mode-map (kbd "C-c C-p") 'dired-preview-file)
    (setq dired-preview-auto-preview t)
    (setq dired-preview-max-size (expt 2 20))
    (setq dired-preview-ignored-extensions-regexp
          (concat "\\."
                  "\\(gz\\|"
                  "zst\\|"
                  "tar\\|"
                  "xz\\|"
                  "rar\\|"
                  "zip\\|"
                  "iso\\|"
                  "epub"
                  "\\)")))

;; Image related dwim commands are in image-extras.el
(use-package dwim-shell-command
  :ensure t)

(use-package image-extras
  :bind (("C-c i w" . steven-image-insert-wikimedia) ;; obsolete
         ("C-c i l" . steven-image-insert-local)
         ("C-c i s" . steven-image-wikimedia-search)
         ("C-c i y" . steven-image-yank)))

(use-package colorful-mode
  ;; :diminish
  :ensure t ; Optional
  :custom
  (colorful-use-prefix t)
  (colorful-prefix-string " ")
  (colorful-only-strings 'only-prog)
  (css-fontify-colors nil)
  :config
  (global-colorful-mode t)
  (add-to-list 'global-colorful-modes 'helpful-mode))

(use-package setup-language
  :bind ("C-<f7>" . steven-toggle-language)
  :hook (text-mode . steven--apply-language-settings)
  :config
  (steven--apply-language-settings))

;; Set the default server to dict.org (avoids prompting each time)
(setq dictionary-server "dict.org")

;; Optional: Set default dictionary to GCIDE for Webster's 1913
(setq dictionary-default-dictionary "gcide")

;; Optional: Bind a key for quick lookups (e.g., on the current word at point)
(global-set-key (kbd "C-c d") #'dictionary-search)

(use-package wiktionary-bro
  :ensure t)

(use-package define-word
  :ensure t)

;; Use Hunspell as the spell-checker
(use-package ispell
  :ensure nil
  :custom
  (ispell-dictionary "nl_NL")
  (flyspell-default-dictionary "nl_NL")
  (ispell-local-dictionary-alist
   '(("en_GB" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_GB") nil utf-8)
     ("nl_NL" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "nl_NL") nil utf-8)))
  :config
  (when (executable-find "hunspell")
    (setq-default ispell-program-name "hunspell")
    (setq ispell-really-hunspell t)))

(use-package flyspell
  :ensure nil
  ;:hook (text-mode . flyspell-mode)
  :bind
  ("<f7>" . flyspell-mode)
  (:map flyspell-mode-map
   ("C-." . nil)))
;(add-hook 'text-mode-hook 'flyspell-mode)

(with-eval-after-load 'org
  (setq org-confirm-babel-evaluate nil)
  (setq org-src-window-setup 'current-window)
  (setq org-edit-src-persistent-message nil)
  (setq org-src-fontify-natively t)
  (setq org-src-preserve-indentation t)
  (setq org-src-tab-acts-natively t)
  (setq org-edit-src-content-indentation 0))

;; Redirect auto-saves
(setq auto-save-file-name-transforms
      `((".*" "~/.config/emacs/auto-saves/\\1" t)))

;;;; Repeatable key chords (repeat-mode)
(repeat-mode 1)
(setq set-mark-command-repeat-pop t)

(use-package savehist 
  :ensure nil ; it is built-in 
  :hook (after-init . recentf-mode))

(use-package minibuffer
  :bind
  (:map minibuffer-local-completion-map
        ("<backtab>" . minibuffer-force-complete))
  :custom
  (completion-styles '(orderless))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion orderless))))
                                   ;(command (styles +orderless-with-initialism))
                                   ;(buffer (styles +orderless-with-initialism))))
  (read-file-name-completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (completion-ignore-case t)
  (enable-recursive-minibuffers t)
  (resize-mini-windows 'grow-only)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  :init
  (minibuffer-depth-indicate-mode)
  (minibuffer-electric-default-mode)
  :hook
  (minibuffer-setup . cursor-intangible-mode))

(use-package savehist
  :ensure nil ; it is built-in
  :hook (after-init . savehist-mode))

  ;; Enable electric-indent-mode globally
  (electric-indent-mode -1)
  (electric-pair-mode 1)
  (electric-quote-mode 1)

(use-package markdown-mode
  :ensure t
  :bind
  (:map markdown-mode-map
        ("C-c m" . markdown-mode-style-map))
  :hook
  (markdown-mode . turn-on-visual-line-mode)
  :custom
  (markdown-hide-markup t)
  :custom-face
  (markdown-metadata-key-face ((t (:inherit default))))
  (markdown-metadata-value-face
   ((t (:inherit default :foreground unspecified)))))
  ;:config
  ;(fset 'markdown-mode-style-map markdown-mode-style-map)
  ;(modify-syntax-entry ?\" "\"" markdown-mode-syntax-table))

      ;;; Org-mode (personal information manager)
(use-package org
    :ensure nil
    ;;:init
    ;;(add-to-list 'safe-local-variable-values '(org-hide-leading-stars . t))
    ;;(add-to-list 'safe-local-variable-values '(org-hide-macro-markers . t))
    :bind
    ( :map global-map
      ("C-c l" . org-store-link)
      ("C-c a" . org-agenda)
      ("C-c o" . org-open-at-point-global)
      :map org-mode-map
      ;; I don't like that Org binds one zillion keys, so if I want one
      ;; for something more important, I disable it from here.
      ("C-c M-l" . org-insert-last-stored-link)
      ("C-c C-M-l" . org-toggle-link-display)
      ("C-'" . nil) ;using this for completion-at-point
      ("C-," . nil)
      ("C-c C-b" . nil) ;using this to switch buffer
      ;("M-." . org-edit-special) ; alias for C-c ' (mnenomic is global M-. that goes to source)
      :map org-src-mode-map
      ("M-," . org-edit-src-exit) ; see M-. above
      :map narrow-map
      ("b" . org-narrow-to-block)
      ("e" . org-narrow-to-element)
      ("s" . org-narrow-to-subtree))
    :config
    (setq org-directory (expand-file-name "~/Documents/Org/"))
    (setq org-agenda-files (list "agenda.org" "inbox.org" "projects.org" "personal.org" "readinglist.org")) 
    (setq org-agenda-skip-scheduled-if-done t)
    (setq org-imenu-depth 7)
    (setq org-refile-targets '(("agenda.org" :maxlevel . 1)
      ("personal.org" :maxlevel . 1)
      ("readinglist.org" :maxlevel . 1)
      ("projects.org" :maxlevel . 2)))
    (setq org-refile-use-outline-path 'file)
    (setq org-outline-path-complete-in-steps nil)
    (setq org-hide-emphasis-markers nil)
    (setq org-hide-leading-stars nil)
    (setq org-ellipsis " ▼")
    (setq org-cycle-separator-lines 1) ;;number of seperator lines between collapsed headings
    (setq org-structure-template-alist
  	'(("s" . "src")
  	  ("e" . "src emacs-lisp")
  	  ("E" . "src emacs-lisp :results value code :lexical t")
  	  ("t" . "src emacs-lisp :tangle FILENAME")
  	  ("b" . "src bash")
  	  ("x" . "comment")
          ("n" . "note")
  	  ("q" . "quote")))
    (setq org-fold-catch-invisible-edits 'show) ;; what happens when you edit in a folded block
    (setq org-loop-over-headlines-in-active-region 'start-level)
    (setq org-modules '(ol-info ol-eww))
    (setq org-startup-with-inline-images t)
    (setq org-insert-heading-respect-content t)
    ;;(setq org-highlight-latex-and-related nil) ; other options affect elisp regexp in src blocks
    (setq org-fontify-quote-and-verse-blocks t)
    (setq org-fontify-whole-block-delimiter-line t)
    (setq org-fontify-done-headline nil)
    (setq org-priority-faces nil)
    (setq org-log-done 'time)
    (setq org-table-convert-region-max-lines 20000)
    (setq org-todo-keywords        ; This overwrites the default Doom org-todo-keywords
  	'((sequence
  	   "TODO(t)"           ; A task that is ready to be tackled
  	   "NEXT(n)"           ; An idea, not urgent
  	   "HOLD(h)"            ; To read, not urgent
  	   "|"                 ; needed for separation
  	   "DONE(d)"           ; Task has been completed
  	   "ARCHIVED(a)" )))
    (setq org-link-frame-setup
      '((file . find-file)))
    (setq org-agenda-custom-commands
      '(("g" "Get Things Done (GTD)"
         ((agenda ""
                  ((org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'deadline))
                   (org-deadline-warning-days 0)))

          (todo "NEXT"
                ((org-agenda-skip-function
                  '(org-agenda-skip-entry-if 'deadline))
                 (org-agenda-prefix-format "  %i %-12:c [%e] ")
                 (org-agenda-overriding-header "\nTasks\n")))


          (tags-todo "planning"
                     ((org-agenda-prefix-format "  %?-12t% s")
                      (org-agenda-overriding-header "\nPlanning\n")))
          (agenda nil
                  ((org-agenda-entry-types '(:deadline))
                   (org-agenda-format-date "")
                   (org-deadline-warning-days 7)
                   (org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'notregexp "\\* NEXT"))
                   (org-agenda-overriding-header "\nDeadlines")))

          (tags-todo "inbox"
                     ((org-agenda-prefix-format "  %?-12t% s")
                      (org-agenda-overriding-header "\nInbox\n")))
     (org-link-set-parameters
        "org-title"
        :store (defun store-org-title-link ()
                 "Store a link to the org file visited in the current buffer.
     Use the #+TITLE as the link description. The link is only stored
     if `org-store-link' is called from the #+TITLE line."
                 (when (and (derived-mode-p 'org-mode)
                            (save-excursion
                              (beginning-of-line)
                              (looking-at "#\\+\\(?:TITLE\\|title\\):")))
                   (org-link-store-props
                    :type "file"
                    :link (concat "file:" (buffer-file-name))
                    :description (cadar (org-collect-keywords '("TITLE")))))))
          )))))

(use-package org-modern
  :ensure t
  :after org
  :config
  ;; Use custom symbols for heading stars
  (setq org-modern-star '("" "" "" "" "" ""))

  ;; Hide the original asterisks
  (setq org-modern-hide-stars nil)
  (setq org-modern-star 'replace)
  ;;(setq org-hide-leading-stars t) Already set in main org settings

  ;; Keep indentation reasonable
  (setq org-indent-indentation-per-level 2)

  ;; Disable other org-modern features
  (setq org-modern-table nil)
  (setq org-modern-list nil)
  (setq org-modern-block-name nil)
  (setq org-modern-checkbox nil)
  (setq org-modern-priority nil)
  (setq org-modern-tag nil)
  (setq org-modern-timestamp nil)
  (setq org-modern-keyword nil)
  (setq org-modern-todo nil)
  (setq org-modern-horizontal-rule nil))

(add-hook 'org-modern-mode-hook
          (lambda ()
            (setq org-hide-leading-stars org-modern-mode)))
(add-hook 'org-mode-hook #'org-modern-mode)

  (use-package org-capture
       :ensure nil
       :bind ("C-c c" . org-capture)
       :config

       (setq org-capture-templates
             `(("e" "Emacs Inbox" entry
                (file+olp "projects.org" "emacs" "Tasks")
                ,(concat "* %^{Title}\n"
                         ":PROPERTIES:\n"
                         ":CAPTURED: %U\n"
                         ":END:\n\n"
                         "%i\n%?\n")
                :empty-lines-after 1)
   	    ("i" "Inbox" entry
                (file+headline "inbox.org" "Inbox")
                ,(concat "* %^{Title}\n"
                         ":PROPERTIES:\n"
                         ":CAPTURED: %U\n"
                         ":END:\n\n"
                         "%i\n%?\n")
                :empty-lines-after 1)
               ("r" "Wishlist" entry
                (file+olp "inbox.org" "Whishlist")
                ,(concat "* %^{Title} %^g\n"
                         ":PROPERTIES:\n"
                         ":CAPTURED: %U\n"
                         ":END:\n\n"
                         "%i\n%?\n")
                :empty-lines-after 1))))

(org-babel-do-load-languages
    'org-babel-load-languages
    '((emacs-lisp . t)
      (python     . t)
      (shell      . t)))

(setq org-confirm-babel-evaluate
     (lambda (lang body)
       (not (member lang '("emacs-lisp" "python" "shell" "yaml" )))))

(use-package org-cliplink
  :ensure t
  :commands (org-cliplink)
  :after org
  :bind (:map org-mode-map
         ("C-c l" . org-cliplink)))

(use-package consult-template
  :vc (:url "https://github.com/StevenFolkersma/consult-template.git" :rev :newest)
  :demand t
  :custom
  ;; Where templates are persisted. Defaults to templates.el in
  ;; user-emacs-directory. Set this before the package loads.
  (consult-templates-file "~/.config/emacs/my-templates.el")
  :bind
  ("C-c i i" . consult-template-insert)
  ("C-c i d" . consult-template-define))

(use-package placeholder
  :vc (:url "https://github.com/oantolin/placeholder.git")
  :bind
  ("M-_" . placeholder-insert)
  ("C-S-n" . placeholder-forward)
  ("C-S-p" . placeholder-backward))

(setq org-export-directory "Exports")

(use-package ox-publish
  :after org)

(use-package mkdocs-extras)

(use-package setup-export)

(use-package expand-region
  :ensure t
  :bind (
         ("C--" . er/contract-region)
         ("C-=" . er/expand-region)))

(use-package consult
  :ensure t
  :bind
  ("M-y" . consult-yank-pop)
  ("M-X" . consult-mode-command)
  ("C-c b" . consult-buffer)
  ("C-c C-b" . consult-buffer) ;this only works in org-mode, in lisp mode it overwritten
  ("C-c 4 b" . consult-buffer-other-window)
  ("C->" . consult-register-store)
  ("C-," . consult-register-load)
  ("C-M-," . consult-register)
  (:map goto-map
        ("l" . consult-line)
        ("M-l" . consult-line)
        ("L" . consult-line-multi)
        ("i" . consult-imenu)
        ("o" . consult-outline)
        ("a" . consult-org-agenda)
        ("I" . consult-imenu-multi)
        ("m" . consult-mark)
        ("k" . consult-global-mark)
        ("h" . consult-org-heading))
  (:map search-map
        ("f" . consult-find)
        ("M-f" . consult-find)
        ("s" . consult-outline)
        ("M-s" . consult-outline)
        ("g" . consult-grep)
        ("G" . consult-git-grep)
        ("r" . consult-ripgrep)
        ("i" . consult-info)
        ("K" . consult-keep-lines)
        ("F" . consult-focus-lines))
  (:map minibuffer-local-map
        ("M-h" . consult-history)
        ("M-r") ("M-s"))
  (:map consult-narrow-map
        ("C-<" . consult-narrow-help))
  (:map isearch-mode-map
        ("M-g l" . consult-line))
  :config
  (setq consult-line-numbers-widen t)
  (setq consult-async-min-input 3)
  (setq consult-async-input-debounce 0.5)
  (setq consult-async-input-throttle 0.8)
  ;; Below are all the standard buffer sources for C-x b. 
  ;; I just moved the bookmarks up to have them listed earlier
  (setq consult-buffer-sources
        '(consult-source-buffer
          consult-source-hidden-buffer
          consult-source-modified-buffer
          consult-source-bookmark
          consult-source-other-buffer
          consult-source-recent-file
          consult-source-buffer-register
          consult-source-file-register 
          consult-source-project-buffer-hidden
          consult-source-project-recent-file-hidden
          consult-source-project-root-hidden))
  (add-to-list 'consult-preview-allowed-hooks 'visual-line-mode)
  (setq consult-find-args
        (concat "find . -not ( "
                "-path */.git* -prune "
                "-or -path */.cache* -prune )"))
  (setq consult-preview-key '(:debounce 0.4 any))
  (consult-customize
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-buffer consult-outline
   :preview-key "M-.")
  ;; Preview after a short delay
  (consult-customize
   consult-find
   :preview-key '(:debounce 0.3 any))
  :custom
   (completion-in-region-function #'consult-completion-in-region)
   (register-preview-function #'consult-register-format)
   (consult-narrow-key "<"))

;; Consult with orderless (from consult wiki)
;(use-package consult
;  :disabled
;  :after orderless
;  :defer
;  :config
;  (defun consult--orderless-regexp-compiler (input type &rest _config)
;    (setq input (orderless-pattern-compiler input))
;    (cons
;     (mapcar (lambda (r) (consult--convert-regexp r type)) input)
;     (lambda (str) (orderless--highlight input t str)))))

(use-package consult-extras
  )

(use-package consult-notes
  :ensure t
  :commands (consult-notes
             consult-notes-search-in-all-notes)
  :config
  ;(setq consult-notes-file-dir-sources '(("Wiki" ?h "~/Documents/Wiki/")))
  ;(setq consult-notes-org-headings-files '("~/Documents/Org/agenda.org"
  ;                                         "~/Documents/Org/projects.org"))

  (when (locate-library "denote")
    (consult-notes-denote-mode)))

(use-package consult-dir
  :ensure t
  :after consult
  :bind (("C-x C-d" . consult-dir)
         :map minibuffer-local-completion-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file))
  :config
  (defun steven--consult-wrapper (&optional dir initial)
    "A wrapper function for consult-find, so preview is active"
    (interactive)
    (let ((this-command 'steven--consult-wrapper))
      (consult-find dir initial)))

  (consult-customize
   steven--consult-wrapper
   :state (consult--file-preview))
  (setq consult-dir-default-command #'steven--consult-wrapper))
  ;;(consult-customize
  ;;   consult-find
  ;;   :preview-key '(:debounce 0.4 any)))

(use-package denote
    :vc (:url "https://github.com/protesilaos/denote")
    :hook
    ;; If you use Markdown or plain text files you want to fontify links
    ;; upon visiting the file (Org renders links as buttons right away).
    ((text-mode . denote-fontify-links-mode-maybe)
     ;; Highlight Denote file names in Dired buffers.  Below is the
     ;; generic approach, which is great if you rename files Denote-style
     ;; in lots of places as I do.
     ;;
     ;; If you only want the `denote-dired-mode' in select directories,
     ;; then modify the variable `denote-dired-directories' and use the
     ;; following instead:
     ;;
     ;;  (dired-mode   . denote-dired-mode-in-directories)
     (dired-mode . denote-dired-mode))
    :bind
    ;; Denote DOES NOT define any key bindings.  This is for the user to
    ;; decide.  Here I only have a subset of what Denote offers.
    ( :map global-map
      ("C-c n F" . consult-notes)
      ("C-c n n" . steven-denote-notes)
      ("C-c n w" . steven-denote-wiki)
      ("C-c n N" . denote-type)
      ("C-c n d" . denote-sort-dired)
      ;; Note that `denote-rename-file' can work from any context, not
      ;; just Dired buffers.  That is why we bind it here to the
      ;; `global-map'.
      ;;
      ;; Also see `denote-rename-file-using-front-matter' further below.
      ("C-c n r" . denote-rename-file)
      ("C-c n k" . denote-rename-file-keyword)
      ("C-c n s" . denote-signature)
      ;; If you intend to use Denote with a variety of file types, it is
      ;; easier to bind the link-related commands to the `global-map', as
      ;; shown here.  Otherwise follow the same pattern for
      ;; `org-mode-map', `markdown-mode-map', and/or `text-mode-map'.
      :map org-mode-map
       ("C-c n i" . denote-link) ; "insert" mnemonic
       ("C-c n I" . denote-add-links)
       ("C-c n b" . denote-backlinks)
       ("C-c n R" . denote-rename-file-using-front-matter)
      ;; Key bindings specifically for Dired.
      :map dired-mode-map
      ("C-c C-d C-i" . denote-dired-link-marked-notes)
      ("C-c C-d C-r" . denote-dired-rename-marked-files)
      ("C-C C-d C-k" . denote-dired-rename-marked-files-with-keywords)
      ("C-c C-d C-f" . denote-dired-rename-marked-files-using-front-matter))
    :config
    ;; Remember to check the doc strings of those variables.
    (setq denote-directory "~/Documents/Notes/")
    (setq denote-prompts '(title keywords))
    ;; If you want to have a "controlled vocabulary" of keywords,
    ;; meaning that you only use a predefined set of them, then you want
    ;; `denote-infer-keywords' to be nil and `denote-known-keywords' to

    ;; have the keywords you need.
    (setq denote-known-keywords '("emacs" "idea" "note" "recipe" "bikes" "config"))
    (setq denote-infer-keywords t)
    (setq denote-sort-keywords t)
    (setq denote-rename-confirmations nil)
    (setq denote-buffer-name-prefix "") ; to identify all Denote buffers
    (setq denote-rename-buffer-format "%D")
    (setq denote-open-link-function #'find-file)
    (denote-rename-buffer-mode 1))

(use-package steven-denote-extras)

(use-package consult-denote
  :vc (:url "https://github.com/protesilaos/consult-denote"  :rev :newest)
  :bind
  (("C-c n f" . consult-denote-find)
   ("C-c n g" . consult-denote-grep))
  :config
  (defun steven-consult-find-notes (&optional dir initial)
    (consult-find dir initial))

  (consult-customize
     steven-consult-find-notes
     :state (consult--file-preview)
     :prompt "Find (All Notes): ")

  (setq consult-denote-find-command #'steven-consult-find-notes)
  (consult-denote-mode 1))

(use-package denote-org
  :vc (:url "https://github.com/protesilaos/denote-org")
  :commands
  ;; I list the commands here so that you can discover them more
  ;; easily.  You might want to bind the most frequently used ones to
  ;; the `org-mode-map'.
  ( denote-org-link-to-heading
    denote-org-backlinks-for-heading

    denote-org-extract-org-subtree

    denote-org-convert-links-to-file-type
    denote-org-convert-links-to-denote-type

    denote-org-dblock-insert-files
    denote-org-dblock-insert-links
    denote-org-dblock-insert-backlinks
    denote-org-dblock-insert-missing-links
    denote-org-dblock-insert-files-as-headings))

(use-package denote-silo
  :vc (:url "https://github.com/protesilaos/denote-silo")
  ;; Bind these commands to key bindings of your choice.
  :commands ( denote-silo-create-note
              denote-silo-open-or-create
              denote-silo-select-silo-then-command
              denote-silo-dired
              denote-silo-cd )
  :config
  ;; Add your silos to this list.  By default, it only includes the
  ;; value of the variable `denote-directory'.
  (setq denote-silo-directories
        (list denote-directory
              "~/Documents/Notes/"
              "~/Documents/Wiki/"
              "~/Documents/Recipebook/Recipes")))

(use-package denote-journal
  :vc (:url "https://github.com/protesilaos/denote-journal")
  ;; Bind those to some key for your convenience.
  :commands ( denote-journal-new-entry
              denote-journal-new-or-existing-entry
              denote-journal-link-or-create-entry
              steven/denote-writingclass-entry )
  :hook (calendar-mode . denote-journal-calendar-mode)
  :config
  ;; Use the "journal" subdirectory of the `denote-directory'.  Set this
  ;; to nil to use the `denote-directory' instead.
  (setq denote-journal-directory
        (expand-file-name "Journal" denote-directory))
  ;; Default keyword for new journal entries. It can also be a list of
  ;; strings.
  (setq denote-journal-keyword "journal")
  ;; Read the doc string of `denote-journal-title-format'.
  (setq denote-journal-title-format 'day-date-month-year)
  (defun steven/denote-writingclass-entry ()
    (interactive)
    (let ((internal-date (current-time)))
      (denote
       (denote-journal-daily--title-format internal-date)
       '("writingclass")
       nil nil nil nil nil))))

(use-package denote-embark
  :vc (:url "https://github.com/StevenFolkersma/denote-embark.git" :rev :newest)
  :after (embark consult denote consult-extras)
  :config
  (dolist (map '(embark-org-link-map
               embark-region-map
               embark-identifier-map))
  (define-key (symbol-value map)
              (kbd "n")
              denote-embark-link-map))
  (dolist (map '(embark-file-map
               embark-buffer-map
               embark-bookmark-map))
  (define-key (symbol-value map)
              (kbd "n")
              denote-embark-notes-map)))

(require 'prot-pair)

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c p") nil))

(use-package vertico
  :ensure t
  :bind
  (:map vertico-map
        ("DEL" . vertico-directory-delete-char)
        ("M-i"     . vertico-insert)
        ("C-M-n"   . vertico-next-group)
        ("C-M-p"   . vertico-previous-group)
        ("C-j"     . (lambda () (interactive)
	        	(if minibuffer--require-match
	        	    (minibuffer-complete-and-exit)
	        	  (exit-minibuffer))))
        ("C->"     . embark-become)
        (">"       . embark-become))
;  :custom
;  (vertico-multiform-categories
;   '((embark-keybinding grid reverse)
;     (command reverse)
;     (file grid)))
;  (vertico-multiform-commands
;   '((org-set-tags-command grid)
;     (org-agenda-set-tags grid)))
  :commands vertico-mode
  :init (vertico-mode 1)
  :config
  (setq vertico-count 10
      vertico-cycle t
      vertico-resize t)
  ;(vertico-multiform-mode)
  )

(use-package vertico-multiform
  :commands vertico-multiform-mode
  :after vertico
  :bind (:map vertico-map
              ("C-l" . vertico-multiform-flat)
              ("M-q" . vertico-multiform-unobtrusive)
              ("C-M-l" . embark-export))
  :init (vertico-multiform-mode 1)
  :config
  (setq vertico-multiform-categories
         '((file reverse)
           (imenu (vertico-count . 14))
           (face reverse (vertico-count . 8))
           (consult-location reverse)
           (consult-grep buffer)
           (notmuch-result reverse)
           (minor-mode reverse)
           (embark-keybinding grid)
           (history reverse)
           (url reverse)
           (consult-info buffer)
           (kill-ring reverse)
           (consult-compile-error reverse)
           (buffer reverse)
           (org-heading reverse)
           (org-link reverse)
           (t reverse)))
   (setq vertico-multiform-commands
         '((tab-bookmark-open reverse)
           (dired-goto-file unobtrusive)
           (load-theme grid reverse)
           (org-refile reverse)
           (org-agenda-refile reverse)
           (org-capture-refile reverse)
           (execute-extended-command unobtrusive)
           (dired-goto-file flat)
           (consult-project-buffer flat)
           (consult-dir-maybe reverse)
           (consult-dir reverse)
           (consult-flymake reverse)
           (consult-history reverse)
           (consult-completion-in-region reverse)
           (completion-at-point reverse)
           (consult-org-heading reverse)
           (embark-find-definition reverse))))

(use-package vertico-quick
  :after vertico
  :bind (:map vertico-map
         ("M-i" . vertico-quick-insert)
         ("'" . vertico-quick-exit)
         ("C-'" . vertico-quick-embark))
  :config
  (defun vertico-quick-embark (&optional arg)
    "Embark on candidate using quick keys."
    (interactive)
    (when (vertico-quick-jump)
      (embark-act arg))))

(use-package vertico-suspend
  :after vertico
  :bind ("C-z" . vertico-suspend))

(use-package vertico-buffer
  :after vertico
  ;; :hook (vertico-buffer-mode . vertico-buffer-setup)
  :config
  (setq vertico-buffer-display-action 'display-buffer-reuse-window))

(use-package marginalia
  :ensure t
  :bind
  (:map minibuffer-local-map
        ("M-A" . marginalia-cycle))
  :hook (after-init . marginalia-mode)
  :config
  ;trying out these setting from oantolin
  (cl-pushnew '(org-goto . org-heading) marginalia-command-categories)
  (cl-pushnew '(org-refile . org-heading) marginalia-command-categories))

(use-package orderless
  :ensure t
  :config
  ;; Define custom orderless style (standard is only orderless-literal I think)
  ;; I set this in the minibuffer section
  (orderless-define-completion-style +orderless-with-initialism
    (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp)))
  )

;;; Extended minibuffer actions and more (embark.el)
(use-package embark
  :ensure t
  :bind
  ("C-." . embark-act)
  ("C-;" . embark-dwim)
  (:map minibuffer-local-map
        ("C-c C-c" . embark-collect)
        ("C-c C-e" . embark-export)
        ("C-." . embark-act)
        ("C-;" . embark-dwim))
  (:map help-map
        ("b" . embark-bindings)
        ("B" . embark-bindings-at-point)
        ("M" . embark-bindings-in-keymap)
        ("E" . embark-on-last-message))
  (:map completion-list-mode-map
        ("." . embark-act))
  (:map embark-collect-mode-map
        ("a") ; I don't like my own default :)
        ("." . embark-act)
        ("F" . consult-focus-lines))
  (:map embark-package-map
        ("t" . try))
  (:map embark-identifier-map
        ("m" . center-line) ;c is taken by capatilize. m for middle
        ("d" . dictionary-search)
        ("w" . wiktionary-bro))
        ;("e" . steven-gptel-lookup)) ;etmology search with gptel
  (:map embark-region-map
        ("m" . center-region) ; m for middle
        ("=" . quick-calc))
  (:map embark-file-map
        ("L" . load-file)
        ("C" . steven-embark-copy-file-or-directory)) ;from embark-extras
  (:map embark-heading-map
        ("SPC" . outline-mark-subtree)
        ("C-SPC" . embark-select))
  :custom
  (prefix-help-command #'embark-prefix-help-command)
  (embark-indicators '(embark-minimal-indicator
                       embark-highlight-indicator
                       embark-isearch-highlight-indicator))
  (embark-cycle-key ".")
  (embark-keymap-prompter-key "`")
  (embark-help-key "`")
  :config
  (setq embark-quit-after-action
        '((kill-buffer . nil)
          (delete-file . nil)
          (delete-directory . nil)
          (copy-file . nil)
          (rename-file . nil)
          (make-directory . nil)
          (embark-denote-rename-file nil)
          (t . t)))
  (defun embark-on-last-message (arg)
    "Act on the last message displayed in the echo area."
    (interactive "P")
    (with-current-buffer "*Messages*"
      (goto-char (1- (point-max)))
      (cl-letf (((symbol-function #'embark--end-of-target) #'ignore))
        (embark-act arg))))
  )


;; Needed for correct exporting while using Embark with Consult commands.
;; my-embark preview command allows previewing embark-dwim (so I can close afer with C-g)
;; copied from consult wiki.
(use-package embark-consult
  :ensure t
  :after (embark consult)
  :config
  (defun steven-embark-preview ()
    "Previews candidate in vertico buffer, unless it's a consult command"
    (interactive)
    (unless (bound-and-true-p consult--preview-function)
      (save-selected-window
        (let ((embark-quit-after-action nil))
          (embark-dwim)))))
  (define-key minibuffer-local-map (kbd "M-.") #'steven-embark-preview)
  :custom
  (keymap-set embark-general-map "s" 'embark-consult-search-map))

(use-package embark-org
  :bind
  (:map embark-org-link-map
        ("a" . arXiv-map))
  (:map embark-org-heading-map
        ("a" . org-archive-subtree-default)) ; skip confirmation
  (:map embark-org-src-block-map
        ("SPC" . org-babel-mark-block) ("C-SPC")
        ("e" . org-edit-special)))

(use-package embark-extras
  :after (embark consult embark-consult)
  :config
  (add-to-list 'embark-target-finders #'embark-target-this-buffer-file 'append)
  (add-to-list 'embark-keymap-alist '(this-buffer-file . this-buffer-file-map))
  (add-to-list 'embark-keymap-alist '(consult-location . embark-consult-location-map))
  (unless (member 'embark-target-this-buffer-file embark-target-finders)
       (setq embark-target-finders
             (append (butlast embark-target-finders 2)
                     '(embark-target-this-buffer-file)
                      (last embark-target-finders 2))))
  (define-key embark-file-map (kbd "l") steven-embark-file-link-map))

(use-package avy
  :ensure t
  :bind
  (("M-j" . avy-goto-char-timer)
   ([remap goto-line] . avy-goto-line))
  (:map isearch-mode-map
        ("M-j" . avy-isearch))
  :config
  (add-to-list 'avy-dispatch-alist '(?\, . avy-action-goto))
  (defun avy-embark-act (pt)
    "Use Embark to act on the item at PT."
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0)))
      t))
  (add-to-list 'avy-dispatch-alist '(?\. . avy-embark-act))
  (defun avy-action-mark-to-char (pt)
    (activate-mark)
    (goto-char pt))

  (setf (alist-get ?  avy-dispatch-alist) 'avy-action-mark-to-char)
  :custom
  (avy-timeout-seconds 0.6)       ; how long to wait for input in char-timer
  (avy-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)) ; home row keys for jump labels
  (avy-style 'at-full)            ; show label over full target word
  (avy-background t))             ; dim background during selection

(use-package cape
  :ensure t
  :bind ("C-c P" . cape-prefix-map)
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

;this is interfering with prot-pair, need to find another one
(global-set-key (kbd "C-\\") #'completion-at-point)
;; (define-key org-mode-map (kbd

(use-package shr
  :ensure nil
  :config
  (setq shr-use-colors nil)             ; t is bad for accessibility
  (setq shr-use-font nil)             
  (setq shr-max-image-proportion 0.6)
  (setq shr-width 80)
  (setq shr-max-width 80)
  (setq shr-discard-aria-hidden t)
  (setq shr-fill-text nil)              ; Emacs 31
  (setq shr-cookie-policy nil))

(use-package olivetti
  :ensure t
  :commands (olivetti-mode)
  :hook (org-mode . olivetti-mode)
  :config
  (setq-default olivetti-body-width 0.65)
  (setq olivetti-minimum-body-width 80)
  (setq olivetti-recall-visual-line-mode-entry-state nil))

(use-package cursory
  :ensure t
  :demand t
  :if (display-graphic-p)
  :config
  (setq cursory-presets
        '((box
           :cursor-color error ; will typically be green
           :blink-cursor-interval 1.2)
          (box-no-blink
           :inherit box
           :blink-cursor-mode -1)
          (bar
           :cursor-type (bar . 2)
           :cursor-color error ; will typically be red
           :blink-cursor-interval 0.8)
          (bar-no-other-window
           :inherit bar
           :cursor-in-non-selected-windows nil)
          (bar-no-blink
           :inherit bar
           :blink-cursor-mode -1)
          (underscore
           :cursor-color warning ; will typically be yellow
           :cursor-type (hbar . 3)
           :blink-cursor-interval 0.3
           :blink-cursor-blinks 50)
          (underscore-no-other-window
           :inherit underscore
           :cursor-in-non-selected-windows nil)
          (underscore-thick
           :inherit underscore
           :cursor-type (hbar . 8)
           :cursor-in-non-selected-windows (hbar . 3))
          (t ; the default values
           :cursor-color unspecified ; use the theme's original
           :cursor-type box
           :cursor-in-non-selected-windows hollow
           :blink-cursor-mode 1
           :blink-cursor-blinks 10
           :blink-cursor-interval 0.2
           :blink-cursor-delay 0.2)))

  ;; i am using the default value of `cursory-latest-state-file'.

  ;; set last preset or fall back to desired style from `cursory-presets'.
  ;; alternatively, use the function `cursory-set-last-or-fallback' (can be added to the `after-init-hook'.
  (cursory-set-preset (or (cursory-restore-latest-preset) 'box))

  ;; persist configurations between emacs sessions.
  ;; also apply the :cursor-color again when swithcing to another theme.
  (cursory-mode 1))

(use-package logos
  :ensure t
  :bind
  (("C-x n n" . logos-narrow-dwim)
   ("C-x ]"   . logos-forward-page-dwim)
   ("C-x ["   . logos-backward-page-dwim)
   ("M-]"     . logos-forward-page-dwim)
   ("M-["     . logos-backward-page-dwim)
   ("M-n"     . logos-forward-page-dwim)
   ("M-p"     . logos-backward-page-dwim)
   ("<f9>"    . logos-focus-mode))
   :config
   (with-eval-after-load 'logos
    (setq logos-outlines-are-pages t)
    (setq logos-outline-regexp-alist
          `((emacs-lisp-mode . ,(format "\\(^;;;+ \\|%s\\)" logos-page-delimiter))
            (org-mode . ,(format "\\(^\\*+ +\\|^-\\{5\\}$\\|%s\\)" logos-page-delimiter))
            (markdown-mode . ,(format "\\(^\\#+ +\\|^[*-]\\{5\\}$\\|^\\* \\* \\*$\\|%s\\)" logos-page-delimiter))
            (conf-toml-mode . "^\\[")))

    ;; These apply when `logos-focus-mode' is enabled.
    ;; Their value is buffer-local.
    (setq-default logos-hide-mode-line t)
    (setq-default logos-hide-header-line t)
    (setq-default logos-hide-buffer-boundaries t)
    (setq-default logos-hide-fringe t)
    (setq-default logos-variable-pitch t) ; see my `fontaine' configurations
    (setq-default logos-buffer-read-only nil)
    (setq-default logos-scroll-lock nil)
    (setq-default logos-olivetti t)

    (add-hook 'enable-theme-functions #'logos-update-fringe-in-buffers)

;;;; Extra tweaks
    ;; place point at the top when changing pages, but not in `prog-mode'
    (defun steven--logos-recenter-top ()
      "Use `recenter' to reposition the view at the top."
      (unless (derived-mode-p 'prog-mode)
        (recenter 1))) ; Use 0 for the absolute top

    (add-hook 'logos-page-motion-hook #'steven--logos-recenter-top)

    (defun steven--logos-osvp ()
      (when logos-focus-mode
        (logos-set-mode-arg 'OSPV-mode nil)))

;;    (add-hook 'logos-focus-mode-hook #'steven--logos-osvp)
    ))

(use-package elfeed
  :ensure t
  :hook
  (elfeed-show-mode . visual-line-mode)
  :bind
  ("C-c e" . elfeed)
  :config
  (load-file "~/.config/emacs/elfeed-feeds.el"))
  ;(require 'steven-elfeed-nano))

(use-package which-key
  :ensure nil ; built into Emacs 30
  :defer t ; do not load it at startup
  :config
  (setq which-key-separator "  ")
  (setq which-key-prefix-prefix "... ")
  (setq which-key-max-display-columns 3)
  (setq which-key-idle-delay 1.5)
  (setq which-key-idle-secondary-delay 0.25)
  (setq which-key-add-column-padding 1)
  (setq which-key-max-description-length 40))

;; Frame-isolated buffers Another package of mine.
;; Read the manual: <https://protesilaos.com/emacs/beframe>.

(require 'beframe)

;; This is the default value.
;; Write here the names of buffers that should not be beframed.
(setq beframe-global-buffers '("*scratch*" "*Messages*" "*Backtrace*"))

(beframe-mode 1)

;; Bind Beframe commands to a prefix key, such as C-c b:
(define-key global-map (kbd "C-x C-b") #'beframe-prefix-map)

(use-package frame-extras
  :bind (("C-c f s" . steven-select-frame)
         ("C-c f h" . steven-switch-to-home-frame)
         ("C-c f w" . steven-switch-to-wiki-frame)))

;;; Standard Unix Shell (M-x shell)

;; Check Prots .bashrc which handles `comint-terminfo-terminal':
;;
;; # Default pager.  The check for the terminal is useful for Emacs with
;; # M-x shell (which is how I usually interact with bash these days).
;; #
;; # The COLORTERM is documented in (info "(emacs) General Variables").
;; # I found the reference to `dumb-emacs-ansi' in (info "(emacs)
;; # Connection Variables").
;; if [ "$TERM" = "dumb" ] && [ "$INSIDE_EMACS" ] || [ "$TERM" = "dumb-emacs-ansi" ] && [ "$INSIDE_EMACS" ]
;; then
;;     export PAGER="cat"
;;     alias less="cat"
;;     export TERM=dumb-emacs-ansi
;;     export COLORTERM=1
;; else
;;     # Quit once you try to scroll past the end of the file.
;;     export PAGER="less --quit-at-eof"
;; fi
(setq shell-command-prompt-show-cwd t) ; Emacs 27.1
(setq shell-input-autoexpand 'input)
(setq shell-highlight-undef-enable t) ; Emacs 29.1
(setq shell-has-auto-cd nil) ; Emacs 29.1
(setq shell-get-old-input-include-continuation-lines t) ; Emacs 30.1
(setq shell-kill-buffer-on-exit t) ; Emacs 29.1
(setq shell-completion-fignore '("~" "#" "%"))
;(setq tramp-default-remote-shell "/bin/bash")

(setq shell-font-lock-keywords
      '(("[ \t]\\([+-][^ \t\n]+\\)" 1 font-lock-builtin-face)
        ("^[^ \t\n]+:.*" . font-lock-string-face)
        ("^\\[[1-9][0-9]*\\]" . font-lock-constant-face)))

(defun steven--shell-rename-buffer ()
  "Rename shell buffers based on the current project or directory.

If inside a project, rename to:
  *shell for PROJECT*

Otherwise rename to:
  *shell DIRNAME*"
  (when (derived-mode-p 'shell-mode 'eshell-mode)
    (let* ((project
            (when (fboundp 'project-current)
              (project-current nil)))
           (project-name
            (when project
              (file-name-nondirectory
               (directory-file-name
                (project-root project)))))
           (dir-name
            (file-name-nondirectory
             (directory-file-name default-directory)))
           (new-name
            (if project-name
                (format "*shell for project: %s*" project-name)
              (format "*shell %s*" dir-name))))
      (rename-buffer new-name t))))

(add-hook 'shell-mode-hook #'steven--shell-rename-buffer)
(add-hook 'eshell-mode-hook #'steven--shell-rename-buffer)

(use-package eat
  :ensure t
  :custom
  ;; Close buffer when shell exits
  (eat-kill-buffer-on-exit t)
  :bind
  ;; Launch a terminal quickly
  ("C-c z" . eat)
  :config
  ;; Emacs keys work in line mode; flip to char mode when you need the terminal
  (eat-eshell-mode 1)
  (eat-eshell-visual-command-mode 1)) ; programs like vim/htop auto-switch to char mode

;;; Notmuch (mail indexer and mail user agent (MUA))

;; I installed notmuch from the distro's repos because the CLI program is not dependent on Emacs.
;; Though the package also includes notmuch.el which is what we use here (they are maintained by the same people).
(use-package notmuch
  :load-path "/usr/local/share/emacs/site-lisp/notmuch/"
  :defer t
  :commands (notmuch notmuch-mua-new-mail)
  :config
   (define-key notmuch-search-mode-map (kbd "a")
      #'steven/notmuch-archive-and-mark-read)
   (define-key notmuch-show-mode-map (kbd "a")
      #'steven/notmuch-show-archive-and-next))

(use-package ol-notmuch
  :ensure t
  :after notmuch)

;;; Interactive and powerful git front-end (Magit)
(use-package transient
  :ensure t
  :config
  (setq transient-show-popup 0.5))

(use-package magit
  :ensure t
  :bind
  ( :map global-map
    ("C-c g" . magit-status))
  :init
  (setq magit-section-visibility-indicator '(magit-fringe-bitmap> . magit-fringe-bitmapv))
  :config
  (setq git-commit-summary-max-length 50)
  (setq git-commit-style-convention-checks '(non-empty-second-line))
  (setq magit-diff-refine-hunk t)
  ;; Show icons for files in the Magit status and other buffers.
  (with-eval-after-load 'magit
    (setq magit-format-file-function #'magit-format-file-nerd-icons)))

(use-package steven-magit-extras)

(setq auto-revert-interval 1)
(global-auto-revert-mode 1)

(when steven-laptop-p
  (use-package pdf-tools
    :ensure t
    :config
    (pdf-tools-install)
    (add-hook 'pdf-view-mode-hook #'auto-revert-mode)))

(use-package ox-latex
  :ensure nil
  :bind ("<f1>" . org-latex-export-to-pdf)
  :custom
  (org-latex-compiler "pdflatex")
  ;; set standard viewer to emacs pdf-tools
  (TeX-view-program-selection '((output-pdf "PDF Tools"))))

(use-package pdf-extras
  :bind (("C-c t l" . steven--pdf-set-dark-background)
         ("<f1>" . steven-org-export-pdf)
         ("C-<f1>" . steven-org-export-pdf-and-open)))

(use-package gptel
  :vc ( :url "https://github.com/karthink/gptel"
        :rev :newest)
  :bind
  (("C-c <return>" . gptel-send)
   ("C-c j" . gptel-menu)
   (:prefix-map global-gptel-map
    :prefix "C-c i"
    ("c" . gptel)
    ("s" . gptel-send)
    ("r" . gptel-rewrite)
    ("a" . gptel-add)
    ("o" . gptel-mode)
    ("m" . gptel-menu)
    ("x" . gptel-context-remove-all)))
  :config
  ;(require 'gptel-extras) ;; hard loading the extras
  (defun steven--get-api-key (host)
    ;(auth-source-forget-all-cached)
     (let ((entry (car (auth-source-search
                        :host host
                        :max 1
                        :require '(:secret)))))
       (when entry
         (funcall (plist-get entry :secret)))))
  (defvar steven-gptel-profiles nil)
  (defun steven-init-gptel ()
  "Init api-keys and backends"
  (interactive)
  (let* ((openai
          (gptel-make-openai
           "openai"
           :key (steven--get-api-key "openai-personal")
           :models '(gpt-5.4
                     gpt-5.5
                     gpt-5.5-mini)))

         (claude
          (gptel-make-anthropic
           "claude"
           :key (steven--get-api-key "claude-personal")
           :models '(claude-opus-4-8
                     claude-opus-4-6
                     claude-sonnet-4-6
                     claude-haiku-4-5-20251001)))

         (mistral
          (gptel-make-openai
           "mistral"
           :host "api.mistral.ai"
           :endpoint "/v1/chat/completions"
           :protocol "https"
           :key (steven--get-api-key "mistral-personal")
           :models '(mistral-small-latest
                     mistral-medium-latest
                     mistral-large-latest))))

    (setq gptel-backends (list openai claude mistral))
    
    (setq steven-gptel-profiles
      `(("openai"
         :backend ,openai
         :model gpt-5.4)
        ("openai-mini"
         :backend ,openai
         :model gpt-5.4-mini)
        ("claude-sonnet"
         :backend ,claude
         :model claude-sonnet-4-6)
        ("claude-haiku"
         :backend ,claude
         :model claude-haiku-4-5-20251001)
        ("mistral"
         :backend ,mistral
         :model mistral-large-latest)))))
  (steven-init-gptel)
  (setq gptel-backend        (gptel-get-backend "openai")
        gptel-model          'gpt-5.5
        gptel-default-mode   'org-mode
        gptel-stream         t))
  

(use-package gptel-agent
  :vc ( :url "https://github.com/karthink/gptel-agent"
        :rev :newest)
  :config (gptel-agent-update))         ;Read files from agents directories

(use-package gptel-extras
  :after (gptel embark)
  :bind
  (:map embark-identifier-map
        ("e" . steven-gptel-lookup)
        ("d" . steven-gptel-define))
  (:map embark-region-map
        ("x" . steven-gptel-quick)
        ("d" . steven-gptel-define))
  (:map global-gptel-map
        ("b" . steven-gptel-switch-backend)
        ("e" . steven-gptel-lookup) ;etmology lookup
        ("p" . steven-gptel-quick)
        ("d" . steven-gptel-define)))

(use-package center-document-mode
  ;:hook ((org-mode . center-document-mode)
  ;       (markdown-mode . center-document-mode)
  ;       (text-mode . center-document-mode))
  )

(use-package show-font
  :ensure t)
