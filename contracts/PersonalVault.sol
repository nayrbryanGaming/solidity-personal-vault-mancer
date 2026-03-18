// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PersonalVault {
    address public owner;           // Who owns this vault
    uint256 public unlockTime;      // When funds become available
    
    // Events
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 newUnlockTime);
    
    // Custom errors
    error FundsLocked();
    error NotOwner();
    error InvalidUnlockTime();

    // Access Control Pattern
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    // Constructor
    constructor(uint256 _unlockTime) payable {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");
        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    /**
     * @dev 1. Deposit
     * Logic: Accept any amount of ETH, Add to balance, Emit event.
     */
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev 2. Withdraw
     * Conditions: Current time >= unlockTime, Caller is owner, Balance > 0.
     */
    function withdraw() public onlyOwner {
        // Check time requirement
        if (block.timestamp < unlockTime) {
            revert FundsLocked();
        }

        // Check balance
        uint256 amount = address(this).balance;
        require(amount > 0, "No balance to withdraw");

        // Emit event
        emit Withdrawal(amount, block.timestamp);

        // Transfer entire contract balance to owner
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Transfer failed");
    }

    /**
     * @dev 3. Extend Lock
     * Logic: Validate newTime > unlockTime, Update, Emit event.
     */
    function extendLock(uint256 newTime) public onlyOwner {
        // Validate newTime is greater than current unlockTime
        if (newTime <= unlockTime) {
            revert InvalidUnlockTime();
        }

        // Update unlockTime
        unlockTime = newTime;

        // Emit event
        emit LockExtended(newTime);
    }

    // Fallback to receive ETH
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}
