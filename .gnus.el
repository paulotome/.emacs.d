(require 'cl)
(require 'gnus)
(require 'gnus-art)
(require 'gnus-cache)
(require 'gnus-demon)
(require 'gnus-score)
(require 'gnus-msg)
(require' gnus-ml)
(require 'gnus-registry)
(require 'gnus-topic)
(require 'smtpmail)

(require 'nnml)
(require 'nntp)
(require 'nnir)
(require 'mm-util)
(require 'rfc2368)
(require 'rfc2047)
(require 'mailheader)

;;;_ , mail and news

;;;_  . news, mail and mail2news gateways
;;;_   , misc
;;;_    . gnus-select-method
(setq gnus-select-method
      '(nntp "news.gnus.org"
	     (nntp-connection-timeout 360)
	     (nntp-open-connection-function nntp-open-network-stream)
	     (nntp-address "news.gnus.org")
	     )
      )

(setq gnus-secondary-select-methods '((nnimap "")))

(add-to-list 'gnus-secondary-select-methods
	     '(nntp "news.gmane.org"
		    (nntp-connection-timeout 240)
		    (nntp-open-connection-function nntp-open-network-stream)
		    (nntp-address "news.gmane.org")
		    )
	     t
	     )

(add-to-list 'gnus-secondary-select-methods
	     '(nnimap "gmail"
		      (nnimap-address "imap.gmail.com")
		      (nnimap-server-port 993)
		      (nnimap-stream ssl)
		      (nnimap-authinfo-file "~/.authinfo")
		      )
	     t
	     )

;; ******************************************************
;; *                      GMAIL		         	*
;; ******************************************************
;;;(setq gnus-select-method '(nnimap "gmail"
;;;			   (nnimap-address "imap.gmail.com")
;;;			   (nnimap-server-port 993)
;;;			   (nnimap-stream ssl)
;;;			   (nnimap-authinfo-file "~/.authinfo")
;;;			   ))



(setq

 starttls-use-gnutls t
 starttls-gnutls-program "gnutls-cli"
 starttls-extra-arguments nil
 smtpmail-smtp-server "smtp.gmail.com"
 smtpmail-smtp-service 587
 smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
 smtpmail-auth-credentials '(("smtp.gmail.com" 587 "paulo.jorge.tome@gmail.com" nil))
 smtpmail-default-smtp-server "smtp.gmail.com"
 smtpmail-debug-info t ; optional, but handy in case something goes wrong
 smtpmail-debug-verb t
 ;; Make Gnus NOT ignore [Gmail] mailboxes
 gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]"

 )

;; http://www.markus-gattol.name/ws/.emacs.html
(setq gnus-parameters `(("nnimap\\+gmail:INBOX" (expiry-wait . 2))
;;;_      . mail
;;;_       , groups
;;;_        . family
;;;_        . misc
;;;_        . spam
					; This is the S P A M group for ALL messages (mail and news)
			("\\`nnml:m.junk"
					; .... spam rules ............
			 (gnus-article-sort-functions (gnus-article-sort-by-chars))
			 (spam-contents gnus-group-spam-classification-spam)
			 (ham-process-destination . "nnml:junk2ham")
					; Regarding the above line -- from there (`nnml:junk2ham'), I manually
					; move/copy ham to a group where it belongs plus I can use them for
					; ham training. Of course I have to inspect my spam group
					; `nnml:m.junk' occasionally in order to find false positives (i.e.
					; legitimate mails, that were wrongly judged as spam) and remove the
					; spam mark (`M-d') -- then at group exit all false positives are
					; moved/copied to `nnml:junk2ham'.

					;The below line is redundancy since other groups already
					;contain the same rule but keeping it doesn't harm --
					;everythime I visit and exit the spam group I can be sure all
					;senders are added to the blacklist
			 (spam-process ((spam spam-use-blacklist)
					(spam spam-use-bogofilter)))
					; .... agent parameters ......
			 (agent-predicate . true)
			 (agent-score . file)
					; - - agent score rule - -
					; .... posting style .........
			 (posting-style
			  (name "NoName")
			  (address "spam_is_for@the_weak.com")
			  )
					; .... group parameters ......
			 (display . 22) ;counting starts at zero so 15 results in 16
					; .... local variables .......
			 )
;;;_       , people
;;;_        . realname
;;;_         , firstname and lastname
;;;			(,priv-my-gmail0-mail-address-gp ; FIXME replace with priv-my-sunoano1-mail-address-gp once my own email system is up and running
;;;					; .... spam rules ............
;;;							 (spam-contents gnus-group-spam-classification-ham)
;;;							 (spam-process-destination . "nnimap:m.junk")
;;;							 (spam-process ((spam spam-use-blacklist)
;;;									(ham spam-use-whitelist)     ; for ham groups only
;;;									(ham spam-use-bogofilter)    ; for ham groups only
;;;									(spam spam-use-bogofilter)))
;;;					; .... agent parameters ......
;;;							 (agent-predicate . true)
;;;							 (agent-score . file)
;;;					; - - agent score rule - -
;;;					; .... posting style .........
;;;							 (posting-style
;;;							  (name priv-my-name)
;;;							  (address priv-my-sunoano1-mail-address)
;;;							  (signature-file (concat emacs-root-dir "gnus/sig/m.realname"))
;;;							  (mml2015-signers priv-my-keyid)
;;;							  )
;;;					; .... group parameters ......
;;;							 (display . 20)
;;;					; .... local variables .......
;;;							 )
;;;_         , only firstname
;;;			(,priv-my-gmail1-mail-address-gp
;;;					; .... spam rules ............
;;;			 (spam-contents gnus-group-spam-classification-ham)
;;;			 (spam-process-destination . "nnimap:m.junk")
;;;			 (spam-process ((spam spam-use-blacklist)
;;;					(ham spam-use-whitelist)     ; for ham groups only
;;;					(ham spam-use-bogofilter)    ; for ham groups only
;;;					(spam spam-use-bogofilter)))
;;;					; .... agent parameters ......
;;;			 (agent-predicate . true)
;;;			 (agent-score . file)
;;;					; - - agent score rule - -
;;;					; .... posting style .........
;;;			 (posting-style
;;;			  (name priv-my-name)
;;;			  (address priv-my-gmail1-mail-address)
;;;			  )
;;;					; .... group parameters ......
;;;			 (display . 20)
;;;					; .... local variables .......
;;;			 )
;;;_        . suno ano
;;;			(,priv-my-gmail2-mail-address-gp ; FIXME replace with priv-my-sunoano0-mail-address-gp once I have my own email system up and running
;;;					; .... spam rules ............
;;;							 (spam-contents gnus-group-spam-classification-ham)
;;;							 (spam-process-destination . "nnimap:m.junk")
;;;							 (spam-process ((spam spam-use-blacklist)
;;;									(ham spam-use-whitelist)     ; for ham groups only
;;;									(ham spam-use-bogofilter)    ; for ham groups only
;;;									(spam spam-use-bogofilter)))
;;;					; .... agent parameters ......
;;;							 (agent-predicate . true)
;;;							 (agent-score . file)
;;;					; - - agent score rule - -
;;;					; .... posting style .........
;;;							 (posting-style
;;;							  (name priv-my-syn-name)
;;;							  (address priv-my-sunoano0-mail-address)
;;;							  (signature-file (concat emacs-root-dir "gnus/sig/m.suno"))
;;;							  (mml2015-signers priv-my-syn-keyid)
;;;							  )
;;;					; .... group parameters ......
;;;							 (display . 20)
;;;					; .... local variables .......
;;;							 )
;;;_       , domains
;;;_        . education
;;;_         , website
;;;			(,priv-my-gmail4-mail-address-gp ; FIXME replace with priv-my-sunoano4-mail-address-gp once I have my own email system up and running
;;;					; .... spam rules ............
;;;							 (spam-contents gnus-group-spam-classification-ham)
;;;							 (spam-process-destination . "nnimap:m.junk")
;;;							 (spam-process ((spam spam-use-blacklist)
;;;									(ham spam-use-whitelist)     ; for ham groups only
;;;									(ham spam-use-bogofilter)    ; for ham groups only
;;;									(spam spam-use-bogofilter)))
;;;					; .... agent parameters ......
;;;							 (agent-predicate . true)
;;;							 (agent-score . file)
;;;					; - - agent score rule - -
;;;					; .... posting style .........
;;;							 (posting-style
;;;							  (name priv-my-syn-name)
;;;							  (address priv-my-sunoano2-mail-address)
;;;							  (signature-file (concat emacs-root-dir "gnus/sig/m.suno"))
;;;							  (mml2015-signers priv-my-syn-keyid)
;;;							  )
;;;					; .... group parameters ......
;;;							 (display . 20)
;;;					; .... local variables .......
;;;							 )
;;;_         , tugraz
;;;         ("\\`nnml:m\\.do\\.tugraz"
;;;          ; .... spam rules ............
;;;          (spam-contents gnus-group-spam-classification-ham)
;;;          (spam-process-destination . "nnml:m.junk")
;;;          (spam-process ((spam spam-use-blacklist)
;;;                         (ham spam-use-whitelist)
;;;                         (ham spam-use-bogofilter)
;;;                         (spam spam-use-bogofilter)))
;;;          ; .... agent parameters ......
;;;          (agent-predicate . true)
;;;          (agent-score . file)
;;;          ; - - agent score rule - -
;;;          ; .... posting style .........
;;;          (posting-style
;;;             (name priv-my-name)
;;;             (address priv-my-tugraz-mail-address)
;;;             (signature-file (concat emacs-root-dir "gnus/sig/m.academia"))
;;;             (body (concat "\n\n"priv-my-firstname",\nwith fondest regards.\n"))
;;;          )
;;;          ; .... group parameters ......
;;;          (display . 20)
;;;          ; .... local variables .......
;;;         )
;;;_        . work
;;;_         , 1
;;;			(,priv-my-gmail3-mail-address-gp
;;;					; .... spam rules ............
;;;			 (spam-contents gnus-group-spam-classification-ham)
;;;			 (spam-process-destination . "nnml:m.junk")
;;;			 (spam-process ((spam spam-use-blacklist)
;;;					(ham spam-use-whitelist)
;;;					(ham spam-use-bogofilter)
;;;					(spam spam-use-bogofilter)))
;;;					; .... agent parameters ......
;;;			 (agent-predicate . true)
;;;			 (agent-score . file)
;;;					; - - agent score rule - -
;;;					; .... posting style .........
;;;			 (posting-style
;;;			  (name priv-my-name)
;;;			  (address priv-my-work0-mail-address)
;;;			  (signature-file (concat emacs-root-dir "gnus/sig/m.work"))
;;;					;(body (concat "\n\n"priv-my-firstname",\nwith fondest regards.\n"))
;;;			  )
;;;					; .... group parameters ......
;;;			 (display . 20)
;;;					; .... local variables .......
;;;			 )
;;;_         , 2
;;;_       , default
					; Note, those need be the last block within each group since they
					; catch everything!

;;;               ("\\`nnml:m\\..*"
;;;                ; .... spam rules ............
;;;                (spam-contents gnus-group-spam-classification-ham)
;;;                (spam-process-destination . "nnml:m.junk")
;;;                (spam-process ((spam spam-use-blacklist)
;;;                               (ham spam-use-whitelist)
;;;                               (ham spam-use-bogofilter)
;;;                               (spam spam-use-bogofilter)))
;;;                ; .... agent parameters ......
;;;                (agent-predicate . true)
;;;                (agent-score . file)
;;;                ; - - agent score rule - -
;;;                ; .... posting style .........
;;;                (posting-style
;;;                   (name "NoName")
;;;                )
;;;                ; .... group parameters ......
;;;                (display . 15)
;;;                ; .... local variables .......
;;;               )
;;;_      . mailing lists
;;;_       , mailing lists default
					; Note, those need be the last block within each group since they
					; catch everything!

;;;               ("\\`nnml:ml\\..*"
;;;                 ; .... spam rules ............
;;;                 (spam-contents gnus-group-spam-classification-ham)
;;;                 (spam-process-destination . "nnml:m.junk")
;;;                 (spam-process ((spam spam-use-blacklist)
;;;                                (ham spam-use-whitelist)
;;;                                (ham spam-use-bogofilter)
;;;                                (spam spam-use-bogofilter)))
;;;                 ; .... agent parameters ......
;;;                 (agent-predicate or high short (not old))
;;;                 (agent-score . file)
;;;                 ; - - agent score rule - -
;;;                 ; .... posting style .........
;;;                 (posting-style
;;;                    (name priv-my-firstname)
;;;                    (address priv-my-gmail1-mail-address)
;;;                 )
;;;                 ; .... group parameters ......
;;;                 (display . [or (not killed) (not expire)])
;;;                 ; .... local variables ......
;;;                  (gnus-thread-sort-functions
;;;                 '(gnus-thread-sort-by-number
;;;                   gnus-thread-sort-by-date
;;;                   gnus-thread-sort-by-total-score))
;;;               )
			("\\`nntp\\+news\\.gmane\\.org:"
					; .... spam rules ............
			 (spam-contents gnus-group-spam-classification-ham)
			 (spam-process-destination . "nnml:m.junk")
			 (spam-process ((spam spam-use-gmane)
					(spam spam-use-blacklist)
					(ham spam-use-whitelist)
					(ham spam-use-bogofilter)
					(spam spam-use-bogofilter)))
			 (spam-autodetect . t)
			 (spam-autodetect-methods spam-use-BBDB          ;never mark incoming mail from folk in my BBDB as spam
						  spam-use-whitelist     ;same as above but for sender addresses not in my BBDB
						  spam-use-regex-headers ;server-side SpamAssassin tags
						  spam-use-blacklist     ;sender addresses from spam declared messages
						  spam-use-bogofilter)   ;therefore bogofilter needs to be installed
					; .... agent parameters ......
			 (agent-predicate or high short (not old))
			 (agent-score . file)
					; - - agent score rule - -
			 (agent-score
			  ("from"
					;("Mr. Foo Bar" 100 nil s)
			   ("debian\\|emacs\\|linux\\|gnu\\|fsf" 100 nil s)
			   )
			  ("subject"
			   ("Nose and Face" -100 nil s)
			   ("debian\\|emacs\\|linux\\|gnu\\|fsf" 100 nil s)
			   )
					; lower the score of articles that have been
					; crossposted to >= 3 groups
			  ("xref"
			   ("[^:\n]+:[0-9]+ +[^:\n]+:[0-9]+ +[^:\n]+:[0-9]+" -100 nil r)
			   )
			  )
					; .... posting style .........
			 (posting-style
			  (name priv-my-name)
			  (address priv-my-sunoano1-mail-address)
			  )
					; .... group parameters ......
			 (display . 20)
					; .... local variables .......
			 )
			))

(setq

 ;; send mail function
 ;; send-mail-function 'sendmail-send-it
 send-mail-function 'smtpmail-send-it
 ;; message-send-mail-function 'sendmail-send-it
 message-send-mail-function 'smtpmail-send-it
 smtpmail-queue-mail nil
 ;; in case:
 smtpmail-debug-info t
 smtpmail-local-domain nil

 )




(defadvice message-send-mail (around gmail-message-send-mail protect activate)
  "Set up SMTP settings to use Gmail's server when mail is from a gmail.com address."
  (interactive "P")
  (if (save-restriction
	(message-narrow-to-headers)
	(string-match "gmail.com" (message-fetch-field "from")))

      (let ((message-send-mail-function 'smtpmail-send-it)
            ;; gmail says use port 465 or 587, but 25 works and those don't, go figure
            (smtpmail-starttls-credentials '(("smtp.gmail.com" 25 nil nil)))
            (smtpmail-auth-credentials '(("smtp.gmail.com" 25 "username@gmail.com" nil)))
            (smtpmail-default-smtp-server "smtp.gmail.com")
            (smtpmail-smtp-server "smtp.gmail.com")
            (smtpmail-smtp-service 25)
            (smtpmail-local-domain "yourdomain.com"))
        ad-do-it)
    ad-do-it))


;; ******************************************************
;; *                    END GMAIL	         	*
;; ******************************************************


(setq gnus-secondary-select-methods '((nnml "")))

(add-to-list 'gnus-secondary-select-methods '(nnimap "gmail"
						     (nnimap-stream ssl)
						     (nnimap-address "imap.gmail.com")
						     (nnimap-server-port 993)
						     (nnir-search-engine imap)))

;;; My own key bindings.
;;;
;;; I want to be able to refer to a parent in a thread with $ (as well
;;; as A r) since my keyboard is slightly broken.
;;;
;;; Gnus at times handles long lines erroneously, so I want to be able
;;; to fill long lines with F only at a few times.
(add-hook 'gnus-summary-mode-hook
	  (function (lambda ()
		      (define-key gnus-summary-mode-map "K" 'gnus-summary-kill-thread)
		      (define-key gnus-summary-mode-map "F" 'gnus-article-fill-long-lines)
		      (define-key gnus-summary-mode-map "$" 'gnus-summary-refer-parent-article)
		      (define-key gnus-summary-mode-map "z" 'scroll-down)
		      (define-key gnus-summary-mode-map "v" 'scroll-up)
		      (define-key gnus-summary-mode-map "-" 'gnus-summary-hide-thread)
		      (define-key gnus-summary-mode-map "+" 'gnus-summary-show-thread)
		      )))

;; Enable mailinglist support
(when (fboundp 'turn-on-gnus-mailing-list-mode)
  (add-hook 'gnus-summary-mode-hook 'turn-on-gnus-mailing-list-mode))




(setq level 2)

(setq
 ;;
 gnus-show-threads t

 ;; Default thread sorting
 ;; par date (plus recent en premier) puis par sujets
;;;(setq gnus-thread-sort-functions
;;;      '(
;;;	gnus-thread-sort-by-total-score
;;;        gnus-thread-sort-by-subject
;;;        (not gnus-thread-sort-by-date)
;;;        ))

;;; gnus-thread-sort-functions '(gnus-thread-sort-by-total-score
;;;			      gnus-thread-sort-by-date
;;;			      )
 gnus-thread-sort-functions '(gnus-thread-sort-by-total-score
			      gnus-thread-sort-by-number
			      gnus-thread-sort-by-most-recent-date)

 gnus-sort-gathered-threads-function 'gnus-thread-sort-by-date


 ;;
 gnus-thread-ignore-subject nil
;;; gnus-thread-ignore-subject t

 ;;
 gnus-thread-hide-subject t

 ;;
 gnus-thread-hide-killed t

 ;;
 gnus-thread-hide-subtree nil
;;; ;; Makes presentation more compact by hiding thread subtree
;;; gnus-thread-hide-subtree t
 )

(setq
 ;;

 ;;
 gnus-thread-indent-level 1

 ;; Gather threads with use of Subject header
 gnus-summary-thread-gathering-function #'gnus-gather-threads-by-subject
 ;;gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references

 ;; Loose threads
 gnus-summary-make-false-root 'empty
 ;; gnus-summary-make-false-root 'adopt

 ;;
 gnus-summary-same-subject ".../" ; UCS #x00[ab]b or #x25b6

 ;; Gather subjects by fuzzy string matching in the same thread if we don't have any References.
 gnus-summary-gather-subject-limit 'fuzzy

 )

(setq

 ;;
 gnus-treat-buttonize t

 ;;
 gnus-use-adaptive-scoring t

 ;; Don't subscribe to newsgroups automagically.
 gnus-subscribe-newsgroup-method 'gnus-subscribe-killed

 ;; send mail function
 ;; send-mail-function 'sendmail-send-it
 send-mail-function 'smtpmail-send-it
 ;; message-send-mail-function 'sendmail-send-it
 message-send-mail-function 'smtpmail-send-it
 smtpmail-queue-mail nil
 ;; in case:
 smtpmail-debug-info t
 ;; smtpmail-local-domain

 ;; Use gnus to send mail
 ;;mail-user-agent 'gnus-user-agent

 ;; Turn off nntp server
 gnus-nntp-server nil

 ;; prevent save dribble file message
 gnus-use-dribble-file nil

 ;; Cache ticked and dormant articles
 gnus-use-cache t

 ;; Suppress duplicate article
 gnus-suppress-duplicates t

 ;; i don't use .newsrsc
 gnus-read-newsrc-file nil
 gnus-save-newsrc-file nil

 ;; ask when fetching more articles than this.
 gnus-large-newsgroup 10000
 )

(setq

 ;;
 ;; quit quietly
 gnus-interactive-exit nil

 ;; turn off cache
 gnus-cacheable-groups "off"

 ;; don't prompt when switching to plugged
 gnus-agent-go-online nil

 ;;
 gnus-group-mode-hook '(gnus-topic-mode gnus-agent-mode)

 ;; fetch all messages and never expire them
 gnus-agent-cache t

 ;; expire certain directories
 gnus-auto-expirable-newsgroups "Trash"

 ;; buttonize the different parts, please
 gnus-buttonized-mime-types '("multipart/encrypted" "multipart/signed")

 ;; but keep buttons for multiple parts
 gnus-inhibit-mime-unbuttonizing t

 ;; Specifies what to do with cross references (`Xref:' field). If it is nil, cross references are ignored
 gnus-use-cross-reference nil
;;; gnus-use-cross-reference t

 ;;
 gnus-summary-check-current t

 ;;
 gnus-select-group-hook nil

 ;;
 gnus-add-to-list t

 ;;
 gnus-summary-display-while-building 10

 ;; fonts, colors, etc.
 gnus-visual t

 ;;
 gnus-activate-foreign-newsgroups gnus-level-subscribed

 ;; hide the annoying Google Groups signature cruft.
 gnus-signature-separator '("^--~--~---[~-]*-~-------~--~----~$")
 gnus-treat-hide-signature t

 ;;
 gnus-use-trees nil

 ;;
 gnus-tree-minimize-window 4

 ;;
 gnus-generate-tree-function 'gnus-generate-horizontal-tree

 ;;
 gnus-break-pages nil

 ;;
 gnus-novice-user t
 gnus-expert-user nil

 )

(setq

 ;; just show the summary, don't fetch the first article
 gnus-auto-select-first nil

 ;;
 gnus-view-pseudos 'automatic

 ;;
 gnus-use-generic-form nil

 ;;
 gnus-auto-select-next 'quietly
 ;;gnus-auto-select-next nil

 gnus-auto-center-summary t
 ;;gnus-auto-center-summary nil

 gnus-auto-select-same nil

 gnus-nov-is-evil nil

 ;; fetch no older articles, but thread everything we got
 gnus-fetch-old-headers nil
 ;;gnus-fetch-old-headers 'some

 ;; caching
 gnus-use-cache t
 gnus-cacheable-groups "gmane\\."
 gnus-uncacheable-groups "^nnml\\|^nnfolder\\|^nnimap"

 ;; no auto centering of the summary line
 gnus-auto-center-subject nil

 ;; don't check for newly created groups
 gnus-check-new-newsgroups nil

 ;; since we don't bother with new groups, don't remember what groups are killed
 gnus-save-killed-list nil

 ;; don't read the entire friggin' active file when we connect
 gnus-read-active-file 'some

 ;; headers
 gnus-sorted-header-list '("^From:" "^Subject:" "^Date:" "^Newsgroups:" "^To:" "^Cc:")

 gnus-visible-headers (format "^%s:"
			      (regexp-opt'("From" "Subject" "Date" "Newsgroups" "Followup-To"
					   "Reply-To" "Summary" "To" "Cc" "Posted-To"
					   "Mail-Copies-To" "Apparently-To" "Resent-From")))

 ;; setq gnus-boring-article-headers '(empty followup-to reply-to newgroups to-address to-list cc-list)

 gnus-treat-hide-boring-headers 'head

 ;; can munge adjacent URLs, ugh
 gnus-treat-unsplit-urls nil

 gnus-treat-wash-html nil

 gnus-treat-date-local nil

 gnus-treat-display-smileys nil

 gnus-treat-display-face nil

 imap-log t

 ;; Save sent mail
 gnus-message-archive-group "sent-mail"

 ;;
 gnus-sum-thread-tree-root " >"
 gnus-sum-thread-tree-single-indent "  "
 gnus-sum-thread-tree-vertical "|"
 gnus-sum-thread-tree-indent " "
 gnus-sum-thread-tree-leaf-with-other "+-> "
 gnus-sum-thread-tree-single-leaf "`-> "

 ;; Grab older messages in the thread
 gnus-fetch-old-headers 100
 )
(setq
 ;; View all the MIME parts in the current article
 gnus-mime-view-all-parts t
 gnus-buttonized-mime-types nil
 gnus-unbuttonized-mime-types '("text/plain")
 )

(setq

 ;;
 gnus-verbose 9
 gnus-verbose-backends 9
 )

;; wash HTML encoded articles with the built in function.
;; mm-text-html-renderer 'html2text

;;; Remove mail we have already fetched. Only reason to have this set
;;; to anything else than t is that you think Gnus will lose your
;;; mail. Useful if you're experimenting with something.
;; (setq mail-source-delete-incoming t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Displaying messages

;;; If we have an alternative, don't show HTML or RichText messages at all.
;;;(eval-after-load "mm-decode"
;;;  '(progn
;;;     (add-to-list 'mm-discouraged-alternatives "text/html")
;;;     (add-to-list 'mm-discouraged-alternatives "text/enriched")
;;;     (add-to-list 'mm-discouraged-alternatives "text/richtext")))

;;; I want to see To: headers instead of From: headers in my outgoing
;;; archive groups.
;; (setq gnus-extra-headers '(To Newsgroups))
;; (setq nnmail-extra-headers gnus-extra-headers)

;; (add-hook 'gnus-part-display-hook 'gnus-article-date-user)

;; http://www.emacswiki.org/emacs/GroupParameters
;;(setq gnus-parameter-to-list-alist '(("stack.exchange" . "do-not-reply@stackexchange.com")))
;;(setq gnus-total-expirable-newsgroups (regexp-opt '("stack.exchange")))

