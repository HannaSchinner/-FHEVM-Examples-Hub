import * as fs from "fs";
import * as path from "path";
import { execSync } from "child_process";

/**
 * @title FHEVM Example Repository Generator
 * @notice Creates standalone Hardhat-based FHEVM example repositories
 *
 * Usage:
 *   ts-node scripts/create-fhevm-example.ts <example-name> <output-path>
 *   ts-node scripts/create-fhevm-example.ts music-royalty ./examples/royalty-example
 */

interface ExampleConfig {
  name: string;
  title: string;
  description: string;
  contractPath: string;
  testPath: string;
  category: string;
  concepts: string[];
}

// Configuration for available examples
const EXAMPLES_CONFIG: Record<string, ExampleConfig> = {
  // ========== Basic Examples ==========
  "fhe-counter": {
    name: "fhe-counter",
    title: "Simple FHE Counter",
    description: "Basic demonstration of an encrypted counter using FHEVM, showing encrypted state variables and simple operations",
    contractPath: "contracts/FHECounter.sol",
    testPath: "test/FHECounter.test.ts",
    category: "basic",
    concepts: ["fhe-basics", "encryption", "arithmetic-operations", "access-control"]
  },
  "arithmetic": {
    name: "arithmetic",
    title: "Arithmetic Operations",
    description: "Demonstrates FHE arithmetic operations (add, sub, mul) on encrypted values without decryption",
    contractPath: "contracts/basic/Arithmetic.sol",
    testPath: "test/basic/Arithmetic.test.ts",
    category: "basic",
    concepts: ["fhe-add", "fhe-sub", "fhe-mul", "homomorphic-operations"]
  },
  "comparison": {
    name: "comparison",
    title: "Comparison Operations",
    description: "Shows encrypted comparison operations (eq, gt, lt) and conditional selection with FHE.select()",
    contractPath: "contracts/basic/Comparison.sol",
    testPath: "test/basic/Comparison.test.ts",
    category: "basic",
    concepts: ["fhe-eq", "fhe-gt", "fhe-lt", "encrypted-conditionals", "fhe-select"]
  },
  "encryption": {
    name: "encryption",
    title: "Encryption Basics",
    description: "Demonstrates encrypting values on-chain, storing encrypted state, and handling external encrypted inputs",
    contractPath: "contracts/basic/Encryption.sol",
    testPath: "test/basic/Encryption.test.ts",
    category: "basic",
    concepts: ["fhe-encryption", "input-proofs", "external-inputs", "encrypted-storage"]
  },

  // ========== Advanced Examples ==========
  "music-royalty": {
    name: "music-royalty",
    title: "Private Music Royalty Distribution",
    description: "A privacy-preserving music royalty distribution system demonstrating FHE encryption for confidential payments and access control",
    contractPath: "contracts/PrivateMusicRoyalty.sol",
    testPath: "test/PrivateMusicRoyalty.test.ts",
    category: "advanced",
    concepts: [
      "encrypted-state-variables",
      "encrypted-computation",
      "access-control",
      "multiple-encrypted-values",
      "async-decryption",
      "real-world-application"
    ]
  },
  "access-control": {
    name: "access-control",
    title: "FHE Access Control Patterns",
    description: "Comprehensive guide to FHE permission management with FHE.allow(), FHE.allowThis(), and multi-party access",
    contractPath: "contracts/advanced/AccessControl.sol",
    testPath: "test/advanced/AccessControl.test.ts",
    category: "advanced",
    concepts: ["fhe-allow", "fhe-allowThis", "permission-management", "multi-party-access"]
  },
  "anti-patterns": {
    name: "anti-patterns",
    title: "FHEVM Anti-Patterns",
    description: "Common mistakes in FHEVM development and how to avoid them, with wrong vs correct examples",
    contractPath: "contracts/advanced/AntiPatterns.sol",
    testPath: "test/advanced/AntiPatterns.test.ts",
    category: "advanced",
    concepts: ["common-mistakes", "best-practices", "debugging", "security"]
  }
};

/**
 * Generate a standalone example repository
 */
function createStandaloneExample(exampleName: string, outputPath: string): void {
  const config = EXAMPLES_CONFIG[exampleName];

  if (!config) {
    console.error(`❌ Example "${exampleName}" not found`);
    console.error(`Available examples: ${Object.keys(EXAMPLES_CONFIG).join(", ")}`);
    process.exit(1);
  }

  console.log(`\n📦 Creating FHEVM Example: ${config.title}`);
  console.log(`📍 Output path: ${outputPath}\n`);

  // Create output directory
  if (!fs.existsSync(outputPath)) {
    fs.mkdirSync(outputPath, { recursive: true });
  }

  // Copy contract and test files
  const contractDestPath = path.join(outputPath, "contracts", path.basename(config.contractPath));
  const testDestPath = path.join(outputPath, "test", path.basename(config.testPath));

  // Create directories
  fs.mkdirSync(path.dirname(contractDestPath), { recursive: true });
  fs.mkdirSync(path.dirname(testDestPath), { recursive: true });

  // Copy files if they exist
  if (fs.existsSync(config.contractPath)) {
    fs.copyFileSync(config.contractPath, contractDestPath);
    console.log(`✅ Copied contract: ${contractDestPath}`);
  }

  if (fs.existsSync(config.testPath)) {
    fs.copyFileSync(config.testPath, testDestPath);
    console.log(`✅ Copied tests: ${testDestPath}`);
  }

  // Generate hardhat.config.ts
  const hardhatConfig = generateHardhatConfig();
  fs.writeFileSync(path.join(outputPath, "hardhat.config.ts"), hardhatConfig);
  console.log(`✅ Generated hardhat.config.ts`);

  // Generate package.json
  const packageJson = generatePackageJson(config);
  fs.writeFileSync(path.join(outputPath, "package.json"), packageJson);
  console.log(`✅ Generated package.json`);

  // Generate README
  const readme = generateReadme(config);
  fs.writeFileSync(path.join(outputPath, "README.md"), readme);
  console.log(`✅ Generated README.md`);

  // Generate tsconfig.json
  const tsconfig = generateTsConfig();
  fs.writeFileSync(path.join(outputPath, "tsconfig.json"), tsconfig);
  console.log(`✅ Generated tsconfig.json`);

  // Generate .gitignore
  const gitignore = generateGitIgnore();
  fs.writeFileSync(path.join(outputPath, ".gitignore"), gitignore);
  console.log(`✅ Generated .gitignore`);

  console.log(`\n✨ Example repository created successfully!\n`);
  console.log(`📚 Next steps:`);
  console.log(`   cd ${outputPath}`);
  console.log(`   npm install`);
  console.log(`   npm run compile`);
  console.log(`   npm run test\n`);
}

/**
 * Generate hardhat.config.ts content
 */
function generateHardhatConfig(): string {
  return `import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-ethers";
import "@fhevm/hardhat-plugin";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    artifacts: "./artifacts",
    cache: "./cache",
  },
  mocha: {
    timeout: 100000,
  },
};

export default config;
`;
}

/**
 * Generate package.json content
 */
function generatePackageJson(config: ExampleConfig): string {
  return JSON.stringify(
    {
      name: \`fhevm-example-\${config.name}\`,
      version: "1.0.0",
      description: config.description,
      main: "index.js",
      scripts: {
        compile: "hardhat compile",
        test: "hardhat test",
        node: "hardhat node",
        clean: "hardhat clean",
        "type-check": "tsc --noEmit",
      },
      keywords: [
        "fhevm",
        "fhe",
        "zama",
        "privacy",
        "confidential-computing",
        config.category,
        ...config.concepts,
      ],
      author: "",
      license: "MIT",
      devDependencies: {
        "@fhevm/hardhat-plugin": "0.0.1-3",
        "@fhevm/mock-utils": "^0.0.1-3",
        "@nomicfoundation/hardhat-ethers": "^3.1.0",
        "@types/chai": "^4.3.5",
        "@types/mocha": "^10.0.1",
        "@types/node": "^20.4.5",
        chai: "^4.3.7",
        hardhat: "^2.19.0",
        mocha: "^10.4.0",
        "ts-node": "^10.9.1",
        typescript: "^5.1.6",
      },
      dependencies: {
        "@fhevm/solidity": "^0.7.0",
        "@zama-fhe/oracle-solidity": "^0.1.0",
        ethers: "^6.14.0",
      },
    },
    null,
    2
  );
}

/**
 * Generate README.md content
 */
function generateReadme(config: ExampleConfig): string {
  return `# \${config.title}

## Overview

\${config.description}

## Key Concepts

\${config.concepts.map((c) => \`- **\${c}**: Demonstrates \${c} pattern\`).join("\n")}

## Project Structure

\`\`\`
.
├── contracts/           # Solidity smart contracts
├── test/               # Test files
├── hardhat.config.ts   # Hardhat configuration
├── package.json        # Dependencies and scripts
└── tsconfig.json       # TypeScript configuration
\`\`\`

## Quick Start

### Installation

\`\`\`bash
npm install
\`\`\`

### Compilation

\`\`\`bash
npm run compile
\`\`\`

### Running Tests

\`\`\`bash
npm run test
\`\`\`

## FHEVM Concepts

### Encrypted State Variables
This example demonstrates storing sensitive data as encrypted values (euint32, euint64) preventing public visibility while allowing computation on encrypted data.

### Access Control with FHE
Learn how to use \`FHE.allow()\` and \`FHE.allowThis()\` to grant permissions for decryption only to authorized parties.

### Encrypted Computation
See how mathematical operations are performed on encrypted values without ever decrypting them.

## Resources

- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Zama on GitHub](https://github.com/zama-ai)
- [Community Discord](https://discord.com/invite/zama)

## License

MIT License

---

**Built with ❤️ using FHEVM by Zama**
`;
}

/**
 * Generate tsconfig.json content
 */
function generateTsConfig(): string {
  return JSON.stringify(
    {
      compilerOptions: {
        target: "ES2020",
        module: "commonjs",
        lib: ["ES2020"],
        outDir: "./dist",
        rootDir: "./",
        strict: true,
        esModuleInterop: true,
        skipLibCheck: true,
        forceConsistentCasingInFileNames: true,
        resolveJsonModule: true,
        declaration: true,
        declarationMap: true,
        sourceMap: true,
        types: ["node"],
      },
      include: ["test/**/*.ts"],
      exclude: ["node_modules", "dist", "artifacts", "cache"],
    },
    null,
    2
  );
}

/**
 * Generate .gitignore content
 */
function generateGitIgnore(): string {
  return `# Dependencies
node_modules/
yarn.lock
package-lock.json

# Hardhat
artifacts/
cache/

# Environment
.env
.env.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Build outputs
dist/
build/
out/

# Test coverage
coverage/

# OS
Thumbs.db
`;
}

/**
 * Parse command line arguments
 */
function parseArgs(): { exampleName: string; outputPath: string } {
  const args = process.argv.slice(2);

  if (args.length < 2) {
    console.log("Usage: ts-node create-fhevm-example.ts <example-name> <output-path>");
    console.log(`\nAvailable examples:`);
    Object.entries(EXAMPLES_CONFIG).forEach(([name, config]) => {
      console.log(`  - ${name}: ${config.title}`);
    });
    process.exit(1);
  }

  return {
    exampleName: args[0],
    outputPath: args[1],
  };
}

// Main execution
const { exampleName, outputPath } = parseArgs();
createStandaloneExample(exampleName, outputPath);
