# Deployment Guide

This guide covers deploying FHEVM example contracts to different networks.

## Prerequisites

### Required
- Node.js v16 or higher
- npm or yarn
- Contracts compiled: `npm run compile`

### For Testnet Deployment
- Private key for testnet wallet (from `.env`)
- Test ETH or ZAMA tokens for gas fees
- RPC URL for the target network

## Environment Setup

### 1. Create .env File

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# Required for deployment
PRIVATE_KEY=your_private_key_here

# Network RPCs
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
ZAMA_TESTNET_RPC_URL=https://devnet.zama.ai

# Optional for verification
ETHERSCAN_API_KEY=your_etherscan_key
```

### 2. Security Considerations

⚠️ **IMPORTANT SECURITY NOTES:**

- **Never commit `.env` to version control**
- Use testnet-only wallets with small amounts of test tokens
- Never use mainnet private keys
- Keep private keys secure and never share
- Use hardware wallets for production deployments

## Local Development

### Start Local Network

```bash
# Terminal 1: Start Hardhat node
npm run node
```

This starts a local Ethereum network at `http://127.0.0.1:8545`.

### Deploy to Local Network

```bash
# Terminal 2: Deploy contracts
npm run deploy:local
```

The deployment script will:
1. Get the deployer account
2. Deploy all contracts
3. Log contract addresses
4. Show deployment status

## Testnet Deployment

### Sepolia Testnet

Sepolia is Ethereum's primary testnet and is widely supported.

#### Get Test ETH

1. Visit [Sepolia Faucet](https://sepolia-faucet.pk910.de/)
2. Enter your wallet address
3. Receive test ETH (may take a few minutes)

#### Deploy to Sepolia

```bash
npm run deploy:sepolia
```

Or using the deployment script directly:

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

**Expected Output:**
```
Deploying contracts with account: 0x...
Account balance: 1.5 ETH
PrivateMusicRoyalty deployed to: 0x...
FHECounter deployed to: 0x...
Deployment completed successfully
```

### Zama Testnet (Recommended for FHEVM)

Zama Testnet has native FHEVM support for full encrypted contract testing.

#### Get ZAMA Tokens

1. Join [Zama Discord](https://discord.com/invite/zama)
2. Request testnet tokens in the appropriate channel
3. Verify tokens received in your wallet

#### Deploy to Zama Testnet

```bash
npm run deploy:zama
```

Or directly:

```bash
npx hardhat run scripts/deploy.js --network zamaTestnet
```

**Network Configuration:**
- **RPC URL**: https://devnet.zama.ai
- **Chain ID**: 8009
- **Block Explorer**: Available through Zama

## Deployment Scripts

### Default Deployment Script

The included `scripts/deploy.js` handles:

```javascript
// Example structure
const PrivateMusicRoyalty = await ethers.getContractFactory("PrivateMusicRoyalty");
const contract = await PrivateMusicRoyalty.deploy();
await contract.waitForDeployment();
console.log("PrivateMusicRoyalty deployed to:", await contract.getAddress());
```

### Custom Deployment

Create your own deployment script:

```typescript
// scripts/my-deployment.ts
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with:", deployer.address);

  // Deploy PrivateMusicRoyalty
  const PrivateMusicRoyalty = await ethers.getContractFactory("PrivateMusicRoyalty");
  const musicRoyalty = await PrivateMusicRoyalty.deploy();
  await musicRoyalty.waitForDeployment();

  console.log("PrivateMusicRoyalty deployed to:", await musicRoyalty.getAddress());

  // Deploy FHECounter
  const FHECounter = await ethers.getContractFactory("FHECounter");
  const counter = await FHECounter.deploy(0);
  await counter.waitForDeployment();

  console.log("FHECounter deployed to:", await counter.getAddress());

  return {
    musicRoyalty: await musicRoyalty.getAddress(),
    counter: await counter.getAddress()
  };
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Run custom script:

```bash
npx hardhat run scripts/my-deployment.ts --network sepolia
```

## Contract Verification

After deployment, verify contracts on block explorers.

### Etherscan Verification

```bash
npx hardhat verify --network sepolia DEPLOYED_CONTRACT_ADDRESS "constructor args if any"
```

Example with constructor args:

```bash
npx hardhat verify --network sepolia 0x1234567890123456789012345678901234567890 "0x_owner_address"
```

### Verify All Contracts

```bash
# Create a verification script
npx hardhat verify --network sepolia \
  --contract contracts/PrivateMusicRoyalty.sol:PrivateMusicRoyalty \
  0x1234567890123456789012345678901234567890
```

## Post-Deployment

### Verify Deployment

1. **Check Contract Deployment:**
   ```bash
   # Check if contract code is at address
   npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
   ```

2. **Test Contract Functions:**
   ```bash
   # Get contract info
   npx hardhat run -e "
     const contract = await ethers.getContractAt('PrivateMusicRoyalty', '<ADDRESS>');
     const info = await contract.getContractInfo();
     console.log('Total Tracks:', info.totalTracksCount);
     console.log('Total Pools:', info.totalRoyaltyPoolsCount);
   " --network sepolia
   ```

3. **Monitor Transactions:**
   - Sepolia Explorer: https://sepolia.etherscan.io
   - Zama Testnet: Check through Zama's tools

### Contract Interaction

After deployment, interact with contracts:

```javascript
// Connect to deployed contract
const contract = await ethers.getContractAt(
  "PrivateMusicRoyalty",
  "0x..." // Contract address
);

// Call functions
const info = await contract.getContractInfo();
console.log("Total Tracks:", info.totalTracksCount);

// Perform transactions (requires signer)
const tx = await contract.registerRightsHolder();
await tx.wait();
```

## Troubleshooting

### Insufficient Funds
**Error:** `insufficient funds for gas * price + value`

**Solution:**
- Request more test ETH from faucets
- Check account balance: `ethers.provider.getBalance(address)`
- Reduce gas price if needed

### Network Connection Error
**Error:** `Could not connect to the network`

**Solution:**
- Verify RPC URL in `.env` is correct
- Check network is online
- Try alternative RPC provider
- Increase timeout in hardhat.config.js

### Private Key Issues
**Error:** `invalid private key` or `privateKey must be 32 bytes`

**Solution:**
- Ensure PRIVATE_KEY in `.env` is exactly 64 hex characters (32 bytes)
- Don't include '0x' prefix
- Use valid hex characters only

### Contract Not Deploying
**Error:** `Contract creation bytecode mismatch`

**Solution:**
- Recompile: `npm run compile`
- Clean artifacts: `npm run clean`
- Check Solidity version matches hardhat.config.js
- Review contract for syntax errors

### Verification Failed
**Error:** `Contract at address is a proxy, implementations contracts are not included`

**Solution:**
- For proxy contracts, verify implementation
- If using upgradeability, follow proxy verification guide
- Ensure constructor arguments match exactly

## Network Comparison

| Network | Purpose | Token | Speed | Cost | FHEVM |
|---------|---------|-------|-------|------|-------|
| Hardhat | Local testing | None | Instant | None | No |
| Sepolia | General testing | ETH | ~12s | Low | No |
| Zama Testnet | FHEVM testing | ZAMA | ~2s | Low | Yes |

## Best Practices

### 1. Test Before Deployment
```bash
npm run compile
npm run test
```

### 2. Use Testnets First
- Always deploy to testnet first
- Test all functionality
- Verify contract behavior
- Check gas costs

### 3. Save Deployment Info
Keep track of deployed addresses:

```json
{
  "sepolia": {
    "PrivateMusicRoyalty": "0x...",
    "FHECounter": "0x...",
    "deploymentBlock": 12345,
    "deploymentDate": "2025-12-23"
  },
  "zamaTestnet": {
    "PrivateMusicRoyalty": "0x...",
    "FHECounter": "0x...",
    "deploymentBlock": 67890,
    "deploymentDate": "2025-12-23"
  }
}
```

### 4. Monitor Gas Costs
- Check estimated gas before deployment
- Use gas optimization in contracts
- Monitor actual gas used

### 5. Verify Contracts
- Verify on block explorer
- Enable contract reading on explorer
- Helps users interact with contract

## Advanced: Multi-Sig Deployment

For production contracts, use multi-signature wallets:

```typescript
// Example with Gnosis Safe
const SafeFactory = await ethers.getContractFactory("SafeProxyFactory");
// Deploy through Safe factory for security
```

## CI/CD Deployment

Automate deployment with GitHub Actions:

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '16'
      - run: npm install
      - run: npm run compile
      - run: npm run test
      - run: npm run deploy:sepolia
        env:
          PRIVATE_KEY: ${{ secrets.PRIVATE_KEY }}
          SEPOLIA_RPC_URL: ${{ secrets.SEPOLIA_RPC_URL }}
```

## Resources

- [Hardhat Deployment Guide](https://hardhat.org/docs/guides/deploying)
- [Etherscan Verification](https://hardhat.org/docs/plugins/nomiclabs-hardhat-etherscan)
- [Zama Testnet Info](https://docs.zama.ai/fhevm/getting_started/working_with_zama_testnet)
- [Sepolia Faucets](https://www.google.com/search?q=sepolia+faucet)
- [Test Token Requests](https://www.zama.ai/community)

---

**Questions?** Reach out on [Zama Community Forum](https://www.zama.ai/community)
