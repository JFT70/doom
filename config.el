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
;; (setq doom-theme 'doom-one)
(setq doom-theme 'doom-dracula)
;; (setq doom-theme 'doom-rouge)
;;(setq doom-theme 'catppuccin-theme)

;; Catppuccin Theme Variations: 'frappe, 'latte, 'macchiato, or 'mocha
(setq catppuccin-flavor 'mocha)
;; (catppuccin-reload)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; (when (display-graphic-p)
;;   (add-to-list 'default-frame-alist '(width . 132))   ;; Set the width (in character columns)
;;   (add-to-list 'default-frame-alist '(height . 50)))  ;; Set the height (in lines)

(defun my/set-default-window-size ()
 (let ((width 132)
       (height 50))
   (unless (frame-parameter nil 'fullscreen))))

(add-hook 'window-setup-hook #'my/set-default-window-size)

;; Keyboards mapping
(map! :leader
      :desc "Ediff Buffers" "e b" #'ediff-buffers)

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

(defun lsp-booster--advice-json-parse (old-fn &rest args)
  "Try to parse bytecode instead of json."
  (or
   (when (equal (following-char) ?#)
     (let ((bytecode (read (current-buffer))))
       (when (byte-code-function-p bytecode)
         (funcall bytecode))))
   (apply old-fn args)))

(advice-add (if (progn (require 'json)
                       (fboundp 'json-parse-buffer))
                'json-parse-buffer
              'json-read)
            :around
            #'lsp-booster--advice-json-parse)

(defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
  "Prepend emacs-lsp-booster command to lsp CMD."
  (let ((orig-result (funcall old-fn cmd test?)))
    (if (and (not test?)                             ;; for check lsp-server-present?
             (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
             lsp-use-plists
             (not (functionp 'json-rpc-connection))  ;; native json-rpc
             (executable-find "emacs-lsp-booster"))
        (progn
          (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $PATH)
            (setcar orig-result command-from-exec-path))
          (message "Using emacs-lsp-booster for %s!" orig-result)
          (cons "emacs-lsp-booster" orig-result))
      orig-result)))

(advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)


(after! lsp-mode
  (setq lsp-headerline-breadcrumb-enable t
        lsp-enable-symbol-highlighting t
        lsp-signature-auto-activate nil)
  (add-hook 'c++-mod-hook #'lsp))

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
  (setq lsp-ui-doc-max-height 40)        ;; Show documentation in a separate window
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

(setq warning-minimum-level :error)

;;
;; Org-Mode Configuration
(after! org

  (map! :map org-mode-map
        :n "M-j" #'org-metadown
        :n "M-l" #'org-metaup)

  (add-hook! 'org-mode-hook #'org-display-outline-path #'org-appear-mode)

  (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))

  (setq! org-ellipsis " ..."
         org-hide-emphasis-markers t)

  (cond
   ((eq system-type 'darwin)
    (set-face-attribute 'org-level-1 nil :height 1.9 :family "Palatino" :overline t :underline t)
    (set-face-attribute 'org-level-2 nil :height 1.7 :family "Palatino")
    (set-face-attribute 'org-level-3 nil :height 1.6 :family "Palatino")
    (set-face-attribute 'org-level-4 nil :height 1.5 :family "Times New Roman" :weight 'bold)
    (set-face-attribute 'org-level-5 nil :height 1.4 :family "Times New Roman" :weight 'bold)
    (set-face-attribute 'org-level-6 nil :height 1.3 :family "Times New Roman" :slant 'italic)
    (set-face-attribute 'org-level-7 nil :height 1.2 :family "Times New Roman")
    (set-face-attribute 'org-level-8 nil :height 1.1 :family "Times New Roman"))
   (t
    (set-face-attribute 'org-level-1 nil :height 1.9 :overline t :underline t)
    (set-face-attribute 'org-level-2 nil :height 1.7 )
    (set-face-attribute 'org-level-3 nil :height 1.6 )
    (set-face-attribute 'org-level-4 nil :height 1.5 :weight 'bold)
    (set-face-attribute 'org-level-5 nil :height 1.4 :weight 'bold)
    (set-face-attribute 'org-level-6 nil :height 1.3 :slant 'italic)
    (set-face-attribute 'org-level-7 nil :height 1.2 )
    (set-face-attribute 'org-level-8 nil :height 1.1 ))
   )

  )

;; "☯☄♉⛬☆★☮☉☞✑"
;; ("⛬" "✨" "✥" "✠" "✑" "✧" "☆" "★" "☉")
;; (after! org-superstar
;;   (setq org-superstar-headline-bullets-list '("⛬" "✨" "✥" "✠" "✑" "✧" "☆" "★" "☉")))
(after! org-superstar
  (setq org-superstar-headline-bullets-list '("☯" "⛬" "✥" "✠" "✑" "✧" "☆" "★" "☉")))

(after! highlight-indent-guides
  (setq! highlight-indent-guides-method 'character
         highlight-indent-guides-responsive 'stack
         highlight-indent-guides-auto-top-character-face-perc 99
         highlight-indent-guides-auto-stack-character-face-perc 40
         highlight-indent-guides-auto-stack-even-face-perc 20
         highlight-indent-guides-auto-stack-even-face-perc 20
         highlight-indent-guides-auto-odd-face-perc 0
         highlight-indent-guides-auto-even-face-perc 0
        )
  )

;; (setq plantuml-server-url "http://localhost:8100/plantuml")
(defun my/plantuml ()
  (let ()
    (setq plantuml-server-url "http://localhost:8100")
    (plantuml-set-exec-mode 'server)))

(add-hook 'plantuml-mode-hook #'my/plantuml)

(after! vterm
  (add-hook 'vterm-mode-hook
            (lambda ()
              (set (make-local-variable 'buffer-face-mode-face) '(:family  "CaskaydiaCove Nerd Font-14"))
              (buffer-face-mode t)) )
  )

(after! cmake-id
  (cmake-ide-setup)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code To The Moon (aka Ken)
;; -----------------------------
;; Extra config
;;
;; https://github.com/MoonKraken/dotfiles/blob/master/.doom.d/config.el

(defun buffer/insert-filename ()
  "Insert file name of current buffer at current point"
  (interactive)
  (insert (buffer-file-name (current-buffer))))

;; Activate Python VIRTUELENV
;;(pythonic-activate "~/some_path")

;; Set which Python interpreter in org-babel
;;(setq org-babel-python-command "full_path?! in Ken example")

;; Windows wrap around!
(setq windmove-wrap-around t)

;; company-mode...

;; ?! WTH is that ?
;;(mac-auto-operator-composition-mode)
