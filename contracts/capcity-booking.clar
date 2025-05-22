;; Capacity Booking Contract
;; Manages reservation of resources

;; Booking structure
(define-map bookings
  { booking-id: uint }
  {
    resource-owner: principal,
    resource-id: uint,
    booker: principal,
    amount: uint,
    start-time: uint,
    end-time: uint,
    status: uint  ;; 1=pending, 2=confirmed, 3=completed, 4=cancelled
  })

(define-data-var next-booking-id uint u1)

;; Book capacity
(define-public (book-capacity
    (resource-owner principal)
    (resource-id uint)
    (amount uint)
    (start-time uint)
    (end-time uint))
  (let ((booking-id (var-get next-booking-id)))
    ;; Basic validation
    (asserts! (> end-time start-time) (err u1))

    ;; Create booking
    (map-set bookings
      { booking-id: booking-id }
      {
        resource-owner: resource-owner,
        resource-id: resource-id,
        booker: tx-sender,
        amount: amount,
        start-time: start-time,
        end-time: end-time,
        status: u1  ;; pending
      })

    ;; Update booking ID counter
    (var-set next-booking-id (+ booking-id u1))
    (ok booking-id)))

;; Confirm booking (resource owner only)
(define-public (confirm-booking (booking-id uint))
  (let ((booking (unwrap! (map-get? bookings { booking-id: booking-id }) (err u2))))
    ;; Check if sender is resource owner
    (asserts! (is-eq (get resource-owner booking) tx-sender) (err u3))
    ;; Check if booking is pending
    (asserts! (is-eq (get status booking) u1) (err u4))

    ;; Update booking status to confirmed
    (ok (map-set bookings
      { booking-id: booking-id }
      (merge booking { status: u2 })))))

;; Complete booking
(define-public (complete-booking (booking-id uint))
  (let ((booking (unwrap! (map-get? bookings { booking-id: booking-id }) (err u2))))
    ;; Check if sender is resource owner or booker
    (asserts! (or
                (is-eq (get resource-owner booking) tx-sender)
                (is-eq (get booker booking) tx-sender))
              (err u3))
    ;; Check if booking is confirmed
    (asserts! (is-eq (get status booking) u2) (err u4))

    ;; Update booking status to completed
    (ok (map-set bookings
      { booking-id: booking-id }
      (merge booking { status: u3 })))))

;; Get booking details
(define-read-only (get-booking (booking-id uint))
  (map-get? bookings { booking-id: booking-id }))
