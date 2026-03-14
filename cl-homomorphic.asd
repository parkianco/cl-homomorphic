;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; cl-homomorphic.asd
;;;; Paillier homomorphic encryption - zero external dependencies

(asdf:defsystem #:cl-homomorphic
  :description "Paillier homomorphic encryption"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "0.1.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :components ((:file "paillier")))))

(asdf:defsystem #:cl-homomorphic/test
  :description "Tests for cl-homomorphic"
  :depends-on (#:cl-homomorphic)
  :serial t
  :components ((:module "test"
                :components ((:file "test-homomorphic"))))
  :perform (asdf:test-op (o c)
             (let ((result (uiop:symbol-call :cl-homomorphic.test :run-tests)))
               (unless result
                 (error "Tests failed")))))
