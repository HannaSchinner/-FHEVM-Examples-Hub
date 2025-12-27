require("dotenv").config();
require("@nomicfoundation/hardhat-ethers");

/**
 * Hardhat Configuration for FHEVM Examples
 *
 * This configuration supports:
 * - Local development with Hardhat Network
 * - Testnet deployment (Sepolia, Zama Testnet)
 * - Contract verification
 * - TypeScript support
 * - FHEVM integration
 */

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      evmVersion: "cancun"
    }
  },
  networks: {
    hardhat: {
      chainId: 1337,
      // For FHEVM testing
      allowUnlimitedContractSize: true
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 1337,
      timeout: 60000
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "https://sepolia.infura.io/v3/YOUR_INFURA_KEY",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111,
      gasPrice: "auto",
      timeout: 60000
    },
    zamaTestnet: {
      url: process.env.ZAMA_TESTNET_RPC_URL || "https://devnet.zama.ai",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 8009,
      gasPrice: "auto",
      timeout: 60000
    }
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY || ""
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 100000
  },
  // TypeScript support
  typechain: {
    outDir: "typechain-types",
    target: "ethers-v6"
  }
};