(defun ryan/open-new-packager ()
  (interactive)
  (shell-command "cd ~/projects/dev/js/mastercard/mastercard-cash-passport/node_modules/react-native/packager && bash launchPackager.command &"))

(provide 'init-react-native)
