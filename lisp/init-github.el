(require 'init-git)

(maybe-require-package 'yagist)
(require-package 'bug-reference-github)
(add-hook 'prog-mode-hook 'bug-reference-prog-mode)

(maybe-require-package 'github-clone)
(maybe-require-package 'github-issues)
(maybe-require-package 'magit-gh-pulls)

(maybe-require-package 'magithub)

(provide 'init-github)
