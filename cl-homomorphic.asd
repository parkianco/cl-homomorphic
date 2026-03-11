;;;; cl-homomorphic.asd
;;;; Paillier homomorphic encryption - zero external dependencies

(asdf:defsystem #:cl-homomorphic
  :description "Paillier homomorphic encryption"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "1.0.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :components ((:file "paillier")))))
