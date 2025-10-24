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

;; Using CaskaydiaCove Nerd Font - includes braille, ligatures, and all icons
(setq doom-font (font-spec :family "CaskaydiaCove Nerd Font" :size 16 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "CaskaydiaCove Nerd Font" :size 16))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-tokyo-night-black)

;; Disable solaire-mode to prevent background color changes
(after! solaire-mode
  (solaire-global-mode -1))

;; Fix current line highlight color to match Neovim
(custom-set-faces!
  '(hl-line :background "#292e42"))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/documents/org/")

;; ============================================================================
;; Org-mode Configuration - ADHD-friendly capture system
;; ============================================================================

(after! org
  ;; Set org-agenda-files to scan only the root org directory (not subdirectories)
  (setq org-agenda-files (list org-directory))

  ;; Show project context in agenda view
  ;; This displays the parent heading (project name) for each TODO
  (setq org-agenda-prefix-format
        '((agenda . " %i %-12:c%?-12t% s")
          (todo . " %i %-12:c %(org-agenda-get-parent-heading) ")
          (tags . " %i %-12:c")
          (search . " %i %-12:c")))

  ;; Helper function to get parent heading for agenda display
  (defun org-agenda-get-parent-heading ()
    "Get the parent heading of the current org entry for agenda display."
    (save-excursion
      (org-back-to-heading t)
      (if (org-up-heading-safe)
          (format "[%s] " (org-get-heading t t t t))
        "")))

  ;; Project selection for capture - simple and working
  (defun my/org-goto-or-create-project ()
    "Select existing project or create new one. Positions point for org-capture."
    (let* ((all-headings '()))
      ;; Collect all top-level project headings
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward "^\\* \\(.+\\)$" nil t)
          (let ((heading (match-string 1)))
            (unless (string= heading "Instructions")
              (push heading all-headings)))))
      
      (setq all-headings (nreverse all-headings))
      
      ;; Prompt for selection (nil nil allows free text for new projects)
      (let ((selection (completing-read "Project: " all-headings nil nil)))
        (goto-char (point-min))
        ;; Try to find existing project
        (unless (re-search-forward (format "^\\* %s$" (regexp-quote selection)) nil t)
          ;; Project doesn't exist - create it at end
          (goto-char (point-max))
          (unless (bolp) (insert "\n"))
          (insert "\n* " selection "\n:PROPERTIES:\n:CREATED: " 
                  (format-time-string "[%Y-%m-%d %a]") "\n:END:\n\n")
          (re-search-backward (format "^\\* %s$" (regexp-quote selection)) nil t))
        ;; Position at the project heading for capture to nest under it
        (beginning-of-line))))

  ;; Capture templates - minimal friction, ADHD-friendly
  (setq org-capture-templates
        `(("t" "Quick Todo" entry
           (file ,(expand-file-name "inbox.org" org-directory))
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :empty-lines 1)

          ("i" "Idea" entry
           (file ,(expand-file-name "ideas.org" org-directory))
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :empty-lines 1)

          ("s" "Solution/Knowledge" entry
           (file ,(expand-file-name "knowledge.org" org-directory))
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n** Problem\n\n** Solution\n\n"
           :empty-lines 1)

          ("p" "Project Note" entry
           (file+function ,(expand-file-name "projects.org" org-directory)
                          my/org-goto-or-create-project)
           "** %^{Heading}\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n%?"
           :empty-lines-after 1))))


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
(setq ispell-program-name "aspell-en")

;; Configure indent-bars for animated indent guides
(after! indent-bars
  (setq indent-bars-treesit-support t
        indent-bars-treesit-ignore-blank-lines-types '("module")
        indent-bars-width-frac 0.2
        indent-bars-pad-frac 0.1
        indent-bars-zigzag nil
        indent-bars-color '(highlight :face-bg t :blend 0.2)
        indent-bars-highlight-current-depth '(:blend 0.8)
        indent-bars-pattern "."))

;; Auto-activate Python virtual environments
(after! python
  (setq python-shell-interpreter "python3")
  (add-hook 'python-mode-hook
            (lambda ()
              (let* ((project-root (or (locate-dominating-file default-directory ".git")
                                       (locate-dominating-file default-directory ".venv")
                                       default-directory))
                     (venv-candidates (when project-root
                                        (directory-files project-root t "^\\..*" nil)))
                     (venv-dir (seq-find (lambda (dir)
                                           (and (file-directory-p dir)
                                                (or (string-match-p "/\\.venv$" dir)
                                                    (file-exists-p (expand-file-name "bin/activate" dir)))))
                                         venv-candidates)))
                (when venv-dir
                  (pyvenv-activate venv-dir))))))

;; ============================================================================
;; System Clipboard Integration - Works with Firefox and other apps
;; ============================================================================

;; Ensure Emacs uses system clipboard globally
(setq select-enable-clipboard t
      select-enable-primary nil
      save-interprogram-paste-before-kill t)

;; ============================================================================
;; Workspace Configuration - Prevent new workspaces for emacsclient frames
;; ============================================================================

;; Don't create new workspace when opening emacsclient frames
;; Instead, use the currently active workspace
(after! persp-mode
  (setq persp-emacsclient-init-frame-behaviour-override -1))

;; ============================================================================
;; Vterm configuration - System-level terminal replacement
;; ============================================================================

(after! vterm
  ;; Disable popup rules for vterm - always display in main window
  (set-popup-rule! "^\\*vterm" :ignore t)

  ;; Performance optimizations
  (setq vterm-max-scrollback 10000)  ; Reasonable scrollback limit
  (setq vterm-timer-delay 0.01)      ; Lower delay for better responsiveness
  (setq vterm-kill-buffer-on-exit t) ; Auto-cleanup dead buffers

  ;; Disable unnecessary features in vterm for performance
  (add-hook 'vterm-mode-hook
            (lambda ()
              (display-line-numbers-mode -1)  ; No line numbers in terminal
              (setq-local global-hl-line-mode nil))) ; No line highlighting

  ;; Mark vterm buffers as disposable (no save prompts)
  (add-hook 'vterm-mode-hook
            (lambda ()
              (setq-local buffer-offer-save nil)))

  ;; Cleanup function to remove old hooks (run this if vterm is laggy)
  (defun my/vterm-cleanup-hooks ()
    "Remove all custom post-command hooks from vterm buffer."
    (interactive)
    (remove-hook 'post-command-hook #'my/vterm-auto-copy-selection t)
    (message "Cleaned up vterm hooks. Restart vterm buffer."))

  ;; Disable evil mode in vterm buffers - force emacs state always
  (evil-set-initial-state 'vterm-mode 'emacs)

  ;; Prevent accidentally switching to normal mode in vterm
  (add-hook 'vterm-mode-hook
            (lambda ()
              ;; Force emacs state
              (evil-emacs-state)
              ;; Disable normal state keybindings that might trigger mode switching
              (evil-local-set-key 'emacs (kbd "C-z") nil)  ; Don't switch to normal
              ))

  ;; If somehow we end up in normal state, immediately switch back to emacs
  (add-hook 'evil-normal-state-entry-hook
            (lambda ()
              (when (eq major-mode 'vterm-mode)
                (evil-emacs-state))))


  ;; Standalone vterm launcher for system-wide Super+T
  (defun my/vterm-standalone ()
    "Launch NEW vterm instance in a standalone frame (for Super+T launcher)."
    (interactive)
    (let ((frame (selected-frame)))
      ;; Mark this frame as a vterm-standalone frame
      (set-frame-parameter frame 'vterm-standalone t)
      ;; Delete other windows to ensure clean slate
      (delete-other-windows)
      ;; Disable popup rules temporarily and create vterm in main window
      (let ((display-buffer-alist nil)
            (+popup-defaults nil))
        ;; Always create a NEW vterm instance with unique name
        (vterm t))
      ;; Ensure vterm buffer is in the main window
      (when (string-match-p "^\\*vterm\\*" (buffer-name))
        (delete-other-windows))))

  ;; Auto-close frame when vterm exits
  (defun my/vterm-close-frame-on-exit ()
    "Close the frame when vterm buffer is killed, if it's a standalone frame."
    (when (and (frame-parameter nil 'vterm-standalone)
               (string-match-p "^\\*vterm\\*" (buffer-name)))
      (delete-frame nil t)))

  (add-hook 'vterm-exit-functions
            (lambda (buffer event)
              (when (buffer-live-p buffer)
                (with-current-buffer buffer
                  (let ((frame (selected-frame)))
                    (when (frame-parameter frame 'vterm-standalone)
                      ;; Make frame invisible immediately to prevent flash
                      (make-frame-invisible frame t)
                      ;; Then delete it after a brief moment
                      (run-at-time 0.05 nil (lambda () (delete-frame frame t)))))))))

  ;; Don't prompt about killing processes when closing vterm frames
  (defun my/vterm-frame-delete-advice (orig-fun &rest args)
    "Close vterm frames without prompts about running processes."
    (let ((frame (or (car args) (selected-frame))))
      (if (frame-parameter frame 'vterm-standalone)
          ;; For vterm standalone frames, kill processes without asking
          (let ((kill-buffer-query-functions nil))
            (apply orig-fun args))
        ;; For normal frames, use default behavior
        (apply orig-fun args))))

  (advice-add 'delete-frame :around #'my/vterm-frame-delete-advice)

  ;; Better process handling - don't confirm kill
  (setq vterm-kill-buffer-on-exit t)
  (setq confirm-kill-processes nil)

  ;; Apply WezTerm Adwaita-dark theme to vterm
  (defun my/vterm-adwaita-theme ()
    "Apply WezTerm Adwaita-dark colors to vterm buffer."
    ;; Cursor - this works!
    (setq evil-emacs-state-cursor '("#ffffff" box))
    (face-remap-add-relative 'cursor :background "#ffffff" :foreground "#000000"))

  (add-hook 'vterm-mode-hook #'my/vterm-adwaita-theme t)

  ;; Copy function that syncs to system clipboard
  (defun my/vterm-copy-to-clipboard ()
    "Copy selected text to system clipboard (like WezTerm)."
    (interactive)
    (when (region-active-p)
      (let ((text (buffer-substring-no-properties (region-beginning) (region-end))))
        (kill-new text)  ; Add to kill-ring
        (gui-select-text text)  ; Explicitly sync to system clipboard
        (deactivate-mark)
        (message "Copied to clipboard"))))

  ;; Paste function that gets from system clipboard
  (defun my/vterm-paste-from-clipboard ()
    "Paste from system clipboard into vterm."
    (interactive)
    (let ((clipboard-text (or (gui-selection-value) (current-kill 0))))
      (when clipboard-text
        (vterm-send-string clipboard-text))))

  ;; Automatic copy-on-select - simple mouse-based approach
  (defun my/vterm-mouse-copy-selection (event)
    "Copy selection to clipboard after mouse drag."
    (interactive "e")
    (mouse-set-region event)
    (when (use-region-p)
      (let ((text (buffer-substring-no-properties (region-beginning) (region-end))))
        (unless (string-empty-p text)
          (kill-new text)
          (gui-select-text text)
          (message "Copied!")))))

  ;; Double-click to select word (whitespace-delimited)
  (defun my/vterm-select-word (event)
    "Select word at point (whitespace-separated) and copy to clipboard."
    (interactive "e")
    (mouse-set-point event)
    (let* ((bounds (bounds-of-thing-at-point 'symbol))
           (start (if bounds (car bounds) (point)))
           (end (if bounds (cdr bounds) (point))))
      ;; Extend to whitespace boundaries
      (save-excursion
        (goto-char start)
        (skip-syntax-backward "^ ")
        (setq start (point))
        (goto-char end)
        (skip-syntax-forward "^ ")
        (setq end (point)))
      (set-mark start)
      (goto-char end)
      (activate-mark)
      (let ((text (buffer-substring-no-properties start end)))
        (unless (string-empty-p text)
          (kill-new text)
          (gui-select-text text)
          (message "Copied word!")))))

  ;; Triple-click to select line
  (defun my/vterm-select-line (event)
    "Select entire line and copy to clipboard."
    (interactive "e")
    (mouse-set-point event)
    (let ((start (line-beginning-position))
          (end (line-end-position)))
      (set-mark start)
      (goto-char end)
      (activate-mark)
      (let ((text (buffer-substring-no-properties start end)))
        (unless (string-empty-p text)
          (kill-new text)
          (gui-select-text text)
          (message "Copied line!")))))

  ;; Enable mouse selection in vterm with auto-copy
  (define-key vterm-mode-map [drag-mouse-1] #'my/vterm-mouse-copy-selection)
  (define-key vterm-mode-map [double-mouse-1] #'my/vterm-select-word)
  (define-key vterm-mode-map [triple-mouse-1] #'my/vterm-select-line)

  ;; Keybindings: Emacs-style M-w / C-y
  (define-key vterm-mode-map (kbd "M-w") #'my/vterm-copy-to-clipboard)
  (define-key vterm-mode-map (kbd "C-y") #'my/vterm-paste-from-clipboard)

  ;; Keep Shift+Insert as alternative paste (traditional)
  (define-key vterm-mode-map (kbd "S-<insert>") #'my/vterm-paste-from-clipboard)

  ;; Prevent ESC from entering copy mode - send ESC to terminal instead
  (define-key vterm-mode-map (kbd "<escape>") #'vterm-send-escape)

  ;; Send Shift+Enter to terminal (for Claude Code multi-line input)
  (define-key vterm-mode-map (kbd "S-<return>")
    (lambda () (interactive) (vterm-send-key (kbd "RET") nil t nil)))

  ;; Enable visual selection mode with Shift+arrows (like traditional terminals)
  (define-key vterm-mode-map (kbd "S-<left>")
    (lambda () (interactive)
      (unless (region-active-p) (set-mark (point)))
      (backward-char)))
  (define-key vterm-mode-map (kbd "S-<right>")
    (lambda () (interactive)
      (unless (region-active-p) (set-mark (point)))
      (forward-char)))
  (define-key vterm-mode-map (kbd "S-<up>")
    (lambda () (interactive)
      (unless (region-active-p) (set-mark (point)))
      (previous-line)))
  (define-key vterm-mode-map (kbd "S-<down>")
    (lambda () (interactive)
      (unless (region-active-p) (set-mark (point)))
      (next-line))))
;; Set vterm ANSI color faces globally (will apply to all vterm buffers)
(custom-set-faces!
  '(vterm-color-black :foreground "#000000" :background "#000000")
  '(vterm-color-red :foreground "#c01c28" :background "#c01c28")
  '(vterm-color-green :foreground "#26a269" :background "#26a269")
  '(vterm-color-yellow :foreground "#a2734c" :background "#a2734c")
  '(vterm-color-blue :foreground "#2a7bde" :background "#2a7bde")
  '(vterm-color-magenta :foreground "#a347ba" :background "#a347ba")
  '(vterm-color-cyan :foreground "#2aa1b3" :background "#2aa1b3")
  '(vterm-color-white :foreground "#ffffff" :background "#ffffff")
  '(vterm-color-bright-black :foreground "#5e5c64" :background "#5e5c64")
  '(vterm-color-bright-red :foreground "#f66151" :background "#f66151")
  '(vterm-color-bright-green :foreground "#33d17a" :background "#33d17a")
  '(vterm-color-bright-yellow :foreground "#e9ad0c" :background "#e9ad0c")
  '(vterm-color-bright-blue :foreground "#2a7bde" :background "#2a7bde")
  '(vterm-color-bright-magenta :foreground "#c061cb" :background "#c061cb")
  '(vterm-color-bright-cyan :foreground "#33c7de" :background "#33c7de")
  '(vterm-color-bright-white :foreground "#ffffff" :background "#ffffff"))

;; Dired/Dirvish file associations (yazi-like behavior)
(after! dired
  ;; Configure what to omit: dotfiles only (not . and ..)
  (setq dired-omit-files "^\\.[^.].*$")

  (defun my/dired-open-file ()
    "Open file at point with external application based on file type."
    (interactive)
    (let* ((file (dired-get-file-for-visit))
           (ext (downcase (or (file-name-extension file) ""))))
      (cond
       ;; Video/audio files - open with mpv (don't open in Emacs)
       ((member ext '("mp4" "mkv" "avi" "mov" "webm" "flv" "mpv" "m4v" "wmv" "mp3" "flac" "wav" "ogg"))
        (message "Opening %s with mpv..." file)
        (start-process "mpv" nil "mpv" file))
       ;; Archive files - extract/unzip
       ((member ext '("zip" "tar" "gz" "bz2" "xz" "7z" "rar"))
        (let ((default-directory (file-name-directory file)))
          (message "Extracting %s..." file)
          (cond
           ((string= ext "zip")
            (shell-command (format "unzip -o %s" (shell-quote-argument file))))
           ((or (string= ext "tar") (string= ext "gz") (string= ext "bz2") (string= ext "xz"))
            (shell-command (format "tar -xf %s" (shell-quote-argument file))))
           ((string= ext "7z")
            (shell-command (format "7z x -y %s" (shell-quote-argument file))))
           ((string= ext "rar")
            (shell-command (format "unrar x -o+ %s" (shell-quote-argument file)))))
          (revert-buffer)))
       ;; Directories - navigate into them
       ((file-directory-p file)
        (dired-find-alternate-file))
       ;; Default - open in Emacs
       (t (find-file file)))))

  ;; Bind RET to custom function
  (map! :map dired-mode-map
        :n "RET" #'my/dired-open-file))

;; Same for dirvish if enabled
(after! dirvish
  ;; Disable video preview to avoid ffmpegthumbnailer error
  (setq dirvish-preview-dispatchers
        (remove 'video dirvish-preview-dispatchers))
  ;; Ensure dirvish shows dotfiles by default
  (setq dirvish-hide-details nil
        dirvish-hide-cursor nil)
  (map! :map dirvish-mode-map
        :n "RET" #'my/dired-open-file
        :n "zh" #'dired-omit-mode))  ; Toggle hidden files with zh (like vim)

;; ============================================================================
;; TRAMP Configuration - Remote file editing via SSH
;; ============================================================================

(after! tramp
  ;; Use sshx method (bypasses fancy shell prompts like oh-my-bash)
  (setq tramp-default-method "sshx")

  ;; Auto-save remote files locally
  (setq tramp-auto-save-directory "~/.config/emacs/.local/tramp-auto-save/")

  ;; Increase verbosity for debugging (set to 0 after fixing)
  (setq tramp-verbose 6)

  ;; Shell prompt regexp - must match remote prompt
  (setq tramp-shell-prompt-pattern
        "\\(?:^\\|\r\\)[^]#$%>\n]*#?[]#$%>] *\\(\\[[0-9;]*[a-zA-Z] *\\)*")

  ;; Disable bash completion on remote to prevent hangs
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)

  ;; Connection timeout settings
  (setq tramp-connection-timeout 10)
  (setq tramp-completion-reread-directory-timeout nil)

  ;; Use simple shell commands for faster response
  (setq tramp-use-ssh-controlmaster-options nil)

  ;; Clear TRAMP cache on connection issues
  (setq tramp-persistency-file-name
        (expand-file-name "tramp" (concat doom-cache-dir "/"))))

;; ============================================================================
;; Simple SSH Server Selection - No extra packages needed
;; ============================================================================

(defun my/ssh-hosts ()
  "Parse SSH config and return list of host aliases."
  (let ((ssh-config (expand-file-name "~/.ssh/config"))
        (hosts '()))
    (when (file-exists-p ssh-config)
      (with-temp-buffer
        (insert-file-contents ssh-config)
        (goto-char (point-min))
        (while (re-search-forward "^Host \\([^*\n]+\\)$" nil t)
          (push (match-string 1) hosts))))
    (reverse hosts)))

(defun my/ssh-connect ()
  "Select SSH server from config and connect with TRAMP."
  (interactive)
  (let* ((hosts (my/ssh-hosts))
         (host (completing-read "Connect to server: " hosts nil t)))
    (when host
      (find-file (format "/sshx:%s:~/" host)))))

(defun my/ssh-dired ()
  "Select SSH server and open dired in home directory."
  (interactive)
  (let* ((hosts (my/ssh-hosts))
         (host (completing-read "Open dired on server: " hosts nil t)))
    (when host
      (dired (format "/sshx:%s:~/" host)))))

;; Keybindings for SSH connections
(map! :leader
      (:prefix ("r" . "remote")
       :desc "Connect to SSH server" "s" #'my/ssh-connect
       :desc "Connect to SSH (dired)" "d" #'my/ssh-dired
       :desc "Cleanup TRAMP connections" "c" #'tramp-cleanup-all-connections
       :desc "Cleanup TRAMP buffers" "k" #'tramp-cleanup-all-buffers))

;; Quick access binding
(global-set-key (kbd "C-c s") #'my/ssh-connect)

;; ============================================================================
;; Org-Planka Integration - Export org files to Planka cards
;; ============================================================================

;; Load org-planka from lisp directory
(add-load-path! (expand-file-name "~/.config/emacs/lisp"))
(require 'org-planka)

;; Configure Planka instance
(setq planka-url "https://scanlister.dev")
(setq planka-username "roberttbrown@gmail.com")
(setq planka-password "T8Eoq3q5UCWXsyN%ta*e")  ; Stored for convenience

;; Optional: Set custom path to planka-api.py if not in default location
;; (setq planka-api-script (expand-file-name "~/.local/bin/planka-api.py"))

;; Keybindings for org-planka
(after! org
  (map! :map org-mode-map
        :localleader
        :desc "Export subtree to Planka" "p s" #'org-planka-export-subtree
        :desc "Export buffer to Planka"  "p b" #'org-planka-export-buffer
        :desc "Clear Planka cache"       "p c" #'planka--clear-cache
        :desc "Force reload org-planka"  "p r" #'planka--force-reload-config))

;; ============================================================================
;; Claude Code IDE Integration - AI assistant with Emacs awareness
;; ============================================================================

(use-package! claude-code-ide
  :config
  ;; Set the full path to claude executable
  (setq claude-code-ide-cli-path "/home/robert/.npm-global/bin/claude")

  ;; Set smaller font for claude-code-ide buffers to fix wrapping
  (defun my/claude-code-ide-set-font ()
    "Set a smaller font size for claude-code-ide buffer."
    (buffer-face-set :family "CaskaydiaCove Nerd Font" :height 100))  ; 100 = 10pt (default 160 = 16pt)

  (add-hook 'claude-code-ide-mode-hook #'my/claude-code-ide-set-font)

  ;; Setup Emacs tools integration via MCP
  (claude-code-ide-emacs-tools-setup)

  ;; Keybindings for Claude Code
  (map! :leader
        (:prefix ("C" . "claude")
         :desc "Claude Code Menu" "c" #'claude-code-ide-menu
         :desc "Start Claude" "s" #'claude-code-ide
         :desc "Continue conversation" "C" #'claude-code-ide-continue
         :desc "Resume session" "r" #'claude-code-ide-resume
         :desc "Stop Claude" "q" #'claude-code-ide-stop
         :desc "Toggle window" "t" #'claude-code-ide-toggle
         :desc "Switch to buffer" "b" #'claude-code-ide-switch-to-buffer))

  ;; Alternative direct keybinding
  (global-set-key (kbd "C-c '") #'claude-code-ide-menu)

  ;; Disable evil mode in claude-code-ide buffers
  (evil-set-initial-state 'claude-code-ide-mode 'emacs)

  ;; Add keybinding to refocus input when cursor gets stuck
  (defun my/claude-focus-input ()
    "Jump back to the Claude input box."
    (interactive)
    (when (derived-mode-p 'claude-code-ide-mode)
      (goto-char (point-max))
      (message "Refocused on input")))

  ;; Bind C-c C-i to refocus input in claude-code-ide buffers
  (add-hook 'claude-code-ide-mode-hook
            (lambda ()
              (local-set-key (kbd "C-c C-i") #'my/claude-focus-input))))

;; ============================================================================
;; Alternative Leader Key - Let Doom handle automatic mirroring
;; ============================================================================
;; Doom automatically mirrors SPC to M-SPC in emacs/insert states
;; We've removed manual bindings to test if Doom's mirroring works properly
