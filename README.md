Fund A Farm - Clarity Smart Contract
# Fund A Farm

## Overview

The Fund A Farm smart contract is built on the Stacks blockchain using Clarity, enabling decentralized crowdfunding for agricultural projects. Farmers can raise funds, and investors can contribute towards these projects with the expectation of receiving a return on investment (ROI) after the project completes. The contract tracks project funding, investments, and handles the distribution of funds and profits.

## Key Features

- **Project Creation**: Farmers can create projects with specified funding goals, duration, and return on investment (ROI).
- **Investment**: Users can invest STX (Stacks tokens) into open projects.
- **Fund Withdrawal**: Once a project is fully funded or the funding period ends, farmers can withdraw the raised funds.
- **Profit Distribution**: After project completion, farmers can return profits to investors based on their contributions and the promised ROI.
- **Refund**: If the project fails to meet its funding goal within the set time, investors are refunded their contributions.

## Smart Contract Functions

### 1. Project Creation

```clarity
(define-public (create-project (funding-goal uint) (duration uint) (roi uint)) -> (response uint uint))
```

**Inputs:**
- `funding-goal`: The required STX amount to fully fund the project.
- `duration`: The number of blocks before the funding period ends.
- `roi`: The return on investment (in percentage) promised to investors.

**Returns:** The project ID of the newly created project.

### 2. Invest in Project

```clarity
(define-public (invest-in-project (project-id uint) (amount uint)) -> (response (string-ascii 32) (string-ascii 32)))
```

**Inputs:**
- `project-id`: ID of the project to invest in.
- `amount`: STX amount to invest.

**Returns:** A success or failure message after the investment is recorded and the funds are transferred.

### 3. Withdraw Funds

```clarity
(define-public (withdraw-funds (project-id uint)) -> (response (string-ascii 32) (string-ascii 32)))
```

**Inputs:**
- `project-id`: ID of the project.

**Returns:** A success or failure message after the funds are withdrawn by the farmer.

### 4. Return Profits

```clarity
(define-public (return-profits (project-id uint)) -> (response bool uint))
```

**Inputs:**
- `project-id`: ID of the project.

**Returns:** A boolean indicating whether profits were successfully returned to investors.

### 5. Refund Investors

```clarity
(define-public (refund-investors (project-id uint)) -> (response (string-ascii 32) (string-ascii 32)))
```

**Inputs:**
- `project-id`: ID of the project.

**Returns:** A success or failure message after refunding all investors if the project did not reach its funding goal.

### 6. Get Investors

```clarity
(define-read-only (get-investors (project-id uint)) -> (response (list 100 principal) uint))
```

**Inputs:**
- `project-id`: ID of the project.

**Returns:** A list of all investors who contributed to the project.

## Project Status

Projects can have the following statuses:

- `0`: Open (available for investment).
- `1`: Funded (goal reached, no longer accepting investments).
- `2`: Closed (funds withdrawn by the farmer).

## Installation

Clone the repository:

```bash
git clone https://github.com/your-username/fund-a-farm.git
```

Install Clarinet to run and test Clarity contracts:

```bash
npm install -g @hirosystems/clarinet
```

Run the tests:

```bash
clarinet test
```

## Usage

- Farmers create projects via `create-project`.
- Investors contribute funds using `invest-in-project`.
- Once a project is fully funded or the duration has ended, farmers can withdraw funds using `withdraw-funds`.
- After the project ends, farmers can distribute profits to investors with `return-profits`.
- If the funding goal is not met, the contract allows refunding investors via `refund-investors`.

## Error Handling

- `u404`: Investors not found for a project.
- `u401`: Unauthorized profit return attempt.
- `u400`: Project not found.
- `u405`: Investment not found.

## License

MIT License

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.