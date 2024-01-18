(prelude-require-packages '(solarized-theme))
(load-theme 'solarized-dark t)

(add-to-list 'term-file-aliases '("foot" . "xterm"))

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq indent-line-function 'insert-tab)

(add-hook 'c-mode-common-hook 'google-set-c-style)

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
