(maybe-require-package 'color-theme)

(require 'url)

(defun download-file (&optional url download-dir download-name)
  (interactive)
  (let ((url (or url
                 (read-string "Enter download URL: "))))
    (let ((download-buffer (url-retrieve-synchronously url)))
      (save-excursion
        (set-buffer download-buffer)
        ;; we may have to trim the http response
        (goto-char (point-min))
        (re-search-forward "^$" nil 'move)
        (forward-char)
        (delete-region (point-min) (point))
        (write-file (concat (or download-dir
                                "~/downloads/")
                            (or download-name
                                (car (last (split-string url "/" t))))))))))

(download-file "https://raw.githubusercontent.com/hbin/molokai-theme/master/molokai-theme.el" "~/.emacs.d/themes/" "molokai-theme.el")
(download-file "https://raw.githubusercontent.com/hbin/molokai-theme/master/molokai-theme-kit.el" "~/.emacs.d/themes/" "molokai-theme-kit.el")
(setq molokai-theme-kit t)

;; {{ work around color theme bug
;; @see https://plus.google.com/106672400078851000780/posts/KhTgscKE8PM
(defadvice load-theme (before disable-themes-first activate)
  ;; diable all themes
  (dolist (i custom-enabled-themes)
    (disable-theme i)))
;; }}

(load-theme 'molokai)

;; This line must be after color-theme-molokai! Don't know why.
(setq color-theme-illegal-faces "^\\(w3-\\|dropdown-\\|info-\\|linum\\|yas-\\|font-lock\\|dired-directory\\)")

(provide 'init-color-theme)
