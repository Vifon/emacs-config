(add-to-list 'load-path "~/.emacs.d/my-fixes")
(add-to-list 'load-path "~/.emacs.d/vifon")
(add-to-list 'load-path "~/.emacs.d/modules")
(require 'my-compat)

;; (setq package-archives
;;       '(("gnu"       . "http://elpa.gnu.org/packages/")
;;         ("marmalade" . "http://marmalade-repo.org/packages/")
;;         ("elpa"      . "http://tromey.com/elpa/")
;;         ("melpa"     . "http://melpa.org/packages/")))

(require 'cask "~/.cask/cask.el")
(add-to-list 'auto-mode-alist '("/Cask\\'" . emacs-lisp-mode))
(add-to-list 'auto-mode-alist '("/emacs\\'" . emacs-lisp-mode))
(cask-initialize)
(require 'pallet)
(pallet-mode 1)
(setq package-enable-at-startup nil)
(package-initialize)
(require 'use-package)

(use-package key-chord
  :config (progn
            (setq key-chord-two-keys-delay 0.050
                  key-chord-one-key-delay  0.070)
            (key-chord-mode 1)))


(require 'my-hooks)
(require 'my-skeletons)
(require 'my-mode-line)
(require 'my-fun)
(require 'my-keys)
(require 'my-god-mode)
(require 'my-helm)
(require 'my-ibuffer)
(require 'my-org)
(require 'my-eshell)
(require 'my-fixes)
(require 'my-registers)
(require 'my-global-settings)

(require 'pastes-from-web)

(use-package ido
  :init (progn
          (setq ido-vertical-define-keys nil)
          (ido-everywhere 1)
          (ido-mode 1)
          (flx-ido-mode 1)
          (ido-vertical-mode 1))
  :config (progn
            (setq ido-enable-flex-matching t
                  ido-enable-tramp-completion nil
                  ido-default-file-method 'selected-window
                  ido-default-buffer-method 'selected-window
                  ido-auto-merge-work-directories-length -1
                  ido-use-virtual-buffers t)
            (add-hook 'ido-setup-hook
                      (defun my-ido-keys ()
                        (define-key ido-file-dir-completion-map
                          (kbd "M-a") 'ido-merge-work-directories)
                        (define-key ido-completion-map
                          (kbd "C-n") 'ido-next-match)
                        (define-key ido-completion-map
                          (kbd "C-p") 'ido-prev-match)))))

(use-package globalff
  :commands globalff)

(use-package paredit
  :diminish "[()]"
  :commands paredit-mode
  :init (setq paredit-space-for-delimiter-predicates
              '((lambda (endp delimiter) nil)))
  :config (progn
            (define-key paredit-mode-map (kbd "M-s") nil)
            (define-key paredit-mode-map (kbd "M-s M-s") 'paredit-splice-sexp)

            (defun paredit-kill-maybe (arg)
              (interactive "P")
              (if (consp arg)
                  (paredit-kill)
                  (kill-line arg))))
  :bind (([remap kill-line] . paredit-kill-maybe)))

(use-package autopair
  :commands autopair-mode)

(use-package hideshow
  :defer t
  :config (progn
            (key-chord-define hs-minor-mode-map
                              "`;" 'hs-hide-level)
            (define-key hs-minor-mode-map (kbd "<M-left>") 'hs-hide-block)
            (define-key hs-minor-mode-map (kbd "<M-right>") 'hs-show-block)
            (define-key hs-minor-mode-map (kbd "<M-up>") 'hs-hide-level)
            (define-key hs-minor-mode-map (kbd "<M-down>") 'hs-show-all)))

(use-package yafolding
  :defer t
  :init (add-hook 'prog-mode-hook #'yafolding-mode)
  :config (defadvice yafolding-go-parent-element
              (around yafolding-python-fix activate)
            (if (eq major-mode 'python-mode)
                (python-nav-backward-up-list)
                ad-do-it)))

(use-package hideshow-org
  :commands hs-org/minor-mode)

(use-package dired-x
  :pre-load (setq dired-x-hands-off-my-keys t))

(use-package yasnippet
  :diminish yas-minor-mode
  :commands yas-global-mode
  :idle (yas-global-mode 1)
  :init (progn (setq yas-trigger-key "TAB"
                     yas-snippet-dirs '("~/.emacs.d/snippets")
                     yas-prompt-functions '(yas/dropdown-prompt
                                            yas/ido-prompt
                                            yas/x-prompt
                                            yas/completing-prompt
                                            yas/no-prompt)
                     auto-mode-alist (cons '("emacs\.d/snippets/" . snippet-mode)
                                           auto-mode-alist)))
  :config (use-package auto-yasnippet
            :bind (("C-c Y" . aya-create)
                   ("C-c y" . aya-expand))))

(use-package tiny
  :bind ("C-c M-y" . tiny-expand))

(use-package hydra
  :bind (("C-c e" . vydra/body))
  :config (progn
            (defhydra vydra
                (global-map "C-c e")
              "vi-hydra"

              ("h" backward-char "left")
              ("j" next-line "down")
              ("k" previous-line "up")
              ("l" forward-char "right")

              ("f" scroll-up-command "PgDn")
              ("b" scroll-down-command "PgUp")

              ("v" er/expand-region "select")

              ("0" move-beginning-of-line-dwim "BOL")
              ("a" move-beginning-of-line-dwim "BOL")
              ("e" move-end-of-line "EOL")

              ("i" nil "quit")
              ("q" nil "quit"))))

(use-package undo-tree
  :diminish undo-tree-mode
  :config (global-undo-tree-mode 1))

(use-package auctex
  :defer t
  :init (setq preview-scale-function 2.0))

(use-package hippie-expand-ido
  :bind ("C-c /" . my-ido-hippie-expand))

(use-package legalese
  :config (defun legalese-box (ask)
            (interactive "P")
            (let ((comment-style 'box))
              (legalese ask))))

(use-package minimap
  :bind ("C-c n" . minimap-toggle)
  :config (defun minimap-toggle ()
            (interactive)
            (if (and minimap-bufname
                     (get-buffer minimap-bufname)
                     (get-buffer-window (get-buffer minimap-bufname)))
                (minimap-kill)
                (minimap-create))))

(use-package transpose-frame
  :bind (("C-x 4 t" . transpose-frame)
         ("C-x 4 i" . flop-frame)
         ("C-x 4 I" . flip-frame)))

(use-package ace-window
  :bind ("C-x O" . ace-window))

(use-package vim-line-open
  :bind ("C-o" . open-next-line-dwim))

(use-package evil-nerd-commenter
  :init (defun evil-nerd-commenter-dwim (arg)
          (interactive "P")
          (if arg
              (evilnc-comment-or-uncomment-lines arg)
              (call-interactively 'comment-dwim)))
  :bind (([remap comment-dwim] . evil-nerd-commenter-dwim)))

(use-package neotree
  :bind (("C-c b" . neotree-toggle)
         ("C-c B" . neotree-find)))

(use-package magit
  :diminish magit-auto-revert-mode
  :bind (("C-c g" . magit-status)
         ("C-x v C-l" . magit-log)
         ("C-x v f" . magit-file-log))
  :init (key-chord-define-global "`m" 'magit-status))

(use-package git-commit-mode
  :defer t
  :config (progn
           (define-key git-commit-mode-map (kbd "C-c C-l") 'magit-log)
           (add-hook 'git-commit-mode-hook 'turn-on-orgstruct++)))

(use-package git-messenger
  :bind ("C-x v p" . git-messenger:popup-message))

(use-package git-timemachine
  :bind ("C-x v t" . git-timemachine))

(use-package ed
  :commands ed)

(use-package goto-last-change
  :demand t
  :bind ("C-x C-\\" . goto-last-change))

(use-package highlight-symbol
  :demand t
  :bind (("<f10>"   . highlight-symbol-at-point)
         ("<C-f10>" . highlight-symbol-reset)
         ("C-c w"   . highlight-symbol-at-point)
         ("C-c W"   . highlight-symbol-reset)
         ("<f11>"   . highlight-symbol-prev)
         ("M-p"     . highlight-symbol-prev)
         ("<f12>"   . highlight-symbol-next)
         ("M-n"     . highlight-symbol-next))
  :init (key-chord-define-global "nl" 'highlight-symbol-at-point)
  :config (defun highlight-symbol-reset ()
            (interactive)
            (highlight-symbol-remove-all)
            (setq highlight-symbol-color-index 0)))

(use-package sentence-highlight
  :commands sentence-highlight-mode)

(use-package indent-guide
  :defer t
  :config (setq indent-guide-delay nil))

(use-package visual-regexp-steroids
  :bind (([remap query-replace-regexp]    . vr/query-replace)
         ([remap isearch-forward-regexp]  . vr/isearch-forward)
         ([remap isearch-backward-regexp] . vr/isearch-backward)))

(use-package volatile-highlights
  :diminish volatile-highlights-mode
  :config (volatile-highlights-mode 1))

(use-package column-marker
  :bind ("C-c u" . column-marker-1))

(use-package typopunct)

(use-package fic-ext-mode
  :diminish fic-ext-mode
  :init (add-hook 'prog-mode-hook
                  #'(lambda () (fic-ext-mode 1)))
  :config (progn
            (defun fic-search-re ()
              "Regexp to search for"
              (let ((fic-words-re (regexp-opt fic-highlighted-words 'words)))
                (concat fic-words-re "\\(?:(\\(" fic-author-name-regexp "\\))\\)?")))
            (add-to-list 'fic-highlighted-words "XXX" 'append)))

(use-package multiple-cursors
  :bind (("C-<"         . mc/mark-previous-like-this)
         ("C->"         . mc/mark-next-like-this)
         ("C-+"         . mc/mark-next-like-this)
         ("C-c h h"     . mc/edit-lines)
         ("C-c h C-e"   . mc/edit-ends-of-lines)
         ("C-c h C-a"   . mc/edit-beginnings-of-lines)
         ("C-c h r"     . mc/reverse-regions)
         ("C-c h C-SPC" . set-rectangular-region-anchor)
         ("C-*"         . mc/mark-all-like-this-dwim)
         ("C-c h e"     . mc/mark-more-like-this-extended)
         ("M-<mouse-1>" . mc/add-cursor-on-click))
  :init (progn
          (global-unset-key (kbd "M-<down-mouse-1>"))
          (key-chord-define-global "[e" 'mc/mark-previous-like-this)
          (key-chord-define-global "]e" 'mc/mark-next-like-this)
          (use-package phi-search
            :bind (("C-s" . phi-search-dwim)
                   ("C-r" . phi-search-backward-dwim))
            :config (progn
                      (defun phi-search-dwim (arg)
                        (interactive "P")
                        (if arg
                            (phi-search)
                            (call-interactively 'isearch-forward)))
                      (defun phi-search-backward-dwim (arg)
                        (interactive "P")
                        (if arg
                            (phi-search-backward)
                            (call-interactively 'isearch-backward))))))
  :config (progn
            (define-key mc/keymap (kbd "C-s") 'phi-search)
            (define-key mc/keymap (kbd "C-r") 'phi-search-backward)))

(use-package multifiles
  :bind ("C-!" . mf/mirror-region-in-multifile))

(use-package iedit
  :bind ("C-;" . iedit-mode))

(use-package vcursor
  :pre-load (setq vcursor-key-bindings t)
  :config (global-set-key (kbd "C-M-<tab>") 'vcursor-swap-point))

(use-package expand-region
  :bind ("C-=" . er/expand-region)
  :init (key-chord-define-global "'e" 'er/expand-region))

(use-package semantic
  :defer t
  :config (progn
            (setq semantic-default-submodes
                  '(global-semantic-idle-scheduler-mode
                    global-semanticdb-minor-mode
                    global-semantic-decoration-mode
                    global-semantic-stickyfunc-mode))
            (use-package semantic/decorate/mode
              :config (setq-default semantic-decoration-styles
                                    '(("semantic-decoration-on-includes" . t))))))

(use-package company
  :diminish "comp"
  :idle (global-company-mode 1)
  :config (progn
            (setq company-idle-delay 0.25)
            (add-hook 'c++-mode-hook
                      #'(lambda ()
                          (make-local-variable 'company-clang-arguments)
                          (setq company-clang-arguments '("-std=c++11"))))
            (setq company-backends '(company-bbdb
                                     company-nxml
                                     company-css
                                     company-eclim
                                     company-semantic
                                     ;; company-clang
                                     company-xcode
                                     company-ropemacs
                                     company-cmake
                                     company-capf
                                     (company-gtags
                                      company-etags
                                      :with
                                      company-keywords
                                      company-dabbrev-code)
                                     company-clang ; moved down
                                     company-oddmuse
                                     company-files
                                     company-dabbrev))
            (add-hook 'eshell-mode-hook '(lambda ()
                                           (company-mode 0)))
            (add-hook 'org-mode-hook '(lambda ()
                                        (company-mode 0))))
  :bind (("C-c v" . company-complete)
         ("C-c V" . company-clang))
  :demand t)

(use-package flycheck
  :defer t
  :config (add-hook 'c++-mode-hook
                    #'(lambda ()
                        (setq flycheck-clang-language-standard "c++11"
                              flycheck-gcc-language-standard "c++11"))))

(use-package cpputils-cmake
  :commands (cppcm-reload-all cppcm-get-exe-path-current-buffer)
  :init (progn
          ;; (add-hook 'c-mode-common-hook
          ;;           (defun my-cpputils-cmake-hook ()
          ;;             (if (derived-mode-p 'c-mode 'c++-mode)
          ;;                 (cppcm-reload-all))))
          (defun gdb-dwim ()
            (interactive)
            (gud-gdb (concat gud-gdb-command-name
                             " --fullname "
                             (cppcm-get-exe-path-current-buffer)))))
  :config (setq cppcm-write-flymake-makefile nil))

(ignore-errors
  (use-package racer
    :load-path "~/src/racer/editors"
    :config (progn
              (setq racer-rust-src-path "/home/vifon/src/rust/src")
              (setq racer-cmd "racer")
              (eval-after-load "rust-mode" '(require 'racer)))))

(use-package bbyac
  :diminish bbyac-mode
  :config (progn
            (bbyac-global-mode 1)
            (define-key bbyac-mode-map (kbd "M-?") 'bbyac-expand-partial-lines)
            (define-key bbyac-mode-map (kbd "C-M-/") 'bbyac-expand-symbols)))

(use-package sx
  :defer t
  :init (use-package sx-search
          :defer t
          :commands sx-search))

(use-package ace-jump-mode
  :bind ("C-c j" . ace-jump-mode)
  :config (setq ace-jump-mode-scope 'frame))

(use-package win-switch
  :bind ("C-x o" . win-switch-dispatch)
  :config (setq win-switch-window-threshold 0))

(use-package popwin
  :defer t
  :config (progn
            (setq popwin:popup-window-height 25)))

(use-package tabbar
  :commands tabbar-mode)

(use-package bbcode-mode
  :commands bbcode-mode)

(use-package c-c++-header
  :mode ("\\.h\\'" . c-c++-header)
  :init (defalias 'h++-mode 'c++-mode))

(use-package uniquify
  :config (setq uniquify-buffer-name-style 'forward
                uniquify-strip-common-suffix t))

(use-package markdown-mode
  :mode ("\\.md$" . markdown-mode))

(use-package pod-mode
  :mode ("\\.pod$" . pod-mode))

(use-package crontab-mode
  :mode ("^/tmp/crontab\\..*" . crontab-mode))

(use-package cperl-mode
  :commands cperl-mode
  :init (defalias 'perl-mode 'cperl-mode)
  :config (load "~/.emacs.d/my-fixes/cperl-lineup.el"))

(use-package python
  :defer t
  :config (progn
            (defun my-python-hook ()
              (company-mode 0)
              (setq tab-width 4
                    python-indent 4
                    py-indent-offset 4))
            (add-hook 'python-mode-hook 'my-python-hook)
            (if (file-exists-p "~/.emacs.d/.python-environments")
                (add-hook 'python-mode-hook 'jedi:setup))
            (setq jedi:complete-on-dot t)))

(use-package jedi
  :defer t
  :config (progn
            (define-key jedi-mode-map (kbd "C-<tab>") nil)
            (define-key jedi-mode-map (kbd "C-c v") 'jedi:complete)
            (if (version<= "25.0" emacs-version)
                (progn
                  (define-key jedi-mode-map [remap xref-find-definitions]
                    'jedi:goto-definition)
                  (define-key jedi-mode-map [remap xref-pop-marker-stack]
                    'jedi:goto-definition-pop-marker))
                (progn
                  (define-key jedi-mode-map [remap find-tag]
                    'jedi:goto-definition)
                  (define-key jedi-mode-map [remap pop-tag-mark]
                    'jedi:goto-definition-pop-marker)))))

(use-package rainbow-mode
  :commands (rainbow-mode)
  :init (define-globalized-minor-mode global-rainbow-mode rainbow-mode
          (lambda ()
            (when (not (equal major-mode 'woman-mode))
              (rainbow-mode 1)))))

(use-package projectile
  :commands (projectile-global-mode
             projectile-switch-project)
  :idle (projectile-global-mode 1)
  :init (progn
          (setq projectile-switch-project-action (lambda ()
                                                   (dired ".")))
          (key-chord-define-global "`p" 'projectile-switch-project))
  :bind ("C-c p p" . projectile-switch-project)
  :config (progn
            (setq projectile-mode-line
                  '(:eval
                    (format " Pro[%s]"
                            (projectile-project-name))))
            (define-key projectile-command-map (kbd "C-b") 'helm-projectile-buffers)
            (define-key projectile-command-map [?h] 'helm-browse-project)))

(use-package helm-ag
  :bind ("C-c p s S" . projectile-helm-ag)
  :config (progn
            (require 'projectile)
            (defun projectile-helm-ag ()
             (interactive)
             (helm-ag (projectile-project-root)))))

(use-package sane-term
  :init (setq sane-term-shell-command "/bin/zsh")
  :config (add-hook 'term-mode-hook
                    #'(lambda ()
                        (yas-minor-mode -1)))
  :bind (("C-x t" . sane-term)
         ("C-x T" . sane-term-create)))

(use-package diff-hl
  :defer t
  :idle (global-diff-hl-mode 1)
  :init (key-chord-define-global "=f" 'diff-hl-mode))

(use-package recentf-merge
  :pre-load (setq recentf-max-menu-items 100))

(use-package image-mode
  :defer t
  :config (progn
            (define-key image-mode-map (kbd "k")
              #'(lambda ()
                  (interactive)
                  (kill-buffer)))
            (define-key image-mode-map (kbd "K")
              #'(lambda ()
                  (interactive)
                  (kill-buffer-and-window)))))

(use-package slime
  :defer t
  :config (when (file-exists-p (expand-file-name "~/quicklisp/slime-helper.el"))
            (load (expand-file-name "~/quicklisp/slime-helper.el"))
            (setq inferior-lisp-program "sbcl")))


(add-hook 'after-init-hook '(lambda () (interactive) (load-theme 'zenburn)))
(setq frame-background-mode 'dark)
(ignore-errors
 (let ((font-name "DejaVu Sans Mono")
       (font-size "11"))
   (let ((font (concat font-name "-" font-size)))
     (add-to-list 'default-frame-alist `(font . ,font))
     (set-frame-font font nil t))))


(ignore-errors
  (use-package my-mu4e
    :idle (require 'my-mu4e)
    :load-path ("~/.emacs.d/secret"
                "~/local/share/emacs/site-lisp/mu4e")
    :bind ("<f5>" . mu4e))
  (use-package my-secret
    :load-path ("~/.emacs.d/secret")))
