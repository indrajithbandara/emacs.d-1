(maybe-require-package 'json-mode)
(maybe-require-package 'js2-mode)
(maybe-require-package 'coffee-mode)
(maybe-require-package 'js2-refactor)
(maybe-require-package 'company-tern)
(maybe-require-package 'indium)
(maybe-require-package 'helm)

;; Start chrome w/ debugging and connect via indium-connect-to-chrome
;; open /Applications/Chromium.app/Contents/MacOS/Chromium --remote-debugging-port=9222 https://localhost:3000



(defcustom preferred-javascript-mode
  (first (remove-if-not #'fboundp '(js2-mode js-mode)))
  "Javascript mode to use for .js files."
  :type 'symbol
  :group 'programming
  :options '(js2-mode js-mode))

(defconst preferred-javascript-indent-level 2)

;; Need to first remove from list if present, since elpa adds entries too, which
;; may be in an arbitrary order
(eval-when-compile (require 'cl))
(setq auto-mode-alist (cons `("\\.\\(js\\|es6\\)\\(\\.erb\\)?\\'" . ,preferred-javascript-mode)
                            (loop for entry in auto-mode-alist
                                  unless (eq preferred-javascript-mode (cdr entry))
                                  collect entry)))


;; js2-mode

;; Change some defaults: customize them to override
(setq-default js2-basic-offset 2
              js2-bounce-indent-p nil)
(after-load 'js2-mode
  ;; Disable js2 mode's syntax error highlighting by default...
  (setq-default js2-mode-show-parse-errors nil
                js2-mode-show-strict-warnings nil)
  ;; ... but enable it if flycheck can't handle javascript
  (autoload 'flycheck-get-checker-for-buffer "flycheck")
  (defun sanityinc/disable-js2-checks-if-flycheck-active ()
    (unless (flycheck-get-checker-for-buffer)
      (set (make-local-variable 'js2-mode-show-parse-errors) t)
      (set (make-local-variable 'js2-mode-show-strict-warnings) t)))
  (add-hook 'js2-mode-hook 'sanityinc/disable-js2-checks-if-flycheck-active)

  (add-hook 'js2-mode-hook (lambda () (setq mode-name "JS2")))

  (after-load 'js2-mode
    (js2-imenu-extras-setup)))

;; js-mode
(setq-default js-indent-level preferred-javascript-indent-level)


(add-to-list 'interpreter-mode-alist (cons "node" preferred-javascript-mode))


;; Javascript nests {} and () a lot, so I find this helpful



;;; Coffeescript

(after-load 'coffee-mode
  (setq coffee-js-mode preferred-javascript-mode
        coffee-tab-width preferred-javascript-indent-level))

(when (fboundp 'coffee-mode)
  (add-to-list 'auto-mode-alist '("\\.coffee\\.erb\\'" . coffee-mode)))

;; ---------------------------------------------------------------------------
;; Run and interact with an inferior JS via js-comint.el
;; ---------------------------------------------------------------------------

(when (maybe-require-package 'js-comint)
  (setq inferior-js-program-command "js")

  (defvar inferior-js-minor-mode-map (make-sparse-keymap))
  (define-key inferior-js-minor-mode-map "\C-x\C-e" 'js-send-last-sexp)
  (define-key inferior-js-minor-mode-map "\C-\M-x" 'js-send-last-sexp-and-go)
  (define-key inferior-js-minor-mode-map "\C-cb" 'js-send-buffer)
  (define-key inferior-js-minor-mode-map "\C-c\C-b" 'js-send-buffer-and-go)
  (define-key inferior-js-minor-mode-map "\C-cl" 'js-load-file-and-go)

  (define-minor-mode inferior-js-keys-mode
    "Bindings for communicating with an inferior js interpreter."
    nil " InfJS" inferior-js-minor-mode-map)

  (dolist (hook '(js2-mode-hook js-mode-hook))
    (add-hook hook 'inferior-js-keys-mode)))

;; ---------------------------------------------------------------------------
;; Alternatively, use skewer-mode
;; ---------------------------------------------------------------------------

(when (maybe-require-package 'skewer-mode)
  (after-load 'skewer-mode
    (add-hook 'skewer-mode-hook
              (lambda () (inferior-js-keys-mode -1)))))

;; Xref-js2
(add-to-list 'load-path "~/.emacs.d/site-lisp/xref-js2/")
(require 'js2-refactor)
(require 'xref-js2)
(add-hook 'js2-mode-hook
          (lambda () (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t)))

(add-hook 'js2-mode-hook #'js2-refactor-mode)
(js2r-add-keybindings-with-prefix "C-c C-r")
(define-key js2-mode-map (kbd "C-k") #'js2r-kill)
(define-key js-mode-map (kbd "M-.") nil)

;; Tern parses js files and gives type inference!


(with-eval-after-load 'company
                       (add-to-list 'company-backends 'company-tern))
(add-hook 'js2-mode-hook (lambda ()
                           (tern-mode)
                           (company-mode)
                           (linum-mode)))
;; Disable completion keybindings, as we use xref-js2 instead
(with-eval-after-load 'tern
  (define-key tern-mode-keymap (kbd "M-.") nil)
  (define-key tern-mode-keymap (kbd "M-,") nil))

;; Disable evil-repeat-bindings, as we use xref-js2 instead
(with-eval-after-load 'evil
  (define-key evil-motion-state-map (kbd "M-.") nil))


;; 2 spaces indentation
(add-hook 'js2-mode-hook
          (lambda () (setq evil-shift-width 2)))


(defun ryan/webradr-api-run ()
  (interactive)
  (let ((currentbuf (get-buffer-window (current-buffer)))
        (newbuf     (generate-new-buffer-name "*webradr-api*")))
    (generate-new-buffer newbuf)
    (set-window-dedicated-p currentbuf nil)
    (set-window-buffer currentbuf newbuf)
    (cd "~/projects/dev/js/webradr/webradr-ep-generic-api")
    (shell-command "npm run dev &" newbuf)))

(defun ryan/react-native-chrome-debugger ()
  (interactive)
  (let ((currentbuf (get-buffer-window (current-buffer)))
        (newbuf     (generate-new-buffer-name "*chrome-debugger*")))
    (generate-new-buffer newbuf)
    (set-window-dedicated-p currentbuf nil)
    (set-window-buffer currentbuf newbuf)
    (shell-command "/Applications/Chromium.app/Contents/MacOS/Chromium --remote-debugging-port=9222 http://localhost:8081/debugger-ui &" newbuf)))

(js2-imenu-extras-mode)

(maybe-require-package 'js-doc)
(setq js-doc-mail-address "rwatkins@redant.com"
      js-doc-author (format "Ryan Watkins <%s>" js-doc-mail-address)
      js-doc-url ""
      js-doc-license "")

(add-hook 'js2-mode-hook
          #'(lambda ()
              (define-key js2-mode-map "\C-ci" 'js-doc-insert-function-doc)
              (define-key js2-mode-map "@" 'js-doc-insert-tag)))

;; (add-hook 'after-init-hook #'global-flycheck-mode)
;; (add-to-list 'flycheck-enabled-checkers 'javascript-standard)
(defun ryan/enable-js-standard ()
  (interactive)
  (flycheck-select-checker 'javascript-standard))

(provide 'init-javascript)
