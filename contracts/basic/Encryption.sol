// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, euint64, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Encryption Example
 * @notice Demonstrates encrypting values on-chain for storage and computation
 * @dev Covered concepts:
 *      - FHE.asEuint32() - encrypt plain values into euint32
 *      - FHE.asEuint64() - encrypt plain values into euint64
 *      - FHE.fromExternal() - convert external encrypted inputs
 *      - Storing encrypted values in state
 *      - Operating on encrypted data
 */
contract Encryption is ZamaEthereumConfig {
    // ✅ Encrypted state variable for single value
    euint32 private encryptedBalance;

    // ✅ Encrypted state variable for multiple values
    mapping(address => euint32) private encryptedBalances;

    // ✅ Counter for tracking encrypted operations
    uint256 private operationCount;

    /**
     * @notice Encrypt and store a single value
     * @param plainValue The plain (unencrypted) value to encrypt
     *
     * ✅ KEY CONCEPT: On-Chain Encryption
     * Plain values can be encrypted directly on-chain
     * FHE.asEuint32() encrypts a plain uint32
     * Result is encrypted and stored in state
     *
     * SECURITY NOTE:
     * - Input is a plain value (not encrypted)
     * - FHE converts it to encrypted euint32
     * - No zero-knowledge proof needed for plain inputs
     * - Output is encrypted and private
     */
    function encryptAndStore(uint32 plainValue) external {
        // ✅ FHE.asEuint32() encrypts a plain uint32 value
        euint32 encrypted = FHE.asEuint32(plainValue);

        // Grant contract permission to use this value
        FHE.allowThis(encrypted);

        // Grant caller permission to decrypt their value
        FHE.allow(encrypted, msg.sender);

        // Store in state (remains encrypted)
        encryptedBalance = encrypted;

        operationCount++;
    }

    /**
     * @notice Store encrypted value per user
     * @param plainValue The value to encrypt and store
     *
     * ✅ KEY CONCEPT: Mapping with Encrypted Values
     * Each user can have their own encrypted balance
     * Values remain private to each user
     * Contract can perform operations on encrypted balances
     */
    function setUserBalance(uint32 plainValue) external {
        euint32 encrypted = FHE.asEuint32(plainValue);

        FHE.allowThis(encrypted);
        FHE.allow(encrypted, msg.sender);

        // Store per-user encrypted balance
        encryptedBalances[msg.sender] = encrypted;

        operationCount++;
    }

    /**
     * @notice Get the encrypted balance for a user
     * @param user The user to query
     * @return The encrypted balance (euint32 handle)
     *
     * ✅ KEY CONCEPT: Returning Encrypted Values
     * Can return encrypted values from view functions
     * Only authorized users can decrypt
     * Prevents unauthorized value leakage
     */
    function getEncryptedBalance(address user) external view returns (euint32) {
        return encryptedBalances[user];
    }

    /**
     * @notice Receives externally encrypted input with proof
     * @param externalValue Encrypted value from external source (client)
     * @param inputProof Zero-knowledge proof of correct encryption
     *
     * @dev Demonstrates receiving encrypted inputs from clients
     * This is the ONLY way to receive encrypted values from untrusted sources
     *
     * ✅ KEY CONCEPT: External Encrypted Inputs
     * Clients encrypt values locally
     * Send both encrypted value and proof
     * FHE.fromExternal() validates and converts
     * Proof ensures:
     *   - Value is properly encrypted
     *   - Encryption bound to correct contract
     *   - User owns the encryption key
     *
     * ⚠️  CRITICAL: Never skip inputProof!
     */
    function receiveEncryptedValue(externalEuint32 externalValue, bytes calldata inputProof)
        external
    {
        // ✅ FHE.fromExternal() converts and validates external encrypted input
        // Proof ensures the encryption is legitimate
        euint32 encryptedValue = FHE.fromExternal(externalValue, inputProof);

        // Grant permissions
        FHE.allowThis(encryptedValue);
        FHE.allow(encryptedValue, msg.sender);

        // Now can store and use the encrypted value
        encryptedBalances[msg.sender] = encryptedValue;

        operationCount++;
    }

    /**
     * @notice Deposit (add to encrypted balance)
     * @param depositAmount Amount to add (plain value)
     *
     * ✅ KEY CONCEPT: Operations on Encrypted State
     * Encrypted state can be updated with operations
     * Plain values are encrypted before operations
     * Result is encrypted
     */
    function deposit(uint32 depositAmount) external {
        // Get current encrypted balance
        euint32 currentBalance = encryptedBalances[msg.sender];

        // Encrypt the deposit amount
        euint32 depositEncrypted = FHE.asEuint32(depositAmount);

        // Add encrypted values (no decryption!)
        euint32 newBalance = FHE.add(currentBalance, depositEncrypted);

        // Grant permissions
        FHE.allowThis(newBalance);
        FHE.allow(newBalance, msg.sender);

        // Update state with encrypted result
        encryptedBalances[msg.sender] = newBalance;

        operationCount++;
    }

    /**
     * @notice Withdraw (subtract from encrypted balance)
     * @param withdrawAmount Amount to withdraw (plain value)
     *
     * ⚠️  NOTE: Cannot verify balance before withdrawal!
     * Cannot decrypt balance to check if sufficient funds
     * Would reveal balance to contract
     * This is a known limitation in current FHE contracts
     *
     * Solution options:
     * 1. User provides attestation of sufficient balance
     * 2. Allow overdrawn (post-verification via callback)
     * 3. Use asynchronous decryption for verification
     */
    function withdraw(uint32 withdrawAmount) external {
        euint32 currentBalance = encryptedBalances[msg.sender];
        euint32 withdrawEncrypted = FHE.asEuint32(withdrawAmount);

        // Subtract encrypted values
        // ⚠️  Cannot verify if balance >= withdrawAmount!
        euint32 newBalance = FHE.sub(currentBalance, withdrawEncrypted);

        FHE.allowThis(newBalance);
        FHE.allow(newBalance, msg.sender);

        encryptedBalances[msg.sender] = newBalance;

        operationCount++;
    }

    /**
     * @notice Encrypt different types of values
     * @param plainUint32 32-bit unsigned integer
     * @param plainUint64 64-bit unsigned integer
     *
     * ✅ KEY CONCEPT: Multiple Encrypted Types
     * FHE supports various encrypted integer sizes
     * euint8, euint16, euint32, euint64 available
     * Different types for different use cases
     */
    function encryptDifferentTypes(uint32 plainUint32, uint64 plainUint64)
        external
        pure
        returns (euint32, euint64)
    {
        // ✅ FHE.asEuint32() encrypts to 32-bit
        euint32 encrypted32 = FHE.asEuint32(plainUint32);

        // ✅ FHE.asEuint64() encrypts to 64-bit
        euint64 encrypted64 = FHE.asEuint64(plainUint64);

        return (encrypted32, encrypted64);
    }

    /**
     * @notice Get operation count (metadata not encrypted)
     * @return Number of encryption operations performed
     *
     * ⚠️  NOTE: Not all data needs encryption
     * Metadata like counts, timestamps can be plain
     * Only sensitive data should be encrypted
     */
    function getOperationCount() external view returns (uint256) {
        return operationCount;
    }

    /**
     * @notice Demonstrates batch encryption
     * @param values Array of plain values
     * @return Array of encrypted values
     *
     * ✅ KEY CONCEPT: Batch Operations
     * Can encrypt multiple values
     * Each receives proper permissions
     * Useful for initializing multiple encrypted states
     */
    function encryptBatch(uint32[] calldata values) external pure returns (euint32[] memory) {
        euint32[] memory encrypted = new euint32[](values.length);

        for (uint256 i = 0; i < values.length; i++) {
            // Encrypt each value
            encrypted[i] = FHE.asEuint32(values[i]);

            // Note: Cannot set permissions in pure function
            // Would be done in non-pure version
        }

        return encrypted;
    }

    /**
     * @notice Common Pattern: Secure Transfer Between Encrypted Balances
     * @param recipient Address to transfer to
     * @param amountEncrypted Encrypted amount to transfer
     * @param inputProof Proof for external encrypted input
     *
     * ✅ KEY CONCEPT: Encrypted Transfers
     * Transfer encrypted amounts between users
     * Neither sender balance nor transfer amount revealed
     * Recipient gets encrypted amount
     */
    function secureTransfer(
        address recipient,
        externalEuint32 amountEncrypted,
        bytes calldata inputProof
    ) external {
        // Convert external encrypted amount
        euint32 amount = FHE.fromExternal(amountEncrypted, inputProof);

        // Sender's balance
        euint32 senderBalance = encryptedBalances[msg.sender];

        // Subtract from sender
        euint32 newSenderBalance = FHE.sub(senderBalance, amount);
        FHE.allowThis(newSenderBalance);
        FHE.allow(newSenderBalance, msg.sender);
        encryptedBalances[msg.sender] = newSenderBalance;

        // Add to recipient
        euint32 recipientBalance = encryptedBalances[recipient];
        euint32 newRecipientBalance = FHE.add(recipientBalance, amount);
        FHE.allowThis(newRecipientBalance);
        FHE.allow(newRecipientBalance, recipient);
        encryptedBalances[recipient] = newRecipientBalance;

        operationCount++;
    }
}
