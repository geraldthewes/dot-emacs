(require 'package) ;; You might already have this line
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) ;; You might already have this line



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(markdown-preview-mode markdown-mode elpy tree-sitter-langs tree-sitter-indent tree-sitter ## go-autocomplete go-eldoc scala-mode ggtags neotree dirtree go-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;(global-set-key "\^xt" 'goto-line)


;;(add-to-list 'load-path "/directory/containing/neotree/")
(require 'neotree)


 (set-face-attribute 'default (selected-frame) :height 150)



(require 'go-eldoc)
(add-hook 'go-mode-hook 'go-eldoc-setup)

;;Format before saving
(defun go-mode-setup ()
  (go-eldoc-setup)
    (add-hook 'before-save-hook 'gofmt-before-save))
(add-hook 'go-mode-hook 'go-mode-setup)

(defun go-mode-setup ()
  (go-eldoc-setup)
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save))
(add-hook 'go-mode-hook 'go-mode-setup)

;;Godef, shows function definition when calling godef-jump
(defun go-mode-setup ()
  (go-eldoc-setup)
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)
  (local-set-key (kbd "M-.") 'godef-jump))
(add-hook 'go-mode-hook 'go-mode-setup)

;;Custom Compile Command
(defun go-mode-setup ()
  (setq compile-command "go build -v && go test -v && go vet && golint")
  (define-key (current-local-map) "\C-c\C-c" 'compile)
  (go-eldoc-setup)
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)
  (local-set-key (kbd "M-.") 'godef-jump))
(add-hook 'go-mode-hook 'go-mode-setup)

(ac-config-default)
(require 'auto-complete-config)
(require 'go-autocomplete)


    (add-to-list 'package-archives
                 '("melpa" . "http://melpa.org/packages/"))


;;Configure golint
;; (add-to-list 'load-path (concat (getenv "GOPATH")  "/src/github.com/golang/lint/misc/emacs"))
;;(require 'golint)

;;Project Explorer
;;(require 'project-explorer)
;;(global-set-key (kbd "M-e") 'project-explorer-toggle)

(defvar my-packages
  '(;;;; Go shit
    go-mode
    go-eldoc
    go-autocomplete

        ;;;;;; Env
    project-explorer)
  "My packages!")

;; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

;; install the missing packages
(dolist (package my-packages)
  (unless (package-installed-p package)
    (package-install package)))

(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))


(require 'tree-sitter)
(require 'tree-sitter-langs)

(use-package elpy
  :ensure t
  :defer t
  :init
  (advice-add 'python-mode :before 'elpy-enable))


(use-package ellama
   :init
   (setopt ellama-keymap-prefix "C-c e")
  (require 'llm-openai)
  (setq ellama-provider
    (make-llm-openai-compatible
     :key "your-api-key"
     :chat-model "glm-4.7-flash"
     :url "http://glm-flash.cluster:8000/v1"  
     ))   
)

(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))

;; Use eat by default, especially inside Eshell
(use-package eat
  :ensure t
  :custom (eat-eshell-mode t))   ; ← this is the magic many people love



;; In your init file (~/.emacs or ~/.config/emacs/init.el)

(use-package grip-mode
  :ensure t
  :hook ((markdown-mode org-mode) . grip-mode)   ; auto-start in .md / .org
  :config
  (setq grip-preview-use-webkit t)               ; ← use embedded browser if you have xwidgets
  ;; (setq grip-url-browser "firefox")           ; or your preferred external browser
  ;; (setq grip-update-after-change t)           ; refresh after every keystroke (can be laggy)
  )


(defvar my-litellm-api-key nil
  "Cached LiteLLM master key fetched from Vault (session lifetime).")

(defun my-litellm-api-key ()
  "Fetch the LiteLLM master_key from HashiCorp Vault (cached for the Emacs session)."
  (or my-litellm-api-key
      (setq my-litellm-api-key
            (string-trim-right               ; remove trailing newline
             (shell-command-to-string
              "vault kv get -adress=http://active.vault.service.consul:8200 -field=master_key secret/litellm/app")))))


(use-package gptel
  :ensure t
  :config
  ;; ── Define the LiteLLM backend ─────────────────────────────────────
  (setq gptel-backend
      (gptel-make-openai "LiteLLM"
    	:host "litellm.cluster:9999"          ; ← change to your proxy (e.g. "proxy.mycompany.com:4000")
    	:protocol "http"                ; use "https" if you have TLS
    	;; :endpoint "/v1/chat/completions"   ; default, so you can omit it
    	:key #'my-litellm-api-key       ; ← your LiteLLM master/virtual key
    	:stream t                       ; highly recommended
    	:models '(claude-opus-standard
              claude-sonnet-standard
              claude-haiku-standard)));

  ;; Make it the default (optional but convenient)
  (setq gptel-model 'claude-sonnet-standard))


;(require 'package)
;(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;(package-initialize)

(use-package vterm
  :ensure t
  :commands vterm)  ; defer loading until you call M-x vterm


(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-follow-after-init t
          treemacs-is-never-other-window t
          treemacs-width 35)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    ;; Optional: simple git integration (no Python needed)
    (treemacs-git-mode 'simple))
  :bind
  (:map global-map
        ("M-0" . treemacs-select-window)
        ("C-c t t" . treemacs)))  ;; or whatever key you prefer
