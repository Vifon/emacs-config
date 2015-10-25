(require 'god-mode)

(defun god-mode-all-mod (&optional arg)
  (interactive)
  (god-mode-all)
  (god-mode-notify god-global-mode))

(defun god-mode+notify (&optional arg)
  (interactive)
  (god-mode)
  (let ((visible-bell t))
    (ding t)))

(key-chord-define-global "jf" 'god-mode+notify)
(key-chord-define god-local-mode-map "ci" (lambda ()
                                            (interactive)
                                            (er/mark-symbol)
                                            (kill-region (point) (mark))
                                            (god-mode+notify)))

(define-key god-local-mode-map (kbd "i") 'god-mode+notify)
(define-key god-local-mode-map (kbd "A") "ei")
(define-key god-local-mode-map (kbd "I") "ai")
(define-key god-local-mode-map (kbd "o") '(lambda ()
                                              (interactive)
                                              (call-interactively 'open-next-line)
                                              (god-mode+notify)))
(define-key god-local-mode-map (kbd "O") '(lambda ()
                                            (interactive)
                                            (call-interactively 'open-previous-line)
                                            (god-mode+notify)))
(define-key god-local-mode-map (kbd "z") 'repeat)
(define-key god-local-mode-map (kbd ".") 'repeat)
(define-key god-local-mode-map (kbd "/") 'undo-tree-undo)

(define-key god-local-mode-map (kbd "C-x C-1") 'delete-other-windows)
(define-key god-local-mode-map (kbd "C-x C-2") 'split-window-below)
(define-key god-local-mode-map (kbd "C-x C-3") 'split-window-right)
(define-key god-local-mode-map (kbd "C-x C-0") 'delete-window)

(defun god-mode-notify (&optional arg)
  (defvar god-mode/default-mode-line-foreground
    (face-attribute 'mode-line :foreground))
  (if arg
      (set-face-foreground 'mode-line
                           "GreenYellow")
      (set-face-foreground 'mode-line
                           god-mode/default-mode-line-foreground))
  (let ((visible-bell t))
    (ding t)))

(provide 'my-god-mode)
