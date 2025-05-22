;; Resource Registration Contract
;; Records available logistics assets

;; Resource structure
(define-map resources
  { owner: principal, resource-id: uint }
  {
    capacity: uint,
    available: bool,
    resource-type: uint
  })

(define-data-var next-resource-id uint u1)

;; Register a new resource
(define-public (register-resource (capacity uint) (resource-type uint))
  (let ((resource-id (var-get next-resource-id)))
    (var-set next-resource-id (+ resource-id u1))
    (ok (map-set resources
      { owner: tx-sender, resource-id: resource-id }
      {
        capacity: capacity,
        available: true,
        resource-type: resource-type
      }))))

;; Get resource details
(define-read-only (get-resource (owner principal) (resource-id uint))
  (map-get? resources { owner: owner, resource-id: resource-id }))

;; Update resource availability
(define-public (update-availability (resource-id uint) (available bool))
  (let ((resource-key { owner: tx-sender, resource-id: resource-id }))
    (asserts! (is-some (map-get? resources resource-key)) (err u1))
    (ok (map-set resources
      resource-key
      (merge (unwrap-panic (map-get? resources resource-key))
             { available: available })))))
