;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-homomorphic)

(define-condition cl-homomorphic-error (error)
  ((message :initarg :message :reader cl-homomorphic-error-message))
  (:report (lambda (condition stream)
             (format stream "cl-homomorphic error: ~A" (cl-homomorphic-error-message condition)))))
