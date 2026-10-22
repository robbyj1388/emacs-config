; A PLIST is a different type of list that gets converted to C better
; (setenv "LSP_USE_PLISTS" "true")
; This is mac specific color stuff
					; (setq default-frame-alist '(
			    ;; Setting the face in here prevents flashes of
                            ;; color as the theme gets activated
;                            (background-color . "#000000")
;                            (ns-appearance . dark)
;                            (ns-transparent-titlebar . t)))

(setq inhibit-splash-screen t)    ; No splash screen.
(setq inhibit-startup-message t)  ; No startup message.

(setq frame-title-format "Dasker Emacs")

(scroll-bar-mode -1)          ; Disable visual scrolbar
(tool-bar-mode -1)            ; Disable the toolbar
; (tooltip-mode -1)             ; Disable tooltips
(set-fringe-mode 10)          ; Adds 10 pixels to edges of screen
(menu-bar-mode  -1)           ; Disable the menu bar

(setq visible-bell t) ; Removes audio bell (might need to change)

(when (and (fboundp 'startup-redirect-eln-cache)
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" user-emacs-directory))))

(setq make-backup-files nil)      ; Get rid of ~ files, auto-save still on
