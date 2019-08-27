(use-package org
  :ensure org-plus-contrib
  :pin org
  :config (progn
            (define-key org-mode-map (kbd "<C-tab>") nil)
            (define-key org-mode-map (kbd "C-c C-1")
              (lambda ()
                (interactive)
                (org-time-stamp-inactive '(16))))
            (setf (cdr (assoc "\\.pdf\\'"
                              org-file-apps))
                  "evince %s")))

(use-package org-attach
  :commands (org-attach-expand-link org-attach-attach)
  :init (defun org-attach-scrot ()
          (interactive)
          (let* ((timestamp (format-time-string "%Y-%m-%d_%H%M-%s"))
                 (basename (concat "scrot-"
                                   timestamp
                                   ".png"))
                 (filepath (concat "/tmp/"
                                   basename)))
            (shell-command
             (concat "scrot -s -d2 "
                     filepath))
            (org-attach-attach filepath nil 'mv)
            (push (list (concat "file:"
                                (file-relative-name
                                 (expand-file-name basename
                                                   (org-attach-dir)))))
                  org-stored-links))))

(defun org-insert-heading-empty-line-fix ()
  "Correctly surround the new org headings with empty lines.
By default the empty line after the new heading is not inserted
when using the `*-respect-content' commands."
  (save-excursion
    (when (org-previous-line-empty-p)
      (insert "\n"))))
(advice-add #'org-insert-heading-respect-content :after
            #'org-insert-heading-empty-line-fix)
(advice-add #'org-insert-todo-heading-respect-content :after
            #'org-insert-heading-empty-line-fix)

(defun org-followup ()
  (interactive)
  (let ((link (org-store-link nil)))
    (org-insert-heading-respect-content)
    (end-of-line)
    (save-excursion
      (insert "\n")
      (indent-for-tab-command)
      (org-time-stamp-inactive '(16))
      (insert "\n")
      (indent-for-tab-command)
      (insert "Follow-up of: " link))))

(require 'org-protocol)
(require 'org-notmuch)

(setq org-hide-leading-stars nil)
(setq org-special-ctrl-a/e t)
(setq org-use-speed-commands t)
(setq org-ellipsis "[…]")

(use-package org-bullets :ensure t :defer t)
(defun org-minor-modes (&optional arg)
  (interactive "P")
  (org-bullets-mode arg)
  (hl-line-mode arg))
(defun my-org-mode-hook ()
  (add-to-list (make-local-variable 'electric-pair-pairs)
               '(?$ . ?$))
  (org-minor-modes))
(add-hook 'org-mode-hook #'my-org-mode-hook)

;;; http://www.howardism.org/Technical/Emacs/orgmode-wordprocessor.html
(font-lock-add-keywords 'org-mode
                        '(("^ +\\(*\\) "
                           (0 (prog1 nil
                                (compose-region (match-beginning 1)
                                                (match-end 1)
                                                "•"))))))
(setq org-hide-emphasis-markers nil)

(setq org-default-notes-file (concat org-directory "/gtd.org"))

(setq org-refile-targets '((org-agenda-files :tag . "PROJECT")
                           (org-agenda-files :tag . "CATEGORY")
                           (org-agenda-files :tag . "GROUP")
                           (org-agenda-files :level . 1)
                           (nil :tag . "PROJECT")
                           (nil :tag . "CATEGORY")
                           (nil :tag . "GROUP")
                           (nil :level . 1)))
(setq org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-skip-timestamp-if-done t)
(setq org-icalendar-combined-agenda-file "~/org/org.ics"
      org-icalendar-use-deadline '(event-if-todo)
      org-icalendar-use-scheduled '(event-if-todo)
      org-icalendar-timezone "Europe/Warsaw"
      org-export-with-tasks 'todo)
(setq org-use-tag-inheritance nil)
(setq org-export-with-toc nil)
(setq org-tags-exclude-from-inheritance '("PROJECT" "ATTACH"))
(setq org-todo-keyword-faces '(("NEXT" . "Tomato")))
(setq org-enforce-todo-dependencies t)
(setq org-clock-into-drawer t)
(setq org-duration-units `(("min" . 1)
                           ("h" . 60)
                           ("d" . ,(* 60 8))
                           ("w" . ,(* 60 8 5))
                           ("m" . ,(* 60 8 5 4))
                           ("y" . ,(* 60 8 5 4 10))))
(setq org-cycle-open-archived-trees nil)
(setq org-archive-default-command 'org-toggle-archive-tag)
(setq org-log-into-drawer t)
(setq org-log-reschedule 'time
      org-log-redeadline 'time)
(setq org-hierarchical-todo-statistics nil)
(setq org-link-abbrev-alist '(("att" . org-attach-expand-link)))
(setq org-catch-invisible-edits 'error)

(when (file-exists-p "~/org/.agenda-files")
  (setq org-agenda-files "~/org/.agenda-files"))
(when (not org-agenda-files)
  (setq org-agenda-files '("~/org/gtd.org")))

(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c S") 'org-store-link)
(global-set-key [f8] '(lambda ()
                        (interactive)
                        (find-file (concat (vc-root-dir) "todo.org"))))

(setq org-capture-templates
      '(("t" "todo" entry (file+headline "" "Index")
         "* TODO %?\n  %U\n  %a\n")

        ("T" "sub-todo" entry (clock)
         "* TODO %?\n  %U\n  %a\n")

        ("b" "issue" entry (file+headline
                            (concat (or (vc-root-dir)
                                        (projectile-project-root)
                                        default-directory) "todo.org") "Issues")
         "* TODO %?\n  %U\n  %a\n")

        ("n" "note" entry (file "notes.org")
         "* %? :NOTE:\n  %U\n  %a\n")

        ("j" "journal + prompt" entry (file+datetree+prompt "journal.org.gpg")
         "* %?")

        ("J" "journal" entry (file+datetree "journal.org.gpg")
         "* %?")))

(setq org-stuck-projects
      '("PROJECT" ("TODO") ("IGNORE") nil))

(plist-put org-format-latex-options :scale 2.0)

(use-package ob
  :defer t
  :config (progn
            (setq org-confirm-babel-evaluate nil)
            (org-babel-do-load-languages
             'org-babel-load-languages
             '((shell . t)
               (awk . t)
               (makefile . t)

               (ditaa . t)
               (plantuml . t)
               (dot . t)
               (gnuplot . t)
               (octave . t)

               (sqlite . t)

               (haskell . t)

               (C . t)

               (python . t)
               (perl . t)

               (java . t)

               (js . t)))
            (setq org-babel-C-compiler "gcc -std=c99"
                  org-babel-C++-compiler "g++ -std=c++14"
                  org-babel-python-command "python3"
                  org-babel-perl-preface "use 5.010;")))

(org-add-link-type "evince" 'org-evince-open)
(defun org-evince-open (link)
  (string-match "\\(.*?\\)\\(?:::\\([0-9]+\\)\\)?$" link)
  (let ((path (match-string 1 link))
        (page (and (match-beginning 2)
                   (match-string 2 link))))
    (if page
        (call-process "evince" nil 0 nil
                      path "-i" page)
      (call-process "evince" nil 0 nil
                    path))))

(use-package org-crypt
  :config (progn
            (org-crypt-use-before-save-magic)
            (add-to-list 'org-tags-exclude-from-inheritance "crypt")
            (setq org-crypt-key "B247B8DE")))

(use-package org-habit
  :after org-agenda
  :config (setq org-habit-show-habits-only-for-today nil
                org-habit-show-all-today nil
                org-agenda-show-future-repeats 'next))

(use-package steam
  :ensure t
  :defer t
  :config (setq steam-username "vifon"))

(provide 'my-org)
