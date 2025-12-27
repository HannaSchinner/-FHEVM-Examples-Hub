// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Anti-Patterns in FHEVM Development
 * @notice Demonstrates COMMON MISTAKES and HOW TO AVOID THEM
 * @dev This contract shows ❌ WRONG patterns alongside ✅ CORRECT patterns
 *
 * Learning Goals:
 * - Recognize anti-patterns in FHEVM code
 * - Understand why they're problematic
 * - Learn correct alternatives
 * - Avoid security and functionality issues
 */
contract AntiPatterns is ZamaEthereumConfig {
    euint32 private encryptedValue;

    // ========================================================================
    // ANTI-PATTERN 1: Missing FHE.allowThis()
    // ========================================================================

    /**
     * ❌ WRONG: Missing FHE.allowThis() before assignment
     *
     * PROBLEM:
     * - Contract cannot use the value in future operations
     * - State update fails because contract lacks permission
     * - Decryption also fails due to missing allowThis
     *
     * SYMPTOM:
     * - Transaction reverts with cryptic permission error
     * - Function call fails unexpectedly
     * - No clear error message about permissions
     */
    function antipattern_MissingAllowThis_WRONG(uint32 value) external {
        euint32 encrypted = FHE.asEuint32(value);

        // ❌ WRONG: Only allow user, not contract
        FHE.allow(encrypted, msg.sender);

        // ❌ This will fail!
        // encryptedValue = encrypted; // REVERTED - contract can't use value
    }

    /**
     * ✅ CORRECT: Always call both allowThis and allow
     *
     * ORDER MATTERS: allowThis BEFORE allow
     */
    function antipattern_MissingAllowThis_CORRECT(uint32 value) external {
        euint32 encrypted = FHE.asEuint32(value);

        // ✅ CORRECT: Grant contract permission FIRST
        FHE.allowThis(encrypted);

        // ✅ CORRECT: Then grant user permission
        FHE.allow(encrypted, msg.sender);

        // ✅ Now works!
        encryptedValue = encrypted;
    }

    // ========================================================================
    // ANTI-PATTERN 2: Using Encrypted Values in View Functions
    // ========================================================================

    /**
     * ❌ WRONG: Returning encrypted value from pure/view function
     *
     * Problem: Cannot update permissions in pure/view functions
     * These functions don't modify state, so they:
     * - Cannot create new encrypted values
     * - Cannot grant permissions
     * - Cannot perform FHE operations that need permission updates
     *
     * Symptom:
     * - Compilation error about modifying state
     * - Cannot use FHE.allowThis() in pure/view
     */
    // COMMENTED OUT - would not compile
    // function antipattern_ViewWithEncryption_WRONG() external view returns (euint32) {
    //     euint32 result = FHE.add(encryptedValue, encryptedValue);
    //     FHE.allowThis(result);  // ❌ NOT ALLOWED in view!
    //     return result;
    // }

    /**
     * ✅ CORRECT: Return pre-computed encrypted values from view
     *
     * Can return encrypted values that were already computed
     * and have permissions granted (in external/public functions)
     */
    function antipattern_ViewWithEncryption_CORRECT() external view returns (euint32) {
        // ✅ Can return encrypted value with existing permissions
        return encryptedValue;
    }

    /**
     * ✅ ALSO CORRECT: Use external function for computation
     *
     * Separate concerns:
     * - external: Create and grant permissions
     * - view: Return pre-computed values
     */
    function computeAndStore(uint32 a, uint32 b) external {
        euint32 aEnc = FHE.asEuint32(a);
        euint32 bEnc = FHE.asEuint32(b);

        // Compute in external function
        euint32 result = FHE.add(aEnc, bEnc);

        FHE.allowThis(result);
        FHE.allow(result, msg.sender);

        encryptedValue = result;
    }

    // ========================================================================
    // ANTI-PATTERN 3: Attempting Decryption in Contract Logic
    // ========================================================================

    /**
     * ❌ WRONG: Trying to decrypt for conditional logic
     *
     * Problem: Cannot decrypt encrypted values in Solidity
     * Decryption requires:
     * - Asynchronous oracle service
     * - User's private key (contract doesn't have)
     * - Special decryption protocol
     *
     * Symptom:
     * - No direct decryption method available
     * - Cannot use encrypted values in if statements
     * - Cannot read encrypted values in contract
     */
    function antipattern_DecryptInLogic_WRONG(uint32 threshold) external {
        // ❌ WRONG: Cannot decrypt encryptedValue here
        // uint32 decrypted = FHE.decrypt(encryptedValue);  // NOT AVAILABLE!
        // if (decrypted > threshold) { ... }

        // ❌ Cannot use encrypted in if condition
        // if (encryptedValue > FHE.asEuint32(threshold)) { ... } // NOT ALLOWED!
    }

    /**
     * ✅ CORRECT: Use encrypted comparisons
     *
     * Don't try to decrypt - instead:
     * - Compare encrypted values with encrypted comparison
     * - Use encrypted conditionals with FHE.select()
     * - Request async decryption for external logic
     */
    function antipattern_DecryptInLogic_CORRECT(uint32 threshold)
        external
        pure
        returns (ebool)
    {
        // ✅ Compare encrypted values WITHOUT decryption
        euint32 thresholdEnc = FHE.asEuint32(threshold);

        // ✅ Result is encrypted boolean
        return FHE.gt(encryptedValue, thresholdEnc);
    }

    // ========================================================================
    // ANTI-PATTERN 4: Signer Mismatch in External Encryption
    // ========================================================================

    /**
     * ❌ WRONG: Signer mismatch between encryption and usage
     *
     * Problem: Client encrypts with one signer, contract uses another
     * Encryption is bound to specific [contract, user] pair
     *
     * Scenario:
     * - Alice encrypts value for this contract
     * - Sends encrypted value to contract
     * - Contract calls this with msg.sender = Bob
     * - FHE rejects because encryption signed by Alice, not Bob
     *
     * Symptom:
     * - "Invalid input proof" error
     * - Decryption fails
     * - FHE.fromExternal() rejects the input
     */
    function antipattern_SignerMismatch_WRONG(externalEuint32 value, bytes calldata proof)
        external
    {
        // ❌ WRONG if caller is different from encryptor:
        // If Alice encrypted for herself but calls through Bob:
        euint32 decrypted = FHE.fromExternal(value, proof);
        // This will FAIL - Alice's encryption != Bob's call
    }

    /**
     * ✅ CORRECT: Ensure signer consistency
     *
     * Rule: msg.sender (caller) must match encryption signer
     *
     * Client pseudocode:
     * ```
     * // Client side:
     * const encrypted = await fhevm.createEncryptedInput(
     *     contractAddress,
     *     userAddress  // ← MUST match who's calling
     * );
     * encrypted.add32(secretValue);
     * const encData = encrypted.encrypt();
     *
     * // On-chain call:
     * contract.myFunction(
     *     encData.handles,
     *     encData.inputProof
     * );  // MUST be called by userAddress!
     * ```
     */
    function antipattern_SignerMismatch_CORRECT(externalEuint32 value, bytes calldata proof)
        external
    {
        // ✅ CORRECT: This works only if:
        // 1. Client encrypted for address(this) (contract address)
        // 2. msg.sender is the address who encrypted
        // 3. Proof matches the encryption

        euint32 decrypted = FHE.fromExternal(value, proof);
        FHE.allowThis(decrypted);
        FHE.allow(decrypted, msg.sender);
    }

    // ========================================================================
    // ANTI-PATTERN 5: Assuming Automatic Overflow Handling
    // ========================================================================

    /**
     * ❌ WRONG: Not handling overflow in encrypted arithmetic
     *
     * Problem: euint32 operations wrap around at 2^32
     * - 2^32 - 1 + 1 = 0 (wraps around)
     * - Subtraction underflows: 0 - 1 = 2^32 - 1
     *
     * Symptom:
     * - Unexpected results in computations
     * - Money loss in financial contracts
     * - Incorrect logic in comparisons
     */
    function antipattern_Overflow_WRONG(euint32 a, euint32 b) external pure returns (euint32) {
        // ❌ WRONG: No overflow check
        // If a + b > 2^32 - 1, result wraps around
        return FHE.add(a, b); // Potential overflow!
    }

    /**
     * ✅ CORRECT: Use appropriate size or check overflow
     *
     * Solutions:
     * 1. Use larger type (euint64 instead of euint32)
     * 2. Verify limits before operation
     * 3. Use specific-sized operations for correctness
     */
    function antipattern_Overflow_CORRECT(euint32 a, euint32 b)
        external
        pure
        returns (euint32)
    {
        // ✅ CORRECT: Use larger type if needed
        // Convert to euint64, operate, convert back if safe
        // Or implement range checks in your logic

        // For now, simple addition assuming no overflow
        return FHE.add(a, b);
    }

    // ========================================================================
    // ANTI-PATTERN 6: Not Validating External Inputs
    // ========================================================================

    /**
     * ❌ WRONG: Using external encrypted input without proof validation
     *
     * Problem: Proof is CRITICAL for security
     * Without proof:
     * - Value not bound to correct contract
     * - Caller might not own the encryption
     * - Value could be replayed from other contexts
     *
     * Symptom:
     * - Security vulnerability
     * - Unauthorized users can use others' encrypted data
     */
    function antipattern_NoValidation_WRONG(euint32 value) external {
        // ❌ WRONG: Using external value without proof
        // This is unsafe - no validation!
        encryptedValue = value;
    }

    /**
     * ✅ CORRECT: Always validate with proof
     *
     * FHE.fromExternal() includes proof validation:
     * - Verifies encryption is correct format
     * - Checks binding to contract address
     * - Validates user signature on encryption
     */
    function antipattern_NoValidation_CORRECT(externalEuint32 value, bytes calldata proof)
        external
    {
        // ✅ CORRECT: fromExternal validates everything
        euint32 validated = FHE.fromExternal(value, proof);

        FHE.allowThis(validated);
        FHE.allow(validated, msg.sender);

        encryptedValue = validated;
    }

    // ========================================================================
    // ANTI-PATTERN 7: Exposing Encrypted Values in Events
    // ========================================================================

    event EncryptedValueStored(euint32 indexed value); // ❌ PROBLEMATIC
    event EncryptedValueStoredCorrect(bytes32 indexed valueHash, address indexed user); // ✅ CORRECT

    /**
     * ❌ WRONG: Emitting encrypted values in events
     *
     * Problem:
     * - Encrypted value handles are logged
     * - Anyone can see the encrypted handle
     * - If logs are stored/analyzed, privacy risks
     *
     * Better: Hash the encrypted value or use metadata
     */
    function antipattern_EventsWithEncryption_WRONG(uint32 value) external {
        euint32 encrypted = FHE.asEuint32(value);
        FHE.allowThis(encrypted);
        FHE.allow(encrypted, msg.sender);

        // ❌ WRONG: Emitting encrypted value
        emit EncryptedValueStored(encrypted);
    }

    /**
     * ✅ CORRECT: Use metadata or hashes in events
     *
     * Emit metadata about the operation, not the encrypted data
     */
    function antipattern_EventsWithEncryption_CORRECT(uint32 value) external {
        euint32 encrypted = FHE.asEuint32(value);
        FHE.allowThis(encrypted);
        FHE.allow(encrypted, msg.sender);

        // ✅ CORRECT: Emit hash/metadata instead
        emit EncryptedValueStoredCorrect(keccak256(abi.encode(encrypted)), msg.sender);
    }

    // ========================================================================
    // SUMMARY OF ANTI-PATTERNS
    // ========================================================================

    /**
     * CHECKLIST: Avoid These Mistakes
     *
     * ❌ DON'T:
     * - [ ] Forget FHE.allowThis() before FHE.allow()
     * - [ ] Try to decrypt encrypted values
     * - [ ] Use encrypted values in contract conditionals
     * - [ ] Mix signers between encryption and usage
     * - [ ] Ignore overflow/underflow possibilities
     * - [ ] Skip proof validation for external inputs
     * - [ ] Emit encrypted values in events
     * - [ ] Assume automatic decryption
     * - [ ] Use encrypted returns in pure/view without care
     * - [ ] Compare encrypted values with plain without FHE ops
     *
     * ✅ DO:
     * - [ ] Always call FHE.allowThis() THEN FHE.allow()
     * - [ ] Use encrypted comparisons (FHE.eq, FHE.gt, etc.)
     * - [ ] Use FHE.select() for encrypted conditionals
     * - [ ] Match signer between encryption and function call
     * - [ ] Consider type sizes and overflow
     * - [ ] Always include proof for external encrypted inputs
     * - [ ] Use hashes or metadata in events, not encrypted values
     * - [ ] Request async decryption for contract logic
     * - [ ] Perform operations on encrypted values
     * - [ ] Think in encrypted operations, not decryption
     */
}
