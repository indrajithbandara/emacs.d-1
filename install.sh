#!/bin/sh
EMACSD_GIT="https://github.com/watkinsr/emacs.d.git"
XREF_JS2_GIT="https://github.com/NicolasPetton/xref-js2"
EMACS_ROOT="/home/ryan/.emacs.d"
EMACS_SITE_LISP="/home/ryan/.emacs.d/site-lisp"
cd /home/ryan/; rm -rf .emacs.d; mkdir $EMACS_ROOT; git clone $EMACSD_GIT $EMACS_ROOT;  git clone $XREF_JS2_GIT $EMACS_SITE_LISP/xref-js2; emacsclient -e "(kill-emacs)"; emacs --daemon;
