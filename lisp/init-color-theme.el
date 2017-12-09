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


(defun ryan/load-molokai ()
  (interactive)
  (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
  (download-file "https://raw.githubusercontent.com/hbin/molokai-theme/master/molokai-theme.el" "~/.emacs.d/themes/" "molokai-theme.el")
  (download-file "https://raw.githubusercontent.com/hbin/molokai-theme/master/molokai-theme-kit.el" "~/.emacs.d/themes/" "molokai-theme-kit.el")
  (setq molokai-theme-kit t)
  (load-theme 'molokai)
  )

(ryan/load-molokai)

(provide 'init-color-theme)
