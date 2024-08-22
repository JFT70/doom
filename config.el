;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
(setq doom-font "CaskaydiaCove Nerd Font-14")
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;(setq doom-theme 'doom-one)
(setq doom-theme 'doom-dracula)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(when (display-graphic-p)
  (add-to-list 'default-frame-alist '(width . 132))   ;; Set the width (in character columns)
  (add-to-list 'default-frame-alist '(height . 50)))  ;; Set the height (in lines)

;(defun my/set-default-window-size ()
;  (let ((width 132)
;        (height 50))
;    (unless (frame-parameter nil 'fullscreen))))
;
;(add-hook 'window-setup-hook 'my/set-default-window-size)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; (after! lsp-mode
;;  (seq lsp-headerline-breadcrumb-enable t
;;       lsp-enable-symbol-highlighting t
;;       lsp-signature-auto-activate nil))

(after! rustic
  (setq rustic-lsp-server 'rust-analyzer)

  ;;(map! :leader
        ;;:desc "Run Cargo Build" "c b" #'rustic-cargo-build
        ;;:desc "Run Cargo Test" "c t" #'rustic-cargo-test
        ;;:desc "Run Cargo Run" "c r" #'rustic-cargo-run
        ;;:desc "Open Cargo.toml" "c o" #'rustic-cargo-edit-open)
  )

(after! lsp-ui
  ;; Enable the UI features you want
  (setq lsp-ui-sideline-enable t)  ;; Show sideline info
  (setq lsp-ui-doc-enable t)        ;; Show documentation in a separate window
  (setq lsp-ui-peek-enable t)       ;; Enable peek feature
  (setq lsp-ui-flycheck-enable t)   ;; Show flycheck errors
  (setq lsp-ui-sideline-show-diagnostics t)
  (setq lsp-ui-sideline-show-hover t)
  (setq lsp-ui-sideline-show-code-actions t)
  (setq lsp-ui-sideline-update-mode 'line)

  ;; Set keybindings for lsp-ui features
  (map! :leader
        :desc "Show documentation" "h d" #'lsp-ui-doc-show
        :desc "Peek definition" "gd" #'lsp-ui-peek-find-definitions
        :desc "Peek references" "gr" #'lsp-ui-peek-find-references))

(setq warning-minimum-level 'error)

(after! org
  (map! :map org-mode-map
        :n "M-j" #'org-metadown
        :n "M-l" #'org-metaup)
  (set-face-attribute 'org-level-1 nil :height 1.8)
  (set-face-attribute 'org-level-2 nil :height 1.6)
  (set-face-attribute 'org-level-3 nil :height 1.4)
  (set-face-attribute 'org-level-4 nil :height 1.2)
  (set-face-attribute 'org-level-5 nil :height 1.1))

;; "⛬☄☆☯♉"
(after! org-superstar
  (setq org-superstar-headline-bullets-list '("☯")))
