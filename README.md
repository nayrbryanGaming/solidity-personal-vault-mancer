# Personal Vault: Time-Locked Savings Contract

## Overview
A personal savings vault smart contract on Ethereum where users can lock their ETH for a specific period. This contract enforces self-discipline by preventing any withdrawals until a predetermined unlock time passes.

## Features
- **Deposit**: Accept any amount of ETH from the owner.
- **Secure Withdrawal**: Funds are only accessible after the `unlockTime`.
- **Lock Extension**: Allows the owner to extend the lock time (cannot be shortened).
- **Modern Security**: Uses `call{value: amount}("")` for safe Ether transfers.
- **Gas Optimized**: Implements custom errors for cost-efficiency.

## Technical Specifications
- **Solidity Version**: `^0.8.0`
- **License**: `MIT`
- **Main Contract**: `PersonalVault.sol`

## Functions
- `constructor(uint256 _unlockTime)`: Sets the initial lock period.
- `deposit() public payable`: Adds ETH to the contract balance.
- `withdraw() public onlyOwner`: Transfers the entire balance back to the owner after `unlockTime`.
- `extendLock(uint256 newTime) public onlyOwner`: Increases the `unlockTime`.

## Usage
1. Deploy with a future timestamp.
2. Deposit funds.
3. Wait until the timer expires.
4. Execute `withdraw` to retrieve your savings.

---
*Created by nayrbryanGaming for Mancer Final Fundamental Test.*
