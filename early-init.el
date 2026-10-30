; A PLIST is a different type of list that gets converted to C better
; (setenv "LSP_USE_PLISTS" "true")
; This is mac specific color stuff
					; (setq default-frame-alist '(
			    ;; Setting the face in here prevents flashes of
                            ;; color as the theme gets activated
;                            (background-color . "#000000")
;                            (ns-appearance . dark)
;                            (ns-transparent-titlebar . t)))

;; Fix the Emacs 29.3 compatibility issue
(unless (fboundp 'custom-initialize-after-file-load)
  (defun custom-initialize-after-file-load (symbol exp)
    "Compatibility fallback for Emacs 31 function missing in Emacs 29."
    (if (not load-file-name)
        (custom-initialize-set symbol exp)
      (let ((file load-file-name))
        (eval-after-load file
          `(custom-initialize-set ',symbol ',exp))))))


(setq inhibit-splash-screen t)    ; No splash screen.
(setq inhibit-startup-message t)  ; No startup message.
(setq robby-default-font-size 180)

(setq frame-title-format "Robby Emacs")

(scroll-bar-mode -1)          ; Disable visual scrolbar
(tool-bar-mode -1)            ; Disable the toolbar
(tooltip-mode -1)             ; Disable tooltips
(set-fringe-mode 10)          ; Adds 10 pixels to edges of screen
(menu-bar-mode  -1)           ; Disable the menu bar
(tab-bar-mode 1)              ; Enable tabs

(set-face-attribute 'default nil 
		    ;:family "JetBrainsMonoNerdFontMono-Regular" ; Disgusting and ungly font
                    :height robby-default-font-size 
                    :weight 'heavy)

(add-to-list 'default-frame-alist '(background-color . "#000000"))
(add-to-list 'default-frame-alist '(ns-appearance . dark))
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq visible-bell t) ; Removes audio bell (might need to change)

(when (and (fboundp 'startup-redirect-eln-cache)
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" user-emacs-directory))))

(setq make-backup-files nil)      ; Get rid of ~ files, auto-save still on
