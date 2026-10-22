;; Launch vscode like terminal in vertically split buffer
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


(tab-bar-mode 1)              ; Enable tabs
;; Set keybinds for text sizing
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
;; Terminal open
(global-set-key (kbd "C-`") 'launch-xterm)

(menu-bar-mode -1) ; Disable the menu bar

(setq ring-bell-function 'ignore) ; Turn off bell/screen flash

(set-face-attribute 'default nil 
		    ;:family "JetBrainsMonoNerdFontMono-Regular" ; Disgusting and ungly font
                    :height 180 
                    :weight 'heavy)

;; make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Line numbers
(column-number-mode) ; Display cursor position
(setq-default display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)



;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package doom-themes
  :init (load-theme 'doom-acario-dark t))

;; Note: On new machines without the font, run
;; M-x all-the-icons-install-fonts
(use-package all-the-icons)

;; Bracket highlighting
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))
  
;; List recent searches first
(use-package ivy-prescient
  :ensure t
  :config
  ;; Remember usage statistics across Emacs restarts
  (ivy-prescient-mode +1))


;; List options when using keybinds
(use-package which-key
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

;; Auto tangle org files like emacs.org
(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode))

;; Window management
(use-package ace-window
  :ensure t
  :bind
  ("C-a" . ace-window)
  :custom
  (aw-dispatch-always t)
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;; Beautify org files
(use-package org-modern
  :ensure t
  :init
  ;; Turn on org-modern globally for all Org files and the Agenda
  (global-org-modern-mode)
  :config
  ;; Hide the raw markup tags like *bold*, /italics/, and _underline_
  (setq org-hide-emphasis-markers t)
  
  ;; Make list hyphens (-) look like neat, centered bullet points
  (setq org-list-allow-alphabetical t)
  
  ;; Replace the basic "..." trailing folded headers with a cleaner arrow
  (setq org-ellipsis " ▼ "))

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

;; Better terminal
(use-package vterm
  :ensure t
  :hook (vterm-mode . (lambda () 
                        (setq display-line-numbers nil))))

;; Helpful tooltip injections
(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

;; Dependancy for counsel and swiper
(use-package ivy
  :ensure t
  :bind (:map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

;; Easier file management
(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-x C-r" . counsel-recentf)
         ("C-c g" . counsel-git)
         ("C-c j" . counsel-git-grep)
         ("C-c /" . counsel-ag)
         :map counsel-find-file-map
         ("M-o" . counsel-find-file-action))
 )

;; Searching for words in files
(use-package swiper
  :ensure t
  :bind (("C-s" . swiper)))

;; AutoComplete
(use-package company
  :ensure t
  :init
  (add-hook 'after-init-hook 'global-company-mode))

;; Org files
(use-package org
  :ensure t
  :defer t                        ; Defers loading until opening an .org file
  
  :bind 
  (("C-c l" . org-store-link)
   ("C-c a" . org-agenda)
   ("C-c c" . org-capture))
  
  :custom
  (org-log-done 'time)
  (org-confirm-babel-evaluate nil)
  (org-startup-folded t))


;; Enable eglot lsps for specific languages
(use-package eglot
  :ensure t
  :hook
  ((c-mode . eglot-ensure)
   (c++-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode) . ("clangd" 
                                      "--query-driver=/usr/bin/g++,/usr/bin/clang++"
                                      "--background-index"
                                      "--header-insertion=never"))))

;; Disable line numbers for specific modes
(dolist (mode '(org-mode
                vterm-mode
                term-mode
                dired-mode
                eshell-mode))
  ;; Disable line numbers via hook
  (add-hook (intern (concat (symbol-name mode) "-hook"))
            (lambda () (display-line-numbers-mode nil))))

;; Disable evil for specific modes
(dolist (mode '(term-mode
                eshell-mode))
  ;; Force Emacs initial state
  (evil-set-initial-state mode 'emacs))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
	 '(org-modern magit all-the-icons doom-themes vterm which-key company rainbow-delimiters doom-modeline doom-modeline-mode ivy-prescient prescient evil-collection evil swiper ivy command-log-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

