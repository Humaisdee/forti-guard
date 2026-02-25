# Forti-Guard

**On-Chain Firewall for Smart Contract Call Management**

## Overview

Forti-Guard is a Clarity smart contract that provides granular access control and authorization checks for smart contract interactions on the Stacks blockchain. It implements a flexible whitelist/blacklist system with optional function-level permissions.

## Features

- **Contract-Level Access Control**: Whitelist or blacklist entire contracts
- **Function-Level Permissions**: Grant access to specific functions within approved contracts
- **Blacklist Override**: Blocked contracts take precedence over whitelisted entries
- **Owner-Controlled Administration**: Secure management functions restricted to contract owner
- **Read-Only Query Functions**: Non-destructive authorization checks

## Core Functions

### Administrative Functions (Owner Only)

| Function | Purpose |
|----------|---------|
| `allow-contract` | Whitelist a contract for interactions |
| `block-contract` | Blacklist a contract (overrides whitelist) |
| `remove-contract` | Remove a contract from both allow/block lists |
| `allow-function` | Grant access to a specific function |
| `remove-function` | Revoke function-level permission |

### Query Functions

| Function | Purpose |
|----------|---------|
| `is-allowed-contract?` | Check if contract is approved |
| `is-function-allowed?` | Check function access (contract or function level) |
| `can-call?` | Final authorization check before interaction |

## Usage Example

```clarity
;; Allow a contract
(allow-contract 'ST1234...)

;; Allow specific function
(allow-function 'ST1234... "transfer")

;; Check authorization
(can-call? 'ST1234... "transfer")
