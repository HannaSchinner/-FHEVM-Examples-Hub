// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Encrypted Counter Contract
 * @notice Demonstrates basic FHEVM concepts with a simple encrypted counter
 * @dev This example shows:
 *      - Encrypted state variables (euint32)
 *      - Basic FHE operations (add, sub)
 *      - Access control with FHE.allow() and FHE.allowThis()
 *      - Permission-based decryption
 */
contract FHECounter is ZamaEthereumConfig {
    /**
     * @dev Private encrypted counter storing the value as euint32
     * The value is encrypted and can only be decrypted by authorized parties
     */
    euint32 private _count;

    /**
     * @notice Emitted when counter is incremented
     * @param newValue The new encrypted counter value (handle representation)
     * @param incrementBy The encrypted increment amount (handle representation)
     */
    event CounterIncremented(euint32 indexed newValue, euint32 indexed incrementBy);

    /**
     * @notice Emitted when counter is decremented
     * @param newValue The new encrypted counter value (handle representation)
     * @param decrementBy The encrypted decrement amount (handle representation)
     */
    event CounterDecremented(euint32 indexed newValue, euint32 indexed decrementBy);

    /**
     * @notice Initialize the counter with a starting encrypted value
     * @param initialValue The initial plain value (will be encrypted)
     * @dev The constructor encrypts the initial value and grants permissions
     */
    constructor(uint32 initialValue) {
        // Encrypt the initial value
        _count = FHE.asEuint32(initialValue);

        // Grant contract permission to use this value
        FHE.allowThis(_count);

        // Grant sender permission to decrypt
        FHE.allow(_count, msg.sender);
    }

    /**
     * @notice Get the encrypted counter value
     * @return The encrypted counter (euint32)
     * @dev The caller must be authorized to decrypt this value
     * Access control is managed by FHE permissions set during operations
     */
    function getEncryptedCount() external view returns (euint32) {
        return _count;
    }

    /**
     * @notice Increment the counter by a specified encrypted value
     * @param encryptedValue The encrypted value to add (provided as external handle)
     * @param inputProof The zero-knowledge proof of correct encryption
     *
     * @dev FHEVM Concepts:
     *      1. externalEuint32: Handle to encrypted value from external source
     *      2. FHE.fromExternal(): Convert external handle to contract value
     *      3. FHE.add(): Perform addition on encrypted values (homomorphic operation)
     *      4. FHE.allowThis(): Grant contract permission (required before assignment)
     *      5. FHE.allow(): Grant user permission to decrypt the result
     *
     * ✅ CORRECT PATTERN:
     *    - Call FHE.fromExternal() to decrypt input proof
     *    - Perform FHE operations
     *    - Call both FHE.allowThis() AND FHE.allow()
     *    - Update state with encrypted result
     *
     * ❌ COMMON MISTAKES:
     *    - Forgetting FHE.allowThis() - causes decryption permission errors
     *    - Only calling FHE.allowThis() without FHE.allow() - user can't decrypt
     *    - Using unencrypted values in FHE operations - type mismatch
     */
    function increment(externalEuint32 encryptedValue, bytes calldata inputProof) external {
        // ✅ DO: Convert external encrypted input with proof
        euint32 value = FHE.fromExternal(encryptedValue, inputProof);

        // ✅ DO: Perform homomorphic addition (no decryption needed!)
        _count = FHE.add(_count, value);

        // ✅ DO: Grant both permissions before storing
        FHE.allowThis(_count);
        FHE.allow(_count, msg.sender);

        emit CounterIncremented(_count, value);
    }

    /**
     * @notice Decrement the counter by a specified encrypted value
     * @param encryptedValue The encrypted value to subtract (provided as external handle)
     * @param inputProof The zero-knowledge proof of correct encryption
     *
     * @dev Same pattern as increment() but using FHE.sub() for subtraction
     * This demonstrates that FHE operations work with any arithmetic operation
     *
     * ✅ PATTERN:
     *    euint32 value = FHE.fromExternal(encryptedValue, inputProof);
     *    _count = FHE.sub(_count, value);
     *    FHE.allowThis(_count);
     *    FHE.allow(_count, msg.sender);
     */
    function decrement(externalEuint32 encryptedValue, bytes calldata inputProof) external {
        // ✅ DO: Convert external encrypted input
        euint32 value = FHE.fromExternal(encryptedValue, inputProof);

        // ✅ DO: Perform homomorphic subtraction
        _count = FHE.sub(_count, value);

        // ✅ DO: Grant permissions
        FHE.allowThis(_count);
        FHE.allow(_count, msg.sender);

        emit CounterDecremented(_count, value);
    }

    /**
     * @notice Multiply the counter by a specified encrypted value
     * @param encryptedValue The encrypted multiplier
     * @param inputProof The zero-knowledge proof of correct encryption
     *
     * @dev Demonstrates FHE.mul() for multiplication operations
     * Shows that FHE supports various arithmetic operations
     */
    function multiply(externalEuint32 encryptedValue, bytes calldata inputProof) external {
        euint32 value = FHE.fromExternal(encryptedValue, inputProof);

        // Multiply encrypted values
        _count = FHE.mul(_count, value);

        FHE.allowThis(_count);
        FHE.allow(_count, msg.sender);
    }

    /**
     * @notice Reset the counter to a new encrypted value
     * @param encryptedValue The new encrypted value
     * @param inputProof The zero-knowledge proof of correct encryption
     *
     * @dev Demonstrates complete replacement of encrypted state
     */
    function reset(externalEuint32 encryptedValue, bytes calldata inputProof) external {
        euint32 newValue = FHE.fromExternal(encryptedValue, inputProof);

        _count = newValue;

        FHE.allowThis(_count);
        FHE.allow(_count, msg.sender);
    }

    /**
     * @notice Transfer decryption rights to another address
     * @param recipient The address that should be able to decrypt
     *
     * @dev Demonstrates access control transfer pattern
     * Useful for: delegation, ownership transfer, multi-party scenarios
     *
     * ⚠️  WARNING: Be careful with permission transfers!
     *     Only trusted addresses should be granted decryption rights
     */
    function grantAccessTo(address recipient) external {
        // Grant recipient permission to decrypt current counter
        FHE.allow(_count, recipient);
    }

    /**
     * @notice Demonstrates the importance of FHE.allowThis()
     * @dev ❌ ANTI-PATTERN EXAMPLE - DO NOT USE THIS!
     *
     * Forgetting FHE.allowThis() is a common mistake that leads to:
     * - Decryption permission errors
     * - Operations that silently fail
     * - Security issues where the contract can't use the values
     *
     * Always remember: ✅ FHE.allowThis() + ✅ FHE.allow()
     */
    function antiPatternExample(externalEuint32 encryptedValue, bytes calldata inputProof) external pure {
        euint32 value = FHE.fromExternal(encryptedValue, inputProof);

        // ❌ WRONG: Missing FHE.allowThis()
        // euint32 result = FHE.add(value, value);
        // FHE.allow(result, msg.sender);  // Missing allowThis!

        // ✅ CORRECT:
        // euint32 result = FHE.add(value, value);
        // FHE.allowThis(result);
        // FHE.allow(result, msg.sender);

        // This function is marked 'pure' to prevent accidental execution
    }
}
