import * as fs from "fs";
import * as path from "path";

/**
 * @title FHEVM Documentation Generator
 * @notice Automatically generates GitBook-compatible documentation from code
 *
 * Usage:
 *   ts-node scripts/generate-docs.ts <example-name>
 *   ts-node scripts/generate-docs.ts music-royalty
 *   ts-node scripts/generate-docs.ts --all
 */

interface ExampleDoc {
  name: string;
  title: string;
  category: string;
  concepts: string[];
  contractCode: string;
  testCode: string;
  description: string;
}

interface DocConfig {
  [key: string]: {
    title: string;
    category: string;
    concepts: string[];
    description: string;
    contractFile: string;
    testFile: string;
  };
}

// Documentation configuration
const DOC_CONFIG: DocConfig = {
  // ========== Basic Examples ==========
  "fhe-counter": {
    title: "Simple FHE Counter",
    category: "basic",
    concepts: ["FHE Basics", "Encryption", "Arithmetic Operations", "Access Control"],
    description: "A simple encrypted counter demonstrating FHE fundamentals with encrypted state variables and operations",
    contractFile: "contracts/FHECounter.sol",
    testFile: "test/FHECounter.test.ts",
  },
  "arithmetic": {
    title: "Arithmetic Operations",
    category: "basic",
    concepts: ["FHE Addition", "FHE Subtraction", "FHE Multiplication", "Homomorphic Operations"],
    description: "Demonstrates FHE arithmetic operations (add, sub, mul) on encrypted values without decryption",
    contractFile: "contracts/basic/Arithmetic.sol",
    testFile: "test/basic/Arithmetic.test.ts",
  },
  "comparison": {
    title: "Comparison Operations",
    category: "basic",
    concepts: ["FHE Comparison", "Encrypted Conditionals", "FHE.select()", "Ordering"],
    description: "Shows encrypted comparison operations and conditional selection for privacy-preserving logic",
    contractFile: "contracts/basic/Comparison.sol",
    testFile: "test/basic/Comparison.test.ts",
  },
  "encryption": {
    title: "Encryption Basics",
    category: "basic",
    concepts: ["FHE Encryption", "Input Proofs", "External Inputs", "Encrypted Storage"],
    description: "Demonstrates encrypting values on-chain, storing encrypted state, and handling external encrypted inputs",
    contractFile: "contracts/basic/Encryption.sol",
    testFile: "test/basic/Encryption.test.ts",
  },

  // ========== Advanced Examples ==========
  "music-royalty": {
    title: "Private Music Royalty Distribution",
    category: "advanced",
    concepts: [
      "Encrypted State Variables",
      "Access Control",
      "Encrypted Computation",
      "Multiple Encrypted Values",
      "Asynchronous Decryption",
      "Real-World Application"
    ],
    description:
      "A privacy-preserving music royalty distribution system demonstrating FHEVM encryption for confidential payments",
    contractFile: "contracts/PrivateMusicRoyalty.sol",
    testFile: "test/PrivateMusicRoyalty.test.ts",
  },
  "access-control": {
    title: "FHE Access Control Patterns",
    category: "advanced",
    concepts: ["FHE.allow()", "FHE.allowThis()", "Permission Management", "Multi-Party Access"],
    description: "Comprehensive guide to FHE permission management and multi-party access control patterns",
    contractFile: "contracts/advanced/AccessControl.sol",
    testFile: "test/advanced/AccessControl.test.ts",
  },
  "anti-patterns": {
    title: "FHEVM Anti-Patterns",
    category: "advanced",
    concepts: ["Common Mistakes", "Best Practices", "Debugging", "Security Pitfalls"],
    description: "Common mistakes in FHEVM development and how to avoid them, with detailed wrong vs correct examples",
    contractFile: "contracts/advanced/AntiPatterns.sol",
    testFile: "test/advanced/AntiPatterns.test.ts",
  },
};

/**
 * Read file content safely
 */
function readFileContent(filePath: string): string {
  try {
    if (fs.existsSync(filePath)) {
      return fs.readFileSync(filePath, "utf-8");
    }
    return `// File not found: ${filePath}`;
  } catch (error) {
    return `// Error reading file: ${error}`;
  }
}

/**
 * Generate documentation for a single example
 */
function generateExampleDoc(exampleName: string): ExampleDoc {
  const config = DOC_CONFIG[exampleName];

  if (!config) {
    throw new Error(`Example "${exampleName}" not found in documentation config`);
  }

  const contractCode = readFileContent(config.contractFile);
  const testCode = readFileContent(config.testFile);

  return {
    name: exampleName,
    title: config.title,
    category: config.category,
    concepts: config.concepts,
    contractCode,
    testCode,
    description: config.description,
  };
}

/**
 * Generate markdown documentation
 */
function generateMarkdown(doc: ExampleDoc): string {
  return `# ${doc.title}

## Overview

${doc.description}

**Category:** \`${doc.category}\`

## Key Concepts

${doc.concepts.map((c) => `- ${c}`).join("\n")}

## Smart Contract

\`\`\`solidity
${doc.contractCode}
\`\`\`

## Test Suite

\`\`\`typescript
${doc.testCode}
\`\`\`

## FHEVM Patterns

### Encrypted State Variables
The contract uses encrypted data types (euint32, euint64) to store sensitive information while allowing computation without decryption.

### Access Control
FHE.allow() and FHE.allowThis() are used to grant decryption permissions only to authorized parties.

### Encrypted Computation
Mathematical operations are performed directly on encrypted values.

## Running the Example

\`\`\`bash
npm install
npm run compile
npm run test
\`\`\`

## Learning Resources

- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Zama Developer Program](https://github.com/zama-ai)
- [FHE Concepts Guide](https://docs.zama.org/protocol/protocol-concepts)

---

Generated automatically for the FHEVM Example Hub.
`;
}

/**
 * Generate SUMMARY.md for GitBook
 */
function generateSummary(examples: string[]): string {
  let summary = `# FHEVM Examples

## Table of Contents

`;

  // Group examples by category
  const byCategory: Record<string, string[]> = {};

  examples.forEach((example) => {
    const config = DOC_CONFIG[example];
    if (config) {
      if (!byCategory[config.category]) {
        byCategory[config.category] = [];
      }
      byCategory[config.category].push(example);
    }
  });

  // Generate summary sections
  Object.entries(byCategory).forEach(([category, examplesInCategory]) => {
    summary += `### ${category.charAt(0).toUpperCase() + category.slice(1)}\n\n`;
    examplesInCategory.forEach((example) => {
      const config = DOC_CONFIG[example];
      summary += `- [${config.title}](./${example}.md)\n`;
    });
    summary += "\n";
  });

  return summary;
}

/**
 * Generate all documentation
 */
function generateAllDocs(): void {
  const examplesDir = path.join(process.cwd(), "examples");

  // Create examples directory if it doesn't exist
  if (!fs.existsSync(examplesDir)) {
    fs.mkdirSync(examplesDir, { recursive: true });
  }

  const examples = Object.keys(DOC_CONFIG);
  console.log(`\n📚 Generating documentation for ${examples.length} examples...\n`);

  // Generate individual example docs
  examples.forEach((example) => {
    try {
      const doc = generateExampleDoc(example);
      const markdown = generateMarkdown(doc);
      const outputPath = path.join(examplesDir, `${example}.md`);

      fs.writeFileSync(outputPath, markdown);
      console.log(`✅ Generated: ${outputPath}`);
    } catch (error) {
      console.error(`❌ Error generating docs for ${example}:`, error);
    }
  });

  // Generate SUMMARY.md
  const summary = generateSummary(examples);
  const summaryPath = path.join(examplesDir, "SUMMARY.md");
  fs.writeFileSync(summaryPath, summary);
  console.log(`✅ Generated: ${summaryPath}`);

  console.log(
    `\n✨ Documentation generated successfully in ${path.relative(process.cwd(), examplesDir)}\n`
  );
}

/**
 * Generate documentation for a single example
 */
function generateSingleDoc(exampleName: string): void {
  try {
    const doc = generateExampleDoc(exampleName);
    const markdown = generateMarkdown(doc);

    const examplesDir = path.join(process.cwd(), "examples");
    if (!fs.existsSync(examplesDir)) {
      fs.mkdirSync(examplesDir, { recursive: true });
    }

    const outputPath = path.join(examplesDir, `${exampleName}.md`);
    fs.writeFileSync(outputPath, markdown);

    console.log(`\n✅ Generated documentation: ${outputPath}\n`);
  } catch (error) {
    console.error(`\n❌ Error generating documentation:`, error);
    console.error(`\nAvailable examples: ${Object.keys(DOC_CONFIG).join(", ")}\n`);
    process.exit(1);
  }
}

/**
 * Parse command line arguments
 */
function main(): void {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log("Usage: ts-node generate-docs.ts <example-name>");
    console.log("       ts-node generate-docs.ts --all");
    console.log(`\nAvailable examples:`);
    Object.entries(DOC_CONFIG).forEach(([name, config]) => {
      console.log(`  - ${name}: ${config.title}`);
    });
    process.exit(1);
  }

  if (args[0] === "--all") {
    generateAllDocs();
  } else {
    generateSingleDoc(args[0]);
  }
}

// Execute
main();
