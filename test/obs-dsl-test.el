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

(provide 'org-assistant-test)
