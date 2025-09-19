;; Decentralized Disaster Recovery Fund (D-DRF) - Clean Clarity implementation

(define-constant MIN-DONATION u100)
(define-constant ERR-INVALID-DONATION u100)
(define-constant ERR-ALREADY-CLAIMED u101)
(define-constant ERR-UNAUTHORIZED u102)
(define-constant ERR-CLAIM-INVALID u103)
(define-constant ERR-NO-FUNDS u104)
(define-constant ERR-NOT-INITIALIZED u105)

;; Storage
(define-map fund-status
  { key: uint }
  { total-funds: uint, is-active: bool, creator: principal }
)

(define-map claims
  { claim-id: uint }
  { reporter: principal, amount: uint, is-verified: bool, is-paid: bool }
)

(define-map donations
  { donor: principal }
  { amount: uint }
)

(define-data-var claim-counter uint u0)

;; Private helper: check if a principal is the creator
(define-private (is-creator (p principal))
  (let ((fs (map-get? fund-status { key: u0 })))
    (if (is-none fs)
      false
      (is-eq p (get creator (unwrap-panic fs)))
    )
  )
)

;; Initialize fund (callable once)
(define-public (initialize-fund)
  (if (is-none (map-get? fund-status { key: u0 }))
    (begin
      (map-set fund-status { key: u0 } { total-funds: u0, is-active: true, creator: tx-sender })
      (ok true)
    )
    (err ERR-CLAIM-INVALID)
  )
)

;; Donate (bookkeeping only)
(define-public (donate (amount uint))
  (if (< amount MIN-DONATION)
    (err ERR-INVALID-DONATION)
    (let ((fs (map-get? fund-status { key: u0 })))
      (if (is-none fs)
        (err ERR-NOT-INITIALIZED)
        (let ((fund (unwrap-panic fs)))
          (map-set fund-status { key: u0 } { total-funds: (+ (get total-funds fund) amount), is-active: (get is-active fund), creator: (get creator fund) })
          (map-set donations { donor: tx-sender } { amount: amount })
          (ok true)
        )
      )
    )
  )
)

;; Submit claim
(define-public (submit-claim (amount uint))
  (if (<= amount u0)
    (err ERR-CLAIM-INVALID)
    (let ((fs (map-get? fund-status { key: u0 })))
      (if (is-none fs)
        (err ERR-NOT-INITIALIZED)
        (let ((fund (unwrap-panic fs)))
          (if (not (get is-active fund))
            (err ERR-CLAIM-INVALID)
            (let ((cid (var-get claim-counter)))
              (var-set claim-counter (+ cid u1))
              (map-set claims { claim-id: (+ cid u1) } { reporter: tx-sender, amount: amount, is-verified: false, is-paid: false })
              (ok (+ cid u1))
            )
          )
        )
      )
    )
  )
)

;; Verify claim and mark paid (bookkeeping only)
(define-public (verify-claim (claim-id uint) (approve bool))
  (if (not (is-creator tx-sender))
    (err ERR-UNAUTHORIZED)
    (let ((c (map-get? claims { claim-id: claim-id })))
      (if (is-none c)
        (err ERR-CLAIM-INVALID)
        (let ((claim (unwrap-panic c)))
          (if (get is-verified claim)
            (err ERR-ALREADY-CLAIMED)
            (begin
              (map-set claims { claim-id: claim-id } { reporter: (get reporter claim), amount: (get amount claim), is-verified: approve, is-paid: (and approve (get is-paid claim)) })
              (if (not approve)
                (ok true)
                (let ((fs (map-get? fund-status { key: u0 })))
                  (if (is-none fs)
                    (err ERR-NOT-INITIALIZED)
                    (let ((fund (unwrap-panic fs)) (amt (get amount claim)))
                      (if (< (get total-funds fund) amt)
                        (err ERR-NO-FUNDS)
                        (begin
                          (map-set fund-status { key: u0 } { total-funds: (- (get total-funds fund) amt), is-active: (get is-active fund), creator: (get creator fund) })
                          (map-set claims { claim-id: claim-id } { reporter: (get reporter claim), amount: amt, is-verified: true, is-paid: true })
                          (ok true)
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )
)

;; Read-only views
(define-read-only (get-fund-status)
  (ok (map-get? fund-status { key: u0 }))
)

(define-read-only (get-claim-status (claim-id uint))
  (ok (map-get? claims { claim-id: claim-id }))
)

(define-read-only (get-donation (donor principal))
  (ok (map-get? donations { donor: donor }))
)
