;; ============================================================
;; Contract: forti-guard.clar
;; Purpose : On-chain firewall for smart contract calls
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------
(define-constant ERR-NOT-OWNER          (err u15001))
(define-constant ERR-NOT-AUTHORIZED     (err u15002))
(define-constant ERR-BLOCKED            (err u15003))

;; -------------------------
;; OWNER
;; -------------------------
(define-data-var contract-owner principal tx-sender)

;; -------------------------
;; STORAGE
;; -------------------------

;; List of approved contracts
(define-map allowed-contracts
  principal
  bool
)

;; List of blocked contracts (overrides allow)
(define-map blocked-contracts
  principal
  bool
)

;; Optional whitelisted functions per contract
(define-map allowed-functions
  { contract: principal, function: (string-ascii 32) }
  bool
)

;; -------------------------
;; READ-ONLY HELPERS
;; -------------------------

(define-read-only (is-owner?)
  (is-eq tx-sender (var-get contract-owner))
)

(define-read-only (is-allowed-contract? (contract principal))
  (and
    (default-to false (map-get? allowed-contracts contract))
    (not (default-to false (map-get? blocked-contracts contract)))
  )
)

(define-read-only (is-function-allowed? (contract principal) (func-name (string-ascii 32)))
  (or
    (default-to false (map-get? allowed-functions { contract: contract, function: func-name }))
    (is-allowed-contract? contract)
  )
)

;; -------------------------
;; OWNER CONTROLS
;; -------------------------

(define-public (allow-contract (contract principal))
  (begin
    (asserts! (is-owner?) ERR-NOT-OWNER)
    (map-set allowed-contracts contract true)
    (ok true)
  )
)

(define-public (block-contract (contract principal))
  (begin
    (asserts! (is-owner?) ERR-NOT-OWNER)
    (map-set blocked-contracts contract true)
    (ok true)
  )
)

(define-public (remove-contract (contract principal))
  (begin
    (asserts! (is-owner?) ERR-NOT-OWNER)
    (map-delete allowed-contracts contract)
    (map-delete blocked-contracts contract)
    (ok true)
  )
)

(define-public (allow-function (contract principal) (func-name (string-ascii 32)))
  (begin
    (asserts! (is-owner?) ERR-NOT-OWNER)
    (map-set allowed-functions { contract: contract, function: func-name } true)
    (ok true)
  )
)

(define-public (remove-function (contract principal) (func-name (string-ascii 32)))
  (begin
    (asserts! (is-owner?) ERR-NOT-OWNER)
    (map-delete allowed-functions { contract: contract, function: func-name })
    (ok true)
  )
)

;; -------------------------
;; INTERACTION CHECK
;; -------------------------

(define-read-only (can-call? (contract principal) (func-name (string-ascii 32)))
  (is-function-allowed? contract func-name)
)
