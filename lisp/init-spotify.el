(defun spotify-search (search-term)
  "Search spotify for SEARCH-TERM, returning the results as a Lisp structure."
  (let ((a-url (format "http://api.spotify.com/v1/search?type=track&q=%s" search-term)))
    (with-current-buffer
        (url-retrieve-synchronously a-url)
      (goto-char url-http-end-of-headers)
      (json-read))))

(defun spotify-format-track (track)
  "Given a TRACK, return a a formatted string suitable for display."
  (let ((track-name   (alist-get '(name) track))
        (track-length (/ (alist-get '(duration_ms) track)) 1000)
        (album-name   (alist-get '(album name) track))
        (artist-names (mapcar (lambda (artist)
                                (alist-get '(name) artist))
                              (alist-get '(artists) track))))
    (format "%s (%dm%0.2ds)\n%s - %s"
            track-name
            (/ track-length 60) (mod track-length 60)
            (mapconcat 'identity artist-names "/")
            album-name)))

(defun spotify-search-formatted (search-term)
  (mapcar (lambda (track)
            (cons (spotify-format-track track) track))
          (alist-get '(tracks items) (spotify-search search-term))))

(defun spotify-play-track (track)
  "Get the Spotify app to play the TRACK."
  (spotify-play-href (alist-get '(uri) track)))

(provide 'init-spotify)
