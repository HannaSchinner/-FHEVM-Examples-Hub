// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Arithmetic Operations Example
 * @notice Demonstrates FHE arithmetic operations on encrypted values
 * @dev Covered concepts:
 *      - FHE.add() - homomorphic addition
 *      - FHE.sub() - homomorphic subtraction
 *      - FHE.mul() - homomorphic multiplication
 *      - Performing math without decryption
 */
contract Arithmetic is ZamaEthereumConfig {
    /**
     * @notice Performs encrypted addition
     * @param a First encrypted value
     * @param b Second encrypted value
     * @return The encrypted sum (a + b)
     *
     * ✅ KEY CONCEPT: Homomorphic Addition
     * Two encrypted numbers can be added without decryption
     * Result is also encrypted and can be used in further operations
     */
    function add(euint32 a, euint32 b) external pure returns (euint32) {
        // ✅ FHE.add() performs addition on encrypted values
        return FHE.add(a, b);
    }

    /**
     * @notice Performs encrypted subtraction
     * @param a First encrypted value (minuend)
     * @param b Second encrypted value (subtrahend)
     * @return The encrypted difference (a - b)
     *
     * ✅ KEY CONCEPT: Homomorphic Subtraction
     * Encrypted subtraction maintains privacy throughout
     * Result can be further operated on without decryption
     *
     * ⚠️  NOTE: For unsigned integers (euint32), underflow wraps around
     * 0 - 1 = 2^32 - 1 (max uint32 value)
     */
    function subtract(euint32 a, euint32 b) external pure returns (euint32) {
        // ✅ FHE.sub() performs subtraction on encrypted values
        return FHE.sub(a, b);
    }

    /**
     * @notice Performs encrypted multiplication
     * @param a First encrypted value
     * @param b Second encrypted value
     * @return The encrypted product (a * b)
     *
     * ✅ KEY CONCEPT: Homomorphic Multiplication
     * Encrypted values can be multiplied without decryption
     * More computationally expensive than add/sub
     * Results can be used in further operations
     */
    function multiply(euint32 a, euint32 b) external pure returns (euint32) {
        // ✅ FHE.mul() performs multiplication on encrypted values
        return FHE.mul(a, b);
    }

    /**
     * @notice Performs complex encrypted arithmetic
     * @param x First encrypted value
     * @param y Second encrypted value
     * @param z Third encrypted value
     * @return Result of encrypted calculation: (x + y) * z
     *
     * ✅ KEY CONCEPT: Chaining Operations
     * Multiple FHE operations can be chained together
     * Each intermediate result remains encrypted
     * Privacy maintained throughout the computation chain
     *
     * CALCULATION FLOW:
     * 1. sum = FHE.add(x, y)       // (x + y) encrypted
     * 2. result = FHE.mul(sum, z)  // ((x + y) * z) encrypted
     * 3. Return result
     */
    function complexOperation(euint32 x, euint32 y, euint32 z) external pure returns (euint32) {
        euint32 sum = FHE.add(x, y);
        return FHE.mul(sum, z);
    }

    /**
     * @notice Demonstrates encrypted integer division simulation
     * @param dividend Encrypted dividend
     * @param divisor Plain divisor (not encrypted)
     * @return Approximate result
     *
     * ⚠️  IMPORTANT: FHE.div() is not directly available in current FHEVM
     * Division of encrypted values requires special techniques:
     * 1. Pre-compute approximations
     * 2. Use repeated subtraction
     * 3. Use lookup tables
     * 4. Approximate with shifts and multiplications
     *
     * This is a limitation of current FHE implementations
     * being actively researched and improved
     */
    function approximateDivision(euint32 dividend, uint32 divisor) external pure returns (euint32) {
        // For now, multiplication by inverse approximation
        // In production, implement division using specific FHE techniques
        uint32 inverse = 1; // Placeholder - would compute actual inverse

        // Cannot directly divide encrypted by encrypted
        // ❌ return FHE.div(dividend, divisor);  // NOT AVAILABLE

        // Workaround: multiply by inverse approximation
        return FHE.mul(dividend, FHE.asEuint32(inverse));
    }
}
