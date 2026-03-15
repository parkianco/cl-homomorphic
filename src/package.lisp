;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

;;;; package.lisp
;;;; cl-homomorphic package definition

(defpackage #:cl-homomorphic
  (:use #:cl)
  (:export
   #:with-homomorphic-timing
   #:homomorphic-batch-process
   #:homomorphic-health-check#:generate-paillier-keys
           #:paillier-encrypt
           #:paillier-decrypt
           #:paillier-add-encrypted
           #:paillier-multiply-constant))
