import { ethers } from "hardhat";

/**
 * @title Deployment Script for FHEVM Contracts
 * @notice Deploys all example contracts in the project
 */

interface DeployedContract {
  name: string;
  address: string;
  deployer: string;
  timestamp: number;
}

async function main() {
  console.log("\n📦 Starting FHEVM Contract Deployment...\n");

  const [deployer] = await ethers.getSigners();
  const balance = await ethers.provider.getBalance(deployer.address);

  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "ETH\n");

  const deployedContracts: DeployedContract[] = [];

  // ================================================================
  // Deploy PrivateMusicRoyalty (Main Example)
  // ================================================================

  console.log("📝 Deploying PrivateMusicRoyalty...");
  try {
    const PrivateMusicRoyalty = await ethers.getContractFactory("PrivateMusicRoyalty");
    const musicRoyalty = await PrivateMusicRoyalty.deploy();
    await musicRoyalty.waitForDeployment();

    const address = await musicRoyalty.getAddress();
    console.log("✅ PrivateMusicRoyalty deployed to:", address);

    deployedContracts.push({
      name: "PrivateMusicRoyalty",
      address,
      deployer: deployer.address,
      timestamp: Math.floor(Date.now() / 1000),
    });
  } catch (error) {
    console.error("❌ Failed to deploy PrivateMusicRoyalty:", error);
  }

  // ================================================================
  // Deploy FHECounter (Basic Example)
  // ================================================================

  console.log("\n📝 Deploying FHECounter...");
  try {
    const FHECounter = await ethers.getContractFactory("FHECounter");
    const counter = await FHECounter.deploy(0); // Initialize with 0
    await counter.waitForDeployment();

    const address = await counter.getAddress();
    console.log("✅ FHECounter deployed to:", address);

    deployedContracts.push({
      name: "FHECounter",
      address,
      deployer: deployer.address,
      timestamp: Math.floor(Date.now() / 1000),
    });
  } catch (error) {
    console.error("❌ Failed to deploy FHECounter:", error);
  }

  // ================================================================
  // Deploy Arithmetic (Basic Example)
  // ================================================================

  console.log("\n📝 Deploying Arithmetic...");
  try {
    const Arithmetic = await ethers.getContractFactory("Arithmetic");
    const arithmetic = await Arithmetic.deploy();
    await arithmetic.waitForDeployment();

    const address = await arithmetic.getAddress();
    console.log("✅ Arithmetic deployed to:", address);

    deployedContracts.push({
      name: "Arithmetic",
      address,
      deployer: deployer.address,
      timestamp: Math.floor(Date.now() / 1000),
    });
  } catch (error) {
    console.error("❌ Failed to deploy Arithmetic:", error);
  }

  // ================================================================
  // Deploy Comparison (Basic Example)
  // ================================================================

  console.log("\n📝 Deploying Comparison...");
  try {
    const Comparison = await ethers.getContractFactory("Comparison");
    const comparison = await Comparison.deploy();
    await comparison.waitForDeployment();

    const address = await comparison.getAddress();
    console.log("✅ Comparison deployed to:", address);

    deployedContracts.push({
      name: "Comparison",
      address,
      deployer: deployer.address,
      timestamp: Math.floor(Date.now() / 1000),
    });
  } catch (error) {
    console.error("❌ Failed to deploy Comparison:", error);
  }

  // ================================================================
  // Deploy Encryption (Basic Example)
  // ================================================================

  console.log("\n📝 Deploying Encryption...");
  try {
    const Encryption = await ethers.getContractFactory("Encryption");
    const encryption = await Encryption.deploy();
    await encryption.waitForDeployment();

    const address = await encryption.getAddress();
    console.log("✅ Encryption deployed to:", address);

    deployedContracts.push({
      name: "Encryption",
      address,
      deployer: deployer.address,
      timestamp: Math.floor(Date.now() / 1000),
    });
  } catch (error) {
    console.error("❌ Failed to deploy Encryption:", error);
  }

  // ================================================================
  // Deploy AccessControl (Advanced Example)
  // ================================================================

  console.log("\n📝 Deploying AccessControl...");
  try {
    const AccessControl = await ethers.getContractFactory("AccessControl");
    const accessControl = await AccessControl.deploy();
    await accessControl.waitForDeployment();

    const address = await accessControl.getAddress();
    console.log("✅ AccessControl deployed to:", address);

    deployedContracts.push({
      name: "AccessControl",
      address,
      deployer: deployer.address,
      timestamp: Math.floor(Date.now() / 1000),
    });
  } catch (error) {
    console.error("❌ Failed to deploy AccessControl:", error);
  }

  // ================================================================
  // Deploy AntiPatterns (Advanced Example)
  // ================================================================

  console.log("\n📝 Deploying AntiPatterns...");
  try {
    const AntiPatterns = await ethers.getContractFactory("AntiPatterns");
    const antiPatterns = await AntiPatterns.deploy();
    await antiPatterns.waitForDeployment();

    const address = await antiPatterns.getAddress();
    console.log("✅ AntiPatterns deployed to:", address);

    deployedContracts.push({
      name: "AntiPatterns",
      address,
      deployer: deployer.address,
      timestamp: Math.floor(Date.now() / 1000),
    });
  } catch (error) {
    console.error("❌ Failed to deploy AntiPatterns:", error);
  }

  // ================================================================
  // Deployment Summary
  // ================================================================

  console.log("\n" + "=".repeat(70));
  console.log("📊 Deployment Summary");
  console.log("=".repeat(70) + "\n");

  console.log(`Total contracts deployed: ${deployedContracts.length}`);
  console.log(`Deployer: ${deployer.address}`);
  console.log(`Network: ${(await ethers.provider.getNetwork()).name}`);
  console.log(`Chain ID: ${(await ethers.provider.getNetwork()).chainId}\n`);

  console.log("Deployed Contracts:");
  console.log("-".repeat(70));

  deployedContracts.forEach((contract, index) => {
    console.log(`${index + 1}. ${contract.name}`);
    console.log(`   Address: ${contract.address}`);
    console.log(`   Time: ${new Date(contract.timestamp * 1000).toISOString()}\n`);
  });

  // ================================================================
  // Save Deployment Info to File
  // ================================================================

  const fs = require("fs");
  const deploymentInfo = {
    network: (await ethers.provider.getNetwork()).name,
    chainId: (await ethers.provider.getNetwork()).chainId,
    deployer: deployer.address,
    timestamp: Math.floor(Date.now() / 1000),
    contracts: deployedContracts,
  };

  const deploymentPath = `./deployments/deployment-${Date.now()}.json`;

  try {
    // Create deployments directory if it doesn't exist
    if (!fs.existsSync("./deployments")) {
      fs.mkdirSync("./deployments");
    }

    fs.writeFileSync(deploymentPath, JSON.stringify(deploymentInfo, null, 2));
    console.log(`\n💾 Deployment info saved to: ${deploymentPath}\n`);
  } catch (error) {
    console.error("❌ Failed to save deployment info:", error);
  }

  // ================================================================
  // Verification Instructions
  // ================================================================

  console.log("=".repeat(70));
  console.log("📝 Next Steps");
  console.log("=".repeat(70) + "\n");

  console.log("To verify contracts on block explorer:\n");

  deployedContracts.forEach((contract) => {
    if (contract.name === "FHECounter") {
      console.log(
        `npx hardhat verify --network <network> ${contract.address} "0"`
      );
    } else {
      console.log(`npx hardhat verify --network <network> ${contract.address}`);
    }
  });

  console.log("\nTo interact with contracts:");
  console.log("npx hardhat console --network <network>");

  console.log("\n✨ Deployment completed successfully!\n");
}

// Execute deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ Deployment failed:");
    console.error(error);
    process.exit(1);
  });
