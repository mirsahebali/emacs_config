(org-babel-load-file
 (expand-file-name
  "config.org"
  user-emacs-directory))

(set-frame-parameter nil 'alpha-background 60)

(add-to-list 'default-frame-alist '(alpha-background . 70))

(setq display-line-numbers-type 'relative)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("80214de566132bf2c844b9dee3ec0599f65c5a1f2d6ff21a2c8309e6e70f9242" "d23073a9616156a16aecbd3d38e1c3a1f006fc5d920e3fbcb681411e35d2a096" "4990532659bb6a285fee01ede3dfa1b1bdf302c5c3c8de9fad9b6bc63a9252f7" "8c7e832be864674c220f9a9361c851917a93f921fedb7717b1b5ece47690c098" "014cb63097fc7dbda3edf53eb09802237961cbb4c9e9abd705f23b86511b0a69" "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d" "aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8" "0527c20293f587f79fc1544a2472c8171abcc0fa767074a0d3ebac74793ab117" default))
 '(evil-org-key-theme
   '(navigation insert return textobjects additional shift todo heading calendar))
 '(evil-org-mode-hook nil)
 '(go-impl-aliases-alist '(("hh" . "http.Handler") ("irw" . "io.ReadWriter")))
 '(newsticker-url-list
   '(("" "https://planet.kde.org/global/atom.xml/" nil nil nil)
     ("" "https://vkc.sh/feed/" nil nil nil)
     ("" "https://www.developer.com/open-source/feed/" nil nil nil)
     ("" "https://dev.to/rss" nil nil nil)
     ("" "https://martinfowler.com/feed.atom" nil nil nil)
     ("" "https://medium.com/feed/airbnb-engineering" nil nil nil)
     ("" "http://feeds.feedburner.com/se-radio" nil nil nil)
     ("" "https://www.toptal.com/blog.rss" nil nil nil)
     ("" "https://netflixtechblog.com/feed" nil nil nil)
     ("" "https://www.uber.com/en-IN/blog/mumbai/engineering/rss/" nil nil nil)
     ("" "https://blog.codinghorror.com/rss/" nil nil nil)
     ("" "https://catonmat.net/feed" nil nil nil)
     ("" "https://medium.engineering/feed" nil nil nil)))
 '(org-agenda-block-separator 61)
 '(org-agenda-loop-over-headlines-in-active-region nil)
 '(org-agenda-prefix-format
   '((dashboard-agenda . " %i %-12:c %s ")
     (agenda . " %i %-12:c%?-12t% s")
     (todo . " %i %-12:c")
     (tags . " %i %-12:c")
     (search . " %i %-12:c")))
 '(org-edit-src-content-indentation 0)
 '(org-link-translation-function 'toc-org-unhrefify)
 '(org-roam-db-autosync-mode t)
 '(org-support-shift-select 'always))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(evil-goggles-change-face ((t (:inherit diff-removed))))
 '(evil-goggles-delete-face ((t (:inherit diff-removed))))
 '(evil-goggles-paste-face ((t (:inherit diff-added))))
 '(evil-goggles-undo-redo-add-face ((t (:inherit diff-added))))
 '(evil-goggles-undo-redo-change-face ((t (:inherit diff-changed))))
 '(evil-goggles-undo-redo-remove-face ((t (:inherit diff-removed))))
 '(evil-goggles-yank-face ((t (:inherit diff-changed)))))
