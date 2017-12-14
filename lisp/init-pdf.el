(maybe-require-package 'pdf-tools)
(pdf-tools-install)

(add-hook 'pdf-view-mode-hook (lambda ()
                                (pdf-view-midnight-minor-mode)))

(setq pdf-view-midnight-colors '("#ff9900" . "#0a0a12" ))


(provide 'init-pdf)
