// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Access Control Example
 * @notice Demonstrates FHE permission management with FHE.allow() and FHE.allowThis()
 * @dev Covered concepts:
 *      - FHE.allowThis() - grant contract permission
 *      - FHE.allow() - grant user permission
 *      - Permission-based decryption
 *      - Multi-party access patterns
 *      - Permission delegation
 */
contract AccessControl is ZamaEthereumConfig {
    // ✅ Encrypted data that needs access control
    mapping(address => euint32) private secretData;

    // Track who has access permissions
    mapping(bytes32 => mapping(address => bool)) private accessGrants;

    // Store encrypted values with metadata
    struct SecretRecord {
        euint32 data;
        address owner;
        uint256 createdAt;
    }

    mapping(bytes32 => SecretRecord) private records;

    /**
     * @notice Demonstrates the TWO-STEP PERMISSION PATTERN
     * @param value The encrypted value to secure
     *
     * ✅ FUNDAMENTAL CONCEPT: FHE Permission System
     *
     * Two permissions are ALWAYS required:
     * 1. FHE.allowThis(value)    - Contract can USE the value
     * 2. FHE.allow(value, user)  - User can DECRYPT the value
     *
     * ❌ COMMON MISTAKE: Forgetting allowThis()
     * If you only call FHE.allow():
     * - User CAN decrypt
     * - But contract CANNOT use in operations
     * - Contract operations will FAIL
     *
     * ❌ ANTI-PATTERN: Calling only allowThis()
     * If you only call FHE.allowThis():
     * - Contract CAN use the value
     * - But user CANNOT decrypt
     * - User sees encrypted handle, not actual value
     *
     * ✅ CORRECT: Always call BOTH in order
     */
    function storeSecretData(uint32 plainValue) external {
        // Step 1: Encrypt the plain value
        euint32 encrypted = FHE.asEuint32(plainValue);

        // Step 2: ✅ GRANT CONTRACT PERMISSION
        // This MUST come first!
        FHE.allowThis(encrypted);

        // Step 3: ✅ GRANT USER PERMISSION
        // This is in addition to allowThis()
        FHE.allow(encrypted, msg.sender);

        // Step 4: Store encrypted value
        secretData[msg.sender] = encrypted;

        // ✅ CORRECT PATTERN DEMONSTRATED:
        // The value can now be:
        // - Used by contract in operations
        // - Decrypted by msg.sender
    }

    /**
     * @notice Retrieve encrypted data (read access)
     * @param user The user whose data to retrieve
     * @return The encrypted data
     *
     * ✅ KEY CONCEPT: Read-Only Access
     * View functions can return encrypted values
     * Caller must be authorized to decrypt
     * FHE enforces decryption permissions
     *
     * Only the authorized user (msg.sender) can decrypt
     * Other addresses get encrypted handle but cannot decrypt
     */
    function getSecretData(address user) external view returns (euint32) {
        return secretData[user];
    }

    /**
     * @notice Share encrypted data with another user
     * @param recipient Address to grant decryption access
     *
     * ✅ KEY CONCEPT: Permission Delegation
     * Owner can share encrypted data with others
     * FHE.allow() can be called multiple times
     * Enables multi-party access scenarios
     *
     * FLOW:
     * 1. Owner stores encrypted data (allowThis + allow owner)
     * 2. Owner calls share() to grant recipient permission
     * 3. Recipient can now decrypt the data
     */
    function shareDataWith(address recipient) external {
        // Get data already stored with permissions
        euint32 data = secretData[msg.sender];

        // ✅ Grant recipient permission to decrypt
        // Note: allowThis() was already called during storage
        // Only need to grant recipient permission
        FHE.allow(data, recipient);

        // Track access grant
        bytes32 recordId = keccak256(abi.encode(msg.sender, "data"));
        accessGrants[recordId][recipient] = true;
    }

    /**
     * @notice Demonstrate permission scope
     * @param sharedValue Encrypted value to share
     * @param recipient Who should access this specific value
     *
     * ✅ KEY CONCEPT: Fine-Grained Access Control
     * Different encrypted values can have different permissions
     * Each euint32 handle has its own permission set
     * Granular control over data access
     *
     * EXAMPLE SCENARIO:
     * - Alice has balance_A (only Alice can decrypt)
     * - Bob has balance_B (only Bob can decrypt)
     * - Carol gets access to both (Carol can decrypt both)
     */
    function grantAccessToSpecificValue(euint32 sharedValue, address recipient) external {
        // Grant recipient access to this specific encrypted value
        FHE.allow(sharedValue, recipient);

        // Other encrypted values are unaffected
        // Each maintains its own permission list
    }

    /**
     * @notice Multi-party approval pattern
     * @param dataId Identifier for the data
     * @param approverData Encrypted approval from approver
     * @param approverProof Proof of correct encryption
     *
     * ✅ KEY CONCEPT: Multi-Signature with Encryption
     * Multiple parties can approve operations
     * Approvals can be encrypted for privacy
     * Contract combines encrypted approvals
     *
     * USE CASE:
     * - Financial transactions requiring multiple approvers
     * - Board decisions with confidential votes
     * - Smart contracts with multi-sig control
     */
    function multiPartyApproval(
        bytes32 dataId,
        externalEuint32 approverData,
        bytes calldata approverProof
    ) external {
        // Convert external encrypted approval
        euint32 approval = FHE.fromExternal(approverData, approverProof);

        // Grant permissions for this approval
        FHE.allowThis(approval);
        FHE.allow(approval, msg.sender);

        // Store encrypted approval
        SecretRecord storage record = records[dataId];
        if (record.owner == address(0)) {
            record.owner = msg.sender;
            record.createdAt = block.timestamp;
        }

        // Track that this approver has given permission
        accessGrants[dataId][msg.sender] = true;
    }

    /**
     * @notice Demonstrates permission inheritance challenge
     * @dev ⚠️  LIMITATION: Encrypted function results
     *
     * CHALLENGE:
     * If a function returns encrypted data, all authorized parties
     * can see the encrypted handle, but only those with FHE.allow()
     * permission can decrypt it.
     *
     * This is a feature, not a bug:
     * - Contract can log/return encrypted values
     * - Only authorized users can decrypt
     * - Hash of encrypted data could be public
     * - Actual data remains private
     */
    function getWithDecryption(address user) external view returns (euint32) {
        // Return encrypted data
        euint32 data = secretData[user];

        // ✅ Only user (and granted addresses) can decrypt
        // Others see encrypted handle but get decryption error if they try
        return data;
    }

    /**
     * @notice Complex access control scenario
     * @param owner Data owner
     * @param recipient Access requester
     * @return Whether recipient should be granted access
     *
     * ✅ KEY CONCEPT: Conditional Permission Grant
     * Access decisions can be based on:
     * - Time-based restrictions
     * - Relationship (following, friends, etc.)
     * - Approval status
     * - Other state conditions
     */
    function shouldGrantAccess(address owner, address recipient)
        external
        view
        returns (bool)
    {
        // Example: Check if access was granted
        bytes32 recordId = keccak256(abi.encode(owner, "data"));
        return accessGrants[recordId][recipient];
    }

    /**
     * @notice Anti-pattern: Forgetting allowThis in state update
     * @dev ❌ DO NOT DO THIS! Demonstrates common mistake
     *
     * WRONG:
     * euint32 result = FHE.add(a, b);
     * FHE.allow(result, user);  // Only allow() - MISSING allowThis()!
     * stateVariable = result;     // Will fail!
     *
     * RIGHT:
     * euint32 result = FHE.add(a, b);
     * FHE.allowThis(result);      // allowThis() first
     * FHE.allow(result, user);    // then allow()
     * stateVariable = result;     // Works!
     */
    function antipatternExample(uint32 a, uint32 b) external {
        // This function intentionally left incomplete
        // to show what NOT to do

        // ❌ WRONG - missing allowThis:
        // euint32 aEnc = FHE.asEuint32(a);
        // euint32 bEnc = FHE.asEuint32(b);
        // euint32 result = FHE.add(aEnc, bEnc);
        // FHE.allow(result, msg.sender);  // Missing allowThis()!
        // secretData[msg.sender] = result; // Will fail

        // ✅ CORRECT - both permissions:
        // euint32 aEnc = FHE.asEuint32(a);
        // euint32 bEnc = FHE.asEuint32(b);
        // euint32 result = FHE.add(aEnc, bEnc);
        // FHE.allowThis(result);
        // FHE.allow(result, msg.sender);
        // secretData[msg.sender] = result; // Works!
    }

    /**
     * @notice Demonstrates FHE.allowTransient()
     * @param temporaryData Encrypted value for temporary use
     *
     * ✅ KEY CONCEPT: Transient Permissions
     * FHE.allowTransient() grants temporary permission
     * Permission automatically revoked after transaction
     * Useful for one-time operations
     *
     * Use cases:
     * - Temporary decryption in callbacks
     * - One-time verification
     * - Decryption during specific operations
     *
     * ⚠️  NOTE: Requires async decryption oracle setup
     */
    function temporaryAccessExample(euint32 temporaryData) external {
        // Grant temporary permission for this transaction only
        // FHE.allowTransient(temporaryData, msg.sender);

        // After transaction ends, permission is revoked
        // User cannot decrypt in future transactions
    }

    /**
     * @notice Audit trail: Who accessed what and when
     * @param user Address to check access history
     * @return accessList List of addresses that have access
     */
    function getAccessList(address user) external view returns (address[] memory) {
        // In production, maintain actual list
        // This is simplified for demonstration
        bytes32 recordId = keccak256(abi.encode(user, "data"));

        // Would iterate through and collect granted addresses
        address[] memory accessList = new address[](0);
        return accessList;
    }
}
