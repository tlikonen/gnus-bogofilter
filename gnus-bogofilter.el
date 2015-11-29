;;; gnus-bogofilter.el --- Bogofilter features for Gnus

;; Author: Teemu Likonen <tlikonen@iki.fi>
;; Created: 2015-10-25
;; URL: https://github.com/tlikonen/gnus-bogofilter
;; Keywords: Bogofilter Gnus spam mail filter

;; Copyright (C) 2015 Teemu Likonen <tlikonen@iki.fi>
;;
;; This program is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation, either version 3 of the License, or (at your
;; option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
;; Public License for more details.
;;
;; The license text: <http://www.gnu.org/licenses/gpl-3.0.html>

;;; Code:


(eval-when-compile
  (require 'gnus)
  (require 'gnus-sum))


;;;###autoload
(defvar bogofilter-program "bogofilter"
  "Name of the Bogofilter executable program.")


(defun bogofilter--process-buffer (&rest args)
  (apply #'call-process-region (point-min) (point-max)
         bogofilter-program t t nil args))


(defmacro bogofilter--with-current-article (&rest body)
  (declare (indent 0))
  (let ((article (make-symbol "-article-")))
    `(progn
       (gnus-summary-show-raw-article)
       (let ((,article (get-buffer gnus-article-buffer)))
         (with-temp-buffer
           (insert-buffer-substring ,article)
           (goto-char (point-min))
           ,@body)))))


(defun bogofilter--register-engine (arg type)
  (let ((articles (gnus-summary-work-articles nil))
        (article nil))
    (save-excursion
      (while articles
        (setq article (pop articles))
        (gnus-summary-goto-subject article)
        (let ((gnus-newsgroup-processable nil))
          (bogofilter--with-current-article
            (bogofilter--process-buffer arg))
          (message "Bogofilter: registered article %s as %s" article type))
        (gnus-summary-remove-process-mark article)))
    (gnus-summary-show-article)))


;;;###autoload
(defun bogofilter-register-spam (&optional arg)
  "Register the current article as \"spam\" with Bogofilter.

Must be used in Gnus summary buffer. Without prefix argument this
command runs the current article through \"bogofilter -s\". With
optional prefix argument, first unregister the message as
\"ham\", then register it as \"spam\". This is runs the article
through \"bogofilter -Ns\"."
  (interactive "P")
  (bogofilter--register-engine (if arg "-Ns" "-s") "spam"))


;;;###autoload
(defun bogofilter-register-ham (&optional arg)
  "Register the current article as \"ham\" with Bogofilter.

Must be used in Gnus summary buffer. Without prefix argument this
command runs the current article through \"bogofilter -n\". With
optional prefix argument, first unregister the message as
\"spam\", then register it as \"ham\". This is runs the article
through \"bogofilter -Sn\"."
  (interactive "P")
  (bogofilter--register-engine (if arg "-Sn" "-n") "ham"))


;;;###autoload
(defun bogofilter-check (&optional interactive)
  "Return current article's Bogofilter classification and score.

Return a cons in which the car value is the symbol `ham', `spam'
or `unsure' and cdr value is article's score (integer or float
from 0 to 1). If called interactively (or when INTERACTIVE is
non-nil) also show the same information in echo area."

  (interactive "p")
  (let* ((status 0)
         (output (bogofilter--with-current-article
                   (setq status (bogofilter--process-buffer "-T"))
                   (buffer-substring-no-properties
                    3 (line-end-position)))))

    (if (= status 3)
        (error "Bogofilter error")
      (gnus-summary-show-article)
      (let ((class (cond ((= status 0) 'spam)
                         ((= status 1) 'ham)
                         ((= status 2) 'unsure)))
            (score (string-to-number output)))
        (when interactive
          (message "Class: %s, Score: %s" class score))
        (cons class score)))))


;;;###autoload
(defun bogofilter-split (spam-split &optional unsure-split ham-split)
  "Bogofilter split function for Gnus.

Usage in `nnmail-split-fancy' or `nnimap-split-fancy':

    (: bogofilter-split SPAM-SPLIT UNSURE-SPLIT HAM-SPLIT)

Only the SPAM-SPLIT argument is mandatory. If mail is detected as
spam return the SPAM-SPLIT argument. If mail's spam status is
unknown return the UNSURE-SPLIT argument. If mail is detected as
ham return the HAM-SPLIT argument. If there's a Bogofilter error
return nil.

This function does not use any of its arguments; it just returns
them. In practice, all arguments must be valid split forms as
described in `nnmail-split-fancy'. Simple spam group name is
probably common:

    (: bogofilter-split \"spam\")

That example means that detected spam mail is delivered to group
\"spam\". Otherwise return nil and mail's processing will
continue to the next split form of `nnmail-split-fancy'. More
complex example:

    (: bogofilter-split '(| (from \"paypal\" \"paypal-spam\")
                            \"other-spam\")
                        \"unsure\"
                        \"good-mail\")

Note that `bogofilter-program' is always executed with \"-u\"
argument which automatically trains the filter database with the
current message. Training occurs only if the message is detected
as ham or spam. If Bogofilter is unsure about message's status
the database is not trained."

  (save-excursion
    (save-restriction
      (widen)
      (let ((message (current-buffer)))
        (with-temp-buffer
          (insert-buffer-substring message)
          (let ((name "bogofilter-split")
                (status (bogofilter--process-buffer "-u")))
            (cond ((= status 0)
                   (message "%s: message is spam." name)
                   spam-split)
                  ((= status 1)
                   (message "%s: message is ham." name)
                   ham-split)
                  ((= status 2)
                   (message "%s: message's status is unknown." name)
                   unsure-split)
                  (t
                   (message "%s: error occurred!" name)
                   nil))))))))


(provide 'gnus-bogofilter)

;;; gnus-bogofilter.el ends here
