;;; doom-tokyo-night-nvim-theme.el --- Tokyo Night theme matching Neovim -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Custom theme matching folke/tokyonight.nvim colors exactly
;;
;;; Code:

(require 'doom-themes)

(defgroup doom-tokyo-night-nvim-theme nil
  "Options for doom-tokyo-night-nvim-theme"
  :group 'doom-themes)

(defcustom doom-tokyo-night-nvim-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-tokyo-night-nvim-theme
  :type 'boolean)

(defcustom doom-tokyo-night-nvim-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-tokyo-night-nvim-theme
  :type 'boolean)

(defcustom doom-tokyo-night-nvim-padded-modeline nil
  "If non-nil, adds a 4px padding to the mode-line."
  :group 'doom-tokyo-night-nvim-theme
  :type '(or integer boolean))

(def-doom-theme doom-tokyo-night-nvim
  "Tokyo Night theme matching folke/tokyonight.nvim (night variant)"

  ;; Exact colors from tokyonight.nvim night variant (darker background)
  ((bg         '("#16161e" nil       nil))
   (bg-alt     '("#0C0E14" nil       nil))
   (bg-dark    '("#000000" nil       nil))
   (base0      '("#414868" "#414868" "black"))
   (base1      '("#51587a" "#51587a" "brightblack"))
   (base2      '("#61698b" "#61698b" "brightblack"))
   (base3      '("#71799d" "#71799d" "brightblack"))
   (base4      '("#8189af" "#8189af" "brightblack"))
   (base5      '("#9099c0" "#9099c0" "brightblack"))
   (base6      '("#a0aad2" "#a0aad2" "brightblack"))
   (base7      '("#b0bae3" "#b0bae3" "brightblack"))
   (base8      '("#c0caf5" "#c0caf5" "white"))
   (fg-alt     '("#c0caf5" "#c0caf5" "brightwhite"))
   (fg         '("#c0caf5" "#c0caf5" "white"))

   (grey       '("#565f89" "#565f89" "brightblack"))
   (red        '("#f7768e" "#f7768e" "red"))
   (orange     '("#ff9e64" "#ff9e64" "brightred"))
   (green      '("#9ece6a" "#9ece6a" "green"))
   (teal       '("#73daca" "#73daca" "brightgreen"))
   (yellow     '("#e0af68" "#e0af68" "yellow"))
   (blue       '("#7aa2f7" "#7aa2f7" "brightblue"))
   (dark-blue  '("#3d59a1" "#3d59a1" "blue"))
   (magenta    '("#bb9af7" "#bb9af7" "magenta"))
   (violet     '("#9d7cd8" "#9d7cd8" "brightmagenta"))
   (cyan       '("#7dcfff" "#7dcfff" "brightcyan"))
   (dark-cyan  '("#2ac3de" "#2ac3de" "cyan"))

   ;; face categories
   (highlight      cyan)
   (vertical-bar   (doom-lighten bg 0.05))
   (selection      base0)
   (builtin        red)
   (comments       (if doom-tokyo-night-nvim-brighter-comments base5 grey))
   (doc-comments   (doom-lighten (if doom-tokyo-night-nvim-brighter-comments base5 grey) 0.25))
   (constants      orange)
   (functions      blue)
   (keywords       magenta)
   (methods        blue)
   (operators      cyan)
   (type           teal)
   (strings        green)
   (variables      fg)
   (numbers        orange)
   (region         base0)
   (error          red)
   (warning        yellow)
   (success        green)
   (vc-modified    orange)
   (vc-added       green)
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-bright doom-tokyo-night-nvim-brighter-modeline)
   (-modeline-pad
    (when doom-tokyo-night-nvim-padded-modeline
      (if (integerp doom-tokyo-night-nvim-padded-modeline)
          doom-tokyo-night-nvim-padded-modeline 4)))

   (modeline-fg     fg)
   (modeline-fg-alt base5)
   (modeline-bg     (doom-darken bg 0.15))
   (modeline-bg-l   (doom-darken bg 0.1))
   (modeline-bg-inactive   (doom-darken bg 0.1))
   (modeline-bg-inactive-l bg))

  ;; --- Extra Faces ------------------------
  (
   ((line-number-current-line &override) :foreground cyan)
   ((line-number &override) :foreground grey :background bg)

   (font-lock-comment-face :foreground comments)
   (font-lock-doc-face :inherit 'font-lock-comment-face :foreground doc-comments)

   ;;; Doom Modeline
   (doom-modeline-bar :background (if -modeline-bright modeline-bg highlight))
   (doom-modeline-buffer-path :foreground fg :weight 'bold)
   (doom-modeline-buffer-file :foreground fg :weight 'bold)

   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))

   ;;; Indentation
   (whitespace-indentation :background bg)
   (whitespace-tab :background bg)

   ;;; Ivy
   (ivy-subdir :foreground blue)
   (ivy-minibuffer-match-face-1 :foreground green :background bg-alt)
   (ivy-minibuffer-match-face-2 :foreground orange :background bg-alt)
   (ivy-minibuffer-match-face-3 :foreground red :background bg-alt)
   (ivy-minibuffer-match-face-4 :foreground yellow :background bg-alt)

   ;;; Solaire
   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-l)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-inactive-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive-l)))

   ;;;; rainbow-delimiters
   (rainbow-delimiters-depth-1-face :foreground fg)
   (rainbow-delimiters-depth-2-face :foreground blue)
   (rainbow-delimiters-depth-3-face :foreground orange)
   (rainbow-delimiters-depth-4-face :foreground green)
   (rainbow-delimiters-depth-5-face :foreground cyan)
   (rainbow-delimiters-depth-6-face :foreground yellow)
   (rainbow-delimiters-depth-7-face :foreground teal)

   ;;; Treemacs
   (treemacs-root-face :foreground magenta :weight 'bold :height 1.2)
   (doom-themes-treemacs-root-face :foreground magenta :weight 'ultra-bold :height 1.2)
   (doom-themes-treemacs-file-face :foreground fg-alt)
   (treemacs-directory-face :foreground blue)
   (treemacs-file-face :foreground fg)
   (treemacs-git-modified-face :foreground orange)

   ;;; Magit
   (magit-section-heading :foreground blue)
   (magit-branch-remote   :foreground orange)
   (magit-diff-removed :foreground red)
   (magit-diff-removed-highlight :foreground red :background (doom-darken red 0.5))

   ;;; org-mode
   (org-hide :foreground hidden)
   (org-block :background (doom-lighten bg 0.03))
   (org-block-begin-line :background (doom-lighten bg 0.03) :foreground comments)

   ;;; markdown-mode
   (markdown-markup-face :foreground violet)
   (markdown-header-face :inherit 'bold :foreground cyan)
   ((markdown-code-face &override) :foreground cyan :background (doom-lighten bg 0.04))))

;;; doom-tokyo-night-nvim-theme.el ends here
