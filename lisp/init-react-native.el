(defun ryan/open-new-packager ()
  (interactive)
  (let ((currentbuf (get-buffer-window (current-buffer)))
        (newbuf     (generate-new-buffer-name "*react-native-packager*")))
    (generate-new-buffer newbuf)
    (set-window-dedicated-p currentbuf nil)
    (set-window-buffer currentbuf newbuf)
    (shell-command "cd ~/projects/dev/js/mastercard/mastercard-cash-passport/node_modules/react-native/packager && bash launchPackager.command &" newbuf)))


(provide 'init-react-native)
