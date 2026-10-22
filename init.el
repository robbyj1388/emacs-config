; When you do automatic config changing, put the changes in custom.el
; instead of this init file
; Change
(setq custom-file
      (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;; Loads the default package manager
(require 'package)

;; Loads 3 different package archives
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
	("org" . "https://orgmode.org/elpa/")
	("elpa" . "https://elpa.gnu.org/packages/")))

;; Essentially APT Update
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Auto tangle org files like emacs.org
(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode))

;; Install the use-package package manager
(require 'use-package)
;; Update some use-package options
;; Set default to be ensure instead of no-ensure
;; AKA don't be lazy unless I say so
(setq use-package-always-ensure t)       ; Turns ensure on by default
(setq use-package-compute-statistics t)  ; Turns on startup statistics

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

  (use-package auto-package-update
    :demand t
    :custom
    (auto-package-update-interval 7)
    (auto-package-update-prompt-before-update t)
    (auto-package-update-hide-results t)
    :config
    (auto-package-update-maybe)
    (auto-package-update-at-time "09:00"))

  (use-package which-key
    :defer nil
    :diminish which-key-mode
    :config (which-key-mode)
    :custom
    (which-key-idle-delay 0.5))

(use-package ace-window
  :ensure t
  :bind
  ("C-a" . ace-window)
  :custom
  (aw-dispatch-always t)
  (aw-keys '(?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9))
  :config
  ;; Ensure tabs is turned on globally
  (tab-bar-mode 1))

  (use-package helpful
    :commands (helpful-callable helpful-variable helpful-command helpful-key))

  (setq inhibit-splash-screen t)    ; No splash screen.
  (setq inhibit-startup-message t)  ; No startup message.

  (setq frame-title-format "Robby Emacs")

  (scroll-bar-mode -1)          ; Disable visual scrolbar
  (tool-bar-mode -1)            ; Disable the toolbar
  (tooltip-mode -1)             ; Disable tooltips
  (fringe-mode '(1 . 1))        ; Sets frame to a minimum of one character
  (menu-bar-mode  -1)           ; Disable the menu bar

  (setq ring-bell-function 'ignore) ; Turn off bell/screen flash

  (column-number-mode)                 ; Adds column number to mode line
  (global-display-line-numbers-mode t) ; Adds line numbers
  (add-hook 'prog-mode-hook 'display-line-numbers-mode)

  (setopt display-fill-column-indicator-column 80)
  (add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

  ;; Disable line numbers for some modes
  (dolist (mode '(org-mode-hook
                  vterm-mode-hook
                  term-mode-hook
                  shell-mode-hook
                  eshell-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0))))

  (use-package modus-themes
    :ensure t
    :demand t
    :custom
    (modus-themes-common-palette-overrides
     '((fg-region unspecified)        ;; highlight not change underlying style 
       (fg-paren-match (extrabold)))) ;; matching parenthesis are bolded

    ;; changes the highlighting of completions
    (modus-themes-completions '((matches . (bold))
                                (selection . (extrabold italic))))

    ;; adds bold to some syntax elements
    (modus-themes-bold-constructs t)
    (modus-themes-italic-constructs t)
    :config
    (modus-themes-load-theme 'modus-vivendi-deuteranopia))

  (use-package rainbow-delimiters
    :defer t
    :hook (prog-mode . rainbow-delimiters-mode))

  (use-package doom-modeline   
    :ensure t   
    :init (doom-modeline-mode 1)   
    :custom 
    (doom-modeline-height 25)      ; Increases the overall height of the modeline bar
    (doom-modeline-icon-scale 1.0) ; Scales the icon size relative to the font (try 0.9 or 1.1 if needed)
    (doom-modeline-v-adjust 0.05)) ; Adjusts vertical position to push text away from icons

  (use-package spacious-padding
    :config
    (spacious-padding-mode 1))

  (setq custom-tab-width 4)
  (setq tab-width custom-tab-width)

  (defun disable-tabs () (setq indent-tabs-mode nil))
  (defun enable-tabs ()
    (local-set-key (kbd "TAB") 'tab-to-tab-stop)
    (setq indent-tabs-mode t)
    (setq tab-width custom-tab-width))

  (add-hook 'prog-mode-hook 'disable-tabs)
  (add-hook 'makefile-mode-hook 'enable-tabs)

  (setq-default electric-indent-inhibit t)
  (setq backward-delete-char-untabify-method 'hungry)

(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

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

;;;; Direct all buffers to open in a dedicated workspace tab automatically
;;
;;(setq display-buffer-alist
;;      `(;; Add buffers to EXCLUDE here
;;        (,(rx (or "*Messages*" "*Warnings*" "*Errors*" "vscod-vterm-window" "*Process List*")) . (nil))
;;        
;;        ;; Open everything else in a new tab
;;        (".*" . (display-buffer-in-new-tab (reusable-frames . t)))))

;; Prevent emacs from resizing windows unevenly across actions
(customize-set-variable 'even-window-sizes nil)

(setq tab-bar-new-tab-choice "*scratch*"   ; New tabs start fresh with a scratch pad
      tab-bar-tab-hints nil)               ; Hides numbers so the bar stays tidy

  (use-package flyspell
    :defer t
    :hook
    (text-mode . flyspell-mode)
    (prog-mode . flyspell-prog-mode)
    :custom 
    (ispell-extra-args '("--lang=en_US")))

  (use-package yasnippet
    :ensure t
    :hook ((text-mode
            prog-mode
            conf-mode
            snippet-mode) . yas-minor-mode-on))

  ;; Sample Snippets
  (use-package yasnippet-snippets
    :after yasnippet)

;; Vim keybindings
(use-package evil
  :init
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

;; Turn non-evil vim buffers to evil vim buffers
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Automatically tangle our emacs.org config file on save
(defun dasker/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.emacs.d/emacs.org"))
    ;; Dyanamic scoping to the resuce
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

;; Set hook to try to run above function on orgmode save
(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'after-save-hook
                      #'dasker/org-babel-tangle-config)))

  (global-set-key (kbd "C-+") 'text-scale-increase)
  (global-set-key (kbd "C--") 'text-scale-decrease)

;; Tmux style prefix setup
(define-prefix-command 'tmux-prefix-map)

;; C-a c -> Open New Tab
(define-key 'tmux-prefix-map (kbd "c") 'tab-duplicate) 

;; C-a n -> Next Tab
(define-key tmux-prefix-map (kbd "n") 'tab-next) 
;; C-a p -> Previous Tab
(define-key tmux-prefix-map (kbd "p") 'tab-previous)

;; Fire ace window if you double tap C-a
(define-key tmux-prefix-map (kbd "C-a") 'ace-window)

;; C-a to point to this new map
(global-set-key (kbd "C-a") tmux-prefix-map)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

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

;; Make minibuffer appear at center of screen

(use-package vertico-posframe
  :after vertico
  :custom
  ;; Keep the popup reasonably small
  (vertico-posframe-height 15)
  (vertico-posframe-min-height 1)
  (vertico-posframe-border-width 1)
  :config
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

  (use-package embark
    :bind
    (("C-." . embark-act)
     ("M-." . embark-dwim)
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

  (defun dasker/org-faces ()
    (set-face-attribute 'org-todo nil :height 0.7)
    (set-face-attribute 'org-done nil :height 0.7)
    (set-face-attribute 'org-headline-done nil :foreground nil)
    (set-face-attribute 'org-tag nil :height 0.7)
    (set-face-attribute 'org-priority nil :height 0.7)
    (set-face-attribute 'org-block-begin-line nil :height 0.7)
    (set-face-attribute 'org-block-end-line nil :height 0.7)
    (modus-themes-with-colors
     (set-face-attribute 'org-hide nil :foreground bg-main :background bg-main))

    (set-face-attribute 'org-level-1 nil :height 1.4)
    (set-face-attribute 'org-level-2 nil :height 1.3)
    (set-face-attribute 'org-level-3 nil :height 1.2)
    (set-face-attribute 'org-level-4 nil :height 1.1)
    (set-face-attribute 'org-level-5 nil :height 1.1)
    (set-face-attribute 'org-level-6 nil :height 1.1)
    (set-face-attribute 'org-level-7 nil :height 1.1)
    (set-face-attribute 'org-level-8 nil :height 1.1)
    (set-face-attribute 'org-block nil
                        :foreground nil :inherit '(fixed-pitch default))
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
    (set-face-attribute 'org-indent
                        nil :inherit '(org-hide fixed-pitch))
    (require 'org-faces)
    (set-face-attribute 'org-latex-and-related nil :inherit 'fixed-pitch)
    (setq org-todo-keyword-faces
          '(("PROGRESS" . (:inherit (warning org-todo)))
            ("WAITING" . (:inherit (shadow org-todo)))))
    )

  (defun dasker/org-mode-setup ()
    (org-indent-mode 1)
    (variable-pitch-mode 1)
    (auto-fill-mode 0)
    (visual-line-mode 1)
    (setq evil-auto-indent nil))

  (use-package org
    :hook ((org-mode . dasker/org-mode-setup)
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
    (org-hide-leading-stars t)          ;; hide the leading stars of heading
    (org-ellipsis " ")                   ;; folded indicator
    (org-pretty-entities t)              ;; utf8 characters in entities
    (org-startup-folded 'fold)           ;; start with evertyhing folded 
    (org-fold-catch-invisible-edits 'show-and-error)
    (org-catch-invisible-edits 'show-and-error)
    (org-special-ctrl-a/e t)
    (org-insert-heading-respect-content t)

    ;; src blocks
    (org-edit-src-content-indentation 0) ;; no spaces at start of src block
    (org-src-fontify-natively t)         ;; use native fonts
    (org-src-tab-acts-natively t)        ;; take tab back
    (org-latex-src-block-backend 'engraved) ;; typesetting src blocks latex

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
    (dasker/org-faces)
    (add-hook 'modus-themes-after-load-theme-hook #'dasker/org-faces)
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
    (with-eval-after-load 'ox-html
      (setq org-html-htmlize-output-type nil))
    )

  (use-package org-auto-tangle
    :load-path "site-lisp/org-auto-tangle/"    ;; this line is necessary only if you cloned the repo in your site-lisp directory 
    :defer t
    :hook (org-src-mode . org-auto-tangle-mode))

  (use-package evil-org
    :after org
    :hook (org-mode . (lambda () evil-org-mode))
    :config
    (require 'evil-org-agenda)
    (evil-org-agenda-set-keys))

(use-package citar
  :after all-the-icons
  :custom
  (org-cite-global-bibliography '("~/orgfiles/refs/Orged.bib"
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
  (defun dasker/org-mode-visual-fill ()
    (setq visual-fill-column-width 80
          visual-fill-column-center-text t)
    (visual-fill-column-mode 1))
  (use-package visual-fill-column
    :hook ((org-mode . dasker/org-mode-visual-fill)))

  (use-package org-modern 
    :hook ((org-mode . org-modern-mode)
           (org-agenda-finalize . org-modern-agenda))
    :config
    (set-face-attribute 'org-modern-symbol nil
                        :height robby-default-font-size)
    :custom
    (org-modern-keyword nil)
    (org-modern-priority nil)
    (org-modern-tag nil)
    (org-modern-timestamp nil)
    (org-modern-todo nil)
    (org-modern-table nil)
    (org-modern-block-name nil)
    (org-modern-block-fringe nil)
  
    ;; Agenda Styling
    (org-agenda-tags-column 0)
    (org-agenda-block-separator ?-))

  (with-eval-after-load 'org
    (require 'org-tempo)

    ;; Added one at a time
    (add-to-list 'org-structure-template-alist
                 '("el" . "src emacs-lisp"))
    (add-to-list 'org-structure-template-alist
                 '("jv" . "src java")))

  (use-package engrave-faces
    :after org)

  (with-eval-after-load 'org
    (setq org-src-preserve-indentation t)
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp . t)
       (java . t)
       (latex . t)
       (python . t)
       (makefile . t)
       (C . t)))
    (setq org-confirm-babel-evaluate nil)
    (setq org-babel-python-command "python3"))

(use-package vterm
  :defer t
  :commands (vterm
             vterm-other-window
             projectile-run-vterm
             projectile-run-vterm-other-window))

  (defun launch-xterm ()
    (interactive)
    (let ((buf (get-buffer "vscode-vterm-window")))
      (if (and buf (get-buffer-window buf))
          ;; If it's visible, hide it
          (delete-windows-on buf)
        ;; If it's hidden or doesn't exist, display it
        (let ((new-win (split-window-below)))
          (select-window new-win)
          (if buf
              (switch-to-buffer buf)
            (vterm "vscode-vterm-window"))))))

  (global-set-key (kbd "C-`") 'launch-xterm)
