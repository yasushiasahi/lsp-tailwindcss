;;; lsp-tailwindcss.el --- the lsp-mode client for tailwindcss  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  A.I.

;; Author: A.I. <merrick@luois.me>
;; Keywords: language tools

;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

(require 'lsp-mode)

(defgroup lsp-tailwindcss nil
  "lsp support for tailwind css"
  :group 'lsp-mode)

(defcustom lsp-tailwindcss-server-download-location
  (expand-file-name "vscode-tailwindcss" user-emacs-directory)
  "download location for automatic install"
  'type 'string
  :group 'lsp-tailwindcss)

(defcustom lsp-tailwindcss-server-file
  (expand-file-name "dist/server/index.js" lsp-tailwindcss-server-download-location)
  "index.js location of vscode-tailwindcss"
  :type 'string
  :group 'lsp-tailwindcss)

(defcustom lsp-tailwindcss-server-remote
  "https://github.com/bradlc/vscode-tailwindcss"
  "git repo of tailwindcss language server"
  :type 'string
  :group 'lsp-tailwindcss)

(defvar lsp-tailwindcss-server-installed-p
  (file-exists-p lsp-tailwindcss-server-file)
  "check if server is installed")

(defun lsp-tailwindcss--callback (workspace &rest _)
  (message "lsp-tailwindcss callback %s" workspace))

(defun lsp-tailwindcss-install-server ()
  (interactive)
  (if lsp-tailwindcss-server-installed-p
      (message "tailwindcss language server already installed")
    (let ((remote lsp-tailwindcss-server-remote)
          (local lsp-tailwindcss-server-download-location)
          (call #'lsp-tailwindcss--call-process))
      (message "installing vscode-tailwindcss, please wait.")
      (funcall call "git" "clone" remote local)
      (message "building tailwindcss lsp server")
      (let ((default-directory local))
        (funcall call "npm" "install")
        (funcall call "npm" "run" "build")
        (message "tailwindcss language server installed")))))

(defun lsp-tailwindcss--call-process (command &rest args)
  (with-temp-buffer
    (cons (or (apply #'call-process command nil t nil (remq nil args))
              -1)
          (string-trim (buffer-string)))))

(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection
                   (list "node" lsp-tailwindcss-server-file "--stdio")
                   (lambda () (f-exists? lsp-tailwindcss-server-file)))
  :major-modes '(web-mode css-mode)
  :server-id 'tailwindcss
  :priority 1
  :notification-handlers (lsp-ht ("tailwindcss/configUpdated" 'lsp-tailwindcss--callback))))

(provide 'lsp-tailwindcss)
