(require 'nnml)
(require 'gnus)
(require 'gnus-topic)
(require 'gnus-art)
(require 'gnus-cache)
(require 'gnus-score)
(require 'gnus-msg)

;; ******************************************************
;; *                      GMAIL		         	*
;; ******************************************************
(setq gnus-select-method
      '(nnimap "gmail"
	(nnimap-address "imap.gmail.com")
	(nnimap-server-port 993)
	(nnimap-stream ssl)
	(nnimap-authinfo-file "~/.authinfo")
	))


(setq message-send-mail-function 'smtpmail-send-it
      smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
      smtpmail-auth-credentials '(("smtp.gmail.com" 587
				   "paulo.jorge.tome@gmail.com" nil))
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587
      smtpmail-debug-info t ; optional, but handy in case something goes wrong
      ;; Make Gnus NOT ignore [Gmail] mailboxes
      gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")


(setq gnus-parameters '(("nnimap\\+gmail:INBOX" (expiry-wait . 2))))

;; ******************************************************
;; *                    END GMAIL	         	*
;; ******************************************************


(setq gnus-secondary-select-methods nil)
(setq gnus-select-group-hook nil)
(setq gnus-auto-select-next t)
(setq gnus-summary-check-current t)
(setq gnus-auto-center-summary nil)
(setq gnus-thread-indent-level 1)

(setq gnus-add-to-list t)
(setq gnus-summary-display-while-building 10)

;;; Fetch no older articles, but thread everything we got.
;; (setq gnus-fetch-old-headers 'nil)
(setq gnus-fetch-old-headers 'some)


;;;; trier :
;; par date (plus recent en premier) puis par sujets
;;;(setq gnus-thread-sort-functions
;;;      '(
;;;	gnus-thread-sort-by-total-score
;;;        gnus-thread-sort-by-subject
;;;        (not gnus-thread-sort-by-date)
;;;        ))

;;; Remove mail we have already fetched. Only reason to have this set
;;; to anything else than t is that you think Gnus will lose your
;;; mail. Useful if you're experimenting with something.
;; (setq mail-source-delete-incoming t)


(setq gnus-subscribe-newsgroup-method
      'gnus-subscribe-killed            ; Don't subscribe to newsgroups automagically.
      gnus-use-generic-form nil         ;
      gnus-auto-select-first nil        ; Just show the summary, don't fetch the first article.
      gnus-auto-select-next nil         ; Same thing with next article.
      gnus-auto-center-subject nil      ; No auto centering of the summary line.
      gnus-check-new-newsgroups nil     ; Don't check for newly created groups.
      gnus-save-killed-list nil         ; Since we don't bother with new groups, don't remember what groups are killed.
      gnus-read-active-file 'some)      ; Don't read the entire friggin' active file when we connect.

(setq gnus-use-adaptive-scoring t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Displaying messages

;;; If we have an alternative, don't show HTML or RichText messages at all.
;;;(eval-after-load "mm-decode"
;;;  '(progn
;;;     (add-to-list 'mm-discouraged-alternatives "text/html")
;;;     (add-to-list 'mm-discouraged-alternatives "text/enriched")
;;;     (add-to-list 'mm-discouraged-alternatives "text/richtext")))

;;; Wash HTML encoded articles with the built in function.
;;(setq mm-text-html-renderer 'html2text)

;;; Customizing threading in Gnus

;;; Yes, please do threading. But don't bore us; hide things like
;;; subject and killed, but not living subtrees.
(setq gnus-show-threads t
      gnus-thread-hide-subject t
      gnus-thread-hide-subtree nil
      gnus-thread-hide-killed t
      gnus-thread-ignore-subject nil
      gnus-use-cross-reference nil
      gnus-nov-is-evil nil)


;;; Gather subjects by fuzzy string matching in the same thread if we
;;; don't have any References.
(setq gnus-summary-gather-subject-limit 'fuzzy)

;;; Gather threads with use of References header.
(setq gnus-summary-thread-gathering-function
      'gnus-gather-threads-by-references)

(setq gnus-summary-make-false-root 'adopt)

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
	    (define-key gnus-summary-mode-map "v" 'scroll-up))))

(add-hook 'gnus-summary-mode-hook 'turn-on-gnus-mailing-list-mode)

;;; I want to see To: headers instead of From: headers in my outgoing
;;; archive groups.
(setq gnus-extra-headers '(To Newsgroups))
(setq nnmail-extra-headers gnus-extra-headers)

;; (add-hook 'gnus-part-display-hook 'gnus-article-date-user)
(setq gnus-treat-buttonize t)

;; http://www.emacswiki.org/emacs/GroupParameters
;;(setq gnus-parameter-to-list-alist '(("stack.exchange" . "do-not-reply@stackexchange.com")))
;;(setq gnus-total-expirable-newsgroups (regexp-opt '("stack.exchange")))

(setq
 ;; prevent save dribble file message
 gnus-use-dribble-file nil

 ;; Cache ticked and dormant articles
 gnus-use-cache t

 ;; Default thread sorting
 gnus-thread-sort-functions '(gnus-thread-sort-by-total-score)

 ;; Suppress duplicate article
 gnus-suppress-duplicates t

 ;; Makes presentation more compact by hiding thread subtree
 gnus-thread-hide-subtree t

 ;; I don't use .newsrsc
 gnus-read-newsrc-file nil
 gnus-save-newsrc-file nil

 ;; Ask when fetching more articles than this.
 gnus-large-newsgroup 10000

 ;; quit quietly
 gnus-interactive-exit nil

 ;; turn off cache
 gnus-cacheable-groups "off"

 ;; don't promp when switching to plugged
 gnus-agent-go-online nil

 gnus-group-mode-hook '(gnus-topic-mode gnus-agent-mode)

 )
