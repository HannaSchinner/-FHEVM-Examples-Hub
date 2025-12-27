import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ethers";
import "dotenv/config";

/**
 * Hardhat Configuration for FHEVM Projects
 *
 * This configuration template supports:
 * - Local development with Hardhat Network
 * - Testnet deployment (Sepolia, Zama Testnet)
 * - Contract verification on Etherscan
 * - TypeScript for scripts and tests
 * - FHEVM integration with @fhevm/solidity
 */

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      evmVersion: "cancun",
    },
  },

  networks: {
    // Local Hardhat Network
    hardhat: {
      chainId: 1337,
      allowUnlimitedContractSize: true,
      gas: "auto",
    },

    // Local Hardhat Node
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 1337,
      timeout: 60000,
    },

    // Sepolia Testnet
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "https://sepolia.infura.io/v3/YOUR_INFURA_KEY",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111,
      gasPrice: "auto",
      timeout: 60000,
    },

    // Zama FHEVM Testnet (Recommended for FHEVM contracts)
    zamaTestnet: {
      url: process.env.ZAMA_TESTNET_RPC_URL || "https://devnet.zama.ai",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 8009,
      gasPrice: "auto",
      timeout: 60000,
    },
  },

  // Etherscan verification
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY || "",
    },
  },

  // Project paths
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },

  // Mocha test configuration
  mocha: {
    timeout: 100000,
  },

  // TypeChain configuration
  typechain: {
    outDir: "typechain-types",
    target: "ethers-v6",
  },

  // Gas reporter (optional)
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
};

export default config;
