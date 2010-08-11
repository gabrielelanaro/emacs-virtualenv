;;; virtualenv.el --- Switching virtual python enviroments seamlessly

;; Copyright (C) 2010 Gabriele Lanaro

;; Author: Gabriele Lanaro <gabriele.lanaro@gmail.com>
;; Version: 0.1
;; Url: 

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with EMMS; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; 

(setq virtualenv-workon-home (getenv "WORKON_HOME"))

(defun virtualenv-append-path (dir var)
  "Append DIR to a path-like varibale VAR, for example:
 (virtualenv-append-path /usr/bin:/bin /home/test/bin) -> /home/test/bin:/usr/bin:/bin"
  (concat (expand-file-name dir)
          path-separator
          var)
  )

  (defun virtualenv-add-to-path (dir)
  "Add the specified path element to the Emacs PATH"
  (interactive "DEnter directory to be added to PATH: ")
  (setenv "PATH"
	  (virtualenv-append-path dir
                                  (getenv "PATH"))))

(defun virtualenv-current ()
  "barfs the current activated virtualenv"
  (message 'virtualenv-name)
  )

(defun virtualenv-activate (dir)
  "Activate the virtualenv located in DIR"
  (interactive "DVirtualenv Directory: ")
  
  ;; Storing old variables
  (setq virtualenv-old-path (getenv "PATH"))
  (setq virtualenv-old-exec-path exec-path)
  
  (setenv "VIRTUAL_ENV" dir)
  (virtualenv-add-to-path (concat dir "/bin"))
  (add-to-list 'exec-path (concat dir "/bin"))
  
  (setq virtualenv-name (file-name-nondirectory dir))
  )

(defun virtualenv-deactivate ()
  "Deactivate the current virtual enviroment"
  (interactive)
  
  ;; Restoring old variables
  (setenv "PATH" virtualenv-old-path)
  (setq exec-path virtualenv-old-exec-path)

  (setq virtualenv-name nil)
  )

(defun virtualenvp (dir)
  "Check if a directory is a virtualenv"
  (file-exists-p (concat dir "/bin/activate"))
  )


(defun virtualenv-workon-complete ()
  "return available completions for virtualenv-workon"
  (let 
      ;;Varlist				
      ((filelist (directory-files virtualenv-workon-home t))) ;; List directory
       ;; Let Body
    (mapcar 'file-name-nondirectory
       (remove nil 'virtualenvp ;; select virtualenvs
	(remove nil 'file-directory-p filelist))) ;; select  directories
    )
  )

(defun virtualenv-workon (name)
  "Issue a virtualenvwrapper-like virtualenv-workon command"
  (interactive (list (completing-read "Virtualenv: " (virtualenv-workon-complete))))
  (virtualenv-activate (concat (getenv "WORKON_HOME") "/" name))
  )

(provide 'virtualenv)
