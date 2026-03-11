;;;; package.lisp
;;;; cl-homomorphic package definition

(defpackage #:cl-homomorphic
  (:use #:cl)
  (:export #:generate-paillier-keys
           #:paillier-encrypt
           #:paillier-decrypt
           #:paillier-add-encrypted
           #:paillier-multiply-constant))
