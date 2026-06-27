;;; -*- lexical-binding: t -*-
(defgroup steven-headerline nil
  "Custom modeline that is stylistically close to the default."
  :group 'header-line)

(defgroup steven-headerline-faces nil
  "Faces for my custom modeline."
  :group 'steven-headerline)

(defface steven-header-line
  '((t (:inherit header-line)))
  "Face for active header line"
  :group 'steven-headerline-faces)

(defface steven-header-line-inactive
  '((t (:inherit header-line-inactve)))
  "Face for inactive header line"
  :group 'steven-headerline-faces)

(defface header-line-status
  '((t (:inherit header-line)))
  "Face for active header line status icon"
  :group 'steven-headerline-faces)

(defface header-line-status-inactive
  '((t (:inherit header-line-inactve)))
  "Face for inactive header line status icon"
  :group 'steven-headerline-faces)

(defun steven-modeline-major-mode-icon ()
  "Return icon for the major mode."
  (if (mode-line-window-selected-p)
    (steven-icons-get-icon major-mode 'header-line-status)
  (steven-icons-get-icon major-mode 'header-line-status-inactive)))

(defun steven-headerline-major-mode-name ()
  "Return the capitalized major mode name unless it's in `steven-headerline-dont-show-modes`."
  (if (not (mode-line-window-selected-p))
      ""
    (capitalize
     (string-remove-suffix
      "-mode"
      (symbol-name major-mode)))))

(defun steven-headerline-buffer-name-face ()
  (let* ((active (mode-line-window-selected-p))
         (modified (and (buffer-file-name)
                        (buffer-modified-p)))
         (base-face (if active
                        'header-line
                      'header-line-inactive)))
    `(:inherit ,base-face
      :weight bold
      ,@(when modified
          '(:slant italic)))))

(defun steven-headerline-buffer-name ()
  (propertize
   (buffer-name)
   'face (steven-headerline-buffer-name-face)))

(defun steven--headerline-get-silo ()
  "Return the conext for the current buffer defined by steven--context-var,
or nil."
  (when (and (boundp 'steven--context-var)
             (local-variable-p 'steven--context-var)
             steven--context-var)
    (let ((silo-name steven--context-var))

       (format "%s%s" " " silo-name))))
        ;'face  'header-line))))

(defun steven--headerline-git-project-name (&optional symbol)
  "Return the current Git project name."
  (when-let* ((file (buffer-file-name))
              (git-root (vc-call-backend 'Git 'root file))
              (project-name
               (file-name-nondirectory
                (directory-file-name git-root))))
    (propertize
     (format "%s%s" (or symbol " ") project-name))))

(defun steven--headerline-git-short (&optional symbol)
  "Git information, only a symbol when vc-mode non-nil"

  (when vc-mode
      (when-let* ((file (buffer-file-name))
                  (branch (substring-no-properties vc-mode 5))
                  (state (vc-state file)))

        (propertize (format "%s" (or symbol " "))))))

(defun steven--headerline-git-info (&optional symbol)
  "Git information as (branch, file status)"

  (when vc-mode
      (when-let* ((file (buffer-file-name))
                  (branch (substring-no-properties vc-mode 5))
                  (state (vc-state file)))

        (propertize (format "%s%s, %s" (or symbol " ") branch state)))))

(defun steven-headerline-context ()
  "Return Denote silo OR Git project for the modeline"
  (when (mode-line-window-selected-p)
    (when-let* ((name (or (steven--headerline-get-silo)
                         (steven--headerline-git-project-name))))
      (format "(%s)" name))))

(defun steven-header-line-window-dedicated ()
  "Return a pin symbol if window is dedicated, otherwise empty string."
  (propertize
   (if (window-dedicated-p) " " "")
   'face 'header-line))

(defun steven-header-line-pdf-page ()
  "PDF view mode page number / page total."
  (when (derived-mode-p 'pdf-view-mode)
    (let ((page-current (pdf-view-current-page))
          (page-total (pdf-cache-number-of-pages)))
      (propertize
       (format "%d/%d " page-current page-total)
       ;'face 'steven-header-line
       ))))


;; Issue is that buffer-local language can differ from global language
;; A solution is below.
(defun steven--header-line-language ()
  "Return `steven--current-language' as \"EN \" or \"NL \"."
  (propertize
   (alist-get steven--current-language
              '(("english" . "EN ")
                ("dutch" . "NL "))
              nil nil #'string=)
   'face '(:weight bold)))

;; (defun steven--header-line-language ()
;;   "Return current ispell dictionary as a short language code."
;;   (propertize
;;    (pcase ispell-local-dictionary
;;      ("en_GB" "EN ")
;;      ("nl_NL" "NL ")
;;      (_ ispell-local-dictionary))
;;    'face '(:weight bold)))

(defun steven-header-line-ispell-dict ()
  "Return an icon if Jinx is active."
  (when (bound-and-true-p jinx-mode)
    (propertize "" 'face '(:weight bold))))

(defun steven--modeline-file-size ()
  "File size in human readable format"

  (if-let* ((file-name (buffer-file-name))
            (file-attributes (file-attributes file-name))
            (file-size (file-attribute-size file-attributes))
            (file-size (file-size-human-readable file-size)))
      (propertize (format "%s " file-size)
                  ;'face (nano-modeline-face 'primary)
                  )
    ""))

;;;; Cursor position

(defun steven--modeline-cursor-position (&optional format)
  "Cursor position using given FORMAT."

  (let ((format (or format "%l:%c ")))
    (propertize (format-mode-line format)
                ;'face (nano-modeline-face 'primary)
                )))

;;;; Line count

(defun steven--modeline-buffer-line-count ()
  "Buffer total number of lines"

  (save-excursion
    (goto-char (point-max))
    (propertize
     (format-mode-line "(%l lines)")
     ;'face (nano-modeline-face 'primary)
     )))

(defun steven--modeline-kbd-macro ()
    "Specific to the current window's mode line."
      (when (and (mode-line-window-selected-p) defining-kbd-macro)
        (propertize " KMacro " 'face 'steven-modeline-indicator-bg)))

;;;; Narrow indicator

(defun steven--modeline-narrow ()
    "Mode line construct to report the narrowed state of the current buffer."
      (when (and (mode-line-window-selected-p)
                 (buffer-narrowed-p)
                 (not (derived-mode-p 'Info-mode 'help-mode 'special-mode 'message-mode)))
        (propertize " [N] " 'face 'steven-modeline-indicator-bg)))

;;;; Input method

(defun steven--modeline-input-method ()
    "Mode line construct to report the multilingual environment."
      (when current-input-method-title
        (propertize (format " %s " current-input-method-title)
                    'face '(:weight bold)
                    'mouse-face 'mode-line-highlight)))

;;;; Buffer status

;; TODO 2023-07-05: What else is there beside remote files?  If
;; nothing, this must be renamed accordingly.
(defun steven-modeline-buffer-status ()
    "Mode line construct for showing remote file name."
      (when (file-remote-p default-directory)
        (propertize " @ "
                    'face 'steven-modeline-indicator-bg
                    'mouse-face 'mode-line-highlight)))


;;;### autoload
(defun nano-modeline-terminal (&optional where)
  "TERM: term mode (including eat)"

  (interactive)
  (nano-modeline where nil
                 (lambda () (nano-modeline-buffer-status ">_"))
                 #'nano-modeline-terminal-shell
                 #'nano-modeline-terminal-mode
                 #'nano-modeline-terminal-directory))

;;;; Alignment functions


(defun steven-header-line-right ()
  "Text to be right aligned"
  (concat
   ;(or (steven-header-line-ispell-dict) "")
   (or (steven-header-line-pdf-page) "")
   (or (steven-header-line-window-dedicated))))

;still used currently.
(defun steven-header-line-align-right ()
  "Return a right aligned string taking into account relevant text"
 (let* ((right-str (steven-header-line-right))
        (right-width (string-width right-str)))
   (propertize
    " "
    'display
    `(space :align-to (- right ,right-width)))))

(defun steven-header-line-propertize (text)
  "Information using primary face"
  (propertize text 'face 'header-line))

(provide 'steven-headerline)
;;; steven-headerline.el ends here
