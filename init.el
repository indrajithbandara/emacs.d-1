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
(require 'init-themes)
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
(require 'init-linum-mode)
(require 'init-erc)
(require 'init-jira)
(require 'init-gnus)
(require 'init-workgroups2)
(require 'init-eyebrowse)
(require 'init-yasnippets)
(require 'init-image)
(require 'init-spotify)
(require 'init-pr)
(require 'init-pdf)
(require 'init-neotree)
(require 'init-android)
(require 'init-harvest)
(require 'init-guile)
(require 'init-mongo)
(require 'init-restclient)

(global-set-key (kbd "C-M-d") 'down-list)
(global-set-key (kbd "C-M-u") 'up-list)

(global-set-key (kbd "C-x TAB") 'counsel-imenu)

(setq kill-ring-max 500)
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

;;; I prefer cmd key for meta
(setq mac-option-key-is-meta t
      mac-command-key-is-meta nil
      mac-command-modifier 'none
      mac-option-modifier 'meta)

;; GPG in MacOSX emacs
(setenv "PATH" (concat "/usr/local/bin" path-separator (getenv "PATH")))
(setq exec-path (append exec-path '("/usr/local/bin")))
(setq exec-path (append exec-path '("/home/ryan/guix/bin")))

(setq epg-gpg-program "/usr/local/bin/gpg")

(workgroups-mode 1)

(maybe-require-package 'go-eldoc)
(add-hook 'go-mode-hook 'go-eldoc-setup)

(maybe-require-package 'ensime)
(maybe-require-package 'restclient)

;; UTF-8 TERM encoding
(setenv "LANG" "en_US.UTF-8")

(blink-cursor-mode 0)

(tool-bar-mode -1)
(menu-bar-mode -1)

(global-set-key (kbd "C-x 4 z") 'ido-switch-frame)

;; Useful for quick feedback from functions
(global-set-key (kbd "C-x 4 e") 'eval-region)

(defun paste-from-x-clipboard ()
  (interactive)
  (shell-command "pbpaste" 1))

(global-set-key (kbd "M-y") 'paste-from-x-clipboard)

;; AucTeX setup
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

;; Open urls with MACOS default
(defun choose-browser (url &rest args)
  (interactive "sURL: ")
  (if (y-or-n-p "Use external browser? ")
      (browse-url-generic url)
    (w3m-browse-url url)))

(setq browse-url-browser-function 'choose-browser)

;; Tramp setup...
(add-to-list 'load-path "~/.emacs.d/tramp-2.2.7/lisp")
(require 'tramp)

;; Make sure we work on remote guixsd machines :)
;; probably only helps if you start on a guixsd machine..!
(setq tramp-remote-path
      (append tramp-remote-path
              '(tramp-own-remote-path)))

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
;; Locales (setting them earlier in this file doesn't work in X)
;;----------------------------------------------------------------------------
(require 'init-locales)

(provide 'init)

;; (set-default-font "Terminus (TTF)-12")
;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;; End:
(put 'set-goal-column 'disabled nil)
