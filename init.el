;;__________________________________________________________________________
;;;;    System Customizations

;; Set buffer behaviour
(setq next-line-add-newlines nil)
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
(setq inhibit-startup-message t)        ;no splash screen
(defconst use-backup-dir t)             ;use backup directory
(defconst query-replace-highlight t)    ;highlight during query
(defconst search-highlight t)           ;highlight incremental search
(setq ls-lisp-dirs-first t)             ;display dirs first in dired
(global-font-lock-mode t)               ;colorize all buffers
(setq ecb-tip-of-the-day nil)           ;turn off ECB tips
(recentf-mode 1)                        ;recently edited files in menu

(global-font-lock-mode t)               ;colorize all buffers
(defconst query-replace-highlight t)    ;highlight during query
(defconst search-highlight t)           ;highlight incremental search
(setq ls-lisp-dirs-first t)             ;display dirs first in dired

;;;
;;; Emacs Server Mode
;;;
(server-mode)


;; (load (expand-file-name "~/quicklisp/slime-helper.el"))
;; (setq inferior-lisp-program "sbcl")

;; (eval-after-load "slime"
;;   '(progn
;;      (setq slime-lisp-implementations
;;            '((sbcl ("/usr/bin/sbcl"))
;;              (ecl ("/usr/bin/ecl"))
;;              (clisp ("/usr/bin/clisp"))))
;;      (slime-setup '(
;;                     slime-asdf
;;                     slime-autodoc
;;                     slime-editing-commands
;;                     slime-fancy-inspector
;;                     slime-fontifying-fu
;;                     slime-fuzzy
;;                     slime-indentation
;;                     slime-mdot-fu
;;                     slime-package-fu
;;                     slime-references
;;                     slime-repl
;;                     slime-sbcl-exts
;;                     slime-scratch
;;                     slime-xref-browser
;;                     ))
;;      (slime-autodoc-mode)
;;      (setq slime-complete-symbol*-fancy t)
;;      (setq slime-complete-symbol-function
;;   'slime-fuzzy-complete-symbol)))


;; (require 'slime)
;; (add-hook 'lisp-mode-hook (lambda () (slime-mode t)))
;; (add-hook 'inferior-lisp-mode-hook (lambda () (inferior-slime-mode t)))
;; (slime-setup '(slime-fancy slime-banner))
;; (global-set-key "\C-cs" 'slime-selector)
;; (setq slime-complete-symbol*-fancy t)
;; (setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)

;;(setq slime-lisp-implementations '((sbcl ("sbcl" "--core" "sbcl.core-for-slime"))))

;; Isto destina-se a permitir seleccionar simbolos com '.' no meio quando se carrega
;; o botao do meio do rato
(modify-syntax-entry ?#  "_   " emacs-lisp-mode-syntax-table)
(modify-syntax-entry ?.  "w   " emacs-lisp-mode-syntax-table)
(modify-syntax-entry ?#  "_   " lisp-mode-syntax-table)
(modify-syntax-entry ?.  "w   " lisp-mode-syntax-table)


;; Deactivate tooltips in emacs:

(tooltip-mode 0)

;;(tool-bar-mode 0)
(tool-bar-mode -1)



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

(global-set-key [f11] 'reposition-defun-at-top)

(global-set-key [f12] 'revert-buffer)

;;;
;;; don't make backup files
;;;
(setq make-backup-files nil)

;;;
;;; Frame format
;;;
;(setq frame-title-format '("" (buffer-file-name "%f - ") "Emacs"))
; (setq icon-title-format  '("" (buffer-file-name "%f - ") "Emacs"))
(setq frame-title-format '("%b - Emacs"))
;(setq icon-title-format  '("%b - PauloTomeEmacs"))

;; (w32-send-sys-command ?\xf030)

(defun sc-mark-sexp (arg)
  "Set mark ARG sexps from point."
  (interactive "p")
  (cond ((char-equal (char-after (point)) 41)
	 (goto-char (1+ (point)))
	 (backward-sexp arg)
	 (save-excursion
	   (forward-sexp arg)
	   (point)))
	((char-equal (char-after (point)) 40)
	 (save-excursion
	   (forward-sexp arg)
	   (point)))
	((char-equal (char-after (1- (point))) 41)
	 (backward-sexp arg)
	 (save-excursion
	   (forward-sexp arg)
	   (point)))
	(t (if (not (find (char-after (1- (point))) '(32 40 41) :test '=))
	       (backward-sexp arg))
	   (save-excursion
	     (forward-sexp arg)
	     (point)))))


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

(global-set-key [C-S-mouse-1] 'buffer-menu)

;;;(global-set-key [C-down-mouse-3] 'x-sc-ignore)
(global-set-key [M-mouse-1]      'x-sc-ignore)
(global-set-key [M-drag-mouse-1] 'x-sc-ignore)
(global-set-key [M-down-mouse-1] 'x-sc-ignore)
(global-set-key [M-mouse-3]      'x-sc-ignore)
(global-set-key [M-mouse-2]      'x-sc-ignore)

(define-key global-map "\M-;" 'sc-insert-commas)
(define-key global-map "\M-:" 'sc-delete-commas)

;;;	09/09/23	P. Madeira	`insert-tab' -> `f3-insert-tab'.
;;;	 Use `insert-tab' with `indent-tabs-mode' set to `t'.
(defun f3-insert-tab (&optional arg)
  (interactive)
  (let ((indent-tabs-mode t))
    (insert-tab arg)))

;;;	09/09/23	P. Madeira	`insert-tabs' -> `f4-insert-tabs'.
;;;	 Use `f3-insert-tab' with count of 5.
(defun f4-insert-tabs ()
  (interactive)
  (f3-insert-tab 5))

(defun move-to-next-tab ()
  (interactive)
  (let ((point (+ (point) 1))
	(max (point-max))
	(beep t))
    (while (< point max)
      (if (= (char-after point) 9)
	  (progn
	    (goto-char point)
	    (setq point max)
	    (setq beep nil))
	(setq point (+ point 1))))
    (if beep (beep))))

(global-set-key [f2] 'move-to-next-tab)
;;;	09/09/23	P. Madeira	Use `f3-insert-tab'
(global-set-key [f3] 'f3-insert-tab)
;;;	09/09/23	P. Madeira	Use `f4-insert-tabs'
(global-set-key [f4] 'f4-insert-tabs)

;; Isto e' para manter a marcacao das areas seleccionadas
(transient-mark-mode nil)

;;(load "C:/Users/Paulo/quicklisp/clhs-use-local.el" t)

(setq-default show-trailing-whitespace t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(initial-frame-alist (quote ((fullscreen . maximized))))
 '(scroll-bar-mode (quote left))
 '(tool-bar-mode nil))

;; Hide splash-screen and startup-message
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

;; Switch to full screen at startup

(defun switch-full-screen ()
  (interactive)
  (shell-command (concat "wmctrl -i -r " (frame-parameter nil 'outer-window-id)
			 " -btoggle,maximized_vert,maximized_horz")))

(switch-full-screen)


;; (desktop-save-mode 1)

;; (setq history-length 250)
;; (add-to-list 'desktop-globals-to-save 'file-name-history)


(setq mouse-wheel-progressive-speed nil)

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ENCODING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq org-list-allow-alphabetical t)

