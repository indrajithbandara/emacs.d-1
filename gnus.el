(setq user-mail-address	"rwatkins@redant.com"
      user-full-name	"Ryan Watkins")

(setq gnus-select-method '(nntp "news.gwene.org"))

(add-to-list 'gnus-secondary-select-methods
             '(nnimap "work"
                      (nnimap-address "outlook.office365.com")
                      (nnimap-server-port 993)
                      (nnimap-stream ssl)
                      (nnimap-authinfo-file "~/.authinfo")))

(setq smtpmail-stream-type 'starttls
      smtpmail-smtp-server "smtp.office365.com"
      smtpmail-smtp-service 587)
