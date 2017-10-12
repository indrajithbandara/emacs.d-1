(defun get-android-vms ()
  "Get list of android VM hashcodes."
  (interactive)
  (let ((vms (shell-command-to-string "VBoxManage list vms")))
    (message vms)))

(provide 'init-android)
;;; init-android.el ends here
