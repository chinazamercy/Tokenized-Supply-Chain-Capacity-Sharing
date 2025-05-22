;; Entity Verification Contract
;; Validates supply chain participants

;; Define admin
(define-data-var admin principal tx-sender)

;; Map to store verified entities
(define-map verified-entities principal bool)

;; Verify an entity (admin only)
(define-public (verify-entity (entity principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (map-set verified-entities entity true))))

;; Check if an entity is verified
(define-read-only (is-verified (entity principal))
  (default-to false (map-get? verified-entities entity)))

;; Revoke verification (admin only)
(define-public (revoke-verification (entity principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (map-set verified-entities entity false))))

;; Change admin (admin only)
(define-public (change-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))))
