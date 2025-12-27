// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Example Contract
 * @notice A simple example contract demonstrating FHEVM basics
 * @dev Use this as a starting point for your FHEVM contracts
 */
contract Example is ZamaEthereumConfig {
    /// @notice An encrypted value stored on-chain
    euint32 private value;

    /**
     * @notice Initialize with an encrypted value
     * @param initialValue The initial encrypted value
     */
    constructor(uint32 initialValue) {
        value = FHE.asEuint32(initialValue);
        FHE.allowThis(value);
        FHE.allow(value, msg.sender);
    }

    /**
     * @notice Get the encrypted value
     * @return The encrypted value (euint32)
     */
    function getValue() external view returns (euint32) {
        return value;
    }

    /**
     * @notice Add an encrypted value
     * @param addedValue The encrypted value to add
     * @param inputProof Zero-knowledge proof of correct encryption
     */
    function add(externalEuint32 addedValue, bytes calldata inputProof) external {
        euint32 encryptedValue = FHE.fromExternal(addedValue, inputProof);
        value = FHE.add(value, encryptedValue);

        FHE.allowThis(value);
        FHE.allow(value, msg.sender);
    }
}
