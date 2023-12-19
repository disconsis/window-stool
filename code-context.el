;;; code-context.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 Jason Zhen
;;
;; Author: Jason Zhen <jaszhe@gmail.com>
;; Maintainer: Jason Zhen <jaszhe@gmail.com>
;; Created: December 16, 2023
;; Modified: December 16, 2023
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/jasonzhen/code-context
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:
;;;

(defun find-previous-non-empty-line ()
  ;; empty body cause we basically just do the re-search-backward as part of the loop
  (while (and (looking-at-p (rx-to-string `(: (* blank) eol)))
              (re-search-backward (rx-to-string `(: (+ any))) nil t))))

(defun get-context-from (pos)
  (goto-char pos)
  (find-previous-non-empty-line)
  (let ((ctx '())
        (prev-indentation (current-indentation)))
    (cl-pushnew (buffer-substring-no-properties (line-beginning-position) (line-end-position)) ctx)
    (while (> (current-indentation) 0)
      (forward-line -1)
      (find-previous-non-empty-line)
      (when (< (current-indentation) prev-indentation)
        (setq prev-indentation (current-indentation))
        (cl-pushnew (buffer-substring-no-properties (line-beginning-position) (line-end-position)) ctx)
        )
      )
    ctx))

(setq prev-ctx nil)
(setq-local prev-window-start (window-start))
(unless buffer-overlay (setq-local buffer-overlay (make-overlay 1 1)))
;; issue where we can't keep scrolling if overlay would move cursor outside of scroll margin
;; really only an issue when scrolling up
(defun code-context-single-overlay (display-start)
  (when (and this-command (not (eq (window-start) prev-window-start)))
    (let ((ctx (save-excursion (get-context-from display-start))))
      (let* ((display-start-empty-line-p (save-excursion (goto-char display-start) (or (looking-at-p "^$") (looking-at-p "[[:blank:]]*$"))))
             (ol-beg-pos display-start)
             (ol-end-pos (save-excursion (goto-char display-start) (forward-line) (line-end-position)))
             (covered-line (save-excursion (goto-char display-start) (forward-line) (buffer-substring (line-beginning-position) (line-end-position))))
             (context-str-1 (when ctx (cl-reduce (lambda (acc str) (concat acc "\n" str)) ctx)))
             (_ (set-text-properties 0 (length context-str-1) '(face hl-line) context-str-1))
             (context-str (concat context-str-1 "\n-------------context-------------\n" covered-line)))
        ;; this only seems to work with post-command-hook
        (when (and ctx (or (eq last-command 'evil-scroll-line-up)
                           (eq last-command 'scroll-down-line)))
          (forward-line (- (+ (min (- (length ctx) (length prev-ctx)) 0) 1))))
        (move-overlay buffer-overlay ol-beg-pos ol-end-pos)
        (overlay-put buffer-overlay 'name 'jason)
        (overlay-put buffer-overlay 'display context-str)
        )
      (setq prev-ctx ctx)))
  (setq-local prev-window-start (window-start)))

(defun code-context-window-scroll-function (_ display-start)
  (let ((display-start-empty-line-p (save-excursion (goto-char display-start) (looking-at-p "^$"))))
    (when (buffer-file-name)
      (code-context-single-overlay display-start)
      )
    )
  )

;;;###autoload
(define-minor-mode code-context-mode
  "Minor mode to show code context based on indentation level within the buffer via overlays"
  :init-value nil
  :lighter " CodeCtx"
  (if code-context-mode
      (progn
        (add-hook 'post-command-hook (lambda () (code-context-window-scroll-function nil (window-start)))))
    (progn
      (remove-hook 'post-command-hook (lambda () (code-context-window-scroll-function nil (window-start))))
      (remove-overlays (point-min) (point-max) 'name 'jason))))

(let ((x 1))
  (progn
    (progn
      (progn
        (progn
          (progn ))))))

(provide 'code-context)
;;; code-context.el ends here


(defun test-function ()
  (when (buffer-file-name)
    (progn
      (let ((x (buffer-name)))
        (let ((y (buffer-name)))
          (let ((z (buffer-name)))
            (message z)))))))





































;;;asdsad