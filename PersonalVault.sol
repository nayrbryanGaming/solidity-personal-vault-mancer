// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PersonalVault
 * @dev Brankas simpanan pribadi yang terkunci waktu.
 */
contract PersonalVault {
    address public owner;           // Pemilik vault
    uint256 public unlockTime;      // Waktu pembukaan kunci (timestamp)
    
    // Events sesuai spesifikasi
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 newUnlockTime);
    
    // Custom errors sesuai spesifikasi
    error FundsLocked();
    error NotOwner();
    error InvalidUnlockTime();

    // Modifier onlyOwner sesuai spesifikasi
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /**
     * @dev Constructor sesuai dengan cuplikan kode di spesifikasi teknis.
     * Menggunakan require untuk pesan error spesifik yang diminta.
     */
    constructor(uint256 _unlockTime) payable {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");
        owner = msg.sender;
        unlockTime = _unlockTime;

        // Mencatat deposit awal jika ada
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    /**
     * @dev 1. Deposit: Menerima ETH dari siapa saja (Owner adalah penyetor utama).
     * Logic: Accept any amount of ETH, Add to balance, Emit event.
     */
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev 2. Withdraw: Menarik dana setelah waktu kunci berakhir.
     * Hanya bisa dipanggil oleh owner.
     */
    function withdraw() public onlyOwner {
        // Cek persyaratan waktu
        if (block.timestamp < unlockTime) {
            revert FundsLocked();
        }

        uint256 amount = address(this).balance;
        require(amount > 0, "No balance to withdraw");

        // Efek: Emit event Withdrawal
        emit Withdrawal(amount, block.timestamp);

        // Interaksi: Transfer seluruh saldo menggunakan call
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    /**
     * @dev 3. Extend Lock: Memperpanjang waktu kunci.
     * Pemilik tidak bisa memperpendek waktu kunci.
     */
    function extendLock(uint256 newTime) public onlyOwner {
        // Validasi: newTime > current unlockTime
        if (newTime <= unlockTime) {
            revert InvalidUnlockTime();
        }

        unlockTime = newTime;
        emit LockExtended(newTime);
    }

    /**
     * @dev Fallback function untuk menerima ETH secara langsung.
     */
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Fungsi pembantu untuk mengecek saldo.
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
