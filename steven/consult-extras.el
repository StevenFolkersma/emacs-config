;;; -*- lexical-binding: t -*-

;;;###autoload
(defun steven-consult-file-containing (pattern)
  "Find files containing PATTERN with rg and read a matching file with preview."
  (interactive "sSearch string: ")
  (let* ((files (process-lines "rg" "-l" pattern))
         (file (consult--read
                files
                :prompt (format "Files (%s): " pattern)
                :sort nil
                :state (consult--file-preview)
                :category 'file
                :require-match t)))
    (find-file file)))


;(defun steven--consult-wrapper-denote ()
;    (interactive)
;    (call-interactively #'steven-consult-find-notes)

;; obsolete
;(defun steven-consult-dir-denote ()
;  "Choose a directory and run ’denote’ on it."
;  (interactive)
;  (let ((denote-directory (consult-dir--pick "In directory: ")))
;      (call-interactively #'denote)))

(defun steven--collect-shr-links (seen)
  "Return alist of (display . url) from shr-url text properties, updating SEEN."
  (let (results)
    (save-excursion
      (goto-char (point-min))
      (let (match)
        (while (setq match (text-property-search-forward 'shr-url nil nil))
          (let* ((url (prop-match-value match))
                 (beg (prop-match-beginning match))
                 (end (prop-match-end match))
                 (text (string-trim (buffer-substring-no-properties beg end))))
            (when (and url (not (string-empty-p url)) (not (gethash url seen)))
              (puthash url t seen)
              (push (cons (if (string-empty-p text) url text) url) results))))))
    (nreverse results)))

(defun steven--collect-denote-links (seen)
  "Return alist of (display . denote:ID) from denote link regexps, updating SEEN."
  (let (results
        (regexps (when (featurep 'denote)
                   (list denote-org-link-in-context-regexp
                         denote-md-link-in-context-regexp
                         denote-id-only-link-in-context-regexp))))
    (dolist (regexp regexps)
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward regexp nil t)
          (let* ((id (match-string-no-properties 1))
                 (desc (or (match-string-no-properties 2) ""))
                 (target (concat "denote:" id))
                 (display (if (string-empty-p desc) target
                            (format "%s  [denote]" desc))))
            (unless (gethash target seen)
              (puthash target t seen)
              (push (cons display target) results))))))
    (nreverse results)))

(defun steven--collect-url-links (seen)
  "Return alist of (url . url) for plain URLs in buffer, updating SEEN."
  (let (results
        (url-re (or (bound-and-true-p my/search-url-regexp) ffap-url-regexp)))
    (when url-re
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward url-re nil t)
          (let ((url (match-string-no-properties 0)))
            (unless (or (gethash url seen)
                        (get-text-property (match-beginning 0) 'shr-url))
              (puthash url t seen)
              (push (cons url url) results))))))
    (nreverse results)))

(defun steven--follow-link (target)
  "Open TARGET, dispatching by link scheme."
  (cond
   ((string-prefix-p "denote:" target)
    (if-let* ((id (substring target 7))
              (file (denote-get-path-by-id id)))
        (find-file file)
      (user-error "No denote file for ID: %s" (substring target 7))))
   ((string-prefix-p "file:" target)
    (find-file (string-trim-left target "file:")))
   ((string-prefix-p "info:" target)
    (info target))
   (t
    (browse-url target))))

;;;###autoload
(defun steven-follow-buffer-link ()
  "Complete-read all links in the current buffer and follow the selected one.
Collects shr-url text properties (EWW, elfeed), denote: links, and plain URLs."
  (interactive)
  (let* ((seen (make-hash-table :test #'equal))
         (candidates (append (steven--collect-shr-links seen)
                             (steven--collect-denote-links seen)
                             (steven--collect-url-links seen))))
    (if (null candidates)
        (user-error "No links found in buffer")
      (let* ((selected (completing-read "Follow link: " candidates nil t))
             (target (cdr (assoc selected candidates))))
        (steven--follow-link target)))))


(provide 'consult-extras)
;;; consult-extras.el ends here
