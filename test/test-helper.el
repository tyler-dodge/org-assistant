;;; -*- lexical-binding: t -*-

(defun relative-to-test-directory (file)
  (->
   (or (-some--> (and (f-exists-p (expand-file-name "test")) "test")
         (f-join it file))
       file)
   expand-file-name))
