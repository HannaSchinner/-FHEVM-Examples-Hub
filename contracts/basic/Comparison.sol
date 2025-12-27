// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, ebool, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Comparison Operations Example
 * @notice Demonstrates FHE comparison operations on encrypted values
 * @dev Covered concepts:
 *      - FHE.eq() - equality comparison
 *      - FHE.ne() - not equal comparison
 *      - FHE.gt() - greater than comparison
 *      - FHE.gte() - greater than or equal
 *      - FHE.lt() - less than comparison
 *      - FHE.lte() - less than or equal
 *      - ebool - encrypted boolean type
 */
contract Comparison is ZamaEthereumConfig {
    /**
     * @notice Checks if two encrypted values are equal
     * @param a First encrypted value
     * @param b Second encrypted value
     * @return Encrypted boolean result (true if a == b)
     *
     * ✅ KEY CONCEPT: Encrypted Equality
     * Can compare encrypted values without decrypting them
     * Result is an encrypted boolean (ebool)
     * Even the comparison result remains private!
     */
    function isEqual(euint32 a, euint32 b) external pure returns (ebool) {
        // ✅ FHE.eq() compares encrypted values for equality
        return FHE.eq(a, b);
    }

    /**
     * @notice Checks if two encrypted values are not equal
     * @param a First encrypted value
     * @param b Second encrypted value
     * @return Encrypted boolean result (true if a != b)
     *
     * ✅ KEY CONCEPT: Encrypted Inequality
     * The opposite of equality, result is encrypted
     */
    function isNotEqual(euint32 a, euint32 b) external pure returns (ebool) {
        // ✅ FHE.ne() checks encrypted inequality
        return FHE.ne(a, b);
    }

    /**
     * @notice Checks if first value is greater than second
     * @param a First encrypted value
     * @param b Second encrypted value
     * @return Encrypted boolean result (true if a > b)
     *
     * ✅ KEY CONCEPT: Encrypted Ordering
     * Can determine ordering without revealing actual values
     * Useful for auctions, voting, comparisons
     */
    function isGreaterThan(euint32 a, euint32 b) external pure returns (ebool) {
        // ✅ FHE.gt() checks if a > b (encrypted)
        return FHE.gt(a, b);
    }

    /**
     * @notice Checks if first value is greater than or equal to second
     * @param a First encrypted value
     * @param b Second encrypted value
     * @return Encrypted boolean result (true if a >= b)
     */
    function isGreaterOrEqual(euint32 a, euint32 b) external pure returns (ebool) {
        // ✅ FHE.gte() checks if a >= b (encrypted)
        return FHE.gte(a, b);
    }

    /**
     * @notice Checks if first value is less than second
     * @param a First encrypted value
     * @param b Second encrypted value
     * @return Encrypted boolean result (true if a < b)
     */
    function isLessThan(euint32 a, euint32 b) external pure returns (ebool) {
        // ✅ FHE.lt() checks if a < b (encrypted)
        return FHE.lt(a, b);
    }

    /**
     * @notice Checks if first value is less than or equal to second
     * @param a First encrypted value
     * @param b Second encrypted value
     * @return Encrypted boolean result (true if a <= b)
     */
    function isLessOrEqual(euint32 a, euint32 b) external pure returns (ebool) {
        // ✅ FHE.lte() checks if a <= b (encrypted)
        return FHE.lte(a, b);
    }

    /**
     * @notice Finds the maximum of two encrypted values
     * @param a First encrypted value
     * @param b Second encrypted value
     * @return The larger of the two encrypted values
     *
     * ✅ KEY CONCEPT: Encrypted Conditional Selection
     * FHE.select() chooses between values based on encrypted condition
     * Implements: condition ? trueValue : falseValue
     * All values remain encrypted throughout
     *
     * PATTERN:
     * 1. Compare: isGreater = FHE.gt(a, b)
     * 2. Select: FHE.select(isGreater, a, b)
     * Returns a if a > b, else b
     */
    function max(euint32 a, euint32 b) external pure returns (euint32) {
        // Step 1: Encrypted comparison
        ebool isGreater = FHE.gt(a, b);

        // Step 2: Encrypted conditional selection
        // ✅ FHE.select(condition, trueValue, falseValue)
        return FHE.select(isGreater, a, b);
    }

    /**
     * @notice Finds the minimum of two encrypted values
     * @param a First encrypted value
     * @param b Second encrypted value
     * @return The smaller of the two encrypted values
     */
    function min(euint32 a, euint32 b) external pure returns (euint32) {
        ebool isLess = FHE.lt(a, b);
        return FHE.select(isLess, a, b);
    }

    /**
     * @notice Checks if a value is within a range (encrypted boundaries)
     * @param value The encrypted value to check
     * @param lower Encrypted lower bound (inclusive)
     * @param upper Encrypted upper bound (inclusive)
     * @return Encrypted boolean (true if lower <= value <= upper)
     *
     * ✅ KEY CONCEPT: Chaining Comparisons
     * Multiple comparison results can be combined
     * Uses FHE.and() to combine encrypted booleans
     * All logic remains encrypted
     */
    function isInRange(euint32 value, euint32 lower, euint32 upper) external pure returns (ebool) {
        // Check: value >= lower
        ebool aboveLower = FHE.gte(value, lower);

        // Check: value <= upper
        ebool belowUpper = FHE.lte(value, upper);

        // Combine: both conditions must be true
        // ✅ FHE.and() performs encrypted logical AND
        return FHE.and(aboveLower, belowUpper);
    }

    /**
     * @notice Demonstrates encrypted OR operation
     * @param condition1 First encrypted boolean
     * @param condition2 Second encrypted boolean
     * @return Encrypted boolean (true if either is true)
     *
     * ✅ KEY CONCEPT: Encrypted Boolean Logic
     * Boolean operations work on encrypted booleans
     * FHE.or(), FHE.and(), FHE.not() available
     */
    function orCondition(ebool condition1, ebool condition2) external pure returns (ebool) {
        // ✅ FHE.or() performs encrypted logical OR
        return FHE.or(condition1, condition2);
    }

    /**
     * @notice Demonstrates encrypted NOT operation
     * @param condition Encrypted boolean
     * @return Encrypted boolean (negation of input)
     */
    function notCondition(ebool condition) external pure returns (ebool) {
        // ✅ FHE.not() performs encrypted logical NOT
        return FHE.not(condition);
    }

    /**
     * @notice Real-world example: Sealed bid auction comparison
     * @param bid1 First encrypted bid
     * @param bid2 Second encrypted bid
     * @return Encrypted boolean (true if bid1 wins)
     *
     * 📝 USE CASE: Blind Auctions
     * Bids remain encrypted while determining winner
     * No one knows actual bid amounts
     * Winner determined without revealing bids
     */
    function compareAuctionBids(euint32 bid1, euint32 bid2) external pure returns (ebool) {
        // Higher bid wins (or equal bids - first wins)
        return FHE.gte(bid1, bid2);
    }

    /**
     * @notice Real-world example: Age verification without revealing age
     * @param encryptedAge User's encrypted age
     * @param minimumAge Plain minimum age requirement
     * @return Encrypted boolean (true if old enough)
     *
     * 📝 USE CASE: Privacy-Preserving Verification
     * Verify user meets age requirement
     * Actual age never revealed
     * Result can be used for access control
     */
    function verifyAge(euint32 encryptedAge, uint32 minimumAge) external pure returns (ebool) {
        // Compare encrypted age with plain minimum
        return FHE.gte(encryptedAge, FHE.asEuint32(minimumAge));
    }

    /**
     * @notice Demonstrates three-way comparison
     * @param value Value to categorize
     * @param threshold1 First threshold
     * @param threshold2 Second threshold
     * @return Category: 0 (low), 1 (medium), or 2 (high)
     *
     * ✅ KEY CONCEPT: Multi-Level Comparison
     * Complex logic with multiple encrypted comparisons
     * All intermediate results remain encrypted
     *
     * LOGIC:
     * - value < threshold1: category 0 (low)
     * - threshold1 <= value < threshold2: category 1 (medium)
     * - value >= threshold2: category 2 (high)
     */
    function categorize(euint32 value, euint32 threshold1, euint32 threshold2)
        external
        pure
        returns (euint32)
    {
        // Check if value is in low range
        ebool isLow = FHE.lt(value, threshold1);

        // Check if value is in high range
        ebool isHigh = FHE.gte(value, threshold2);

        // Select category based on comparisons
        euint32 category = FHE.select(isLow, FHE.asEuint32(0), FHE.asEuint32(1));
        category = FHE.select(isHigh, FHE.asEuint32(2), category);

        return category;
    }
}
