(setq debug-on-error t)


(defvar elpaca-installer-version 0.6)
 (defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
 (defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
 (defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
 (defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
				:ref nil
				:files (:defaults (:exclude "extensions"))
				:build (:not elpaca--activate-package)))
 (let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
	 (build (expand-file-name "elpaca/" elpaca-builds-directory))
	 (order (cdr elpaca-order))
	 (default-directory repo))
   (add-to-list 'load-path (if (file-exists-p build) build repo))
   (unless (file-exists-p repo)
     (make-directory repo t)
     (when (< emacs-major-version 28) (require 'subr-x))
     (condition-case-unless-debug err
	  (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
		   ((zerop (call-process "git" nil buffer t "clone"
					 (plist-get order :repo) repo)))
		   ((zerop (call-process "git" nil buffer t "checkout"
					 (or (plist-get order :ref) "--"))))
		   (emacs (concat invocation-directory invocation-name))
		   ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
					 "--eval" "(byte-recompile-directory \".\" 0 'force)")))
		   ((require 'elpaca))
		   ((elpaca-generate-autoloads "elpaca" repo)))
	      (kill-buffer buffer)
	    (error "%s" (with-current-buffer buffer (buffer-string))))
	((error) (warn "%s" err) (delete-directory repo 'recursive))))
   (unless (require 'elpaca-autoloads nil t)
     (require 'elpaca)
     (elpaca-generate-autoloads "elpaca" repo)
     (load "./elpaca-autoloads")))
 (add-hook 'after-init-hook #'elpaca-process-queues)
 (elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

;;When installing a package which modifies a form used at the top-level
;;(e.g. a package which adds a use-package key word),
;;use `elpaca-wait' to block until that package has been installed/configured.
;;For example:
;;(use-package general :demand t)
;;(elpaca-wait)

;; Expands to: (elpaca evil (use-package evil :demand t))
    (use-package evil
        :init      ;; tweak evil's configuration before loading it
            (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
            (setq evil-want-keybinding nil)
            (setq evil-vsplit-window-right t)
            (setq evil-split-window-below t)
        :config
            (evil-set-undo-system 'undo-redo)
            (evil-mode))
  (use-package evil-collection
        :after evil
        :config
            (setq evil-collection-mode-list '(dashboard dired ibuffer))
            (evil-collection-init))
    (use-package evil-tutor)
    (use-package evil-surround
        :ensure t
        :config
            (global-evil-surround-mode 1))
    ;;Turns off elpaca-use-package-mode current declartion
    ;;Note this will cause the declaration to be interpreted immediately (not deferred).
    ;;Useful for configuring built-in emacs features.
    (use-package emacs :elpaca nil :config (setq ring-bell-function #'ignore))

;; Don't install anything. Defer execution of BODY
;;(elpaca nil (message "deferred"))

(use-package general
  :config
  (general-evil-setup)

  ;; set up 'SPC' as the global leader key
  (general-create-definer saheb/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  (saheb/leader-keys
    "." '(find-file :wk "Find file")
    "s c" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit emacs config")
    "f s" '(save-buffer :wk "File Save")
    "f m" '(treemacs :wk "File Tree")
    )

  (saheb/leader-keys
    "b" '(:ignore t :wk "buffer")
    "b b" '(switch-to-buffer :wk "Switch buffer")
    "b i" '(ibuffer :wk "Ibuffer")
    "b d" '(kill-this-buffer :wk "Kill this buffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer"))

  (saheb/leader-keys
    "e" '(:ignore t :wk "Evaluate")    
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp expression")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region")) 

   (saheb/leader-keys
    "h" '(:ignore t :wk "Help/Errors")
    "h f" '(describe-function :wk "Describe function")
    "h v" '(describe-variable :wk "Describe variable")
    "h e" '(flycheck-list-errors :wk  "List errors in buffer")
    ;;"h r r" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "Reload emacs config"))
    "h r r" '(reload-init-file :wk "Reload emacs config"))

   (saheb/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t t" '(visual-line-mode :wk "Toggle truncated lines"))
 (saheb/leader-keys
    "m" '(:ignore t :wk "Org")
    "m a" '(org-agenda :wk "Org agenda")
    "m e" '(org-export-dispatch :wk "Org export dispatch")
    "m i" '(org-toggle-item :wk "Org toggle item")
    "m t" '(org-todo :wk "Org todo")
    "m B" '(org-babel-tangle :wk "Org babel tangle")
    "m T" '(org-todo-list :wk "Org todo list"))

  (saheb/leader-keys
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

  (saheb/leader-keys
    "m d" '(:ignore t :wk "Date/deadline")
    "m d t" '(org-time-stamp :wk "Org time stamp"))

  (saheb/leader-keys
    "p" '(projectile-command-map :wk "Projectile"))

(saheb/leader-keys
    "q" '(kill-buffer-and-window :wk "Kill buffer and window"))

  (saheb/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))
;; 'g-keys'
    (general-create-definer saheb/g-keys
        :states '(normal visual)
        :keymaps 'override
        :prefix "g" ;; set g
    )
    (saheb/g-keys 
	    "c" '(:ignore t :wk "Comment")
        "c c" '(comment-line :wk "Comment line")
        "c b" '(comment-box :wk "Comment box"))
;; 'Registers' mappings
    (general-define-key 
	    :states '(normal visual)
	    " \" " '(view-register :wk "Registers"))
;; 'JK' to escape
    (general-imap "j"
	(general-key-dispatch 'self-insert-command 
	:timeout 0.25
	"k" 'evil-normal-state))
;; 'LSP' keymaps
    (general-define-key
        :states '(normal visual)
        "K" 'lsp-ui-doc-glance)
;; 'ORG' keymaps to move between headings
    (general-define-key
        :states '(normal visual)
        :keymaps 'org-mode-map
            "gj" 'org-next-visible-heading
            "gk" 'org-previous-visible-heading)
;; Better 'Buffer' navigation
    (general-define-key
        :states '(normal visual emacs)
            "M-i" 'next-buffer
            "M-u" 'previous-buffer)
    (general-define-key
        :states '(normal visual emacs)
            "C-h" '(evil-window-left :wk "Window left")
            "C-j" '(evil-window-down :wk "Window down")
            "C-k" '(evil-window-up :wk "Window up")
            "C-l" '(evil-window-right :wk "Window right")
)
(general-define-key
        :states '(normal visual emacs)
            "M-j" '(evil-collection-unimpaired-move-text-down :wk "Move Text Down")
            "M-k" '(evil-collection-unimpaired-move-text-up :wk "Move Text Up"))
)

(use-package undo-fu
  :config
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z")   'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo))
(use-package undo-fu-session)

(electric-pair-mode)

(set-face-attribute 'default nil
  :font "JetBrains Mono Nerd Font"
  :height 110
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "JetBrains Mono Nerd Font"
  :height 120
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "JetBrains Mono Nerd Font"
  :height 110
  :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "JetBrains Mono Nerd Font-11"))

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(electric-indent-mode -1)
(setq org-edit-src-content-indentation 0)

(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(require 'org-tempo)

(use-package projectile
  :config
  (projectile-mode 1))

(use-package rainbow-mode
  :diminish
  :hook 
  ((org-mode prog-mode) . rainbow-mode))

(use-package which-key
 :init
   (which-key-mode 1)
 :config
    (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-max-display-columns nil
        which-key-min-display-lines 7
        which-key-side-window-slot -10
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.8
        which-key-max-description-length 25
        which-key-allow-imprecise-window-fit t
        which-key-separator " → " ))

(use-package company
     :defer 2
     :diminish
     :init
     (setq company-backends `((:separate company-capf company-yasnippet)))
     :config
     (setq lsp-completion-provider :none)
     :custom
     (company-begin-commands '(self-insert-command))
     (company-idle-delay .1)
     (company-minimum-prefix-length 2)
     (company-show-numbers t)
     (company-tooltip-align-annotations 't)
     (global-company-mode t))

   (use-package company-box
     :after company
     :diminish
     :hook (company-mode . company-box-mode))
   (use-package auto-complete
   :config
(ac-config-default)
   )

;;(use-package polymode
;;:ensure t))

;;(use-package poly-markdown
 ;; :ensure t
;;:config
;;(add-to-list 'auto-mode-alist '("\\.md" . poly-markdown-mode)))

(use-package flycheck
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode))

(use-package magit)

(use-package lsp-mode :hook ((lsp-mode . lsp-enable-which-key-integration)))
(use-package lsp-ui)
(use-package dap-mode :after lsp-mode :config (dap-auto-configure-mode))
(use-package lsp-treemacs)

(use-package go-mode
        :config
            (setq company-idle-delay 0)
            (setq company-minimum-prefix-length 1)

            ;; Go - lsp-mode
            ;; Set up before-save hooks to format buffer and add/delete imports.
            (defun lsp-go-install-save-hooks ()
            (add-hook 'before-save-hook #'lsp-format-buffer t t)
            (add-hook 'before-save-hook #'lsp-organize-imports t t))
            (add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

            ;; Start LSP Mode and YASnippet mode
            (add-hook 'go-mode-hook #'lsp-deferred)
            (add-hook 'go-mode-hook #'yas-minor-mode)
       ) 
    (use-package go-impl
        :config
            (custom-set-variables
            '(go-impl-aliases-alist '(("hh" . "http.Handler")
                                ("irw" . "io.ReadWriter"))))
)

(use-package haskell-mode)
(use-package lsp-haskell)

(use-package lua-mode)

(use-package web-mode
:config
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
)
(use-package emmet-mode
:config
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation.
(add-hook 'web-mode-hook 'emmet-mode)
(add-hook 'html-hook 'emmet-mode)

(add-hook 'html-hook 'emmet-preview-mode)
(add-hook 'sgml-mode-hook 'emmet-preview-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook  'emmet-preview-mode) ;; enable Emmet's css abbreviation.
(add-hook 'web-mode-hook 'emmet-preview-mode )
)

(use-package yasnippet
:config 
(define-key yas-minor-mode-map (kbd "M-o") #'yas-expand)
(yas-global-mode)
)
(use-package yasnippet-snippets)

(use-package counsel
  :after ivy
  :diminish
  :config (counsel-mode))

(use-package ivy
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :diminish
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package harpoon
:after 
general
:config
(general-create-definer harpoon/leader-keys
:prefix "C-SPC"
)
(harpoon/leader-keys
:keymaps 'normal
"m" '(harpoon-quick-menu-hydra :wk "Harpoon Quick Menu")
"a" '(harpoon-add-file :wk "Harpoon add current file"))
;;"1"
;;"2"
;;"3"
)

(use-package centaur-tabs
  :init
  (setq centaur-tabs-enable-key-bindings t)
  :config
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 32
        centaur-tabs-set-icons t
        centaur-tabs-show-new-tab-button t
        centaur-tabs-set-modified-marker t
        centaur-tabs-show-navigation-buttons t
        centaur-tabs-set-bar 'under
        centaur-tabs-show-count nil
        ;; centaur-tabs-label-fixed-length 15
        ;; centaur-tabs-gray-out-icons 'buffer
        ;; centaur-tabs-plain-icons t
        x-underline-at-descent-line t
        centaur-tabs-left-edge-margin nil)
  (centaur-tabs-change-fonts (face-attribute 'default :font) 110)
  (centaur-tabs-headline-match)
  ;; (centaur-tabs-enable-buffer-alphabetical-reordering)
  ;; (setq centaur-tabs-adjust-buffer-order t)
  (centaur-tabs-mode t)
  (setq uniquify-separator "/")
  (setq uniquify-buffer-name-style 'forward)
  (defun centaur-tabs-buffer-groups ()
    "`centaur-tabs-buffer-groups' control buffers' group rules.

Group centaur-tabs with mode if buffer is derived from `eshell-mode' `emacs-lisp-mode' `dired-mode' `org-mode' `magit-mode'.
All buffer name start with * will group to \"Emacs\".
Other buffer group by `centaur-tabs-get-group-name' with project name."
    (list
     (cond
      ;; ((not (eq (file-remote-p (buffer-file-name)) nil))
      ;; "Remote")
      ((or (string-equal "*" (substring (buffer-name) 0 1))
           (memq major-mode '(magit-process-mode
                              magit-status-mode
                              magit-diff-mode
                              magit-log-mode
                              magit-file-mode
                              magit-blob-mode
                              magit-blame-mode
                              )))
       "Emacs")
      ((derived-mode-p 'prog-mode)
       "Editing")
      ((derived-mode-p 'dired-mode)
       "Dired")
      ((memq major-mode '(helpful-mode
                          help-mode))
       "Help")
      ((memq major-mode '(org-mode
                          org-agenda-clockreport-mode
                          org-src-mode
                          org-agenda-mode
                          org-beamer-mode
                          org-indent-mode
                          org-bullets-mode
                          org-cdlatex-mode
                          org-agenda-log-mode
                          diary-mode))
       "OrgMode")
      (t
       (centaur-tabs-get-group-name (current-buffer))))))
  :hook
  (dashboard-mode . centaur-tabs-local-mode)
  (term-mode . centaur-tabs-local-mode)
  (calendar-mode . centaur-tabs-local-mode)
  (org-agenda-mode . centaur-tabs-local-mode)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward)
  ("C-S-<prior>" . centaur-tabs-move-current-tab-to-left)
  ("C-S-<next>" . centaur-tabs-move-current-tab-to-right)
  (:map evil-normal-state-map
        ("g t" . centaur-tabs-forward)
        ("g T" . centaur-tabs-backward)))

(use-package catppuccin-theme
    :init
    (load-theme 'catppuccin))

(use-package hl-todo
:ensure t
:config
(setq hl-todo-keyword-faces
      '(("TODO"   . "#FF0000")
        ("FIXME"  . "#FF0000")
        ("DEBUG"  . "#A020F0")
        ("GOTCHA" . "#FF4500")
	    ("NOTE"   . "#00FFEF")
        ("REFACTOR" . "#E4E8FF")
        ("REVIEW". "#FFC0CB")
        ("PERF" . "#7D7EEC")
        ("STUB"   . "#1E90FF")))

        (hl-todo-mode)
)

(use-package nerd-icons
   ;; :custom
   ;; The Nerd Font you want to use in GUI
   ;; "Symbols Nerd Font Mono" is the default and is recommended
   ;; but you can use any other Nerd Font if you want
   ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
   )
(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(use-package dashboard
  :ensure t 
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "R.T.F.M.  Run The Funking Monad")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner "/home/mirsahebali/.config/emacs/images/Arch-linux-logo.png")  ;; use custom image as banner
  (setq dashboard-center-content t) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)))
  :custom
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

(use-package neotree
:init
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))
)

(use-package treemacs)
(use-package treemacs-evil
 :after (treemacs evil)
:ensure t
:config
(treemacs-load-theme "Idea")
)

(use-package treemacs-projectile
 :after (treemacs evil projectile)
  :ensure t)

(use-package treemacs-icons-dired
 :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
 :after (treemacs evil magit)
  :ensure t)

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
 :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :ensure t
 :config (treemacs-set-scope-type 'Perspectives))

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
 :after (treemacs)
  :ensure t
 :config (treemacs-set-scope-type 'Tabs))

(use-package doom-modeline
:ensure t
:init (doom-modeline-mode 1)
)

(use-package diminish)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package perspective
  :bind
  ("C-x C-b" . persp-list-buffers)         ; or use a nicer switcher, see below
  :custom
  (persp-mode-prefix-key (kbd "M-W"))  ; pick your own prefix key here
  :init
  (persp-mode))

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
;;  "Switches between the current buffer, and the buffer above the
;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
"Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
"Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
"Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(defun reload-init-file ()
  (interactive)
  (load-file user-init-file)
  (load-file user-init-file))

(add-to-list 'display-buffer-alist
             '("\\`\\*shell\\*\\(?:<[[:digit:]]+>\\)?\\'"
               (display-buffer-in-side-window (side . bottom))))

(use-package literate-calc-mode
  :ensure t)

(use-package transient
:ensure t)
