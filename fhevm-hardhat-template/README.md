# FHEVM Hardhat Template

A production-ready Hardhat template for building FHEVM (Fully Homomorphic Encryption Virtual Machine) smart contracts.

## Overview

This template provides a complete development environment for creating privacy-preserving smart contracts using Zama's FHEVM technology.

## Features

- ✅ Pre-configured Hardhat setup with FHEVM support
- ✅ TypeScript support for scripts and tests
- ✅ Comprehensive testing utilities
- ✅ Deployment scripts for multiple networks
- ✅ Environment configuration management
- ✅ Code quality tools and linting
- ✅ Contract verification setup

## Quick Start

### Installation

```bash
npm install
```

### Compile Contracts

```bash
npm run compile
```

### Run Tests

```bash
npm run test
```

### Deploy

```bash
# Local development
npm run node  # Terminal 1
npm run deploy:local  # Terminal 2

# Testnet deployment
npm run deploy:sepolia
npm run deploy:zama
```

## Project Structure

```
fhevm-hardhat-template/
├── contracts/          # Solidity smart contracts
├── test/              # Test files (TypeScript)
├── scripts/           # Deployment and utility scripts
├── hardhat.config.ts  # Hardhat configuration
├── package.json       # Dependencies and scripts
├── tsconfig.json      # TypeScript configuration
├── .env.example       # Environment variables template
└── README.md          # This file
```

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

```env
PRIVATE_KEY=your_private_key_here
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
ZAMA_TESTNET_RPC_URL=https://devnet.zama.ai
ETHERSCAN_API_KEY=your_etherscan_api_key
```

### Network Configuration

Supported networks:
- **hardhat** - Local development
- **localhost** - Local Hardhat node
- **sepolia** - Ethereum testnet
- **zamaTestnet** - Zama FHEVM testnet (recommended for FHEVM)

## FHEVM Basics

### Encrypted Types

```solidity
import { FHE, euint32, euint64, ebool } from "@fhevm/solidity/lib/FHE.sol";

contract Example {
    euint32 private encryptedValue;
}
```

### Basic Operations

```solidity
// Addition
euint32 sum = FHE.add(a, b);

// Subtraction
euint32 diff = FHE.sub(a, b);

// Multiplication
euint32 product = FHE.mul(a, b);

// Comparison
ebool isEqual = FHE.eq(a, b);
```

### Access Control

```solidity
// Grant contract permission
FHE.allowThis(encryptedValue);

// Grant user permission
FHE.allow(encryptedValue, userAddress);
```

## Available Scripts

```json
{
  "compile": "Compile smart contracts",
  "test": "Run test suite",
  "node": "Start local Hardhat node",
  "deploy:local": "Deploy to local network",
  "deploy:sepolia": "Deploy to Sepolia testnet",
  "deploy:zama": "Deploy to Zama testnet",
  "clean": "Clean build artifacts",
  "verify": "Verify contract on block explorer"
}
```

## Development Workflow

### 1. Create Contract

Create your contract in `contracts/`:

```solidity
// contracts/MyContract.sol
// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

contract MyContract is ZamaEthereumConfig {
    euint32 private encryptedValue;

    function setValue(externalEuint32 value, bytes calldata proof) external {
        euint32 encrypted = FHE.fromExternal(value, proof);
        FHE.allowThis(encrypted);
        FHE.allow(encrypted, msg.sender);
        encryptedValue = encrypted;
    }

    function getValue() external view returns (euint32) {
        return encryptedValue;
    }
}
```

### 2. Create Tests

Create tests in `test/`:

```typescript
// test/MyContract.test.ts
import { expect } from "chai";
import { ethers } from "hardhat";

describe("MyContract", function () {
  it("Should deploy correctly", async function () {
    const MyContract = await ethers.getContractFactory("MyContract");
    const contract = await MyContract.deploy();
    await contract.waitForDeployment();

    expect(await contract.getAddress()).to.be.properAddress;
  });
});
```

### 3. Compile and Test

```bash
npm run compile
npm run test
```

### 4. Deploy

```bash
npm run deploy:sepolia
```

## Best Practices

### ✅ DO's

- ✅ Always call `FHE.allowThis()` before `FHE.allow()`
- ✅ Use encrypted types for sensitive data
- ✅ Test on Zama testnet before mainnet
- ✅ Include comprehensive tests
- ✅ Document FHE operations clearly

### ❌ DON'Ts

- ❌ Don't use view functions with encrypted returns
- ❌ Don't forget `FHE.allowThis()` permissions
- ❌ Don't expose unencrypted sensitive data
- ❌ Don't skip input proof validation
- ❌ Don't commit `.env` to version control

## Testing

### Unit Tests

```bash
npm run test
```

### Coverage

```bash
npm run coverage
```

### Gas Reports

```bash
REPORT_GAS=true npm run test
```

## Deployment

### Testnet Deployment

1. Get test tokens from faucets
2. Configure `.env` with private key
3. Deploy:

```bash
npm run deploy:sepolia
```

### Contract Verification

```bash
npx hardhat verify --network sepolia DEPLOYED_ADDRESS "constructor args"
```

## Resources

- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Zama GitHub](https://github.com/zama-ai)
- [Community Forum](https://www.zama.ai/community)
- [Discord](https://discord.com/invite/zama)

## Troubleshooting

### Common Issues

**Issue:** `Module not found: @fhevm/solidity`
**Solution:** Run `npm install`

**Issue:** `Network connection failed`
**Solution:** Check RPC URL in `.env`

**Issue:** `Insufficient funds`
**Solution:** Request test tokens from faucet

## Contributing

To contribute improvements:

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file

---

**Built with ❤️ using FHEVM by Zama**
