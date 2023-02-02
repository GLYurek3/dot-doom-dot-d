(map! :leader
      (:prefix ("r" . "registers")
       :desc "Copy to register" "c" #'copy-to-register
       :desc "Frameset to register" "f" #'frameset-to-register
       :desc "Insert contents of register" "i" #'insert-register
       :desc "Jump to register" "j" #'jump-to-register
       :desc "List registers" "l" #'list-registers
       :desc "Number to register" "n" #'number-to-register
       :desc "Interactively choose a register" "r" #'counsel-register
       :desc "View a register" "v" #'view-register
       :desc "Window configuration to register" "w" #'window-configuration-to-register
       :desc "Increment register" "+" #'increment-register
       :desc "Point to register" "SPC" #'point-to-register))

;; https://stackoverflow.com/questions/9547912/emacs-calendar-show-more-than-3-months
(defun dt/year-calendar (&optional year)
  (interactive)
  (require 'calendar)
  (let* (
      (current-year (number-to-string (nth 5 (decode-time (current-time)))))
      (month 0)
      (year (if year year (string-to-number (format-time-string "%Y" (current-time))))))
    (switch-to-buffer (get-buffer-create calendar-buffer))
    (when (not (eq major-mode 'calendar-mode))
      (calendar-mode))
    (setq displayed-month month)
    (setq displayed-year year)
    (setq buffer-read-only nil)
    (erase-buffer)
    ;; horizontal rows
    (dotimes (j 4)
      ;; vertical columns
      (dotimes (i 3)
        (calendar-generate-month
          (setq month (+ month 1))
          year
          ;; indentation / spacing between months
          (+ 5 (* 25 i))))
      (goto-char (point-max))
      (insert (make-string (- 10 (count-lines (point-min) (point-max))) ?\n))
      (widen)
      (goto-char (point-max))
      (narrow-to-region (point-max) (point-max)))
    (widen)
    (goto-char (point-min))
    (setq buffer-read-only t)))

(defun dt/scroll-year-calendar-forward (&optional arg event)
  "Scroll the yearly calendar by year in a forward direction."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     last-nonmenu-event))
  (unless arg (setq arg 0))
  (save-selected-window
    (if (setq event (event-start event)) (select-window (posn-window event)))
    (unless (zerop arg)
      (let* (
              (year (+ displayed-year arg)))
        (dt/year-calendar year)))
    (goto-char (point-min))
    (run-hooks 'calendar-move-hook)))

(defun dt/scroll-year-calendar-backward (&optional arg event)
  "Scroll the yearly calendar by year in a backward direction."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     last-nonmenu-event))
  (dt/scroll-year-calendar-forward (- (or arg 1)) event))

(map! :leader
      :desc "Scroll year calendar backward" "<left>" #'dt/scroll-year-calendar-backward
      :desc "Scroll year calendar forward" "<right>" #'dt/scroll-year-calendar-forward)

(defalias 'year-calendar 'dt/year-calendar)

(setq gc-cons-threshold 50000000)

(setq-default tab-width 4
              ;; tab-always-indent 'complete
              indent-tabs-mode t)

(setq lsp-clangd-binary-path "/nix/store/xwnhwdqck5c5x7xddgj2vcrdjd274b3z-system-path/bin/clangd")

(setq ispell-program-name "aspell")

(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

(setq user-full-name "Gerald Lee Yurek III"
      user-mail-address "g3@yurek.me")

(setq initial-scratch-message "")

(defun remove-scratch-buffer ()
  (if (get-buffer "*scratch*")
      (kill-buffer "*scratch*")))

(add-hook 'after-change-major-mode-hook 'remove-scratch-buffer)

(add-hook 'native-comp-limple-mode-hook 'kill-buffer "*Native-compile-Log*")
(setq-default native-comp-verbose 0)

;;insurance policy
(if (get-buffer "*Native-compile-Log*") (kill-buffer "*Native-compile-Log*"))
(if (get-buffer "*Async-native-compile-log*") (kill-buffer "*Async-native-compile-log*"))

(setq-default message-log-max nil)
;; (kill-buffer "*Messages*")

;;insurance policy
(if (get-buffer "*Messages*") (kill-buffer "*Messages*"))

(setq-default comp-async-report-warnings-errors nil)

(add-hook 'minibuffer-exit-hook
	  '(lambda ()
	     (let ((buffer "*Completions*"))
	       (and (get-buffer buffer)
		    (kill-buffer buffer)))))

(setq inhibit-startup-buffer-menu t)

;; Show only one active window when opening multiple files at the same time.
;; (add-hook 'window-setup-hook 'delete-other-windows)

(defun doom-dashboard-draw-ascii-emacs-banner-fn ()
  "This figlet font is called broadway"
  (let* ((banner
      '("                                                              .         .          "
        "888888888o.          ,o888888o.         ,o888888o.           ,8.       ,8.         "
        "8888    `^888.    . 8888     `88.    . 8888     `88.        ,888.     ,888.        "
        "8888        `88. ,8 8888       `8b  ,8 8888       `8b      .`8888.   .`8888.       "
        "8888         `88 88 8888        `8b 88 8888        `8b    ,8.`8888. ,8.`8888.      "
        "8888          88 88 8888         88 88 8888         88   ,8'8.`8888,8^8.`8888.     "
        "8888          88 88 8888         88 88 8888         88  ,8' `8.`8888' `8.`8888.    "
        "8888         ,88 88 8888        ,8P 88 8888        ,8P ,8'   `8.`88'   `8.`8888.   "
        "8888        ,88' `8 8888       ,8P  `8 8888       ,8P ,8'     `8.`'     `8.`8888.  "
        "8888    ,o88P'    ` 8888     ,88'    ` 8888     ,88' ,8'       `8        `8.`8888. "
        "888888888P'          `8888888P'         `8888888P'  ,8'         `         `8.`8888."
        "   _____________________________________________________________________________   "
        ".o8888888888888888888888888888888888888888888888888888888888888888888888888888888o."
        "                                                                                   "))

     (longest-line (apply #'max (mapcar #'length banner))))
    (put-text-property
     (point)
     (dolist (line banner (point))
       (insert (+doom-dashboard--center
        +doom-dashboard--width
        (concat
         line (make-string (max 0 (- longest-line (length line)))
                   98)))
           "\n"))
     'face 'doom-dashboard-banner)))

(setq +doom-dashboard-ascii-banner-fn #'doom-dashboard-draw-ascii-emacs-banner-fn);)

(custom-set-faces!
  '(doom-dashboard-banner :foreground "#d79921" )
  '(doom-dashboard-footer :foreground "#b16286")
  '(doom-dashboard-footer-icon :foreground "#689d6a")
  '(doom-dashboard-loaded :foreground "#b8bb26")
  '(doom-dashboard-menu-desc :foreground "#83a598" )
  '(doom-dashboard-menu-title  :foreground "#fb4934")
  '(doom-modeline-time :foreground "#458588"))
(setq doom-gruvbox-dark-variant "medium")

(setq doom-font (font-spec :family "Fira Code" :size 14))
(setq doom-unicode-font (font-spec :family "Fira Code" :size 14))

(setq doom-theme 'doom-gruvbox)

(setq display-line-numbers-type t)

(setq doom-modeline-time t
      doom-modeline-height 11
      doom-modeline-buffer-name t
      doom-modeline--battery-status t)
(setq doom-modeline-enable-word-count t
      doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode))
(display-battery-mode)
(setq display-time-day-and-date t)
(display-time-mode)

(setq org-directory "~/org/")

(setq org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-confirm-babel-evaluate nil
      org-edit-src-content-indentation 0)

(setq org-journal-dir "~/org/journal/")

(setq org-journal-file-format "%Y/%m/%d.org")

(map! :leader
      (:prefix ("j" ."Org Journal")
       :desc "new entry in org journal" "n" #'org-journal-new-entry
       :desc "open current journal file" "c" #'org-journal-open-current-journal-file
       ))

(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)

(setq dired-open-extensions '(("gif" . "nsxiv")
			      ("jpg" . "nsxiv")
			      ("png" . "nsxiv")
			      ("mkv" . "mpv")
			      ("mp4" . "mpv")))

(setq ranger-show-hidden "t")

(map! :leader
      (:prefix ("d" . "dired")
       :desc "Open dired" "d" #'dired
       :desc "Dired jump to current" "j" #'dired-jump
       :desc "Dired Ranger" "r" #'ranger
       :desc "Close dired ranger" "qr" #'ranger-close)
      (:after dired
              (:map dired-mode-map
               :desc "Peep-dired image previews" "d p" #'peep-dired
               :desc "Dired view file" "d v" #'dired-view-file)))

(evil-define-key 'normal dired-mode-map
  (kbd "M-RET") 'dired-display-file
  (kbd "h") 'dired-up-directory
  (kbd "l") 'dired-open-file ; use dired-find-file instead of dired-open.
  (kbd "m") 'dired-mark
  (kbd "t") 'dired-toggle-marks
  (kbd "u") 'dired-unmark
  (kbd "C") 'dired-do-copy
  (kbd "D") 'dired-do-delete
  (kbd "J") 'dired-goto-file
  (kbd "M") 'dired-do-chmod
  (kbd "O") 'dired-do-chown
  (kbd "P") 'dired-do-print
  (kbd "R") 'dired-do-rename
  (kbd "T") 'dired-do-touch
  (kbd "Y") 'dired-copy-filenamecopy-filename-as-kill ; copies filename to kill ring.
  (kbd "Z") 'dired-do-compress
  (kbd "+") 'dired-create-directory
  (kbd "-") 'dired-do-kill-lines
  (kbd "% l") 'dired-downcase
  (kbd "% m") 'dired-mark-files-regexp
  (kbd "% u") 'dired-upcase
  (kbd "* %") 'dired-mark-files-regexp
  (kbd "* .") 'dired-mark-extension
  (kbd "* /") 'dired-mark-directories
  (kbd "; d") 'epa-dired-do-decrypt
  (kbd "; e") 'epa-dired-do-encrypt)

(setq inferior-lisp-program "sbcl")

(map! :leader
      (:prefix "o"
       :desc "open the common lisp repl" "l" #'sly))

(setq mail-user-agent 'mu4e-user-agent)

(setq +mu4e-backend 'mbsync)

(setq mu4e-root-maildir "~/Mail/")

(setq mu4e-change-filenames-when-moving t)

(setq mu4e-compose-dont-reply-to-self t)

(setq message-kill-buffer-on-exit t)

(setq mu4e-maildir-shortcuts
	  '( ("/yurek.me/Inbox" . ?i)
	 ("/yurek.me/Archive" . ?a)
	 ("/yurek.me/Drafts" . ?d)
	 ("/yurek.me/Deleted Items" . ?t)
	 ("/yurek.me/Sent Items" . ?s)
	 ;; Throwaway email for mailing lists
	 ;; It would be a horrible idea for me to subscribe to
	 ;; very active mailing lists for development on my
	 ;; domain email, so I will not
	 ("/gmail.com/All Mail" . ?1)
	 ("/gmail.com/Kernel" .?2)
	 ("/gmail.com/Kernel Newbies" . ?3)
	 ("/gmail.com/Emacs" . ?4)
	 ("/gmail.com/Arch" . ?5)
	 ("/gmail.com/Arch Commits" . ?6)
	 ("/gmail.com/Gentoo Dev" . ?7)
	 ("/gmail.com/TLDR" . ?8)
	 ))

(set-email-account! "yurek.me"
		    '((user-mail-address      . "g3@yurek.me")
		      (user-full-name         . "Gerald Lee Yurek III")
		      (smtpmail-smtp-server   . "smtp.office365.com")
		      (smtpmail-smtp-service  . 587)
		      (smtpmail-stream-type   . starttls)
		      (smtpmail-debug-info    . t)
		      (mu4e-drafts-folder     . "/yurek.me/Drafts")
		      (mu4e-refile-folder     . "/yurek.me/Archive")
		      (mu4e-sent-folder       . "/yurek.me/Sent Items")
		      (mu4e-trash-folder      . "/yurek.me/Deleted Items")
		      (mu4e-update-interval   . 1800)
					;(mu4e-sent-messages-behavior . 'delete)
		      )
		    t )

(set-email-account! "gmail.com"
		    '((user-mail-address      . "gly3mb@gmail.com")
		      (user-full-name         . "Gerald Lee Yurek III")
		      (smtpmail-smtp-server   . "smtp.gmail.com")
		      (smtpmail-smtp-service  . 587)
		      (smtpmail-stream-type   . starttls)
		      (smtpmail-debug-info    . t)
		      (mu4e-drafts-folder     . "/gmail.com/Drafts")
		      (mu4e-refile-folder     . "/gmail.com/Archive")
		      (mu4e-sent-folder       . "/gmail.com/Sent")
		      (mu4e-trash-folder      . "/gmail.com/Trash")
		      (mu4e-update-interval   . 1800)
					;(mu4e-sent-messages-behavior . 'delete)
		      )
		    t )

(setq which-key-idle-delay 0.5)

(map! :leader
      (:prefix "o"
       :desc "Open Elpher" "g" #'elpher)
      (:prefix ("e" . "Elpher")
       :desc "Open Elpher" "e" #'elpher
       :desc "Return to the start page" "U" #'elpher-back-to-start
       :desc "Go back" "u" #'elpher-back
       :desc "Download item under cursor" "d" #'elpher-download
       :desc "Download current page" "D" #'elpher-download-current
       :desc "Bookmark current page" "A" #'elpher-bookmark-current
       :desc "Bookmark item under cursor" "a" #'elpher-bookmark-link
       :desc "Bookmark list" "b" #'elpher-show-bookmarks
       ))

;; Enable the www ligature in every possible major mode
;; (setq +ligatures-in-modes '(not comint-mode Info-mode elfeed-search-mode elfeed-show-mode))
;; (ligature-set-ligatures 't '("www"))

;; Enable ligatures in programming modes
(ligature-set-ligatures 't '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\" "{-" "::"
                                     ":::" ":=" "!!" "!=" "!==" "-}" "----" "-->" "->" "->>"
                                     "-<" "-<<" "-~" "#{" "#[" "##" "###" "####" "#(" "#?" "#_"
                                     "#_(" ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*" "/**"
                                     "/=" "/==" "/>" "//" "///" "&&" "||" "||=" "|=" "|>" "^=" "$>"
                                     "++" "+++" "+>" "=:=" "==" "===" "==>" "=>" "=>>" "<="
                                     "=<<" "=/=" ">-" ">=" ">=>" ">>" ">>-" ">>=" ">>>" "<*"
                                     "<*>" "<|" "<|>" "<$" "<$>" "<!--" "<-" "<--" "<->" "<+"
                                     "<+>" "<=" "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<"
                                     "<~" "<~~" "</" "</>" "~@" "~-" "~>" "~~" "~~>" "%%"))
;; (add-to-list 'ligature-composition-table '(("-" . ,() (rx (+ "-") ">"))))





(global-ligature-mode 't)
