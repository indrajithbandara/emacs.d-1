;; Provide here IRC settings, bitlbee and so forth...

(defun setup-erc ()
  (interactive)
  ;; Auto-connect to channels in the background instead of grabbing buffers...
  (setq erc-join-buffer 'bury)
  (setq erc-autojoin-channels-alist
        '(("freenode.net" "#archlinux-arm" "#emacs" "#qutebrowser" "#lisp" "#mezzano" "#guix" "#guile" "#raspberrypi")))
  (erc :server "irc.freenode.net" :port 6667 :nick "ryanwatkins"))


(add-hook 'erc-mode-hook
          '(lambda ()
             (define-key erc-mode-map "\C-m" 'newline)
             (define-key erc-mode-map "\C-c\C-c" 'erc-send-current-line)
             ))

(provide 'init-erc)
