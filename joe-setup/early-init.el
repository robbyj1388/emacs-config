(setq ns-use-native-fullscreen nil) ;; Needed so that frames work well
(setq frame-title-format "Job Emacs") ;; Sets frame title to Job Emacs.

(add-to-list 'default-frame-alist '(background-color . "#000000"))
(add-to-list 'default-frame-alist '(ns-appearance . dark))
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(fullscreen . fullscreen))

(setq inhibit-splash-screen t)    ; No splash screen.
(setq inhibit-startup-message t)  ; No startup message.

(setq make-backup-files nil)      ; Get rid of ~ files, auto-save still on

(scroll-bar-mode -1)          ; Disable visual scrolbar
(tool-bar-mode -1)            ; Disable the toolbar
(tooltip-mode -1)             ; Disable tooltips
(set-fringe-mode 10)          ; Adds 10 pixels to edges of screen
(menu-bar-mode  -1)           ; Disable the menu bar

(setq visible-bell t) ; Removes audio bell (might need to change)

(setenv "LSP_USE_PLISTS" "true")

(when (and (fboundp 'startup-redirect-eln-cache)
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" user-emacs-directory))))
