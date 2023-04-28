;;; -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'org)
(require 'el-mock)

(when (require 'undercover nil t)
  (undercover "*.el"))
(require 'org-assistant (expand-file-name "org-assistant.el"))

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

#+BEGIN_EXAMPLE
A-response
#+END_EXAMPLE

#+BEGIN_SRC assistant
B
#+END_SRC

#+BEGIN_EXAMPLE
B-response
#+END_EXAMPLE

#+BEGIN_SRC ?
C
#+END_SRC

#+BEGIN_EXAMPLE
C-response
#+END_EXAMPLE
")
    (goto-char (point-min))
    (should (eq (org-assistant--org-blocks nil) nil))
    (search-forward "#+BEGIN_EXAMPLE")
    (goto-char (match-beginning 0))
    (should (equal (org-assistant--org-blocks nil) (list (cons 'system "System Prompt"))))
    (search-forward "#+BEGIN_SRC")
    (goto-char (match-beginning 0))
    (should (equal (org-assistant--org-blocks nil) (list
                                                (cons 'system "System Prompt")
                                                (cons 'user "A"))))
    (search-forward "#+BEGIN_EXAMPLE")
    (goto-char (match-beginning 0))
    (should (equal (org-assistant--org-blocks nil)
                   (list
                    (cons 'system "System Prompt")
                    (cons 'user "A")
                    (cons 'assistant "A-response"))))
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
  (with-current-buffer (get-buffer-create " *assistant-test*")
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

#+BEGIN_EXAMPLE
A-response
#+END_EXAMPLE
** B Branch
#+BEGIN_SRC assistant
B
#+END_SRC

#+BEGIN_SRC text
Ignore me B
#+END_SRC

#+BEGIN_EXAMPLE
B-response
#+END_EXAMPLE

** C Branch
#+BEGIN_SRC assistant
C
#+END_SRC

#+BEGIN_SRC text
Ignore me
#+END_SRC

#+BEGIN_EXAMPLE
C-response
#+END_EXAMPLE
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

#+BEGIN_EXAMPLE
A-response
#+END_EXAMPLE
** B Branch
#+BEGIN_SRC assistant
B
#+END_SRC

#+BEGIN_SRC text
Ignore me B
#+END_SRC

#+BEGIN_EXAMPLE
B-response
#+END_EXAMPLE

** C Branch
#+BEGIN_SRC assistant
C
#+END_SRC

#+BEGIN_SRC text
Ignore me
#+END_SRC

#+BEGIN_EXAMPLE
C-response
#+END_EXAMPLE
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

(provide 'org-assistant-test)
