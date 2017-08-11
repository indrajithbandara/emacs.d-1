;; Elscreen bindings
(require 'elscreen)

(define-prefix-command 'elscreen-map)

(global-set-key (kbd "C-x C-a") 'elscreen-map)

(define-key elscreen-map (kbd "C-n") 'elscreen-next)
(define-key elscreen-map (kbd "C-p") 'elscreen-previous)
(define-key elscreen-map (kbd "C-c") 'elscreen-create)
(define-key elscreen-map (kbd "C-k") 'elscreen-kill)

(provide 'init-elscreen)
