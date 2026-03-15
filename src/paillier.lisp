;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

;;;; paillier.lisp
;;;; Paillier homomorphic encryption implementation

(in-package #:cl-homomorphic)

;;; Paillier Cryptosystem
;;; Additively homomorphic: D(E(m1) * E(m2) mod n^2) = m1 + m2
;;; Reference: Paillier, "Public-Key Cryptosystems Based on Composite Degree Residuosity Classes"

;;; Structures

(defstruct (paillier-public-key (:constructor %make-paillier-public-key))
  "Paillier public key."
  (n 0 :type integer)      ; n = p * q
  (n-squared 0 :type integer)  ; n^2
  (g 0 :type integer))     ; generator, typically n + 1

(defstruct (paillier-private-key (:constructor %make-paillier-private-key))
  "Paillier private key."
  (lambda-val 0 :type integer)  ; lcm(p-1, q-1)
  (mu 0 :type integer)          ; L(g^lambda mod n^2)^(-1) mod n
  (n 0 :type integer)
  (n-squared 0 :type integer))

;;; Number-theoretic utilities

(defun mod-expt (base exponent modulus)
  "Modular exponentiation: base^exponent mod modulus."
  (declare (type integer base exponent modulus))
  (when (zerop modulus)
    (error "Modulus cannot be zero"))
  (cond ((zerop exponent) 1)
        ((minusp exponent)
         (mod-expt (mod-inverse base modulus) (- exponent) modulus))
        (t
         (let ((result 1)
               (base (mod base modulus)))
           (loop while (plusp exponent)
                 do (when (oddp exponent)
                      (setf result (mod (* result base) modulus)))
                    (setf exponent (ash exponent -1))
                    (setf base (mod (* base base) modulus)))
           result))))

(defun extended-gcd (a b)
  "Extended Euclidean algorithm. Returns (values gcd x y) where ax + by = gcd."
  (if (zerop b)
      (values a 1 0)
      (multiple-value-bind (g x y) (extended-gcd b (mod a b))
        (values g y (- x (* y (floor a b)))))))

(defun mod-inverse (a n)
  "Modular multiplicative inverse of a mod n."
  (multiple-value-bind (g x) (extended-gcd a n)
    (unless (= g 1)
      (error "No modular inverse exists for ~D mod ~D" a n))
    (mod x n)))

(defun lcm-integers (a b)
  "Least common multiple of a and b."
  (/ (* a b) (gcd a b)))

(defun l-function (u n)
  "L function: L(u) = (u - 1) / n."
  (/ (1- u) n))

;;; Primality testing (Miller-Rabin)

(defun random-in-range-simple (min max)
  "Simple random integer in range [min, max)."
  (+ min (random (- max min))))

(defun miller-rabin-witness-p (a n)
  "Check if a is a Miller-Rabin witness for compositeness of n."
  (let* ((d (1- n))
         (r 0))
    ;; Write n-1 as 2^r * d
    (loop while (evenp d)
          do (setf d (ash d -1))
             (incf r))
    ;; Compute a^d mod n
    (let ((x (mod-expt a d n)))
      (when (or (= x 1) (= x (1- n)))
        (return-from miller-rabin-witness-p nil))
      (loop repeat (1- r)
            do (setf x (mod (* x x) n))
               (when (= x (1- n))
                 (return-from miller-rabin-witness-p nil)))
      t)))

(defun probably-prime-p (n &optional (iterations 20))
  "Miller-Rabin primality test."
  (cond ((<= n 1) nil)
        ((= n 2) t)
        ((evenp n) nil)
        (t (loop repeat iterations
                 for a = (+ 2 (random (- n 3)))
                 never (miller-rabin-witness-p a n)))))

(defun generate-prime (bits)
  "Generate a random prime of approximately BITS bits."
  (loop for candidate = (logior (random (ash 1 bits))
                                (ash 1 (1- bits))  ; Ensure high bit set
                                1)                  ; Ensure odd
        when (probably-prime-p candidate 20)
          return candidate))

;;; Key generation

(defun generate-paillier-keys (bits)
  "Generate Paillier keypair with modulus of BITS bits.
   Returns (values public-key private-key)."
  (let* ((half-bits (ceiling bits 2))
         (p (generate-prime half-bits))
         (q (loop for q = (generate-prime half-bits)
                  until (/= p q)
                  finally (return q)))
         (n (* p q))
         (n-squared (* n n))
         (g (1+ n))  ; Simple choice: g = n + 1
         (lambda-val (lcm-integers (1- p) (1- q)))
         (u (mod-expt g lambda-val n-squared))
         (mu (mod-inverse (l-function u n) n)))
    (values
     (%make-paillier-public-key :n n :n-squared n-squared :g g)
     (%make-paillier-private-key :lambda-val lambda-val :mu mu
                                  :n n :n-squared n-squared))))

;;; Encryption

(defun paillier-encrypt (public-key plaintext)
  "Encrypt plaintext (integer) using Paillier encryption.
   Plaintext must be in [0, n)."
  (let* ((n (paillier-public-key-n public-key))
         (n-squared (paillier-public-key-n-squared public-key))
         (g (paillier-public-key-g public-key)))
    (unless (and (>= plaintext 0) (< plaintext n))
      (error "Plaintext ~D out of range [0, ~D)" plaintext n))
    ;; Choose random r in [1, n-1] coprime with n
    (let* ((r (loop for r = (1+ (random (1- n)))
                    when (= 1 (gcd r n))
                      return r))
           ;; c = g^m * r^n mod n^2
           (gm (mod-expt g plaintext n-squared))
           (rn (mod-expt r n n-squared)))
      (mod (* gm rn) n-squared))))

;;; Decryption

(defun paillier-decrypt (private-key ciphertext)
  "Decrypt ciphertext using Paillier private key."
  (let* ((n (paillier-private-key-n private-key))
         (n-squared (paillier-private-key-n-squared private-key))
         (lambda-val (paillier-private-key-lambda-val private-key))
         (mu (paillier-private-key-mu private-key))
         ;; m = L(c^lambda mod n^2) * mu mod n
         (u (mod-expt ciphertext lambda-val n-squared)))
    (mod (* (l-function u n) mu) n)))

;;; Homomorphic operations

(defun paillier-add-encrypted (public-key c1 c2)
  "Add two encrypted values homomorphically.
   D(result) = D(c1) + D(c2) mod n."
  (let ((n-squared (paillier-public-key-n-squared public-key)))
    (mod (* c1 c2) n-squared)))

(defun paillier-multiply-constant (public-key ciphertext constant)
  "Multiply encrypted value by a plaintext constant.
   D(result) = D(ciphertext) * constant mod n."
  (let ((n-squared (paillier-public-key-n-squared public-key)))
    (mod-expt ciphertext constant n-squared)))
