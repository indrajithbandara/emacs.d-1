(defun my-gnus-group-list-subscribed-groups ()
  "List all subscribed groups with or without un-read messages"
  (interactive)
  (gnus-group-list-all-groups 5))

(setq pop3-leave-mail-on-server t)

(add-hook 'gnus-group-mode-hook
          (lambda () (local-set-key "o" 'my-gnus-group-list-subscribed-groups )))

(setq gnus-article-sort-functions
      '((not gnus-article-sort-by-date)
        (not gnus-article-sort-by-number)))

;; Ignore certificate hostname.
(setq starttls-extra-arguments '("--insecure"))

(defun message-select-forwarded-email-tags ()
  "Select the <#mml-or-what-ever> tags in message-mode"
  (interactive)
  (let (start rlt)
    (when (search-forward "<#")
      (setq start (point))
      (push-mark (point) t t)
      (goto-char (point-max))
      (search-backward ">")
      (forward-char)
      (setq rlt t))
    rlt))

(defun message-copy-select-forwarded-email-tags ()
  "copy the <#mml-or-what-ever> tags in message-mode"
  (interactive)
  (save-excursion
    (cond
     ((message-select-forwarded-email-tags)
      (copy-region-as-kill (region-beginning) (region-end))
      (message "forwarded email tags copied!"))
     (t (message "NO forwarded email tags found!"))
     )))

(defun gnus-summary-extract-mail-address(regexp)
  "Extract TO/CC/FROM fields from mails in current Gnus Summary Buffer.
REGEXP is pattern to exclude extracted address.  For example, 'Tom|gmail' excludes Tom or gmail.
Final result is inserted into kill-ring and returned."
  (interactive
   (let* ((regexp (read-regexp "Regex to exclude mail address (OPTIONAL):")))
     (list regexp)))

  (unless (featurep 'cl)
    (require 'cl))

  (let ((rlt "") (i 0))
    (dolist (d gnus-newsgroup-data)
      (let ((header (gnus-data-header d)) cc-to)
        (setq i (+ 1 i))
        (if (= (mod i 100) 0) (message "%s mails scanned ..." i))
        (when (vectorp header)
          (if (setq cc-to (mail-header-extra header))
              ;; (message "cc-to=%s cc=%s" cc-to (assoc 'Cc cc-to))
              (setq rlt (concat rlt
                                (cdr (assoc 'To cc-to))
                                ", "
                                (cdr (assoc 'Cc cc-to))
                                ", ")))
          (setq rlt (concat rlt (if (string= "" rlt) "" ", ") (mail-header-from header) ", "))
          )))
    ;; trim trailing ", "
    (setq rlt (split-string (replace-regexp-in-string (rx (* (any ", ")) eos)
                                                      ""
                                                      rlt) ", *"))

    ;; remove empty strings
    (setq rlt (delq nil (remove-if (lambda (s) (or (not s) (string= "" s)))
                               rlt)))
    ;; remove actually duplicated mails
    (setq rlt (delq nil (remove-duplicates rlt
                                 :test (lambda (x y)
                                         (let (x1 y1)
                                           ;; Tom W <tom.w@gmail.com> | tom.w@gmail.com (Tom W)
                                           (if (string-match "^[^<]*<\\([^ ]*\\)> *$" x)
                                               (setq x1 (match-string 1 x))
                                             (setq x1 (replace-regexp-in-string " *([^()]*) *" "" (if x x ""))))
                                           (if (string-match "^[^<]*<\\([^ ]*\\)> *$" y)
                                               (setq y1 (match-string 1 y))
                                             (setq y1 (replace-regexp-in-string " *([^ ]*) *" "" (if y y ""))))
                                           (string= x1 y1)))
                                 :from-end t)))
    ;; exclude mails
    (if (and regexp (not (string= regexp "")))
        (setq rlt (delq nil (remove-if (lambda (s)
                                         (string-match (concat "\\(" (replace-regexp-in-string "|" "\\\\|" regexp) "\\)") s))
                                       rlt))))
    (kill-new (mapconcat 'identity rlt ", "))
    (message "Mail addresses => kill-ring")
    rlt))

(with-eval-after-load "mm-decode"
  (add-to-list 'mm-discouraged-alternatives "text/html")
  (add-to-list 'mm-discouraged-alternatives "text/richtext"))

(maybe-require-package 'alert)
(maybe-require-package 'gnus-desktop-notify)
(gnus-desktop-notify-mode)
(gnus-demon-add-scanmail)

(setq send-mail-function    'smtpmail-send-it
      smtpmail-smtp-server  "mail.office365.com"
      smtpmail-stream-type  'starttls
      smtpmail-smtp-service 587)

(gnus-demon-add-handler 'gnus-demon-scan-news 2 t)

(provide 'init-gnus)
