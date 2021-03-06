(maybe-require-package 'json-mode)
(maybe-require-package 'js2-mode)
(maybe-require-package 'coffee-mode)
(maybe-require-package 'js2-refactor)
(maybe-require-package 'company-tern)
(maybe-require-package 'indium)
(maybe-require-package 'helm)
(maybe-require-package 'rjsx-mode)
(maybe-require-package 'mocha)

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

;; Xref-js2
(defun ryan/setup-xref-js2 ()
  (interactive)
  (download-file "https://raw.githubusercontent.com/NicolasPetton/xref-js2/master/xref-js2.el" "~/.emacs.d/site-lisp/xref-js2/" "xref-js2.el")
  (add-to-list 'load-path "~/.emacs.d/site-lisp/xref-js2/")
  (require 'xref-js2)
  (add-hook 'js2-mode-hook
            (lambda () (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t))))

(ryan/setup-xref-js2)

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
                           (linum-mode 1)))
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

(defun ryan/spawn-react-packager (path)
  (let ((buf (ryan/gen-switch-buffer "*react-native-packager*")))
    (shell-command (concat "cd ~/projects/dev/js/" path "/node_modules/react-native/scripts; bash launchPackager.command &") buf buf)))

(defun ryan/webradr-app-run (type)
  (interactive)
  (let ((buf (ryan/gen-switch-buffer "*webradr-app*")))
    (shell-command (concat "cd ~/projects/dev/js/webradr/webradr-app; npm run " type " &") buf)))

(defun ryan/webradr-init-local (type)
  (interactive)
  (ryan/spawn-react-packager "webradr/webradr-app")
  (ryan/webradr-api-run)
  (split-window-horizontally)
  (ryan/webradr-app-run type))

(defun ryan/webradr-init ()
  (interactive)
  (ryan/webradr-react-packager)
  (split-window-horizontally)
  (ryan/webradr-ios "ios-develop"))

(defun ryan/webradr-api-run ()
  (interactive)
  (let ((buf (ryan/gen-switch-buffer "*webradr-api*")))
    (cd "~/projects/dev/js/webradr/webradr-ep-generic-api")
    (shell-command "npm run dev-local &" buf)))

(defun ryan/webradr-api-indium ()
  (interactive)
  (cd "~/projects/dev/js/webradr/webradr-ep-generic-api")
  (indium-run-node "npm run dev-local"))

(defun ryan/enable-js-standard ()
  (interactive)
  (flycheck-select-checker 'javascript-standard))

(defun ryan/react-native-chrome-debugger ()
  (interactive)
  (let ((buf (ryan/gen-switch-buffer "*chrome-debugger*")))
    (shell-command "/Applications/Chromium.app/Contents/MacOS/Chromium --remote-debugging-port=9222 http://localhost:8081/debugger-ui &" buf)))

(defun ryan/gen-switch-buffer (new-buffer-name)
  (interactive)
  (let ((currentbuf (get-buffer-window (current-buffer)))
        (newbuf     (generate-new-buffer-name new-buffer-name)))
    (generate-new-buffer newbuf)
    (set-window-dedicated-p currentbuf nil)
    (set-window-buffer currentbuf newbuf)
    newbuf))

(defun ryan/create-data-driven-config (module-name service scene-name mock)
  (interactive)
  (progn (prin1 module-name)
         (prin1 service)
         (prin1 scene-name)
         (prin1 mock)))
  ;; (cons module-name '(service scene-name mock)))

(defun ryan/create-data-driven-service (name &rest endpoint-types)
  (interactive)
  (cons name '(endpoint-types)))

(defun ryan/create-scene (path name)
  (interactive)
  (let ((buf (ryan/gen-switch-buffer "*JS-scene-creation*"))
        (cmd (concat "cd ~/projects/dev/js/" path "/scripts/scene-creator; ./scene-creator " name)))
    (shell-command cmd)))


(ryan/create-data-driven-config 'report (ryan/create-data-driven-service 'report 'GET 'POST) 'ReportSubmission 'foo)

(defun ryan/create-data-driven-component (name config)
  (interactive)
  (let ((buf (ryan/gen-switch-buffer "*JS-data-driven-create*"))
        (cd-scripts "cd ~/projects/dev/js/webradr/webradr-app/scripts;")
        (module-create (concat "cd module-creator; ./module-creator " name "; cd ../;"))
        (service-create (concat "cd service-creator; ./service-creator " name)))

    (shell-command (concat cd-command call-script) buf)))

(defun ryan/create-redux-service (service-name)
  (interactive)
  (let* ((buf (ryan/gen-switch-buffer "*redux-service-creation"))
         (cd-scripts "cd ~/projects/dev/github/redux-scripts;")
         (project-dir (read-string "Enter a project dir: "))
         (module-create (concat "./module-creator " service-name " " project-dir " ;"))
         (service-create (concat "./service-creator " service-name " " project-dir " ;"))
         (call-script (concat cd-scripts module-create service-create)))
    (shell-command call-script buf)))

(defun ryan/create-redux-module (module-name)
  (interactive)
  (let* ((buf (ryan/gen-switch-buffer "*redux-module-creation"))
         (cd-scripts "cd ~/projects/dev/github/redux-scripts;")
         (project-dir (read-string "Enter a project dir: "))
         (module-create (concat "./module-creator " service-name " " project-dir " ;"))
         (call-script (concat cd-scripts module-create)))
    (shell-command call-script buf)))

(defun ryan/switch-webradr-env (env)
  (interactive)
  (let* ((buf (ryan/gen-switch-buffer "*webradr-env-log*"))
         (cd-root "cd ~/projects/dev/js/webradr/webradr-app;")
         (cmd (concat cd-root "npm run env -- " env ";")))
    (shell-command cmd buf)))

(add-hook 'js2-mode-hook (lambda () (push '("function" . ?λ) prettify-symbols-alist)))

(provide 'init-javascript)
