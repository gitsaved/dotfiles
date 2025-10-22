;;; doom-tokyo-night-black-theme.el --- Tokyo Night with pure black background -*- lexical-binding: t; no-byte-compile: t; -*-

(require 'doom-themes)

;;
;;; Variables

(defgroup doom-tokyo-night-black-theme nil
  "Options for the `doom-tokyo-night-black' theme."
  :group 'doom-themes)

(defcustom doom-tokyo-night-black-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-tokyo-night-black-theme
  :type 'boolean)

(defcustom doom-tokyo-night-black-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-tokyo-night-black-theme
  :type 'boolean)

(defcustom doom-tokyo-night-black-comment-bg doom-tokyo-night-black-brighter-comments
  "If non-nil, comments will have a subtle, darker background. Enhancing their legibility."
  :group 'doom-tokyo-night-black-theme
  :type 'boolean)

(defcustom doom-tokyo-night-black-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to determine the exact padding."
  :group 'doom-tokyo-night-black-theme
  :type '(choice integer boolean))

;;
;;; Theme definition

(def-doom-theme doom-tokyo-night-black
  "A dark theme inspired by Tokyo Night with pure black background"

  ;; name        default   256       16
  ((bg         '("#000000" nil       nil            ))  ;; Pure black background
   (bg-alt     '("#000000" nil       nil            ))  ;; Pure black
   (base0      '("#1f2335" "black"   "black"        ))
   (base1      '("#292e42" "#1e1e1e" "brightblack"  ))
   (base2      '("#343b58" "#2e2e2e" "brightblack"  ))
   (base3      '("#414868" "#262626" "brightblack"  ))
   (base4      '("#545c7e" "#3f3f3f" "brightblack"  ))
   (base5      '("#565f89" "#525252" "brightblack"  ))
   (base6      '("#787c99" "#6b6b6b" "brightblack"  ))
   (base7      '("#9aa5ce" "#979797" "brightblack"  ))
   (base8      '("#dadce8" "#dfdfdf" "white"        ))
   (fg         '("#dadce8" "#bfbfbf" "brightwhite"  ))
   (fg-alt     '("#a9b1d6" "#2d2d2d" "white"        ))

   (grey       base4)
   (red        '("#f7768e" "#ff6655" "red"          ))
   (orange     '("#ff9e64" "#dd8844" "brightred"    ))
   (green      '("#9ece6a" "#99bb66" "green"        ))
   (teal       '("#1abc9c" "#44b9b1" "brightgreen"  ))
   (yellow     '("#e0af68" "#ECBE7B" "yellow"       ))
   (blue       '("#7aa2f7" "#51afef" "brightblue"   ))
   (dark-blue  '("#2ac3de" "#2257A0" "blue"         ))
   (magenta    '("#bb9af7" "#c678dd" "brightmagenta"))
   (violet     '("#9d7cd8" "#a9a1e1" "magenta"      ))
   (cyan       '("#7dcfff" "#46D9FF" "brightcyan"   ))
   (dark-cyan  '("#0db9d7" "#5699AF" "cyan"         ))

   ;; face categories -- required for all themes
   (highlight      blue)
   (vertical-bar   (doom-darken base1 0.1))
   (selection      dark-blue)
   (builtin        magenta)
   (comments       (if doom-tokyo-night-black-brighter-comments dark-cyan base5))
   (doc-comments   (doom-lighten (if doom-tokyo-night-black-brighter-comments dark-cyan base5) 0.25))
   (constants      orange)
   (functions      blue)
   (keywords       violet)
   (methods        cyan)
   (operators      blue)
   (type           yellow)
   (strings        green)
   (variables      fg)
   (numbers        orange)
   (region         base2)
   (error          red)
   (warning        yellow)
   (success        green)
   (vc-modified    orange)
   (vc-added       green)
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-bright doom-tokyo-night-black-brighter-modeline)
   (-modeline-pad
    (when doom-tokyo-night-black-padded-modeline
      (if (integerp doom-tokyo-night-black-padded-modeline) doom-tokyo-night-black-padded-modeline 4)))

   (modeline-fg     fg)
   (modeline-fg-alt base5)

   (modeline-bg
    (if -modeline-bright
        (doom-darken blue 0.475)
      `(,(doom-darken (car bg-alt) 0.15) ,@(cdr base0))))
   (modeline-bg-l
    (if -modeline-bright
        (doom-darken blue 0.45)
      `(,(doom-darken (car bg-alt) 0.1) ,@(cdr base0))))
   (modeline-bg-inactive   `(,(doom-darken (car bg-alt) 0.1) ,@(cdr bg-alt)))
   (modeline-bg-inactive-l `(,(car bg-alt) ,@(cdr base1))))


  ;;;; Base theme face overrides
  (((line-number &override) :foreground base4)
   ((line-number-current-line &override) :foreground fg)
   ((font-lock-comment-face &override)
    :background (if doom-tokyo-night-black-comment-bg (doom-lighten bg 0.05)))
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis :foreground (if -modeline-bright base8 highlight))

   ;;;; doom-modeline
   (doom-modeline-bar :background (if -modeline-bright modeline-bg highlight))
   (doom-modeline-buffer-file :inherit 'mode-line-buffer-id :weight 'bold)
   (doom-modeline-buffer-path :inherit 'mode-line-emphasis :weight 'bold)
   (doom-modeline-buffer-project-root :foreground green :weight 'bold)
   ;;;; css-mode <built-in> / scss-mode
   (css-proprietary-property :foreground orange)
   (css-property             :foreground green)
   (css-selector             :foreground blue)
   ;;;; markdown-mode
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground red)
   ((markdown-code-face &override) :background (doom-lighten base3 0.05))
   ;;;; org <built-in>
   ((org-block &override) :background (doom-lighten base3 0.05))
   ((org-block-begin-line &override) :foreground base5)
   ;;;; solaire-mode
   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-l)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-inactive-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive-l))))

  ;;;; Base theme variable overrides-
  ())

;;; doom-tokyo-night-black-theme.el ends here
