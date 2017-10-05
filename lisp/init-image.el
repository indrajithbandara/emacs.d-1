(maybe-require-package 'svg)
(maybe-require-package 'image+)

;; Helper functions
(defun img-dims-buffer ()
  "Get image dimensions of image in a buffer"
  (shell-command-to-string (concat "sips -g pixelHeight -g pixelWidth " buffer-file-name)))

(defun capture-image-dimensions ()
  "Capture image-dims-in-a-buffer in variables"
  )

(defun ryan-convert-image ()
  "Convert a given file to 3x/2x w/ diff fname"
  (interactive)
  (let*
      ((width3x (read-string "Width(3x): "))
       (height3x (read-string "Height(3x): "))
       (width2x (two-thirds-string width3x))
       (height2x (two-thirds-string height3x))
       (width1x (one-third-string width3x))
       (height1x (one-third-string height3x))
       (in (read-string "In: "))
       (out (read-string "Out(pre): ")))
    (shell-command (concat "convert " in " -resize " width3x "x" height3x "\! " (concat out "@3x.png")))
    (shell-command (concat "convert " in " -resize " width2x "x" height2x "\! " (concat out "@2x.png")))
    (shell-command (concat "convert " in " -resize " width1x "x" height1x "\! " (concat out ".png")))))

(defun two-thirds-string (x)
  (number-to-string (* (/ (string-to-number x) 3) 2)))


(defun one-third-string (x)
  (number-to-string (/ (string-to-number x) 3)))

(provide 'init-image)
