;;; This file bootstraps the configuration, which is divided into
;;; a number of other files.

(let ((minver "23.3"))
  (when (version<= emacs-version minver)
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))
(when (version<= emacs-version "24")
  (message "Your Emacs is old, and some functionality in this config will be disabled. Please upgrade if possible."))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'init-benchmarking) ;; Measure startup time

(defconst *spell-check-support-enabled* nil) ;; Enable with t if you prefer
(defconst *is-a-mac* (eq system-type 'darwin))

;;----------------------------------------------------------------------------
;; Temporarily reduce garbage collection during startup
;;----------------------------------------------------------------------------
(defconst sanityinc/initial-gc-cons-threshold gc-cons-threshold
  "Initial value of `gc-cons-threshold' at start-up time.")
(setq gc-cons-threshold (* 128 1024 1024))
(add-hook 'after-init-hook
          (lambda () (setq gc-cons-threshold sanityinc/initial-gc-cons-threshold)))

;;----------------------------------------------------------------------------
;; Bootstrap config
;;----------------------------------------------------------------------------
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(require 'init-compat)
(require 'init-utils)
(require 'init-site-lisp) ;; Must come before elpa, as it may provide package.el
;; Calls (package-initialize)
(require 'init-elpa)      ;; Machinery for installing required packages
(require 'init-exec-path) ;; Set up $PATH

;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-preload-local.el"
;;----------------------------------------------------------------------------
(require 'init-preload-local nil t)

;;----------------------------------------------------------------------------
;; Load configs for specific features and modes
;;----------------------------------------------------------------------------

(require-package 'wgrep)
(require-package 'project-local-variables)
(require-package 'diminish)
(require-package 'scratch)
(require-package 'mwe-log-commands)

(require 'init-frame-hooks)
(require 'init-xterm)
(require 'init-color-theme)
(require 'init-emacs-w3m)
;; (require 'init-themes)
(require 'init-osx-keys)
(require 'init-gui-frames)
(require 'init-dired)
(require 'init-isearch)
(require 'init-grep)
(require 'init-uniquify)
(require 'init-ibuffer)
(require 'init-flycheck)

(require 'init-recentf)
(require 'init-smex)
;; If you really prefer ido to ivy, change the comments below. I will
;; likely remove the ido config in due course, though.
;; (require 'init-ido)
(require 'init-ivy)
(require 'init-hippie-expand)
(require 'init-company)
(require 'init-windows)
(require 'init-sessions)
(require 'init-fonts)
(require 'init-mmm)

(require 'init-editing-utils)
(require 'init-whitespace)
(require 'init-fci)

(require 'init-vc)
(require 'init-darcs)
(require 'init-git)
(require 'init-github)

(require 'init-projectile)

(require 'init-compile)
(require 'init-crontab)
(require 'init-textile)
(require 'init-markdown)
(require 'init-csv)
(require 'init-erlang)
(require 'init-javascript)
(require 'init-php)
(require 'init-org)
(require 'init-nxml)
(require 'init-html)
(require 'init-css)
(require 'init-haml)
(require 'init-python-mode)
(unless (version<= emacs-version "24.3")
  (require 'init-haskell))
(require 'init-elm)
(require 'init-ruby-mode)
(require 'init-rails)
(require 'init-sql)

(require 'init-paredit)
(require 'init-lisp)
(require 'init-slime)
(unless (version<= emacs-version "24.2")
  (require 'init-clojure)
  (require 'init-clojure-cider))
(require 'init-common-lisp)

(when *spell-check-support-enabled*
  (require 'init-spelling))

(require 'init-misc)

(require 'init-folding)
(require 'init-dash)
(require 'init-ledger)

;;---------------------------------------------------------------------------
;; RYAN'S EXTRA STUFF
;;---------------------------------------------------------------------------
;; init-javascript extras
(add-to-list 'load-path "~/.emacs.d/site-lisp/xref-js2/")

;; JIRA in emacs..
(require 'init-jira)
(require 'init-evil)
(require 'init-gnus)
(require 'init-workgroups2)
(require 'init-elscreen)
(workgroups-mode 1)

(require 'init-linum-mode)
(require 'init-erc)

;; TODO :: Seperate to init-go
(add-to-list 'load-path "~/go-autocomplete/")
(require 'go-autocomplete)
(require 'auto-complete-config)
(ac-config-default)

(require 'go-eldoc)
(add-hook 'go-mode-hook 'go-eldoc-setup)

;; SCALA
(require 'ensime)

;; REST
(require 'restclient)

;; UTF-8 TERM encoding
(setenv "LANG" "en_US.UTF-8")

;; PDF-TOOLS
(pdf-tools-install)

(blink-cursor-mode 0)

;; INDENT
(setq tab-width 4)

;; FRAME MANAGEMENT
(defun ido-switch-frame ()
  "Switch frame with ido"
  (interactive)
  (when (not (minibufferp))
    (let* (
           (frames (frame-list))
           (frame-to (ido-completing-read "Select Frame:  "
                                          (mapcar (lambda (frame) (frame-parameter frame 'name)) frames))))
      (catch 'break
        (while frames
          (let ((frame (car frames)))
            (if (equal (frame-parameter frame 'name) frame-to)
                (throw 'break (select-frame-set-input-focus frame))
              (setq frames (cdr frames)))))))))

(global-set-key (kbd "C-x 4 z") 'ido-switch-frame)

;; Useful for quick feedback from functions
(global-set-key (kbd "C-x 4 e") 'eval-region)

;; Color-theme hack, load-theme somehow lost between Purcell and my fork
(load-theme 'molokai t)

(defun paste-from-x-clipboard ()
  (interactive)
  (shell-command "pbpaste" 1))

(global-set-key (kbd "M-y") 'paste-from-x-clipboard)

;; AucTeX setup
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

;; Open urls with icecat
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "icecat")

;; Tramp setup...
(add-to-list 'load-path "~/.emacs.d/tramp-2.2.7/lisp")
(require 'tramp)

;; Make sure we work on remote guixsd machines :)
;; probably only helps if you start on a guixsd machine..!
(setq tramp-remote-path
      (append tramp-remote-path
              '(tramp-own-remote-path)))

(global-linum-mode 0)

;; MISC stuff from Purcell
(require-package 'gnuplot)
(require-package 'lua-mode)
(require-package 'htmlize)
(require-package 'dsvn)
(when *is-a-mac*
  (require-package 'osx-location))
(require-package 'regex-tool)

;;----------------------------------------------------------------------------
;; Allow access from emacsclient
;;----------------------------------------------------------------------------
(require 'server)
(unless (server-running-p)
  (server-start))


;;----------------------------------------------------------------------------
;; Variables configured via the interactive 'customize' interface
;;----------------------------------------------------------------------------
(when (file-exists-p custom-file)
  (load custom-file))


;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-local" containing personal settings
;;----------------------------------------------------------------------------
(require 'init-local nil t)


;;----------------------------------------------------------------------------
;; Locales (setting them earlier in this file doesn't work in X)
;;----------------------------------------------------------------------------
(require 'init-locales)

(provide 'init)

;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;; End:
