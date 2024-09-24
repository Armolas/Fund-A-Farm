;; fund_a_farm
;; A decentralized crowdfunding smart contract for agricultural projects on the Stacks blockchain. 
;; Farmers can create projects, set a funding goal, and allow investors to contribute STX tokens. 
;; After a project is funded, farmers can withdraw funds and later return profits to investors based on their ROI.
;; If the project is not funded within a given duration, investors can be refunded.

;; constants
;;
;; Define the contract owner (usually set to the address deploying the contract)
(define-constant contract-owner (as-contract tx-sender))

;; data maps and vars
;;
;; Define a map to store project details such as funding goals, duration, and status
(define-map projects
  {project-id: uint}
  {
    farmer: principal,          ;; Farmer who created the project
    funding-goal: uint,         ;; Amount needed to fully fund the project
    amount-raised: uint,        ;; Amount raised so far
    duration: uint,             ;; Duration of the funding period (in blocks)
    roi: uint,                  ;; Return on investment percentage for investors
    end-time: uint,             ;; Block height when funding period ends
    status: int                 ;; 0 = Open, 1 = Funded, 2 = Closed
  }
)

;; Define a map to store the investments made by each investor
(define-map investments
  {project-id: uint, investor: principal}
  {
    amount: uint,               ;; Amount invested by the investor
    invested-at: uint           ;; Block height when the investment was made
  }
)

;; Variable to keep track of the total number of projects created
(define-data-var project-counter uint u1)

;; private functions
;;
;; No private functions defined in this contract. 

;; public functions
;;

;; Create a new project
(define-public (create-project (funding-goal uint) (duration uint) (roi uint))
  (let ((new-project-id (var-get project-counter))  ;; Fetch the current project ID
        (end-time (+ block-height duration)))       ;; Set the end-time based on current block height
    ;; Store the project data
    (map-set projects {project-id: new-project-id}
      {
        farmer: tx-sender,                          ;; Assign the project creator as the farmer
        funding-goal: funding-goal,                 ;; Set the funding goal
        amount-raised: u0,                          ;; Initially, no funds are raised
        duration: duration,                         ;; Set the project's duration
        roi: roi,                                   ;; Set the ROI for investors
        end-time: end-time,                         ;; Block height at which the project will close
        status: 0                                   ;; Set project status to Open (0)
      }
    )
    ;; Increment project counter for the next project
    (var-set project-counter (+ new-project-id u1))
    (ok new-project-id)                             ;; Return the new project ID
  )
)

;; Invest in a project
(define-public (invest-in-project (project-id uint) (amount uint))
  (let ((project (unwrap! (map-get? projects {project-id: project-id}) (err "Project not found"))))
    (match project
      project-data
        (begin
          ;; Ensure the project is still open for investment
          (asserts! (is-eq (get status project-data) 0) (err "Project is not open for investment"))
          ;; Ensure the project is still within the funding period
          (asserts! (< block-height (get end-time project-data)) (err "Funding period has ended"))

          ;; Update the amount raised in the project
          (let ((new-amount-raised (+ (get amount-raised project-data) amount)))
            (map-set projects {project-id: project-id}
              {
                farmer: (get farmer project-data),
                funding-goal: (get funding-goal project-data),
                amount-raised: new-amount-raised,    ;; Update the amount raised
                duration: (get duration project-data),
                roi: (get roi project-data),
                end-time: (get end-time project-data),
                status: (if (>= new-amount-raised (get funding-goal project-data)) 1 0) ;; Update status if funded
              }
            )
          )

          ;; Record the investor's contribution in the investments map
          (map-set investments {project-id: project-id, investor: tx-sender}
            {
              amount: amount,                       ;; Amount invested
              invested-at: block-height             ;; Record the block height of the investment
            }
          )

          ;; Transfer the invested funds to the contract
          (stx-transfer? amount tx-sender contract-owner)
          (ok "Investment successful")
        )
      (err "Project not found")
    )
  )
)