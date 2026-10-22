(setq custom-file
      (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;; bootstraps straight.el without package.el!
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Trying to stop an eglot error with straight.el related to the movement of
;; project.el
(setq straight-built-in-pseudo-packages
      '(project))

(straight-use-package 'use-package)      ; Gets `use-package` using `straight.el`
(setq straight-use-package-by-default t) ; Makes sure that :straight t is included
                                         ; by default in use-package statements.
(setq use-package-compute-statistics t)  ; Turns on startup statsitics

(use-package exec-path-from-shell
  :straight t)
(when (memq system-type '(mac ns x darwin))
  (exec-path-from-shell-initialize))

;; moves backup files to .emacs.d/tmp/backups
(setq backup-directory-alist
      `(("." .
         ,(expand-file-name "tmp/backups/" user-emacs-directory))))

;; auto-saves
(make-directory (expand-file-name "tmp/auto-saves/" user-emacs-directory) t)
(setq auto-save-list-file-prefix
      (expand-file-name "tmp/auto-saves/sessions/" user-emacs-directory)
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "tmp/auto-saves/" user-emacs-directory) t)))

(use-package no-littering)

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config (which-key-mode)
  :custom
  (which-key-idle-delay 0.5))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key))

(use-package pdf-tools
  :defer t)

(use-package page-break-lines
  :init
  (page-break-lines-mode))

(setq inhibit-splash-screen t)    ; No splash screen.
(setq inhibit-startup-message t)  ; No startup message.

(setq frame-title-format "Job Emacs")

(scroll-bar-mode -1)          ; Disable visual scrolbar
(tool-bar-mode -1)            ; Disable the toolbar
(tooltip-mode -1)             ; Disable tooltips
(fringe-mode '(1 . 1))        ; Sets frame to a minimum of one character
(menu-bar-mode  -1)           ; Disable the menu bar

(setq visible-bell t) ; Removes audio bell (might need to change)

(column-number-mode)                 ; Adds column number to mode line
;(global-display-line-numbers-mode t) ; Adds line numbers
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(setopt display-fill-column-indicator-column 80)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		term-mode-hook
                vterm-mode-hook
                dired-mode-hook
                image-mode-hook
                help-mode-hook
                helpful-mode-hook
		shell-mode-hook
                compilation-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq job/current-theme 'modus-vivendi-deuteranopia)

(defun job/frame-startup-theme (frame)
  (with-selected-frame frame
    (when (display-graphic-p)
      (modus-themes-load-theme job/current-theme))))

(use-package modus-themes
  :straight t
  :demand t
  :custom
  (modus-themes-common-palette-overrides
   '((fg-region unspecified)        ;; highlight not change underlying style 
     (fg-paren-match (extrabold)))) ;; matching parenthesis are bolded

  ;; changes the highlighting of completions
  (modus-themes-completions '((matches . (bold))
			      (selection . (extrabold italic))))

  (modus-themes-headings
   '((1 . (1.4))
     (2 . (1.3))
     (3 . (1.2))
     (t . (1.1))))

  ;; adds bold to some syntax elements
  (modus-themes-bold-constructs t)
  (modus-themes-italic-constructs t)
  :config
  (setq modus-themes-common-palette-overrides
        '((fg-heading-1 fg-main)
          (fg-heading-2 blue-faint)
          (fg-heading-3 yellow-faint)))
  (modus-themes-load-theme 'modus-vivendi-deuteranopia)
  (add-hook 'after-make-frame-functions #'job/frame-startup-theme)
  (add-hook 'modus-themes-after-load-theme-hook
            (lambda ()
              (setq job/current-theme (modus-themes-get-current-theme)))))

(use-package auto-dark
  :after modus-themes
  :init
  (setq auto-dark-allow-osascript t)
  (setq auto-dark-themes
        '((modus-vivendi-deuteranopia) (modus-operandi-deuteranopia)))
  (auto-dark-mode)
  :hook
  (auto-dark-dark-mode
   . (lambda ()
       (setq job/current-theme 'modus-vivendi-deuteranopia)
       (modus-themes-load-theme 'modus-vivendi-deuteranopia)))
  (auto-dark-light-mode
   . (lambda ()
       (setq job/current-theme 'modus-operandi-deuteranopia)
       (modus-themes-load-theme 'modus-operandi-deuteranopia))))

(defgroup job-faces nil
  "Job Emacs text cutomization."
  :group 'faces
  :prefix "job-")

(defcustom job-default-font-size 180
  "Default font size for Job Emacs."
  :type '(integer)
  :group 'job-faces)

(defcustom job-default-font-family "Iosevka"
  "Default font family for Job Emacs."
  :type '(string)
  :group 'job-faces)

(defcustom job-fixed-pitch-font-family "Iosevka"
  "Fixed-pitch font family for Job Emacs."
  :type '(string)
  :group 'job-faces)

(defcustom job-variable-pitch-font-family "Iosevka Aile"
  "Variable-pitch font family for Job Emacs."
  :type '(string)
  :group 'job-faces)

(defun job/make-faces ()
  "Makes the faces for job."
  ;; Default font family
  (set-face-attribute 'default nil
                      :family job-default-font-family
                      :height job-default-font-size)

  ;; Fixed-pitch (i.e., mono-spaced)
  (set-face-attribute 'fixed-pitch nil
                      :inherit 'default
		      :family job-fixed-pitch-font-family)

  ;; Variable-pitch (i.e., non-mono-spaced)
  (set-face-attribute 'variable-pitch nil
                      :inherit 'default
		      :family job-variable-pitch-font-family)
  (modus-themes-with-colors
    (custom-set-faces
     `(flymake-error
       ((,c
         :background ,bg-prominent-err
         :underline nil)))
     `(flymake-warning
       ((,c
         :background ,bg-prominent-warning
         :underline nil)))
     `(flymake-note
       ((,c
         :background ,bg-prominent-note
         :underline nil)))
     `(flyspell-incorrect
       ((,c
         :background ,bg-red-subtle
         :underline nil)))
     `(flyspell-duplicate
       ((,c
         :background ,bg-magenta-subtle
         :underline nil))))))

(if (daemonp)
    (add-hook 'server-after-make-frame-hook
	      (lambda (frame)
		(with-selected-frame frame
		  (job/make-faces))))
  (job/make-faces))

(add-hook 'modus-themes-after-load-theme-hook #'job/make-faces)
(set-fontset-font "fontset-default" nil "Symbols Nerd Font" nil 'append)

(use-package dashboard
  :straight t
  :config
  (setq dashboard-startup-banner "~/.emacs.d/job-emacs-logo.txt")
  (setq dashboard-banner-logo-title "Welcome to Job Emacs")
  (setq dashboard-center-content t)
  (setq dashboard-icon-type 'all-the-icons)
  (setq dashboard-startupify-list '(dashboard-insert-banner
                                  dashboard-insert-newline
                                  dashboard-insert-banner-title
                                  dashboard-insert-newline
                                  dashboard-insert-navigator
                                  dashboard-insert-newline
                                  dashboard-insert-init-info
                                  dashboard-insert-items))
  (setq dashboard-items '((agenda    . 5)))
  (setq dashboard-item-shortcuts '((agenda    . "a")))
  (setq dashboard-week-agenda t)
  (dashboard-setup-startup-hook))

(setq doc-view-resolution 300) ;;default resolution in ppi
(defadvice doc-view-display (after fit-width activate)
  (doc-view-fit-width-to-window))

(use-package rainbow-delimiters
  :defer t
  :hook (prog-mode . rainbow-delimiters-mode))

(defun job/modeline-faces (&rest _)
  (modus-themes-with-colors
    (custom-set-faces
     `(mode-line
       ((,c
         :inherit modus-themes-ui-variable-pitch
         :background ,bg-main
         :foreground ,fg-main
         :box (:line-width (2 . 4) :color ,bg-main :style nil))))
     `(mode-line-active
       ((,c
         :inherit mode-line
         :background ,bg-main
         :foreground ,fg-main
         :box (:line-width (2 . 4) :color ,bg-main :style nil))))
     `(mode-line-inactive
       ((,c
         :inherit mode-line
         :background ,bg-main
         :foreground ,fg-dim
         :box (:line-width (2 . 4) :color ,bg-main :style nil)))))))

(add-hook 'modus-themes-after-load-theme-hook #'job/modeline-faces)
(add-hook 'emacs-startup-hook #'job/modeline-faces)

(defun job/doom-modeline-faces (&rest _)
  (modus-themes-with-colors
    (custom-set-faces
     `(doom-modeline-bar
       ((,c
         :inherit modus-themes-ui-variable-pitch
         :background ,bg-main
         :foreground ,fg-main
         :box nil)))
     `(doom-modeline-bar-inactive
       ((,c
         :inherit mode-line
         :background ,bg-main
         :foreground ,fg-dim
         :box nil))))))

(use-package doom-modeline
  :custom
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-project-name t)
  (doom-modeline-display-default-persp-name t)
  (doom-modeline-persp-name t)
  (doom-modeline-persp-icon t)
  (doom-modeline-enable-word-count t)
  (doom-modeline-enable-buffer-position nil)
  (doom-modeline-buffer-file-name-style 'file-name)
  (doom-modeline-time nil)
  (doom-modeline-battery nil)
  :config
  (doom-modeline-remove-segment 'misc-info)
  :init
  (job/modeline-faces)
  (job/doom-modeline-faces)
  (setq doom-modeline-support-imenu t)
  (add-hook 'modus-themes-after-load-theme-hook #'job/doom-modeline-faces)
  (doom-modeline-mode 1))

(defgroup job/header-faces nil
  "Job Emacs header faces."
  :group 'faces
  :prefix "job-")

(defface job/header-battery-charging nil
  "Face for the battery segment while charging")

(defface job/header-battery-critical nil
  "Face for the battery segment while critical")

(defface job/header-battery-warning nil
  "Face for the battery segment while warning")

(defface job/header-battery-normal nil
  "Face for the battery segment while normal")

(defface job/header-battery-full nil
  "Face for the battery segment while full")

(defface job/header-icon nil
  "Face for job icon in header bar")

(defface job/header-frame-name nil
  "Face for frame name in header bar")

(defface job/header-time nil
  "Face for time in header bar")

(defun job/tab-bar-faces (&rest _)
  (modus-themes-with-colors
    (custom-set-faces
     `(tab-bar
       ((,c
         :inherit modus-themes-ui-variable-pitch
         :background ,bg-main
         :foreground ,fg-main
         :underline (:color ,fg-main :position t)
         :box (:line-width (2 . 4) :color ,bg-main :style nil))))
     `(job/header-battery-charging
       ((,c
         :inherit tab-bar
         :foreground ,green-intense)))
     `(job/header-battery-critical
       ((,c
         :inherit tab-bar
         :foreground ,red-intense)))
     `(job/header-battery-warning
       ((,c
         :inherit tab-bar
         :foreground ,yellow-intense)))
     `(job/header-battery-normal
       ((,c
         :inherit tab-bar)))
     `(job/header-battery-full
       ((,c
         :inherit tab-bar
         :foreground ,blue-intense)))
     `(job/header-icon
       ((,c
         :inherit tab-bar
         :foreground ,magenta-warmer)))
     `(job/header-frame-name
       ((,c
         :inherit tab-bar
         :bold t)))
     `(job/header-time
       ((,c
         :inherit tab-bar
         :foreground ,fg-dim)))
     )))
(add-hook 'modus-themes-after-load-theme-hook #'job/tab-bar-faces)

;; Frame title tab-bar header segement
(setq-default global-frame-string '("" (:eval
                                        (frame-title))))
(defun frame-title ()
  (let* ((title (cdr (assoc 'name (frame-parameters)))))
    (if (equal title "") "" title)))
(defun tab-bar-format-frame-title ()
  (mapcar (lambda (string)
            `(global menu-item
                     ,(format-mode-line string 'job/header-frame-name) ignore))
          global-frame-string))

;; Time segment for tab-bar header
(setq-default global-time-string '("" (:eval display-time-string)))
(defun tab-bar-format-time ()
  (mapcar (lambda (string)
            `(global menu-item
                     ,(format-mode-line string 'job/header-time) ignore))
          global-time-string))
(setq display-time-format "%a %b %d %T")
(setq display-time-24hr-format t)
(setq display-time-interval 1)
(setq display-time-default-load-average nil)
(display-time-mode)

(setq-default global-persp-string '("" (:eval (persp-mode-line))))
(defun tab-bar-format-persp ()
  (mapcar (lambda (string)
            `(global menu-item ,(format-mode-line string) ignore))
          global-persp-string))

(setq-default global-space-string '("" " "))
(defun tab-bar-format-space ()
  (mapcar (lambda (string)
            `(global menu-item ,(format-mode-line string) ignore))
          global-space-string))

(setq-default global-job-icon '("" "ⓙ "))
(defun tab-bar-format-job-icon ()
  (mapcar (lambda (string)
            `(global menu-item ,(format-mode-line string 'job/header-icon) ignore))
          global-job-icon))

(defun get-battery-status ()
  (let*
      ((data (and battery-status-function
                  (funcall battery-status-function)))
       (status (cdr (assoc ?L data)))
       (charging? (or (string= "AC" status)
                      (string= "on-line" status)))
       (percentage
        (car (read-from-string (or (cdr (assq ?p data)) "ERR"))))
       (icon (cond ((<= percentage 10) (if charging? "󰢜" "󰁺"))
                   ((<= percentage 20) (if charging? "󰂆" "󰁻"))
                   ((<= percentage 30) (if charging? "󰂇" "󰁼"))
                   ((<= percentage 40) (if charging? "󰂈" "󰁽"))
                   ((<= percentage 50) (if charging? "󰢝" "󰁾"))
                   ((<= percentage 60) (if charging? "󰂉" "󰁿"))
                   ((<= percentage 70) (if charging? "󰢞" "󰂀"))
                   ((<= percentage 80) (if charging? "󰂊" "󰂁"))
                   ((<= percentage 90) (if charging? "󰂋" "󰂂"))
                   (t (if charging? "󰂅" "󰁹"))))
       (face (cond (charging? 'job/header-battery-charging)
                   ((< percentage battery-load-critical)
                    'job/header-battery-critical)
                   ((< percentage 25) 'job/header-battery-warning)
                   ((< percentage 95) 'job/header-battery-normal)
                   (t 'job/header-battery-full))))
    (format-mode-line
     (format "%s " icon)
     face)))

(setq-default global-battery-string
              '(""
                (:eval (get-battery-status))))
(defun tab-bar-format-battery-string ()
  (mapcar (lambda (string)
            `(global menu-item ,(format-mode-line string) ignore))
          global-battery-string))
(display-battery-mode)

(setf tab-bar-format '())
(add-to-list 'tab-bar-format 'tab-bar-format-job-icon 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-frame-title 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-space 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-persp 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-battery-string 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-space 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-time 'append)
(tab-bar-mode)

(defun job/beacon-color (&rest _)
  (modus-themes-with-colors
      (setq beacon-color cursor)))

(use-package beacon
  :init
  (beacon-mode 1)
  :config
  (add-hook 'modus-themes-after-load-theme-hook #'job/beacon-color)
  (job/beacon-color))

(setq scroll-conservatively 0
      scroll-margin 0)

(window-divider-mode)

(defun job/window-divider-faces (&rest _)
  (customize-set-variable 'window-divider-default-places t)
  (customize-set-variable 'window-divider-default-right-width 1)
  (customize-set-variable 'window-divider-default-bottom-width 1) 
  (modus-themes-with-colors
    (custom-set-faces
     `(window-divider
       ((,c
        :inherit default
         :background ,fg-dim
         :foreground ,fg-dim
         :box nil))))))

(job/window-divider-faces)
(add-hook 'window-divider-mode-hook #'job/window-divider-faces)
(add-hook 'modus-themes-after-load-theme-hook #'job/window-divider-faces)
;; magit commit eats window-dividers for whatever reason.
(add-hook 'magit-post-commit-hook #'job/window-divider-faces)
(add-hook 'magit-diff-mode-hook #'job/window-divider-faces)

(use-package all-the-icons)
(use-package nerd-icons)

(setq custom-tab-width 4)
(setq tab-width custom-tab-width)

(defun disable-tabs () (setq indent-tabs-mode nil))
(defun enable-tabs ()
       (local-set-key (kbd "TAB") 'tab-to-tab-stop)
       (setq indent-tabs-mode t)
       (setq tab-width custom-tab-width))

(add-hook 'prog-mode-hook 'disable-tabs)
(add-hook 'makefile-mode-hook 'enable-tabs)
(add-hook 'gdscript-mode-hook 'enable-tabs)

(setq-default electric-indent-inhibit t)
(setq backward-delete-char-untabify-method 'hungry)

(electric-pair-mode 1)

;; Region wraps
(with-eval-after-load 'evil
  (evil-define-key 'visual 'electric-pair-mode-map
    (kbd "C-{") 'insert-pair)
  (evil-define-key 'visual 'electric-pair-mode-map
    (kbd "C-<") 'insert-pair)
  (evil-define-key 'visual 'electric-pair-mode-map
    (kbd "C-(") 'insert-pair)
  (evil-define-key 'visual 'electric-pair-mode-map
    (kbd "C-\"") 'insert-pair)
  (evil-define-key 'visual 'electric-pair-mode-map
    (kbd "M-[") 'insert-pair))

; changes default behavior on what emacs does when displaying windows
(customize-set-variable 'display-buffer-base-action
  '((display-buffer-reuse-window display-buffer-same-window)
    (reusable-frames . t)))

(customize-set-variable 'even-window-sizes nil) ; avoid resizing

(use-package flyspell
  :defer t
  :hook
  ('text-mode-hook . 'flyspell-mode)
  ('prog-mode-hook . 'flyspell-prog-mode)
  :custom 
  (ispell-extra-args '("--lang=en_US")))

(use-package yasnippet
  :straight t
  :hook ((text-mode
          prog-mode
          conf-mode
          snippet-mode) . yas-minor-mode-on))

;; Sample Snippets
(use-package yasnippet-snippets
  :after yasnippet)

(use-package general
  :after evil
  :config
  (general-evil-setup t)
  (general-create-definer job/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")
  (general-create-definer job/org-roam-leader
    :keymaps '(normal insert visual emacs)
    :prefix "s-r"))

(defun job/evil-hook ()
  (dolist (mode '(custom-mode
		  eshell-mode
		  git-rebase-mode
		  erc-mode
		  circe-server-mode
		  circe-chat-mode
		  circe-query-mode
		  sauron-mode
		  term-mode))
    (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil
  :demand t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-wanat-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :straight t
  :config
  ;; Makes sure I can use RET key to submit commands in modes like eshell
  ;; and vterm, etc.
  (setq evil-collection-repl-submit-state 'insert)
  (evil-collection-init))

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(job/leader-keys
  "st" '(hydra-text-scale/body :which-key "scale text"))

(use-package vertico
  :bind (:map vertico-map
	      ("C-j" . 'vertico-next)
	      ("C-k" . 'vertico-previous))
  :custom
  (vertico-resize nil)             ;; Grow and shrink the Vertico mini-buffer
  (vertico-cycle t)                ;; Enable cycling for `vertico-next/previous`
  (context-menu-mode t)
  ;;(enable-recursive-minibuffers t) ;; Allow for minibuffers in existing minibuffers
  :init
  (vertico-mode))

;; Persist history over Emacs restarts.
(use-package savehist
  :init
  (savehist-mode))

(setq job/previous-frame-name nil)

(defun job/posframe-set-name ()
  (setq job/previous-frame-name (frame-title))
  (set-frame-name "*MINIBUFFER*"))

(defun job/posframe-unset-name ()
  (set-frame-name job/previous-frame-name))

;; Make minibuffer appear at center of screen
(use-package vertico-posframe
  :after vertico
  :config
  (add-hook 'minibuffer-setup-hook 'job/posframe-set-name)
  (add-hook 'minibuffer-exit-hook 'job/posframe-unset-name)
  :init
  (vertico-posframe-mode 1))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package all-the-icons-completion
  :after (marginalia all-the-icons)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substringing

(use-package consult)

(job/leader-keys
  "b" '(consult-buffer :which-key "consult buffer"))

(use-package embark
  :bind
  (("C-." . embark-act)
   ("M-." . emabrk-dwim)
   ("C-h B" . embark-bindings))
  :custom
  (embark-quit-after-action nil)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))

  )

;; Consult with Embark
(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(job/leader-keys
  "a" '(embark-act :which-key "embark act"))

(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-quit-at-boundary nil)
  (corfu-quit-no-match nil)
  :bind (("C-/" . completion-at-point)
	 :map corfu-map
         ("C-j" . corfu-next)
         ("C-k" . corfu-previous))
  :init
  (global-corfu-mode)
  (corfu-history-mode))

(defun job/org-faces ()
  (set-face-attribute 'org-todo nil :height 0.7)
  (set-face-attribute 'org-done nil :height 0.7)
  (set-face-attribute 'org-headline-done nil :foreground 'unspecified)
  (set-face-attribute 'org-tag nil :height 0.7)
  (set-face-attribute 'org-priority nil :height 0.7)
  (set-face-attribute 'org-block-begin-line nil :height 0.7)
  (set-face-attribute 'org-drawer nil :inherit '(fixed-pitch default))
  (set-face-attribute 'org-block-end-line nil :height 0.7)
  (modus-themes-with-colors
    (set-face-attribute 'org-hide nil :foreground bg-main :background bg-main))

    (set-face-attribute 'org-block nil
		      :foreground 'unspecified :inherit '(fixed-pitch default))
  (set-face-attribute 'org-code nil :inherit '(shadow fixed-pitch default))
  (set-face-attribute 'org-verbatim nil
		      :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil
		      :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil
		      :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-formula nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-document-info-keyword nil
		      :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-document-title nil
		      :weight 'bold :height 1.8)
  (require 'org-indent)
  (set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
  (require 'org-faces)
  (set-face-attribute 'org-latex-and-related nil :inherit 'fixed-pitch)
  (setq org-todo-keyword-faces
        '(("PROGRESS" . (:inherit (warning org-todo)))
          ("WAITING" . (:inherit (shadow org-todo))))))

(defun job/org-mode-setup ()
  (org-indent-mode 1)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (setq evil-auto-indent nil))

(use-package org
  :hook ((org-mode . job/org-mode-setup)
         (org-mode . org-fold-hide-drawer-all)
         ;; inhibits the auto pairing of '<' characters
         (org-mode . (lambda () 
                       (setq-local electric-pair-inhibit-predicate
				   '(lambda (c)
				      (if (char-equal c 60) t nil))))))
  :custom
  ;; Basic
  (undo-limit 50000)                   ;; lower undo-limit for performance
  (org-list-allow-alphabetical 1)      ;; allow alphabetical lists
  (org-startup-with-inline-images 1)   ;; show images on startup
  (org-hide-emphasis-markers t)        ;; hide the emphasis markers
  (org-hide-leading-stars t)           ;; hide the leading stars of heading
  (org-ellipsis " ")                   ;; folded indicator
  (org-pretty-entities t)              ;; utf8 characters in entities
  (org-startup-folded 'showall)           ;; start with evertyhing folded 
  (org-fold-catch-invisible-edits 'show-and-error)
  (org-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)

  ;; src blocks
  (org-edit-src-content-indentation 0)    ;; no spaces at start of src block
  (org-src-fontify-natively t)            ;; use native fonts
  (org-src-tab-acts-natively t)           ;; take tab back
  (org-latex-src-block-backend 'engraved) ;; typesetting src blocks latex

  ;; Links
  (org-link-file-path-type 'absolute)

  ;; Task
  (org-log-done 'time)      ;; log time when done with a task
  (org-log-into-drawer t)   ;; log into a drawer so I can hide it
  (org-lowest-priority ?C)  ;; lowest prioirty for task is C
  (org-default-priority ?B) ;; default priority is B
  (org-todo-keywords        ;; adds different todo keywords
   '((sequence
      "TODO(t)" "PROGRESS(p)" "WAITING(w)"
      "|"
      "DONE(d)")))
  (org-priority-faces
   '((?A . (:inherit (bold org-priority)))
     (?B . (:inherit (org-priority)))
     (?C . (:inherit (shadow org-priority)))))

  ;; Tags
  (org-tags-column 0)     ;; put tags right after header
  (org-auto-align-tags 1) ;; align tags automatically
  (org-tag-alist '(("idea" . ?i)
		   ("research" . ?r)
                   (:startgroup . nil)
                   ("personal" . ?p)
                   ("work" . ?w)
                   (:endgroup . nil)))

  ;; Org Agenda
  (org-agenda-start-with-log-mode t) ;; start agenda in log mode
  (org-agenda-files                  ;; where to find agenda files
   '("~/orgfiles/refile.org"
     "~/orgfiles/ideas.org"
     "~/orgfiles/work.org"
     "~/orgfiles/personal.org"))
  (org-agenda-start-on-weekday 0)    ;; start on sunday
  (org-agenda-window-setup 'current-window)

  ;; LaTeX
  (org-latex-compiler "lualatex")   ;; use lualatex to export
  (org-highlight-latex-and-related  ;; latex hl
   '(native latex script entities))
  
  ;; Capture
  (org-refile-targets
   '((org-agenda-files . (:level 1))))
  (org-refile-use-outline-path 'file)
  (org-capture-templates
   '(("t" "Tasks")
     ("tt" "Task" entry (file "~/orgfiles/refile.org")
      "* TODO %?\n %U\n %i" :empty-lines 1)
     ("tw" "Work Task" entry (file "~/orgfiles/work.org")
      "* TODO %? :work:\n %U\n %i" :empty-lines 1)
     ("tp" "Personal Task" entry (file "~/orgfiles/personal.org")
      "* TODO %? :personal:\n %U\n %i" :empty-lines 1)
     ("tr" "Research Task" entry (file "~/orgfiles/research.org")
      "* TODO %? :research:\n %U\n %i" :empty-lines 1)
     ("i" "Idea")
     ("ii" "Idea" entry (file "~/orgfiles/ideas.org")
      "* TODO %? :idea:\n %U\n %i" :empty-lines 1)
     ("ir" "Research Idea" entry (file "~/orgfiles/research.org")
      "* TODO %? :research:idea:\n %U\n %i" :empty-lines 1)))
  
  :config
  (job/org-faces)
  (add-hook 'modus-themes-after-load-theme-hook #'job/org-faces)
  (add-hook 'org-mode-hook 'org-link-preview-refresh)
  ;; Adds ids to top of org files
  (add-hook 'before-save-hook (lambda ()
                                (when (string-equal major-mode "org-mode")
                                  (let ((opt  (point-marker)))
                                    (goto-char (point-min))
                                    (org-id-get-create)
                                    (goto-char opt)))))
  (add-to-list 'org-link-frame-setup '(file . find-file))
  (require 'ox)
  (add-to-list 'org-latex-classes
               '("extarticle" "\\documentclass{extarticle}"
		 ("\\section{%s}" . "\\section*{%s}")
		 ("\\subsection{%s}" . "\\subsection*{%s}")
		 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
		 ("\\paragraph{%s}" . "\\paragraph*{%s}")
		 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
  (setq org-image-actual-width nil)
  (setq org-latex-pdf-process '("latexmk -f -pdf -%latex -interaction=nonstopmode -shell-escape -output-directory=%o %f"))
  (with-eval-after-load 'ox-html
    (setq org-html-htmlize-output-type nil)))

(use-package evil-org
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package org-appear
  :after org
  :straight '(org-appear :type git :host github :repo "awth13/org-appear")
  :init
  :config
  (setq org-appear-trigger 'manual)
  (setq org-appear-autolinks t)
  (add-hook 'org-mode-hook 'org-appear-mode)
  (add-hook 'org-mode-hook (lambda ()
                             (add-hook 'evil-insert-state-entry-hook
                                       #'org-appear-manual-start
                                       nil
                                       t)
                             (add-hook 'evil-insert-state-exit-hook
                                       #'org-appear-manual-stop
                                       nil
                                       t))))

(use-package citar
  :custom
  (org-cite-global-bibliography '("~/orgfiles/Refs/Orged.bib"
                                  "~/Documents/cv/content/me.bib"))
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (citar-bibliography org-cite-global-bibliography)
  (citar-notes-paths '("~/orgfiles/refs/notes/"))
  :hook
  (LaTeX-mode . citar-capf-setup)
  (org-mode . citar-capf-setup)
  :config
  (defvar citar-indicator-files-icons
    (citar-indicator-create
     :symbol (all-the-icons-faicon
              "file-o"
              :face 'all-the-icons-green
              :v-adjust -0.1)
     :function #'citar-has-files
     :padding "  " ; need this because the default padding is too low for these icons
     :tag "has:files"))

  (defvar citar-indicator-links-icons
    (citar-indicator-create
     :symbol (all-the-icons-octicon
              "link"
              :face 'all-the-icons-orange
              :v-adjust 0.01)
     :function #'citar-has-links
     :padding "  "
     :tag "has:links"))

  (defvar citar-indicator-notes-icons
    (citar-indicator-create
     :symbol (all-the-icons-material
              "speaker_notes"
              :face 'all-the-icons-blue
              :v-adjust -0.3)
     :function #'citar-has-notes
     :padding "  "
     :tag "has:notes"))

  (defvar citar-indicator-cited-icons
    (citar-indicator-create
     :symbol (all-the-icons-faicon
              "circle-o"
              :face 'all-the-icons-green)
     :function #'citar-is-cited
     :padding "  "
     :tag "is:cited"))

  (setq citar-indicators
        (list citar-indicator-files-icons
              citar-indicator-links-icons
              citar-indicator-notes-icons
              citar-indicator-cited-icons)))

(use-package citar-embark
  :after (citar embark)
  :no-require
  :config (citar-embark-mode))

;; Center org 80 character line in buffer
;;(defun job/org-mode-visual-fill ()
;;  (setq visual-fill-column-width 80 
;;        visual-fill-column-center-text t)
;;  (visual-fill-column-mode 1))
;;(use-package visual-fill-column
;;  :hook ((org-mode . job/org-mode-visual-fill)))

(with-eval-after-load 'org
  (require 'org-tempo)

  ;; Added one at a time
  (add-to-list 'org-structure-template-alist
               '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist
               '("jv" . "src java"))
  (tempo-define-template "transclude"
                         '("#+transclude: " p >)
                         "<t"
                         "Insert a transclude"))

(use-package engrave-faces
  :after org)

(with-eval-after-load 'org
  (setq org-src-preserve-indentation t)
  (setq org-babel-lilypond-ly-command "/usr/local/bin/lilypond")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (java . t)
     (latex . t)
     (python . t)
     (makefile . t)
     (lilypond . t)
     (shell . t)
     (C . t)))
  (add-hook 'org-babel-tangle-finished-hook 'org-link-preview-refresh)
  (setq org-babel-lilypond-ly-command "/usr/local/bin/lilypond")
  (setq org-confirm-babel-evaluate nil)
  (setq org-babel-python-command "python3"))

;; Automatically tangle our emacs.org config file when you save it
(defun job/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
		      (expand-file-name "~/.emacs.d/emacs.org"))
  ;; Dyanamic scoping to the resuce
  (let ((org-confirm-babel-evaluate nil))
    (org-babel-tangle))))

;; Set hook to try to run above function on orgmode save
(add-hook 'org-mode-hook
    (lambda ()
      (add-hook 'after-save-hook
		#'job/org-babel-tangle-config)))

(use-package org-auto-tangle
  :defer t
  :after org
  :hook (org-src-mode . org-auto-tangle-mode))

(use-package hide-mode-line
  :after org-present)

(defun job/org-present-start ()
  (org-present-big)
  (org-link-preview-refresh)
  (visual-fill-column-mode 1)
  (visual-line-mode 1)
  (blink-cursor-mode -1)
  (hide-mode-line-mode 1)
  (tab-bar-mode -1)
  (beacon-mode -1)
  (evil-normal-state))

(defun job/org-present-end ()
  (org-present-small)
  (visual-fill-column-mode 1)
  (visual-line-mode 1)
  (blink-cursor-mode 1)
  (hide-mode-line-mode -1)
  (beacon-mode 1)
  (tab-bar-mode 1)
  (evil-normal-state))

(use-package org-present
  :commands (org-present)
  :config
  (setq org-present-text-scale 4)
  (add-hook 'org-present-mode-hook 'job/org-present-start)
  (add-hook 'org-present-mode-quit-hook 'job/org-present-end))

(with-eval-after-load 'org-transclusion
  (add-to-list 'org-transclusion-extensions 'org-transclusion-indent-mode)
  (require 'org-transclusion-indent-mode))

(use-package org-transclusion
  :after org
  :config
  (setq org-transclusion-exclude-elements
        '(keyword property-drawer))
  (add-hook 'org-transclusion-mode 'org-transclusion-indent-mode))


(job/leader-keys
  "ci"  '(org-cite-insert :which-key "insert citation")
  "coo" '(citar-open :which-key "citar open")
  "cop" '(citar-open-files :which-key "citar pdf at point")
  "con" '(citar-open-note :which-key "citar notes at point"))

(job/leader-keys
  "oa" '(org-agenda :which-key "org agenda")
  "oc" '(org-capture :which-key "org capture")
  "ohn" '(org-add-note :which-key "org-add-note under heading")
  "ot" '(org-todo :which-key "set todo state")
  "ol" '(org-insert-link :which-key "adds an org link")
  "oi" '(org-link-preview-refresh :which-key "redisplay images"))

(use-package org-roam
  :after org
  :config
  (setq org-roam-directory (file-truename "~/orgfiles"))
  (setq org-roam-capture-templates '(("d" "default" plain
                                      "%?"
                                      :target
                                      (file+head
                                       "%<%Y%m%d%H%M%S>-${slug}.org"
                                       "#+title: ${note-title}\n")
                                      :unnarrowed t)
                                     ("r" "references note" plain
                                      "%?"
                                      :target
                                      (file+head
                                       "%(expand-file-name (or citar-org-roam-subdir \"\") org-roam-directory)/${citar-citekey}.org"
                                       "#+title: ${citar-citekey} (${citar-date}). ${note-title}.\n#+created: %U\n#+filetags: :refnotes:\n\n")
                                      :unnarrowed t)))
  (require 'org-roam-export)
  :init
  (org-roam-db-autosync-mode))

(use-package citar-org-roam
  :after (citar org-roam)
  :config
  (setq citar-org-roam-capture-template-key "r")
  (setq citar-org-roam-subdir "~/orgfiles/refs/notes/")
  (citar-org-roam-mode))

(job/org-roam-leader
  "f" '(org-roam-node-find :which-key "org-roam-node-find")
  "i" '(org-roam-node-insert :which-key "org-roam-node-insert")
  "c" '(org-id-get-create :which-key "org-id-get-create"))

(use-package project)

(defun job/persp-name-color (&rest _)
  (modus-themes-with-colors
    (set-face-attribute 'persp-selected-face nil
                      :weight 'bold
                      :foreground fg-mark-select)))

(use-package perspective
  :demand t
  :straight t
  :custom
  ((persp-mode-prefix-key (kbd "s-o"))
   (persp-state-default-file "~/.emacs.d/perspectives/default-perspective-save"))
  :init
  (persp-mode)
  :config
  ;; Adds consult support to perspective.el
  (with-eval-after-load 'consult
    (consult-customize consult-source-buffer :hidden t :default nil)
    (add-to-list 'consult-buffer-sources persp-consult-source))
  (job/persp-name-color)
  (add-hook 'modus-themes-after-load-theme-hook #'job/persp-name-color))

;; Perspective embark config
(with-eval-after-load 'embark
  (add-to-list 'marginalia-prompt-categories '("Perspective name" . persp))
  (defvar-keymap embark-perspective-actions
    :doc "Keymap for actions for perspective.el"
    :parent embark-general-map
    "k" #'persp-kill)
  (push #'embark--confirm
        (alist-get 'persp-kill
                   embark-pre-action-hooks))
  (add-to-list 'embark-keymap-alist '(persp . embark-perspective-actions)))

;; Keeping incase I want to bring back this option, but projects are now by defaul
;; stored in a single frame with perspectives
(defun job/make-persp-after-project-switch ()
  "Switches to a clean perspective after opening a project with Projectile."
  (let ((dest-buffer (current-buffer)))
    (persp-switch (projectile-project-name))
    (dolist (buffer (projectile-project-buffer-names))
      (persp-set-buffer buffer))
    (switch-to-buffer dest-buffer)))

(use-package projectile
  :demand t
  :diminish projectile-mode
  :config (projectile-mode +1)
  :init
  ;(add-hook 'projectile-after-switch-project-hook
  ;          #'job/make-persp-after-project-switch)
  :custom (;(projectile-switch-project-action 'job/switch-project-action)
           (projectile-switch-project-action (lambda () ))
	   (projectile-project-search-path '("~/.emacs.d/"))
	   (projectile-auto-cleanup-known-projects t)
	   (projectile-track-known-projects-automatically nil))
  :bind-keymap
  ("s-p" . projectile-command-map))

(defun job/agenda-for-project ()
  (interactive)
  (let* ((project-name (projectile-project-name))
	 (project-root (projectile-project-root))
	 (org-agenda-files (list (concat project-root "project.org"))))
    (org-agenda)))

(define-key projectile-command-map (kbd "a") #'job/agenda-for-project)

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(job/leader-keys
  "gs" '(magit-status :which-key "opens magit status"))

(defun job/aw-leading-char-face (&rest _)
  (modus-themes-with-colors
    (set-face-attribute 'aw-leading-char-face nil
		      :weight 'bold
		      :foreground cursor 
		      :height 3.0)))

(use-package ace-window
  :after modus-themes
  :custom
  ((aw-keys '(?a ?s ?d ?f ?g ?j ?k ?l))
   (aw-dispatch-always t)
   (aw-scope 'frame))
  :config
  (setq aw-dispatch-alist '((?x aw-delete-window "Delete Window")
			    (?c aw-split-window-fair "Split Fair Window")
                            (?v aw-split-window-horz "Split Vert Window")
			    (?h aw-split-window-vert "Split Horz Window")
			    (?m aw-swap-window "Swap Window")
			    (?M aw-move-window "Move Window")
			    (?o delete-other-windows "Delete Other Windows")
			    (?p aw-flip-window)
			    (?? aw-show-dispatch-help)))
  (job/aw-leading-char-face)
  (add-hook 'modus-themes-after-load-theme-hook #'job/aw-leading-char-face) 
  (job/leader-keys
    "SPC" '(ace-window :which-key "start ace-window")
    "C-SPC" '(ace-window :which-key "start ace-window")))


(defun job/make-frame-with-name (name)
  (interactive
   (let* ((default "frame")
          (input (read-string (format-prompt "Select Frame" default))))
     (if (= (length input) 0)
         (list default)
       (list input))))
  (message name)
  (dolist (frame (frame-list))
    (when (equal (frame-parameter frame 'name) name)
      (error "There is already a frame named `%s'" name)))
  (with-selected-frame (make-frame)
    (set-frame-name name)))

(define-key global-map (kbd "s-n") 'job/make-frame-with-name)
(define-key global-map (kbd "s-b") 'select-frame-by-name)

;; Switches to a project based on frames instead of perspectives
;; TODO Load perpective from project-perspective-alist on setup
(defcustom job/project-startup-alist
  '(("~/.emacs.d/" .
     (lambda ()
       (find-file "~/.emacs.d/emacs.org")
       (split-window-right)
       (other-window 1)
       (vterm)
       (rename-uniquely)
       (other-window 1)))
    ("~/Projects/rpc/rpc/" .
     (lambda ()
       (dired "~/Projects/rpc/rpc")
       (require 'gdscript-mode)
       (gdscript-godot-open-project-in-editor))))
  "Startup function by project as an association list")

(defun job/project-switch (&optional arg)
  "Switches to a new frame and starts the project with its own perspectives"
  (interactive "P")
  (let ((projects (projectile-relevant-known-projects)))
    (if projects
        (projectile-completing-read
         "Switch to project: " projects
         :action (lambda (project)
                   (let* ((name (projectile-project-name project)))
                     (catch 'done
                       (dolist (frame (frame-list))
                         (when (equal (frame-parameter frame 'name) name)
                           (select-frame-by-name name)
                           (throw 'done nil)))
                       (job/setup-project-frame project))))
         :caller 'projectile-read-project)
      (user-error "There are no known projects"))))

(with-eval-after-load 'projectile
  (define-key projectile-command-map (kbd "p") #'job/project-switch))

(defun job/switch-project-action (project)
  (let* ((root (abbreviate-file-name (projectile-acquire-root project)))
         (function (cdr (assoc root job/project-startup-alist))))
    (if function 
        (funcall function)
      (dired (projectile-acquire-root project)))))

(defun job/setup-project-frame (project)
  "Creates a new frame, selects the frame, asks for a project, setsup project"
  (let* ((buffer (switch-to-buffer-other-frame (get-scratch-buffer-create)))
         (frame (selected-frame))
         (name (projectile-project-name project)))
    (message project)
    (with-selected-frame frame
      (persp-init-frame frame)
      (projectile-switch-project-by-name project)
      (set-frame-name name)
      (job/switch-project-action project))))


(use-package dired
  :demand t
  :straight nil
  :commands (dired dired-jump)
  :hook
  (dired-mode . dired-hide-details-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file)
  (let ((gls (executable-find "gls")))
    (when gls
      (setq insert-directory-program gls)))
  :custom
  ((dired-listing-switches "-aBhl --group-directories-first")
   (dired-kill-when-opening-new-dired-buffer t)
   (dired-recursive-copies 'always)
   (dired-dwim-target t)
   (dired-create-destination-dirs 'ask)))

;; icons for files in dired (uses the same ones as modeline)
(use-package all-the-icons-dired
  :demand t
  :hook
  (dired-mode . all-the-icons-dired-mode))

;; changes how dired opens files
(use-package dired-open
  :after dired
  :custom
  (dired-open-extensions '(("png" . "open")
			   ("pdf" . "open")
			   ("jpg" . "open")
			   ("jpeg" . "open"))))

;; hides dotfiles see them on "H" in normal mode
(use-package dired-hide-dotfiles
  :after dired
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-define-key 'normal 'dired-mode-map
			       "H" 'dired-hide-dotfiles-mode))

(job/leader-keys
  "dj" '(dired-jump :which-key "jump to dired in current directory")
  "dd" '(dired :which-key "open dired at some location interactive"))

(use-package eglot
  :commands (eglot eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-watch-files-outside-project-root nil))

(require 'treesit)

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(org-mode . ("harper-ls" "--stdio"))))

;; The complicated lambda expression makes sure that harper doesn't start on org captures
;; If it starts on an org capture it has very strange behavior.
(add-hook 'org-mode-hook (lambda ()
                           (when
                               (and (buffer-file-name)
                                    (not
                                     (member (abbreviate-file-name (buffer-file-name))
                                             org-agenda-files)))
                             (eglot-ensure))))

(add-hook 'java-mode-hook 'eglot-ensure)
(add-hook 'java-ts-mode-hook 'eglot-ensure)

;; Change from c-indent to indent-for-tab-command to facilitate completion tab
(evil-define-key 'insert java-mode-map (kbd "TAB") 'indent-for-tab-command)
(evil-define-key 'insert java-ts-mode-map (kbd "TAB") 'indent-for-tab-command)

;; Grammer
(add-to-list
 'treesit-language-source-alist
 '(java "https://github.com/tree-sitter/tree-sitter-java" "v0.20.2" "src"))

;; remap the major mode to use ts now
(add-to-list 'major-mode-remap-alist
             '(java-mode . java-ts-mode))

(add-hook 'python-mode-hook 'eglot-ensure)
(add-hook 'python-ts-mode-hook 'eglot-ensure)

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((python-ts-mode-hook python-mode) . ("pyright-langserver" "--stdio"))))

;; Grammer
(add-to-list
 'treesit-language-source-alist
 '(python "https://github.com/tree-sitter/tree-sitter-python" "v0.25.0" "src"))

;; remap the major mode to use ts
(add-to-list 'major-mode-remap-alist
	     '(python-mode . python-ts-mode))

(add-to-list
 'treesit-language-source-alist
 '(elisp "https://github.com/Wilfred/tree-sitter-elisp"))

;; maybe its done automatically, can't find ts mode for elisp

(add-to-list
 'treesit-language-source-alist
 '(makefile "https://github.com/alemuller/tree-sitter-make"))

(use-package gdscript-mode
  :straight (gdscript-mode
             :type git
             :host github
             :repo "godotengine/emacs-gdscript-mode")
  :hook
  (gdscript-mode . eglot-ensure)
  (gdcript-ts-mode . eglot-ensure)
  :custom
  (gdscript-godot-executable "/Applications/Godot.app/Contents/MacOS/Godot")
  :config
  (add-to-list
   'treesit-language-source-alist
   '(gdscript "https://github.com/PrestonKnopp/tree-sitter-gdscript" "v6.1.0" "src")))

(with-eval-after-load 'org (require 'lilypond-mode))

(use-package neocaml)
(use-package ocaml-eglot
  :ensure t
  :after neocaml
  :hook
  (neocaml-base-mode . ocaml-eglot-mode)
  (ocaml-eglot-mode . eglot-ensure))

(with-eval-after-load 'eglot
  ;; Set configs for lanugage servers
  (setq-default eglot-workspace-configuration
                '(:harper-ls
                  (:linters
                   (:SpellCheck :json-false
                    :ToDoHyphen :json-false
                    :NoFrenchSpaces :json-false
                    :LongSentences :json-false
                    :NumericRangeEnDash :json-false
                    :ExpandMemoryShorthands :json-false
                    :Dashes :json-false
                    :Spaces :json-false)
                   :dialect "American"))))

(with-eval-after-load 'flymake
  (define-key evil-normal-state-map (kbd "]d") 'flymake-goto-next-error)
  (define-key evil-normal-state-map (kbd "[d") 'flymake-goto-prev-error))

(job/leader-keys
  "la" '(eglot-code-actions :which-key "eglot-code-actions")
  "lr" '(eglot-reconnect :which-key "eglot-reconnect") 
  "lf" '(eglot-format :which-key "eglot-format")
  "ld" '(xref-find-definitions :which-key "xref-find-definitions"))

(use-package term
  :defer t
  :straight nil
  :config
  (setq explicit-shell-file-name "zsh"))

(use-package eterm-256color
  :after term
  :hook (term-mode . eterm-256color-mode))

(defun job/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  (evil-normalize-keymaps)

  (setq eshell-history-size 10000
	eshell-buffer-maximum-lines 10000
	eshell-hist-ignordups t
	eshell-scroll-to-bottom-on-input t))

(use-package eshell
  :defer t
  :commands (eshell project-eshell projectile-run-eshell)
  :hook (eshell-first-time-mode . job/configure-eshell))

;; add git information into eshell
(use-package eshell-git-prompt
  :after eshell
  :config
  (eshell-git-prompt-use-theme 'multiline))

(use-package vterm
  :defer t
  :commands (vterm
             vterm-other-window
             projectile-run-vterm
             projectile-run-vterm-other-window))

(use-package simple-httpd
  :defer t
  :commands (httpd-serve-directory))


