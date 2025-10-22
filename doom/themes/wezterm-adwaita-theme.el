;;; wezterm-adwaita-theme.el --- Custom theme matching WezTerm Adwaita config

(require 'doom-themes)

(defgroup wezterm-adwaita-theme nil
  "Options for wezterm-adwaita."
  :group 'doom-themes)

(def-doom-theme wezterm-adwaita
  "A dark theme matching WezTerm's Adwaita configuration with pure black background."

  ;; name        default   256       16
  ((bg         '("#000000" nil       nil            ))
   (bg-alt     '("#1a1a1a" nil       nil            ))
   (base0      '("#000000" "black"   "black"        ))
   (base1      '("#1a1a1a" "#1a1a1a" "brightblack"  ))
   (base2      '("#2a2a2a" "#2a2a2a" "brightblack"  ))
   (base3      '("#3a3a3a" "#3a3a3a" "brightblack"  ))
   (base4      '("#5e5c64" "#5e5c64" "brightblack"  ))
   (base5      '("#77767b" "#77767b" "brightblack"  ))
   (base6      '("#9a9996" "#9a9996" "brightblack"  ))
   (base7      '("#c0bfbc" "#c0bfbc" "brightblack"  ))
   (base8      '("#ffffff" "#ffffff" "white"        ))
   (fg         '("#ffffff" "#ffffff" "white"        ))
   (fg-alt     '("#c0bfbc" "#c0bfbc" "brightwhite"  ))

   (grey       base4)
   (red        '("#f66151" "#f66151" "red"          ))
   (orange     '("#e9ad0c" "#e9ad0c" "brightred"    ))
   (green      '("#33d17a" "#33d17a" "green"        ))
   (teal       '("#2aa1b3" "#2aa1b3" "brightgreen"  ))
   (yellow     '("#e9ad0c" "#e9ad0c" "yellow"       ))
   (blue       '("#3584e4" "#3584e4" "brightblue"   ))
   (dark-blue  '("#2a7bde" "#2a7bde" "blue"         ))
   (magenta    '("#c061cb" "#c061cb" "brightmagenta"))
   (violet     '("#a347ba" "#a347ba" "magenta"      ))
   (cyan       '("#33c7de" "#33c7de" "brightcyan"   ))
   (dark-cyan  '("#2aa1b3" "#2aa1b3" "cyan"         ))

   ;; face categories -- required for all themes
   (highlight      blue)
   (vertical-bar   (doom-darken base1 0.1))
   (selection      blue)
   (builtin        magenta)
   (comments       base6)
   (doc-comments   (doom-lighten base6 0.25))
   (constants      cyan)
   (functions      blue)
   (keywords       violet)
   (methods        blue)
   (operators      fg)
   (type           yellow)
   (strings        green)
   (variables      fg)
   (numbers        orange)
   (region         blue)
   (error          red)
   (warning        yellow)
   (success        green)
   (vc-modified    orange)
   (vc-added       green)
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-bright t)
   (-modeline-pad 4)

   (modeline-fg     nil)
   (modeline-fg-alt base6)

   (modeline-bg base1)
   (modeline-bg-l base2)
   (modeline-bg-inactive   `(,(doom-darken (car bg-alt) 0.1) ,@(cdr base0)))
   (modeline-bg-inactive-l `(,(car bg-alt) ,@(cdr base0))))


  ;; --- extra faces ------------------------
  ((elscreen-tab-other-screen-face :background "#353a42" :foreground "#1e2022")

   ((line-number &override) :foreground base4)
   ((line-number-current-line &override) :foreground blue)

   (font-lock-comment-face
    :foreground comments)
   (font-lock-doc-face
    :inherit 'font-lock-comment-face
    :foreground doc-comments)

   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis
    :foreground highlight)

   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-l)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-inactive-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive-l)))

   ;; --- major-mode faces -------------------
   ;; css-mode / scss-mode
   (css-proprietary-property :foreground orange)
   (css-property             :foreground green)
   (css-selector             :foreground blue)

   ;; markdown-mode
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground red)
   ((markdown-code-face &override) :background (doom-lighten base3 0.05))

   ;; org-mode
   (org-hide :foreground hidden)
   (solaire-org-hide-face :foreground hidden))


  ;; --- extra variables ---------------------
  ()
  )

(provide-theme 'wezterm-adwaita)
;;; wezterm-adwaita-theme.el ends here