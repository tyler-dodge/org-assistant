;;; -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'org)
(require 'el-mock)
(require 'ert-async)

(ert-deftest org-assistant-exists ()
  "Sanity check to make sure expected symbols are exported."
  (should (functionp 'org-assistant)))

(ert-deftest org-assistant-org-blocks-works-as-expected ()
  "Sanity check to make sure `org-assistant--org-blocks' works as expected."
  (with-current-buffer (get-buffer-create " *assistant-test*")
    (erase-buffer)
    (org-mode)
    (insert "* Question
#+BEGIN_SRC text
Should not be included
#+END_SRC

#+BEGIN_EXAMPLE
System Prompt
#+END_EXAMPLE
#+BEGIN_SRC assistant
A
#+END_SRC

#+BEGIN_SRC assistant :sender assistant
A-response
#+END_SRC

#+BEGIN_SRC assistant
B
#+END_SRC

#+BEGIN_SRC assistant :sender assistant
B-response
#+END_SRC

#+BEGIN_SRC ?
C
#+END_SRC

#+BEGIN_SRC assistant :sender assistant
C-response
#+END_SRC
")
    (goto-char (point-min))
    (should (eq (org-assistant--org-blocks nil) nil))
    (search-forward "#+BEGIN_EXAMPLE")
    (goto-char (match-beginning 0))
    (save-match-data (should (equal (org-assistant--org-blocks nil) (list (cons 'system "System Prompt")))))
    (search-forward "#+BEGIN_SRC")
    (goto-char (match-beginning 0))
    (save-match-data
      (should (equal (org-assistant--org-blocks nil) (list
                                                      (cons 'system "System Prompt")
                                                      (cons 'user "A")))))
    (goto-char (match-end 0))
    (search-forward "#+BEGIN_SRC assistant")
    (goto-char (match-beginning 0))
    (save-match-data
      (should (equal (org-assistant--org-blocks nil)
                     (list
                      (cons 'system "System Prompt")
                      (cons 'user "A")
                      (cons 'assistant "A-response")))))
    (goto-char (match-end 0))
    (search-forward "#+BEGIN_SRC")
    (goto-char (match-beginning 0))
    (should (equal (org-assistant--org-blocks nil)
                   (list
                    (cons 'system "System Prompt")
                    (cons 'user "A")
                    (cons 'assistant "A-response")
                    (cons 'user "B"))))

    (goto-char (point-max))
    (should (equal (org-assistant--org-blocks nil)
                   (list
                    (cons 'system "System Prompt")
                    (cons 'user "A")
                    (cons 'assistant "A-response")
                    (cons 'user "B")
                    (cons 'assistant "B-response")
                    (cons 'user "C")
                    (cons 'assistant "C-response"))))))

(ert-deftest org-assistant-org-blocks-handles-multiple-branches ()
  "Sanity check to make sure `org-assistant--org-blocks' handles branches correctly."
  (with-current-buffer (get-buffer-create "*assistant-test*")
    (erase-buffer)
    (org-mode)
    (insert "* Question
#+BEGIN_EXAMPLE
System Prompt
#+END_EXAMPLE
#+BEGIN_SRC assistant
A
#+END_SRC

#+BEGIN_SRC ignored
A
#+END_SRC

#+BEGIN_SRC assistant :sender assistant
A-response
#+END_SRC
** B Branch
#+BEGIN_SRC assistant
B
#+END_SRC

#+BEGIN_SRC text
Ignore me B
#+END_SRC

#+BEGIN_SRC assistant :sender assistant
B-response
#+END_SRC

** C Branch
#+BEGIN_SRC assistant
C
#+END_SRC

#+BEGIN_SRC text
Ignore me
#+END_SRC

#+BEGIN_SRC assistant :sender assistant
C-response
#+END_SRC
")
    (goto-char (point-min))
    (search-forward "B-response")
    (should (equal (org-assistant--org-blocks nil)
                   (list
                    (cons 'system "System Prompt")
                    (cons 'user "A")
                    (cons 'assistant "A-response")
                    (cons 'user "B")
                    (cons 'assistant "B-response"))))
    (search-forward "C-response")
    (should (equal (org-assistant--org-blocks nil)
                   (list
                    (cons 'system "System Prompt")
                    (cons 'user "A")
                    (cons 'assistant "A-response")
                    (cons 'user "C")
                    (cons 'assistant "C-response"))))))

(ert-deftest org-assistant-handles-noweb-output ()
  "Sanity check to make sure `org-assistant--org-blocks' handles branches correctly."
  (with-current-buffer (get-buffer-create " *assistant-test*")
    (org-mode)
    (erase-buffer)
    (insert "* Question
#+BEGIN_EXAMPLE
System Prompt
#+END_EXAMPLE

#+NAME: substitution-A
#+BEGIN_SRC text
SUBSTITUTION
#+END_SRC

#+BEGIN_SRC assistant :noweb yes
A <<substitution-A>>
#+END_SRC

#+BEGIN_SRC ignored
A
#+END_SRC

#+BEGIN_SRC assistant :sender assistant
A-response
#+END_SRC
** B Branch
#+BEGIN_SRC assistant
B
#+END_SRC

#+BEGIN_SRC text
Ignore me B
#+END_SRC

#+BEGIN_SRC assistant :sender assistant
B-response
#+END_SRC

** C Branch
#+BEGIN_SRC assistant
C
#+END_SRC

#+BEGIN_SRC text
Ignore me
#+END_SRC

#+BEGIN_SRC assistant :sender assistant
C-response
#+END_SRC
")
    (goto-char (point-min))
    (search-forward "<<substitution-A>>")
    (forward-line 1)
    (should (equal (org-assistant--org-blocks t)
                   '((system . "System Prompt")
                     (user . "A SUBSTITUTION"))))

    (search-forward "c-response")
    (should (equal (org-assistant--org-blocks t)
                   '((system . "System Prompt")
                     (user . "A SUBSTITUTION")
                     (assistant . "A-response")
                     (user . "C")
                     (assistant . "C-response"))))

    (should (equal (org-assistant--org-blocks nil)
                   '((system . "System Prompt")
                     (user . "A <<substitution-A>>")
                     (assistant . "A-response")
                     (user . "C")
                     (assistant . "C-response"))))))

(ert-deftest-async org-assistant-end-to-end-test (done done-output-replaced)
  "Sanity check to make sure `org-assistant--org-blocks' handles branches correctly."
  (setq org-assistant-chat-extra-parameters-alist '((temperature . 2)
                                                    (stop . "abc")))
  (with-current-buffer (get-buffer-create " *assistant-test*")
    (setq org-assistant-execute-curl-process-function
          (lambda (&rest args)
            (funcall done)
            (-let* (((&keys :url :body :method :buffer) args) 
                    (file (make-temp-file "org-json" nil nil
                                          (org-assistant--json-encode '(("choices" . [(("message" ("content" . "TEST")))]))))))
              (should (string= url (org-assistant-chat-endpoint)))
              (should (string= method "POST"))
              (let ((json
                     (sort (org-assistant--json-decode
                            (with-current-buffer (find-file-noselect (substring (cadr (plist-get args :body)) 1))
                              (buffer-string)))
                           (lambda (lhs rhs) (string> (symbol-name (car lhs)) (symbol-name (car rhs)))))))
                (should (equal json
                               '((temperature . 1)
                                 (stop . "abc")
                                 (model . "gpt-3.5-turbo")
                                 (messages . [((content . "System Prompt") (role . "system"))
                                              ((content . "A <<substitution-A>>") (role . "user"))
                                              ((content . "A-response") (role . "assistant"))
                                              ((content . "C") (role . "user"))
                                              ((content . "C-response") (role . "assistant"))]))))
                (should (org-assistant--json-encode json))
                (make-process
                 :name "org-assistant-json-echo"
                 :buffer buffer
                 :filter #'internal-default-process-filter
                 :command (list "cat" file))))))
    (org-mode)
    (erase-buffer)
    (insert "* Question
#+BEGIN_EXAMPLE
System Prompt
#+END_EXAMPLE

#+NAME: substitution-A
#+BEGIN_SRC text
SUBSTITUTION
#+END_SRC

#+BEGIN_SRC assistant :noweb yes
A <<substitution-A>>
#+END_SRC

#+BEGIN_SRC ignored
A
#+END_SRC

#+BEGIN_SRC assistant :sender assistant
A-response
#+END_SRC
** B Branch
#+BEGIN_SRC assistant
B
#+END_SRC

#+BEGIN_SRC text
Ignore me B
#+END_SRC

#+BEGIN_SRC assistant :sender assistant
B-response
#+END_SRC

** C Branch
#+BEGIN_SRC assistant
C
#+END_SRC

#+BEGIN_SRC text
Ignore me
#+END_SRC

#+BEGIN_SRC assistant :sender assistant :params '((temperature . 1))
C-response
#+END_SRC
")
    (goto-char (point-min))
    (search-forward "c-response")
    (should (equal (org-assistant--org-blocks t)
                   '((system . "System Prompt")
                     (user . "A SUBSTITUTION")
                     (assistant . "A-response")
                     (user . "C")
                     (assistant . "C-response"))))
    (defun yes-or-no-p (prompt) t)
    (let* ((uuid (org-ctrl-c-ctrl-c))
           (location (save-excursion (goto-char (point-min))
                                     (re-search-forward (rx (literal uuid)))
                                     (match-beginning 0)))
           (timer-cons (cons nil nil)))
      (should (stringp uuid))
      (goto-char location)
      (should (looking-at-p (rx (literal uuid))))
      (let ((buffer (current-buffer)))
        (setcar timer-cons
                (run-at-time
                 nil 0.1
                 (lambda ()
                   (with-current-buffer buffer
                     (goto-char location)
                     (when (not (looking-at-p (rx (literal uuid))))
                       (should (looking-at-p (rx line-start "#+BEGIN_SRC assistant :sender assistant"))) (forward-line 1)
                       (should (looking-at-p (rx line-start "TEST" line-end))) (forward-line 1)
                       (should (looking-at-p (rx line-start "#+END_SRC")))
                       (cancel-timer (car timer-cons))
                       (funcall done-output-replaced))))))))))

(provide 'org-assistant-test)
