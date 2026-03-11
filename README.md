# cl-homomorphic

Paillier homomorphic encryption for Common Lisp with zero external dependencies.

## Installation

```lisp
(asdf:load-system :cl-homomorphic)
```

## API

- `(generate-paillier-keys bits)` - Generate Paillier keypair
- `(paillier-encrypt public-key plaintext)` - Encrypt plaintext
- `(paillier-decrypt private-key ciphertext)` - Decrypt ciphertext
- `(paillier-add-encrypted public-key c1 c2)` - Add two ciphertexts
- `(paillier-multiply-constant public-key ciphertext constant)` - Multiply by constant

## Example

```lisp
(multiple-value-bind (pub priv) (cl-homomorphic:generate-paillier-keys 2048)
  (let* ((c1 (cl-homomorphic:paillier-encrypt pub 10))
         (c2 (cl-homomorphic:paillier-encrypt pub 20))
         (c-sum (cl-homomorphic:paillier-add-encrypted pub c1 c2)))
    (cl-homomorphic:paillier-decrypt priv c-sum)))
; => 30
```

## License

BSD-3-Clause - Parkian Company LLC 2024-2026
