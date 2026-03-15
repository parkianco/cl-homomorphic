;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-homomorphic)

;;; Core types for cl-homomorphic
(deftype cl-homomorphic-id () '(unsigned-byte 64))
(deftype cl-homomorphic-status () '(member :ready :active :error :shutdown))
