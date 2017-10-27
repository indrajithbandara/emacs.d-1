(defun ryan/get-android-vms ()
  "Get list of android VM hashcodes."
  (interactive)
  (let ((vms (shell-command-to-string "VBoxManage list vms")))
    (message vms)))

(defun ryan/start-android-s5 ()
  "Start Galaxy S5 Genymotion Emulator."
  (interactive)
  (shell-command "/Applications/Genymotion.app/Contents/MacOS/player.app/Contents/MacOS/player --vm-name s5 &"))

(provide 'init-android)
;;; init-android.el ends here
