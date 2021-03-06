(defun ryan/visit-pull-request-url ()
  "Visit the current branch's PR on Github."
  (interactive)
  (let ((repo (magit-get "remote" (magit-get-remote) "url")))
    (if (not repo)
        (setq repo (magit-get "remote" (magit-get-push-remote) "url")))
    (if (string-match "github\\.com" repo)
        (visit-gh-pull-request repo)
      (visit-bb-pull-request repo))))

(defun visit-gh-pull-request (repo)
  "Visit the current branch's PR on Github."
  (interactive)
  (message repo)
  (browse-url
   (format "https://github.com/%s/pull/new/%s"
           (replace-regexp-in-string
            "\\`.+github\\.com:\\(.+\\)\\(\\.git\\)?\\'" "\\1"
            repo)
           (magit-get-current-branch))))

;; Bitbucket pull requests are kinda funky, it seems to try to just do the
;; right thing, so there's no branches to include.
;; https://bitbucket.org/<username>/<project>/pull-request/new
(defun visit-bb-pull-request (repo)
  (message repo)
  (browse-url
   (format "%s/pull-request/new?source=%s&t=1"
           (replace-regexp-in-string
            "\\`.+bitbucket\\.org:\\(.+\\)\\.git\\'" "\\1"
            repo)
           (magit-get-current-branch))))
;; visit PR for github or bitbucket repositories with "v"
(eval-after-load 'magit
  '(define-key magit-mode-map "v"
     #'ryan/visit-pull-request-url))

(provide 'init-pr)
