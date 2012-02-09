;;; ess-dnd.el --- R drag and Drop
;; 
;; Filename: ess-dnd.el
;; Description: R Drag and Drop
;; Author: Matthew L. Fidler
;; Maintainer: Matthew L. Fidler
;; Created: Thu Feb  9 09:37:32 2012 (-0600)
;; Version: 
;; Last-Updated: 
;;           By: 
;;     Update #: 0
;; URL: 
;; Keywords: 
;; Compatibility: 
;; 
;; Features that might be required by this library:
;;
;;   None
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Commentary: 
;; 
;; Drag and drop files into ESS and produce code.  Currently supports
;; only R and CSV but is extendable to other languages.
;;
;; Put this somewhere in your load path and add the following to your
;; .emacs
;;
;; (require 'ess-dnd)
;; (ess-drag-and-drop-activate)
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Change Log:
;; 
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Code:

(defadvice dnd-open-local-file (around ess-import-drag-and-drop activate)
  "* Drag Files to Emacs Speaks Statistics."
  (unless (ess-drag-and-drop (ad-get-arg 0))
    ad-do-it))

(defadvice dnd-open-file (around ess-import-drag-and-drop activate)
  "* Drag Files to Emacs Speaks Statistics"
  (unless (ess-drag-and-drop (ad-get-arg 0))
    ad-do-it))

(defgroup ess-dnd nil
  "Drag and Drop support for Emacs Speaks Statistics"
  :group 'ess)

(defcustom ess-dnd-supported-files
  '(("S"
     (("R"
       (("csv" "read.csv(\"%s\",na.strings=c(\".\",\"NA\"));"))))))
  "Ess Drag and Drop supported files"
  :type '(repeat
	  (list
	   (string :tag "Ess Language")
	   (repeat 
	   (list
	    (string :tag "ESS dialect")
	    (repeat 
	     (list
	     (string :tag "Extension")
	     (string :tag "Code; %s represents file name")))))))
  :group 'ess-dnd)

(defcustom ess-dnd-relative t
  "Use a relative directory."
  :type 'boolean
  :group 'ess-dnd)

(defvar ess-drag-and-drop-active nil
  "Determines if ESS drag and drop is active.")

(defun ess-drag-and-drop-activate ()
  "Activates ess-drag-and-drop"
  (setq ess-drag-and-drop-active t))

(defun ess-drag-and-drop (uri)
  "* Drag and drop support for Emacs Speaks Statistics."
  (let ((f (dnd-get-local-file-name uri t))
	exts
	pt
	ret)
    (when ess-drag-and-drop-active
      (when (eq major-mode 'ess-mode)
	(setq exts (assoc ess-language ess-dnd-supported-files))
	(when exts
	  (setq exts (assoc ess-dialect (cadr exts)))
	  (when exts
	    (setq exts (assoc (file-name-extension f) (cadr exts)))
	    (when exts
	      (when ess-dnd-relative
		(when (string-match "^[A-Z]:" f)
		  (setq f (concat (downcase  (substring f 0 1))
				  (substring f 1))))
		(setq f (file-relative-name f (file-name-directory (buffer-file-name)))))
	      (insert (format (nth 1 exts) f))
	      (setq ret 't))))
	(symbol-value 'ret)))))
  
(provide 'ess-dnd)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ess-dnd.el ends here
