;; ******************************************************
;; *                    EZWINPORTS                      *
;; ******************************************************


(if (eq system-type 'windows-nt)
    (progn
      (setq exec-path (cons "C:/gnu/ezwinports/bin" exec-path))
      (setenv "PATH" (concat "C:\\gnu\\ezwinports\\bin;" (getenv "PATH")))
      ))

(if (eq system-type 'windows-nt)
    (setq tls-program '("C:/siscog-dev-tools/Git/bin/openssl.exe s_client -connect %h:%p -no_ssl2 -ign_eof")))

;; ******************************************************
;; *               Maximize Emacs window                *
;; ******************************************************
;; Start emacs in fullscreen mode in Xorg
(defun fullscreen ()
  (interactive)
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                         '(2 "_NET_WM_STATE_FULLSCREEN" 0)))
(cond (eq window-system 'x)
      (add-hook 'emacs-startup-hook 'fullscreen)
      (eq system-type 'windows-nt)
      ;; Maximize Emacs window
      (w32-send-sys-command ?\xf030)
      ;;(w32-send-sys-command #xf030)
      )

;; ******************************************************
(setq time-stamp-format "%:y-%02m-%02d %02H:%02M:%02S")

(setq indicate-empty-lines t)

;;; Display date and time in mode line
(setq display-time-24hr-format t)
(setq display-time-day-and-date t)
(setq display-time-format "∥ %A %e %B − %R ∥")
(display-time-mode 1)

(setq fill-column 80)
(auto-fill-mode t)

;; display only tails of lines longer than 80 columns, tabs and
;; trailing whitespaces
(setq whitespace-line-column 80
      whitespace-style '(tabs trailing lines-tail))

(require 'whitespace)

;; face for long lines' tails
(set-face-attribute 'whitespace-line nil
                    :background "red1"
                    :foreground "yellow"
                    :weight 'bold)

;; face for Tabs
(set-face-attribute 'whitespace-tab nil
                    :background "red1"
                    :foreground "yellow"
                    :weight 'bold)

(require 'info)
(require 'cl)
(require 'advice)
(require 'bytecomp)
(require 'timer)
;; FIXME
;;(require 'setnu)
;;(require 'wtf)

(add-hook 'prog-mode-hook #'hs-minor-mode)

;; (find-lisp-object-file-name 'goto-line 'function)

(setq find-function-C-source-directory "~/git/emacs/src")
(setq source-directory "~/git/emacs")

;; Info directory
(unless (boundp 'Info-directory-list)
  (setq Info-directory-list Info-default-directory-list))


;; copy/paste between emacs and e.g. iceweasel
(setq x-select-enable-clipboard t)

;;
(setq default-truncate-lines t)

;; Since my sentences end with `. ' and not `.  '
(setq sentence-end-double-space 'nil)

;; all files end with `\n'
(setq require-final-newline 'visit-save)

;; no pager-like behavior with ansi-term
(setq term-buffer-maximum-size 0)
(setq backup-by-copying t)
(setq compilation-scroll-output t)

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

;; Elevate some limits
(setq max-lisp-eval-depth '4000)
(setq max-specpdl-size '10000)

;; Disable enabled commands/keybindings
(put 'overwrite-mode 'disabled t)

;;;_ , automatically create path

;; some sort of mkdir -p for non existing paths
;;   when opening a non-existing file (e.g. myfile) within some yet
;;   non-existing directory, it automatically creates the file and
;;   /path/to/file/myfile when the file is saved witin emacs

(add-hook 'before-save-hook
          '(lambda ()
             (or (file-exists-p (file-name-directory buffer-file-name))
                 (make-directory (file-name-directory buffer-file-name) t)))
          'append)

;;;_ , automatically delete trailing whitespace

(add-hook 'before-save-hook 'delete-trailing-whitespace)


;;;_ , automatically untabify buffers

(add-hook 'before-save-hook
          '(lambda ()
             (untabify (point-min) (point-max))))

;;;_ , autosave

;; save every 100 characters typed
(setq auto-save-interval 100)

;; save after 10 seconds of idle time
(setq auto-save-timeout 10)

(defun my-save-buffer-if-visiting-file (&optional args)
  "Save the current buffer only if it is visiting a file"
  (interactive)
  (if (buffer-file-name)
      (save-buffer args)))

;; This causes files that I'm editing to be saved automatically by the
;; emacs auto-save functionality.  I'm hoping to break myself of the
;; c-x c-s twitch.
(add-hook 'auto-save-hook 'my-save-buffer-if-visiting-file)

;;;_ , my-frame-title-refresh

;; Show date and current time, GNU Emacs version and `buffer-file-name'
;; if available, `buffer-name' otherwise
(defun my-frame-title-refresh ()
  (setq frame-title-format
        `(,(buffer-file-name "buffer-file-name: %f" ("%b"))
          "      "
          ,(format-time-string "Week/Day of year: %W/%j")
          "      "
          ,(format-time-string "Weekday: %A")
          "      "
          ,(format-time-string "Date: %Y/%m/%d")
          "      "
          ,(format-time-string "Time:  ")
          ,(replace-regexp-in-string "\n" "" (shell-command-to-string "date -u +%H:%M"))
          " UTC"
          "      "
          ,(substring (emacs-version) 0 20)
          )))

;; Update frame title every minute
(run-with-timer 1 60 'my-frame-title-refresh)


;;;_ , Auto bytecompile

(defun byte-compile-init-file ()
  (when (equal buffer-file-name user-init-file)
    (let ((byte-compile-warnings '(unresolved)))
      (when (file-exists-p (concat user-init-file ".elc"))
        (delete-file (concat user-init-file ".elc")))
      (byte-compile-file user-init-file)
      (message "Just compiled %s " user-init-file))))

(add-hook 'kill-buffer-hook 'byte-compile-init-file)

;;_ , command-history

;; See `chistory.el'

;; NOTES:
;; 1) I use `command-history' which is bound to `C-x c' on a regular
;; 2) Using `repeat-complex-command' wich is bound to `C-x M-:' per
;; default is also pretty useful

(setq list-command-history-max '100)

;;;_ , higlight-changes-mode

;;(global-highlight-changes-mode t)
(setq highlight-changes-global-changes-existing-buffers t)

;;;_ , uniquify
;; See (Info-goto-node "(emacs) Uniquify")

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)
(setq uniquify-trailing-separator-p t)

;;_ , multi-protocol remote file access

;; See (Info-goto-node "(tramp)Top") as well as
;; http://www.emacswiki.org/cgi-bin/wiki/TrampMode

;; What I also consider very useful is
;;(Info-goto-node "(tramp)Version Control")

(require 'tramp)
;;(add-to-list 'Info-default-directory-list "~/git/tramp/info/")
(setq tramp-default-method "ssh")

;;;_ , dired

(setq dired-dwim-target t)
(setq dired-recursive-copies 'always)
(setq dired-recursive-deletes 'always)
(setq image-dired-external-viewer "/usr/bin/gimp")

;;;_ , dired-x

;; See (Info-goto-node "(dired-x) Top")
(require 'dired-x)

;;;_  . Advanced Mark Commands

;; (Info-goto-node "(dired-x) Advanced Mark Commands")

;;;_  . Omit

(dired-omit-mode 1)
(setq dired-omit-files (concat dired-omit-files "\\|^\\."))
(setq dired-omit-extensions `(,@dired-omit-extensions ".avi" ".mp3"))

;;;_ , image-dired

;; See http://www.emacswiki.org/cgi-bin/wiki/Tumme
(require 'image-dired)

(setq image-dired-show-all-from-dir-max-files 100)
(setq image-dired-thumb-margin 4)
(setq image-dired-thumb-relief 0)

(require 'recentf)
(recentf-mode 1)                        ;recently edited files in menu
(setq recentf-max-menu-items 25)
(global-set-key "\C-xr" 'recentf-open-files)

;;;_ Web

;;;_. standard browser to open URLs within GNU Emacs

;; See http://www.emacswiki.org/cgi-bin/wiki/BrowseUrl for more information.

(setq gnus-button-url 'browse-url-generic
      browse-url-generic-program "iceweasel"
      browse-url-browser-function gnus-button-url)


(setf browse-url-browser-function 'browse-url-generic)

;; (setf browse-url-generic-program "C:/Program Files/Google/Chrome/Application/chrome.exe")

(defun google ()
  "Googles a query or region if any."
  (interactive)
  (browse-url
   (concat
    "http://www.google.com/search?ie=utf-8&oe=utf-8&q="
    (if mark-active
        (buffer-substring (region-beginning) (region-end))
	(read-string "Query: ")))))

(global-set-key [M-mouse-3] 'google)

;;;_. w3m

;;(require 'w3m)


;;; GNUGP && EasyPG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (add-to-list 'load-path (expand-file-name "~/git/gnupg"))

;;(require 'epa-file)
;;(epa-file-enable)

;;; Info mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; After Info-mode has started
(add-hook 'Info-mode-hook
          (lambda ()
            (setq Info-additional-directory-list Info-default-directory-list)
            )
          'append)
(add-to-list 'Info-default-directory-list "Z:/siscog/git/gnupg/doc")
(add-to-list 'Info-default-directory-list "Z:/siscog/git/gnus/texi")
(add-to-list 'Info-default-directory-list "Z:/siscog/git/org-mode/doc")

;;;(Info-goto-node "(emacs)FFAP")
;;;(Info-goto-node "(dired-x) Top")
;;;(Info-goto-node "(gnus)Category Syntax")
;;;(Info-goto-node "(bbdb) Mail Sending Interfaces")
;;;(Info-goto-node "(message)Security")
;;__________________________________________________________________________
;;;;    System Customizations

;; This is bound to f11 in Emacs 24.4
;;(toggle-frame-fullscreen)

;; keys for moving to prev/next code section (Form Feed; ^L)
(global-set-key (kbd "<C-M-prior>") 'backward-page) ; Ctrl+Alt+PageUp
(global-set-key (kbd "<C-M-next>") 'forward-page)   ; Ctrl+Alt+PageDown


;; Prevent the cursor from blinking
(blink-cursor-mode 0)


;; Who use the bar to scroll?
;;(scroll-bar-mode left)
(set-scroll-bar-mode 'left)

;; Deactivate tooltips in emacs
(tooltip-mode 0)
(tool-bar-mode -1)
;;(fringe-mode 'no-fringes)
;; Delete the selection area with a keypress
(delete-selection-mode t)
;; Use font-lock everywhere.
(global-font-lock-mode t)

;; We have CPU to spare; highlight all syntax categories.
(setq font-lock-maximum-decoration t)

;;; Show matching parenthesis
(setq show-paren-delay 0) ; how long to wait?
(show-paren-mode t) ; turn paren-mode on
(setq show-paren-style 'expression) ; alternatives are 'parenthesis' and 'mixed'

;; Set buffer behaviour
;; Prevent emacs from adding newlines when pressing down arrow at the end of the buffer
(setq next-line-add-newlines nil)
;; Ordinarily emacs jumps by half a page when scrolling -- reduce:
(setq scroll-step 1)
(setq scroll-conservatively 5)

;; Enable emacs functionality that is disabled by default
(put 'eval-expression 'disabled nil)
(put 'set-goal-column 'disabled nil)
(put 'narrow-to-page 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(setq enable-recursive-minibuffers t)

;; Misc customizations
(fset 'yes-or-no-p 'y-or-n-p)           ;replace y-e-s by y
;;________________________________________________________________
;;    Don't display initial logo
;;________________________________________________________________
(setq inhibit-startup-message t)        ;no startup message
(setq inhibit-splash-screen t)          ;no splash screen
(setq initial-scratch-message "")       ; Don't use messages that you don't read
(defconst use-backup-dir t)             ;use backup directory
(defconst query-replace-highlight t)    ;highlight during query
(defconst search-highlight t)           ;highlight incremental search
(setq ls-lisp-dirs-first t)             ;display dirs first in dired
(global-font-lock-mode t)               ;colorize all buffers
(setq ecb-tip-of-the-day nil)           ;turn off ECB tips

;; If we read a compressed file, uncompress it on the fly:
;; (this works with .tar.gz and .tgz file as well)
(auto-compression-mode 1)

;; The following key-binding iconifies a window -- we disable it:
(global-unset-key "\C-x\C-z")

;; The following key-binding quits emacs -- we disable it too:
(global-unset-key "\C-x\C-c")

;; But we establish a longer sequence that is harder to hit by accident:
(global-set-key "\C-x\C-c\C-v" 'save-buffers-kill-emacs)
;; The longer sequence is all right: emacs should be launched just
;; once at login and never killed until ready to logout.

;; Disable binding of C-z to iconify a window.
(global-unset-key "\C-z")

;; M-` invokes tmm-menubar; disable it.
(global-unset-key "\M-`")

;; C-x C-n invokes set-goal-column; disable it.
(global-unset-key "\C-x\C-n")

;;________________________________________________________________
;;    Flash the screen on error; don't beep.
;;________________________________________________________________
(setq-default visible-bell t)
;;;
;;; Emacs Server Mode
;;;
(server-mode)

;;________________________________________________________________
;;    Files and directories
;;________________________________________________________________

;; dired-x is a nice substitute for Windows Explorer and OSX's Finder.
;; M-o: avoid seeing all the backup files.
;; C-x C-j: enter dired/dired-x mode.
(add-hook 'dired-load-hook
          (function (lambda ()
                      (load "dired-x"))))

;; Ordinarily emacs jumps by half a page when scrolling -- reduce:
(setq scroll-step 1)

;;________________________________________________________________
;;    scroll-left is disabled by default; enable it.
;;________________________________________________________________
(put 'scroll-left 'disabled nil)

(put 'set-goal-column 'disabled nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; KEY RECONFIGURATION

;; HOME - go to beginning of line
(define-key global-map [home]   'beginning-of-line)

;; C-HOME - go to beginning of buffer
(define-key global-map [C-home] 'beginning-of-buffer)

;; END - go to end of line
(define-key global-map [end]    'end-of-line)

;; C-END - go to end of buffer
(define-key global-map [C-end]  'end-of-buffer)

;; KEYPAD-/ - "/" character
(define-key global-map [kp-divide] "/")

(global-set-key [C-tab] 'hippie-expand)

(global-set-key [M-delete] 'kill-word)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NAVIGATION

;; M-LEFT - begining of S-Expression
(define-key global-map [M-left]  'backward-sexp)

;; M-RIGHT - end of S-Expression
(define-key global-map [M-right] 'forward-sexp)


;; Isto destina-se a permitir seleccionar simbolos com '.' no meio quando se carrega
;; o botao do meio do rato
(modify-syntax-entry ?#  "_   " emacs-lisp-mode-syntax-table)
(modify-syntax-entry ?.  "w   " emacs-lisp-mode-syntax-table)
(modify-syntax-entry ?#  "_   " lisp-mode-syntax-table)
(modify-syntax-entry ?.  "w   " lisp-mode-syntax-table)


;;; VISUAL ENHANCEMENTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Background selection color
(set-face-background 'region "darkseagreen")

;;; Background Color
(set-background-color "seashell")

;;(show-paren-match ((t (:bold t))))
;;(setq show-paren-style 'expression)
(set-face-background 'show-paren-match-face "LightSteelBlue2")

;;; Highlight isearch current match
(setq search-highlight t)

;; Permanent display of line and column numbers is handy.
(setq-default line-number-mode 't)
(setq-default column-number-mode 't)

;;; Display date and time in mode line
(setq display-time-24hr-format t)
(setq display-time-day-and-date t)
(display-time)


(setq flyspell-issue-welcome-flag nil)

(setq mouse-wheel-progressive-speed nil)

(setq-default show-trailing-whitespace t)

;;; Quick expression selection with control return
(defun select-current-sexp ()
  (interactive)
  (when (and (not (char-equal (char-after) ?\())
             (char-equal (char-before) ?\)))
    (backward-char)
    (backward-up-list))
  (when mark-active
    (backward-up-list))
  (mark-sexp 1))

(global-set-key [(ctrl return)] 'select-current-sexp)

(global-set-key [f10] 'reposition-defun-at-top)

(global-set-key [f12] 'revert-buffer)


;; ******************************************************
;; *                    EMACS - SLIME                   *
;; ******************************************************

;; How to customize Emacs split-window-X with the new window showing the next buffer?
;; Funciona para C-x 2 e C-x 3.

(defun split-window-and-next-buffer (new-window)
  (let ((old-window (selected-window)))
    (select-window new-window)
    (next-buffer)
    (select-window old-window)
    new-window))

(defadvice split-window-right (after split-window-right-and-next-buffer
                                     activate protect compile)
  (split-window-and-next-buffer ad-return-value))

(defadvice split-window-below (after split-window-bellow-and-next-buffer
                                     activate protect compile)
  (split-window-and-next-buffer ad-return-value))

;; To remove the advices, call the functions until they return nil.
;;(ad-unadvise 'split-window-below)
;;(ad-unadvise 'split-window-right)


(defvar electrify-return-match
  "[\]}\)\"]"
  "If this regexp matches the text after the cursor, do an \"electric\"
  return.")


(defun electrify-return-if-match (arg)
  "If the text after the cursor matches `electrify-return-match' then
  open and indent an empty line between the cursor and the text.  Move the
  cursor to the new line."
  (interactive "P")
  (let ((case-fold-search nil))
    (if (looking-at electrify-return-match)
        (save-excursion (newline-and-indent)))
    (newline arg)
    (indent-according-to-mode)))

(require 'eldoc) ; if not already loaded
;;;(eldoc-add-command
;;; 'paredit-backward-delete
;;; 'paredit-close-round)
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
;;;         (paredit-mode t)
            (turn-on-eldoc-mode)
;;;         (eldoc-add-command
;;;          'paredit-backward-delete
;;;          'paredit-close-round)
            (local-set-key (kbd "RET") 'electrify-return-if-match)
            (eldoc-add-command 'electrify-return-if-match)))
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)


;; source: http://steve.yegge.googlepages.com/my-dot-emacs-file
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ENCODING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C-h C RET
;; M-x describe-current-coding-system

(add-to-list 'file-coding-system-alist '("\\.tex" . utf-8-unix) )
(add-to-list 'file-coding-system-alist '("\\.txt" . utf-8-unix) )
(add-to-list 'file-coding-system-alist '("\\.el" . utf-8-unix) )
(add-to-list 'file-coding-system-alist '("\\.lisp" . utf-8-unix) )
(add-to-list 'file-coding-system-alist '("\\.cl" . utf-8-unix) )
(add-to-list 'file-coding-system-alist '("\\.scratch" . utf-8-unix) )
(add-to-list 'file-coding-system-alist '("user_prefs" . utf-8-unix) )

(add-to-list 'process-coding-system-alist '("\\.txt" . utf-8-unix) )

(add-to-list 'network-coding-system-alist '("\\.txt" . utf-8-unix) )

(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)
(set-terminal-coding-system 'utf-8-unix)
(set-keyboard-coding-system 'utf-8-unix)
(set-selection-coding-system 'utf-8-unix)
(setq-default buffer-file-coding-system 'utf-8-unix)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))
(set-charset-priority 'unicode)

;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; mnemonic for utf-8 is "U", which is defined in the mule.el
(setq eol-mnemonic-dos ":CRLF")
(setq eol-mnemonic-mac ":CR")
(setq eol-mnemonic-undecided ":?")
(setq eol-mnemonic-unix ":LF")

(defalias 'read-buffer-file-coding-system 'lawlist-read-buffer-file-coding-system)
(defun lawlist-read-buffer-file-coding-system ()
  (let* ((bcss (find-coding-systems-region (point-min) (point-max)))
         (css-table
          (unless (equal bcss '(undecided))
            (append '("dos" "unix" "mac")
                    (delq nil (mapcar (lambda (cs)
                                        (if (memq (coding-system-base cs) bcss)
                                            (symbol-name cs)))
                                      coding-system-list)))))
         (combined-table
          (if css-table
              (completion-table-in-turn css-table coding-system-alist)
            coding-system-alist))
         (auto-cs
          (unless find-file-literally
            (save-excursion
              (save-restriction
                (widen)
                (goto-char (point-min))
                (funcall set-auto-coding-function
                         (or buffer-file-name "") (buffer-size))))))
         (preferred 'utf-8-unix)
         (default 'utf-8-unix)
         (completion-ignore-case t)
         (completion-pcm--delim-wild-regex ; Let "u8" complete to "utf-8".
          (concat completion-pcm--delim-wild-regex
                  "\\|\\([[:alpha:]]\\)[[:digit:]]"))
         (cs (completing-read
              (format "Coding system for saving file (default %s): " default)
              combined-table
              nil t nil 'coding-system-history
              (if default (symbol-name default)))))
    (unless (zerop (length cs)) (intern cs))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SPELL CHECKER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;(if (file-exists-p "C:/gnu/ezwinports/bin/hunspell.exe")
;;;    (progn
;;;      (setq ispell-program-name "hunspell")
;;;      (eval-after-load "ispell"
;;;        '(progn (setq ispell-dictionary "american"
;;;                   ispell-extra-args '("-a" "-i" "utf-8")
;;;                   ispell-silently-savep t)))))
;;;
;;;(setq-default ispell-program-name "C:/gnu/ezwinports/bin/hunspell.exe")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SHOW ERRORS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Show errors in this file:
(setq debug-on-error t)
(setq stack-trace-on-error t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ELECTRIC MODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(electric-pair-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ORG MODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'load-path (expand-file-name "~/org-mode/lisp"))
(add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\)$" . org-mode))
(require 'org)
(require 'org-id)
;; (require 'org-checklist)
;;(require 'org-latex)
(require 'org-clock)
(require 'org-special-blocks)

;; Nice bullets
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
;;
;; Standard key bindings
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cb" 'org-iswitchb)

;; Custom Key Bindings
(global-set-key (kbd "<f11>") 'org-clock-goto)


(add-to-list 'org-src-lang-modes
             '("elisp" . emacs-lisp))
(add-to-list 'org-src-lang-modes
             '("emacs_lisp" . emacs-lisp))

(setq org-src-preserve-indentation t)
(setq org-edit-src-auto-save-idle-delay 5)
(setq org-edit-src-content-indentation 0)

(setq org-export-coding-system 'utf-8-unix)

(unless (boundp 'org-export-latex-classes)
  (setq org-export-latex-classes nil))

(add-to-list 'org-export-latex-classes
             '("article"
               "\\documentclass{article}"
               ("\\section{%s}" . "\\section*{%s}")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ORG-MODE SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq org-directory "~/git/org-mode")
(setq org-default-notes-file "~/github/notes.org")

(add-to-list 'load-path (expand-file-name "~/git/org-mode/contrib/lisp"))

(setq org-empty-line-terminates-plain-lists t)

(setq org-enforce-todo-dependencies t)

(setq org-cycle-separator-lines 0)

(setq org-blank-before-new-entry (quote ((heading)
                                         (plain-list-item . auto))))

(setq org-insert-heading-respect-content nil)

(setq org-M-RET-may-split-line (quote ((headline) (default . t))))

(setq org-show-following-heading t)
(setq org-show-hierarchy-above t)
(setq org-show-siblings (quote ((default))))

(setq org-id-method (quote uuidgen))

(setq org-table-export-default-format "orgtbl-to-csv")

(setq org-time-stamp-rounding-minutes (quote (1 1)))

(defvar bh/insert-inactive-timestamp t)

(defun bh/toggle-insert-inactive-timestamp ()
  (interactive)
  (setq bh/insert-inactive-timestamp (not bh/insert-inactive-timestamp))
  (message "Heading timestamps are %s" (if bh/insert-inactive-timestamp "ON" "OFF")))

(defun bh/insert-inactive-timestamp ()
  (interactive)
  (org-insert-time-stamp nil t t nil nil nil))

(defun bh/insert-inactive-timestamp ()
  (interactive)
  (org-insert-time-stamp nil t t nil nil nil))

(defun bh/insert-heading-inactive-timestamp ()
  (save-excursion
    (when bh/insert-inactive-timestamp
      (org-return)
      (org-cycle)
      (bh/insert-inactive-timestamp))))


(add-hook 'org-insert-heading-hook 'bh/insert-heading-inactive-timestamp 'append)

;; (global-set-key (kbd "<f9> t") 'bh/insert-inactive-timestamp)



(setq org-todo-keywords '((sequence "TODO(t)" "WAITING(w)" "DEFERRED(f)" "STARTED(s)" "|" "DONE(d)" "NOTE(n)"  "PHONE(p)" "MEETING(m)" "CLOSED(l)" "CANCELED(c)")))

(setq org-todo-keyword-faces (quote (("TODO" :foreground "red" :weight bold)
                                     ("WAITING" :foreground "orange" :weight bold)
                                     ("DEFERRED" :foreground "orange" :weight bold)
                                     ("STARTED" :foreground "orange" :weight bold)
                                     ("DONE" :foreground "forest green" :weight bold)
                                     ("NOTE" :foreground "dark violet" :weight bold)
                                     ("PHONE" :foreground "dark violet" :weight bold)
                                     ("MEETING" :foreground "dark violet" :weight bold)
                                     ("CLOSED" :foreground "forest green" :weight bold)
                                     ("CANCELLED" :foreground "forest green" :weight bold))))

(setq org-use-fast-todo-selection t)

(setq org-treat-S-cursor-todo-selection-as-state-change nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ORG REFILE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq org-refile-targets '((nil :maxlevel . 2)
                                        ; all top-level headlines in the
                                        ; current buffer are used (first) as a
                                        ; refile target
                           (org-agenda-files :maxlevel . 2)))

;; provide refile targets as paths, including the file name
;; (without directory) as level 1 of the path
(setq org-refile-use-outline-path 'file)

;; allow to create new nodes (must be confirmed by the user) as
;; refile targets
(setq org-refile-allow-creating-parent-nodes 'confirm)


(setq org-log-refile t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ORG CLOCKING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Resume clocking task when emacs is restarted
(org-clock-persistence-insinuate)
;;
;; Show lot of clocking history so it's easy to pick items off the C-F11 list
(setq org-clock-history-length 23)

;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)

(setq org-clock-in-switch-to-state "STARTED")

;; Show the time-clock in the modeline.
(setq org-clock-modeline-total 'current)

;; Keybindings. I don't want Org Mode to grab the movement keys for indentation.
(setq org-replace-disputed-keys t)

;; Separate drawers for clocking and logs
(setq org-drawers (quote ("PROPERTIES" "LOGBOOK" "CLOCK" "SCHEDULE" "HIDDEN")))

;; Time Tracking
(setq org-log-done (quote time))

(setq org-log-into-drawer "LOGBOOK")

(setq org-log-repeat 'time)

;; Save clock data and state changes and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)

;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)

;; Clock out when moving task to a done state
(setq org-clock-out-when-done t)

;; Save the running clock and all clock history when exiting Emacs, load it on startup
(setq org-clock-persist t)

;; Do not prompt to resume an active clock
(setq org-clock-persist-query-resume nil)

;; Enable auto clock resolution for finding open clocks
(setq org-clock-auto-clock-resolution (quote when-no-clock-is-running))

(setq bh/keep-clock-running nil)

(defun bh/clock-in-to-next (kw)
  "Switch a task from TODO to NEXT when clocking in.
Skips capture tasks, projects, and subprojects.
Switch projects and subprojects from NEXT back to TODO"
  (when (not (and (boundp 'org-capture-mode) org-capture-mode))
    (cond
     ((and (member (org-get-todo-state) (list "TODO"))
           (bh/is-task-p))
      "NEXT")
     ((and (member (org-get-todo-state) (list "NEXT"))
           (bh/is-project-p))
      "TODO"))))


;; Remove empty LOGBOOK drawers on clock out
(defun bh/remove-empty-drawer-on-clock-out ()
  (interactive)
  (save-excursion
    (beginning-of-line 0)
    (org-remove-empty-drawer-at "LOGBOOK" (point))))

(add-hook 'org-clock-out-hook 'bh/remove-empty-drawer-on-clock-out 'append)


(defun bh/find-project-task ()
  "Move point to the parent (project) task if any"
  (save-restriction
    (widen)
    (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
      (while (org-up-heading-safe)
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq parent-task (point))))
      (goto-char parent-task)
      parent-task)))

(defun bh/punch-in (arg)
  "Start continuous clocking and set the default task to the
selected task.  If no task is selected set the Organization task
as the default task."
  (interactive "p")
  (setq bh/keep-clock-running t)
  (if (equal major-mode 'org-agenda-mode)
      ;;
      ;; We're in the agenda
      ;;
      (let* ((marker (org-get-at-bol 'org-hd-marker))
             (tags (org-with-point-at marker (org-get-tags-at))))
        (if (and (eq arg 4) tags)
            (org-agenda-clock-in '(16))
          (bh/clock-in-organization-task-as-default)))
    ;;
    ;; We are not in the agenda
    ;;
    (save-restriction
      (widen)
      ;; Find the tags on the current task
      (if (and (equal major-mode 'org-mode) (not (org-before-first-heading-p)) (eq arg 4))
          (org-clock-in '(16))
        (bh/clock-in-organization-task-as-default)))))

(defun bh/punch-out ()
  (interactive)
  (setq bh/keep-clock-running nil)
  (when (org-clock-is-active)
    (org-clock-out))
  (org-agenda-remove-restriction-lock))

(defun bh/clock-in-default-task ()
  (save-excursion
    (org-with-point-at org-clock-default-task
      (org-clock-in))))

(defun bh/clock-in-parent-task ()
  "Move point to the parent (project) task if any and clock in"
  (let ((parent-task))
    (save-excursion
      (save-restriction
        (widen)
        (while (and (not parent-task) (org-up-heading-safe))
          (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
            (setq parent-task (point))))
        (if parent-task
            (org-with-point-at parent-task
              (org-clock-in))
          (when bh/keep-clock-running
            (bh/clock-in-default-task)))))))

(defvar bh/organization-task-id "eb155a82-92b2-4f25-a3c6-0304591af2f9")

(defun bh/clock-in-organization-task-as-default ()
  (interactive)
  (org-with-point-at (org-id-find bh/organization-task-id 'marker)
    (org-clock-in '(16))))

(defun bh/clock-out-maybe ()
  (when (and bh/keep-clock-running
             (not org-clock-clocking-in)
             (marker-buffer org-clock-default-task)
             (not org-clock-resolving-clocks-due-to-idleness))
    (bh/clock-in-parent-task)))

(add-hook 'org-clock-out-hook 'bh/clock-out-maybe 'append)

(defun bh/clock-in-task-by-id (id)
  "Clock in a task by id"
  (org-with-point-at (org-id-find id 'marker)
    (org-clock-in nil)))

(defun bh/clock-in-last-task (arg)
  "Clock in the interrupted task if there is one
Skip the default task and get the next one.
A prefix arg forces clock in of the default task."
  (interactive "p")
  (let ((clock-in-to-task
         (cond
          ((eq arg 4) org-clock-default-task)
          ((and (org-clock-is-active)
                (equal org-clock-default-task (cadr org-clock-history)))
           (caddr org-clock-history))
          ((org-clock-is-active) (cadr org-clock-history))
          ((equal org-clock-default-task (car org-clock-history)) (cadr org-clock-history))
          (t (car org-clock-history)))))
    (widen)
    (org-with-point-at clock-in-to-task
      (org-clock-in nil))))

(setq org-time-stamp-rounding-minutes (quote (1 1)))

;; Set default column view headings: Task Effort Clock_Summary
(setq org-columns-default-format "%80ITEM(Task) %10Effort(Effort){:} %10CLOCKSUM")

;; global Effort estimate values
;; global STYLE property values for completion
(setq org-global-properties (quote (("Effort_ALL" . "0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 0:00")
                                    ("STYLE_ALL" . "habit"))))

;; Tags with fast selection keys
(setq org-tag-alist (quote ((:startgroup)
                            ("@errand" . ?e)
                            ("@office" . ?o)
                            ("@home" . ?H)
                            ("@farm" . ?f)
                            (:endgroup)
                            ("WAITING" . ?w)
                            ("HOLD" . ?h)
                            ("PERSONAL" . ?P)
                            ("WORK" . ?W)
                            ("FARM" . ?F)
                            ("ORG" . ?O)
                            ("NORANG" . ?N)
                            ("crypt" . ?E)
                            ("NOTE" . ?n)
                            ("CANCELLED" . ?c)
                            ("FLAGGED" . ??))))

;; Allow setting single tags without the menu
(setq org-fast-tag-selection-single-key (quote expert))

(setq org-fast-tag-selection-include-todo t)

(setq org-fontify-done-headline t)

;; Capture templates for: TODO tasks, Notes, appointments, phone calls, and org-protocol
(setq org-capture-templates
      (quote (("t" "todo" entry (file "~/github/agenda/refile.org")
               "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
              ("r" "respond" entry (file "~/github/agenda/refile.org")
               "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
              ("n" "note" entry (file "~/github/agenda/refile.org")
               "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
              ("j" "Journal" entry (file+datetree "~/github/agenda/diary.org")
               "* %?\n%U\n" :clock-in t :clock-resume t)
              ("w" "org-protocol" entry (file "~/github/agenda/refile.org")
               "* TODO Review %c\n%U\n" :immediate-finish t)
              ("m" "Meeting" entry (file "~/github/agenda/refile.org")
               "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
              ("p" "Phone call" entry (file "~/github/agenda/refile.org")
               "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
              ("h" "Habit" entry (file "~/github/agenda/refile.org")
               "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"<%Y-%m-%d %a .+1d/3d>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n"))))

(define-key org-mode-map (kbd "C-S-a") 'org-archive-subtree)

(setq org-use-speed-commands t)
(setq org-speed-commands-user (quote (("0" . ignore)
                                      ("1" . ignore)
                                      ("2" . ignore)
                                      ("3" . ignore)
                                      ("4" . ignore)
                                      ("5" . ignore)
                                      ("6" . ignore)
                                      ("7" . ignore)
                                      ("8" . ignore)
                                      ("9" . ignore)

                                      ("a" . ignore)
                                      ("d" . ignore)
                                      ("h" . bh/hide-other)
                                      ("i" progn
                                       (forward-char 1)
                                       (call-interactively 'org-insert-heading-respect-content))
                                      ("k" . org-kill-note-or-show-branches)
                                      ("l" . ignore)
                                      ("m" . ignore)
                                      ("q" . bh/show-org-agenda)
                                      ("r" . ignore)
                                      ("s" . org-save-all-org-buffers)
                                      ("w" . org-refile)
                                      ("x" . ignore)
                                      ("y" . ignore)
                                      ("z" . org-add-note)

                                      ("A" . ignore)
                                      ("B" . ignore)
                                      ("E" . ignore)
                                      ("F" . bh/restrict-to-file-or-follow)
                                      ("G" . ignore)
                                      ("H" . ignore)
                                      ("J" . org-clock-goto)
                                      ("K" . ignore)
                                      ("L" . ignore)
                                      ("M" . ignore)
                                      ("N" . bh/narrow-to-org-subtree)
                                      ("P" . bh/narrow-to-org-project)
                                      ("Q" . ignore)
                                      ("R" . ignore)
                                      ("S" . ignore)
                                      ("T" . bh/org-todo)
                                      ("U" . bh/narrow-up-one-org-level)
                                      ("V" . ignore)
                                      ("W" . bh/widen)
                                      ("X" . ignore)
                                      ("Y" . ignore)
                                      ("Z" . ignore))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DISPLAY IMAGES IN ORG MODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; -- Display images in org mode
;; enable image mode first
;; (iimage-mode)
;; add the org file link format to the iimage mode regex
;;;(add-to-list 'iimage-mode-image-regex-alist
;;;          (cons (concat "\\[\\[file:\\(~?" iimage-mode-image-filename-regex "\\)\\]") 1))
;; add a hook so we can display images on load
;; (add-hook 'org-mode-hook '(lambda () (org-turn-on-iimage-in-org)))
(add-hook 'org-mode-hook ' (lambda ()
                             (org-indent-mode t)
                             (imenu-add-to-menubar "Imenu")
                             (local-set-key "\M-I" 'org-toggle-iimage-in-org))
          t)

;; Explicitly load required exporters
;; (require 'ox-html)
;; (require 'ox-latex)
;; (require 'ox-ascii)

;; Don't enable this because it breaks access to emacs from my Android phone
(setq org-startup-with-inline-images nil)

;; Force showing the next headline
(setq org-show-entry-below (quote ((default))))

(setq org-enforce-todo-dependencies t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Org Indent Mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-startup-indented t)

(setq org-indent-mode-turns-on-hiding-stars t)

(setq org-cycle-separator-lines 0)

(setq org-blank-before-new-entry (quote ((heading)
                                         (plain-list-item . auto))))

(setq org-insert-heading-respect-content nil)

(setq org-reverse-note-order nil)

(setq org-show-following-heading t)
(setq org-show-hierarchy-above t)
(setq org-show-siblings (quote ((default))))

(setq org-special-ctrl-a/e t)
(setq org-special-ctrl-k t)
(setq org-yank-adjusted-subtrees t)

(setq org-deadline-warning-days 30)


;; flyspell mode for spell checking everywhere
;; (add-hook 'org-mode-hook 'turn-on-flyspell 'append)


;; function to setup images for display on load
(defun org-turn-on-iimage-in-org ()
  "display images in your org file"
  (interactive)
  (turn-on-iimage-mode)
  (set-face-underline-p 'org-link nil))
;; function to toggle images in a org buffer
(defun org-toggle-iimage-in-org ()
  "display images in your org file"
  (interactive)
  (if (face-underline-p 'org-link)
      (set-face-underline-p 'org-link nil)
      (set-face-underline-p 'org-link t))
  (call-interactively 'iimage-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SAVE PLACE  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file "~/.emacs.d/saved-places")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; KILL PROCESS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; http://stackoverflow.com/questions/10627289/emacs-internal-process-killing-any-command
(define-key process-menu-mode-map (kbd "C-k") 'ptome/delete-process-at-point)

(defun ptome/delete-process-at-point ()
  (interactive)
  (let ((process (get-text-property (point) 'tabulated-list-id)))
    (cond ((and process
                (processp process))
           (delete-process process)
           (revert-buffer))
          (t
           (error "no process at point!")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ORG AGENDA  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq org-agenda-persistent-filter t)

(setq org-agenda-skip-additional-timestamps-same-entry t)

;;(setq org-agenda-window-setup 'current-window)
(setq org-agenda-window-setup 'reorganize-frame)

(setq org-agenda-files (quote ("~/github/agenda")))

(global-set-key "\C-ca" 'org-agenda)

;; Do not dim blocked tasks
(setq org-agenda-dim-blocked-tasks nil)

;; Compact the block agenda view
(setq org-agenda-compact-blocks t)

(setq org-blank-before-new-entry (quote ((heading . auto) (plain-list-item . auto))))

;; Custom agenda command definitions
(setq org-agenda-custom-commands
      (quote (("a" agenda ""
               ((org-deadline-warning-days -5)))
              ("N" "Notes" tags "NOTE"
               ((org-agenda-overriding-header "Notes")
                (org-tags-match-list-sublevels t)))
              ("h" "Habits" tags-todo "STYLE=\"habit\""
               ((org-agenda-overriding-header "Habits")
                (org-agenda-sorting-strategy
                 '(todo-state-down effort-up category-keep))))
              (" " "Agenda"
               ((agenda "" nil)
                (tags "REFILE"
                      ((org-agenda-overriding-header "Tasks to Refile")
                       (org-tags-match-list-sublevels nil)))
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Stuck Projects")
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header "Waiting and Postponed Tasks")
                            (org-agenda-skip-function 'bh/skip-stuck-projects)
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled t)
                            (org-agenda-todo-ignore-deadlines t)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))
               nil))))


(defun bh/org-auto-exclude-function (tag)
  "Automatic task exclusion in the agenda with / RET"
  (and (cond
        ((string= tag "hold")
         t))
       (concat "-" tag)))

(setq org-agenda-auto-exclude-function 'bh/org-auto-exclude-function)

(setq org-agenda-clock-consistency-checks
      (quote (:max-duration "4:00"
              :min-duration 0
              :max-gap 0
              :gap-ok-around ("0:05"))))

(setq org-agenda-start-with-clockreport-mode t)

(setq org-agenda-start-with-log-mode t)

;; Agenda log mode items to display (closed and state changes by default)
(setq org-agenda-log-mode-items (quote (closed state)))

;; For tag searches ignore tasks with scheduled and deadline dates
(setq org-agenda-tags-todo-honor-ignore-options t)

(setq org-agenda-span 'day)

;; Limit restriction lock highlighting to the headline only
(setq org-agenda-restriction-lock-highlight-subtree nil)

;; Keep tasks with dates on the global todo lists
(setq org-agenda-todo-ignore-with-date nil)

;; Keep tasks with deadlines on the global todo lists
(setq org-agenda-todo-ignore-deadlines nil)

;; Keep tasks with scheduled dates on the global todo lists
(setq org-agenda-todo-ignore-scheduled nil)

;; Keep tasks with timestamps on the global todo lists
(setq org-agenda-todo-ignore-timestamp nil)

;; Remove completed deadline tasks from the agenda view
(setq org-agenda-skip-deadline-if-done t)

;; Remove completed scheduled tasks from the agenda view
(setq org-agenda-skip-scheduled-if-done t)

;; Remove completed items from search results
(setq org-agenda-skip-timestamp-if-done t)

(setq org-agenda-include-diary t)

(setq org-agenda-include-all-todo t)

(setq org-agenda-diary-file "~/git/org/diary.org")

;; Any time strings in the heading are shown in the agenda
(setq org-agenda-insert-diary-extract-time t)

;; Include agenda archive files when searching for things
(setq org-agenda-text-search-extra-files (quote (agenda-archives)))

;; Show all future entries for repeating tasks
(setq org-agenda-repeating-timestamp-show-all t)

;; Show all agenda dates - even if they are empty
(setq org-agenda-show-all-dates t)

;; Sorting order for tasks on the agenda
(setq org-agenda-sorting-strategy
      (quote ((agenda habit-down time-up user-defined-up effort-up category-keep)
              (todo category-up effort-up)
              (tags category-up effort-up)
              (search category-up))))

;; Start the weekly agenda
(setq org-agenda-start-on-weekday nil)

;; Enable display of the time grid so we can see the marker for the current time
(setq org-agenda-time-grid (quote ((daily today remove-match)
                                   #("----------------" 0 16 (org-heading t))
                                   (0900 1100 1300 1500 1700))))

;; Display tags farther right
(setq org-agenda-tags-column -102)

;; Agenda clock report parameters
(setq org-agenda-clockreport-parameter-plist
      (quote (:link t :maxlevel 5 :fileskip0 t :compact t :narrow 80)))

;; Always highlight the current agenda line
(add-hook 'org-agenda-mode-hook '(lambda () (hl-line-mode 1)) 'append)

;; Use sticky agenda's so they persist
(setq org-agenda-sticky t)

(setq org-src-fontify-natively t)
(setq org-src-tab-acts-natively t)
(setq org-src-preserve-indentation nil)
(setq org-src-fontify-natively t)

(setq org-edit-src-content-indentation 0)

(setq org-catch-invisible-edits 'error)

;;;(setq org-time-clocksum-format
;;;      '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))

(setq org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id)


(defun bh/show-org-agenda ()
  (interactive)
  (if org-agenda-sticky
      (switch-to-buffer "*Org Agenda( )*")
    (switch-to-buffer "*Org Agenda*"))
  (delete-other-windows))

;;
;; Agenda sorting functions
;;
(setq org-agenda-cmp-user-defined 'bh/agenda-sort)

(defun bh/agenda-sort (a b)
  "Sorting strategy for agenda items.
Late deadlines first, then scheduled, then non-late deadlines"
  (let (result num-a num-b)
    (cond
     ;; time specific items are already sorted first by org-agenda-sorting-strategy

     ;; non-deadline and non-scheduled items next
     ((bh/agenda-sort-test 'bh/is-not-scheduled-or-deadline a b))

     ;; deadlines for today next
     ((bh/agenda-sort-test 'bh/is-due-deadline a b))

     ;; late deadlines next
     ((bh/agenda-sort-test-num 'bh/is-late-deadline '> a b))

     ;; scheduled items for today next
     ((bh/agenda-sort-test 'bh/is-scheduled-today a b))

     ;; late scheduled items next
     ((bh/agenda-sort-test-num 'bh/is-scheduled-late '> a b))

     ;; pending deadlines last
     ((bh/agenda-sort-test-num 'bh/is-pending-deadline '< a b))

     ;; finally default to unsorted
     (t (setq result nil)))
    result))

(defmacro bh/agenda-sort-test (fn a b)
  "Test for agenda sort"
  `(cond
    ;; if both match leave them unsorted
    ((and (apply ,fn (list ,a))
          (apply ,fn (list ,b)))
     (setq result nil))
    ;; if a matches put a first
    ((apply ,fn (list ,a))
     (setq result -1))
    ;; otherwise if b matches put b first
    ((apply ,fn (list ,b))
     (setq result 1))
    ;; if none match leave them unsorted
    (t nil)))

(defmacro bh/agenda-sort-test-num (fn compfn a b)
  `(cond
    ((apply ,fn (list ,a))
     (setq num-a (string-to-number (match-string 1 ,a)))
     (if (apply ,fn (list ,b))
         (progn
           (setq num-b (string-to-number (match-string 1 ,b)))
           (setq result (if (apply ,compfn (list num-a num-b))
                            -1
                          1)))
       (setq result -1)))
    ((apply ,fn (list ,b))
     (setq result 1))
    (t nil)))

(defun bh/is-not-scheduled-or-deadline (date-str)
  (and (not (bh/is-deadline date-str))
       (not (bh/is-scheduled date-str))))

(defun bh/is-due-deadline (date-str)
  (string-match "Deadline:" date-str))

(defun bh/is-late-deadline (date-str)
  (string-match "\\([0-9]*\\) d\. ago:" date-str))

(defun bh/is-pending-deadline (date-str)
  (string-match "In \\([^-]*\\)d\.:" date-str))

(defun bh/is-deadline (date-str)
  (or (bh/is-due-deadline date-str)
      (bh/is-late-deadline date-str)
      (bh/is-pending-deadline date-str)))

(defun bh/is-scheduled (date-str)
  (or (bh/is-scheduled-today date-str)
      (bh/is-scheduled-late date-str)))

(defun bh/is-scheduled-today (date-str)
  (string-match "Scheduled:" date-str))

(defun bh/is-scheduled-late (date-str)
  (string-match "Sched\.\\(.*\\)x:" date-str))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END ORG AGENDA  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The following custom-set-faces create the highlights
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-mode-line-clock ((t (:background "grey75" :foreground "red" :box (:line-width -1 :style released-button)))) t))


;; Include current clocking task in clock reports
(setq org-clock-report-include-clocking-task t)

(setq org-stuck-projects (quote ("" nil nil "")))

(defvar bh/hide-scheduled-and-waiting-next-tasks t)

(defun bh/toggle-next-task-display ()
  (interactive)
  (setq bh/hide-scheduled-and-waiting-next-tasks (not bh/hide-scheduled-and-waiting-next-tasks))
  (when  (equal major-mode 'org-agenda-mode)
    (org-agenda-redo))
  (message "%s WAITING and SCHEDULED NEXT Tasks" (if bh/hide-scheduled-and-waiting-next-tasks "Hide" "Show")))

(defun bh/skip-stuck-projects ()
  "Skip trees that are not stuck projects"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                nil
              next-headline)) ; a stuck project, has subtasks but no next task
        nil))))

(defun bh/skip-non-stuck-projects ()
  "Skip trees that are not stuck projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                next-headline
              nil)) ; a stuck project, has subtasks but no next task
        next-headline))))

(defun bh/skip-non-projects ()
  "Skip trees that are not projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (if (save-excursion (bh/skip-non-stuck-projects))
      (save-restriction
        (widen)
        (let ((subtree-end (save-excursion (org-end-of-subtree t))))
          (cond
           ((bh/is-project-p)
            nil)
           ((and (bh/is-project-subtree-p) (not (bh/is-task-p)))
            nil)
           (t
            subtree-end))))
    (save-excursion (org-end-of-subtree t))))

(defun bh/skip-project-trees-and-habits ()
  "Skip trees that are projects"
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-projects-and-habits-and-single-tasks ()
  "Skip trees that are projects, tasks that are habits, single non-project tasks"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((org-is-habit-p)
        next-headline)
       ((and bh/hide-scheduled-and-waiting-next-tasks
             (member "WAITING" (org-get-tags-at)))
        next-headline)
       ((bh/is-project-p)
        next-headline)
       ((and (bh/is-task-p) (not (bh/is-project-subtree-p)))
        next-headline)
       (t
        nil)))))

(defun bh/skip-project-tasks-maybe ()
  "Show tasks related to the current restriction.
When restricted to a project, skip project and sub project tasks, habits, NEXT tasks, and loose tasks.
When not restricted, skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
           (next-headline (save-excursion (or (outline-next-heading) (point-max))))
           (limit-to-project (marker-buffer org-agenda-restrict-begin)))
      (cond
       ((bh/is-project-p)
        next-headline)
       ((org-is-habit-p)
        subtree-end)
       ((and (not limit-to-project)
             (bh/is-project-subtree-p))
        subtree-end)
       ((and limit-to-project
             (bh/is-project-subtree-p)
             (member (org-get-todo-state) (list "NEXT")))
        subtree-end)
       (t
        nil)))))

(defun bh/skip-project-tasks ()
  "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       ((bh/is-project-subtree-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-non-project-tasks ()
  "Show project tasks.
Skip project and sub-project tasks, habits, and loose non-project tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
           (next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((bh/is-project-p)
        next-headline)
       ((org-is-habit-p)
        subtree-end)
       ((and (bh/is-project-subtree-p)
             (member (org-get-todo-state) (list "NEXT")))
        subtree-end)
       ((not (bh/is-project-subtree-p))
        subtree-end)
       (t
        nil)))))

(defun bh/skip-projects-and-habits ()
  "Skip trees that are projects and tasks that are habits"
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-non-subprojects ()
  "Skip trees that are not projects"
  (let ((next-headline (save-excursion (outline-next-heading))))
    (if (bh/is-subproject-p)
        nil
      next-headline)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Org Archiving ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-archive-mark-done nil)
(setq org-archive-location "%s_archive::* Archived Tasks")

(defun bh/skip-non-archivable-tasks ()
  "Skip trees that are not available for archiving"
  (save-restriction
    (widen)
    ;; Consider only tasks with done todo headings as archivable candidates
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
          (subtree-end (save-excursion (org-end-of-subtree t))))
      (if (member (org-get-todo-state) org-todo-keywords-1)
          (if (member (org-get-todo-state) org-done-keywords)
              (let* ((daynr (string-to-int (format-time-string "%d" (current-time))))
                     (a-month-ago (* 60 60 24 (+ daynr 1)))
                     (last-month (format-time-string "%Y-%m-" (time-subtract (current-time) (seconds-to-time a-month-ago))))
                     (this-month (format-time-string "%Y-%m-" (current-time)))
                     (subtree-is-current (save-excursion
                                           (forward-line 1)
                                           (and (< (point) subtree-end)
                                                (re-search-forward (concat last-month "\\|" this-month) subtree-end t)))))
                (if subtree-is-current
                    subtree-end ; Has a date in this month or last month, skip it
                  nil))  ; available to archive
            (or subtree-end (point-max)))
        next-headline))))

(setq org-alphabetical-lists t)

(setq org-list-allow-alphabetical t)

(setq org-return-follows-link t)

(setq org-read-date-prefer-future 'time)

(setq org-list-demote-modify-bullet (quote (("+" . "-")
                                            ("*" . "-")
                                            ("1." . "-")
                                            ("1)" . "-")
                                            ("A)" . "-")
                                            ("B)" . "-")
                                            ("a)" . "-")
                                            ("b)" . "-")
                                            ("A." . "-")
                                            ("B." . "-")
                                            ("a." . "-")
                                            ("b." . "-"))))
(setq org-tags-match-list-sublevels t)

(setq org-agenda-persistent-filter t)

(setq org-agenda-skip-additional-timestamps-same-entry t)

(setq org-file-apps (quote ((auto-mode . emacs)
                            ("\\.mm\\'" . system)
                            ("\\.x?html?\\'" . system)
                            ("\\.pdf\\'" . system))))

;; Overwrite the current window with the agenda
(setq org-cycle-include-plain-lists t)

(setq org-startup-folded t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INDENTING XML  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun bf/pretty-print-xml-region (begin end)
  "Pretty format XML markup in region. You need to have nxml-mode
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this. The function inserts linebreaks to separate tags that have
nothing but whitespace between them. It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
    (nxml-mode)
    (goto-char begin)
    (while (search-forward-regexp "\>[ \\t]*\<" nil t)
      (backward-char) (insert "\n") (setq end (1+ end)))
    (indent-region begin end))
  (message "Ah, much better!"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HELM-SPOTIFY  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helm
(add-to-list 'load-path (expand-file-name "~/git/helm/"))
(require 'helm-config)

;; Multi
;; (add-to-list 'load-path (expand-file-name "~/git/emacs-multi/"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CASK  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;(require 'cask "~/.cask/cask.el")
;;;(cask-initialize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EMACS JABBER  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; adjust this path:
;; (add-to-list 'load-path "~/git/emacs-jabber")

;; For 0.7.90 and above:
(require 'jabber-autoloads)

(setq special-display-regexps
      '(("jabber-chat"
         (width . 80)
         (scroll-bar-width . 16)
         (height . 15)
         (tool-bar-lines . 0)
         (menu-bar-lines 0)
         (font . "-GURSoutline-Courier New-normal-r-normal-normal-11-82-96-96-c-70-iso8859-1")
         (left . 80))))

(setq

 jabber-history-enabled t
 jabber-use-global-history nil
 jabber-backlog-number 40
 jabber-backlog-days 30

 )

(setq jabber-chat-header-line-format
      '(" " (:eval (jabber-jid-displayname jabber-chatting-with))
        " " (:eval (jabber-jid-resource jabber-chatting-with)) "\t";
        (:eval (let ((buddy (jabber-jid-symbol jabber-chatting-with)))
                 (propertize
                  (or
                   (cdr (assoc (get buddy 'show) jabber-presence-strings))
                   (get buddy 'show))
                  'face
                  (or (cdr (assoc (get buddy 'show) jabber-presence-faces))
                      'jabber-roster-user-online))))
        "\t" (:eval (get (jabber-jid-symbol jabber-chatting-with) 'status))
        (:eval (unless (equal "" *jabber-current-show*)
                 (concat "\t You're " *jabber-current-show*
                         " (" *jabber-current-status* ")")))))

;; Don't disturb me if someone chage presence status (usually remote clients make this automatically):
(setq jabber-alert-presence-message-function (lambda (who oldstatus newstatus statustext)
                                               nil))

;; Redefine standard binding for sending message form RET to C-RET
;; (define-key jabber-chat-mode-map (kbd "RET") 'newline)
;; (define-key jabber-chat-mode-map [C-return] 'jabber-chat-buffer-send)

;; (add-hook 'jabber-alert-message-hooks 'jabber-message-xmessage jabber-message-beep)
(add-hook 'jabber-alert-message-hooks 'jabber-message-xmessage)

;; hook which will highlight URLs, and bind C-c RET to open the URL using browse-url:
(add-hook 'jabber-chat-mode-hook 'goto-address)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MAGIT  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'load-path "~/git/git-modes")
(add-to-list 'load-path "~/git/magit")
(eval-after-load 'info
  '(progn (info-initialize)
          (add-to-list 'Info-directory-list "~/git/magit/")))
(require 'magit)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; GNUS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (add-to-list 'load-path "~/git/gnus/elisp/gnus/lisp")
;; (add-to-list 'load-path "~/git/gnus/elisp/gnus/contrib")
;;(load-file "~/github/.emacs.d/.gnus.el")
;;(byte-recompile-directory (expand-file-name "~/git") 0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CUSTOM-SET-VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(doc-view-continuous t)
 '(ediff-window-setup-function (quote ediff-setup-windows-plain))
 '(gnus-home-directory "~/.emacs.d/")
 '(gnus-init-file "~/.emacs.d/.gnus.el")
 '(initial-frame-alist (quote ((fullscreen . maximized)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SISCOG-STUFF ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun x-sc-mark-sexp (click)
  "Moves point to current mouse position. Then marks the S-Expression.
Finaly, blinks at the end of the marked region."
  (interactive "e")
  (mouse-set-point click)
  (let ((mark (sc-mark-sexp nil)))
    (push-mark mark nil t)))

(defvar *last-copy-kill-yank* nil)

(defun x-sc-copy-kill-yank (click)
  "Several actions can be performed. See comments in the code."
  (interactive "e")
  (if mark-active
      (cond ((equal *last-copy-kill-yank* (list (current-buffer) (point) (mark)))
             ;; If it is the second time the text is deleted from the buffer
             (delete-region (point) (mark))
             (setq *last-copy-kill-yank* nil))
            (t
             ;; If it is the first time the marked text is saved to the kill ring
             (copy-region-as-kill (point) (mark))
             (setq *last-copy-kill-yank* (list (current-buffer) (point) (mark)))
             (setq deactivate-mark nil)))
      ;; Otherwise yank the text in the kill ring
      (yank)))

(global-set-key [mouse-2]        'x-sc-mark-sexp)
(global-set-key [double-mouse-2] 'x-sc-mark-sexp)
(global-set-key [triple-mouse-2] 'x-sc-mark-sexp)

(global-set-key [S-mouse-2]      'x-sc-copy-kill-yank)
(global-set-key [mouse-3]        'x-sc-copy-kill-yank)
(global-set-key [double-mouse-3] 'x-sc-copy-kill-yank)
(global-set-key [triple-mouse-3] 'x-sc-copy-kill-yank)
