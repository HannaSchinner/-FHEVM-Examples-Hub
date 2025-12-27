# Automation Scripts Documentation

This directory contains TypeScript-based automation tools for generating FHEVM example repositories and documentation.

## Overview

The automation scripts enable:
- **Standalone Repository Generation** - Create complete FHEVM projects from templates
- **Documentation Auto-Generation** - Create GitBook-compatible markdown from code
- **Configuration Management** - Centralized example configuration
- **Scaffolding** - Quick setup of new examples

## Scripts

### create-fhevm-example.ts

**Purpose**: Generate standalone FHEVM example repositories

**Functionality**:
- Creates a complete Hardhat project structure
- Copies contract and test files
- Generates configuration files (hardhat.config.ts, package.json, tsconfig.json)
- Creates README with example-specific content
- Sets up .gitignore for the project
- Ready to use with `npm install && npm run test`

**Usage**:
```bash
# Using npm script
npm run create-example <example-name> <output-path>

# Direct execution
ts-node scripts/create-fhevm-example.ts <example-name> <output-path>

# Example
npm run create-example music-royalty ./examples/royalty-distribution
ts-node scripts/create-fhevm-example.ts fhe-counter ./test-output/counter
```

**Example Configuration**:
```typescript
const EXAMPLES_CONFIG: Record<string, ExampleConfig> = {
  "music-royalty": {
    name: "music-royalty",
    title: "Private Music Royalty Distribution",
    description: "...",
    contractPath: "contracts/PrivateMusicRoyalty.sol",
    testPath: "test/PrivateMusicRoyalty.test.ts",
    category: "advanced",
    concepts: ["encrypted-state-variables", "access-control", ...]
  }
};
```

**Generated Files**:
```
output-path/
├── contracts/
│   └── [Contract].sol
├── test/
│   └── [Contract].test.ts
├── hardhat.config.ts
├── package.json
├── tsconfig.json
├── .gitignore
└── README.md
```

**Command Line Output**:
```
📦 Creating FHEVM Example: Private Music Royalty Distribution
📍 Output path: ./examples/royalty-distribution

✅ Copied contract: ./examples/royalty-distribution/contracts/PrivateMusicRoyalty.sol
✅ Copied tests: ./examples/royalty-distribution/test/PrivateMusicRoyalty.test.ts
✅ Generated hardhat.config.ts
✅ Generated package.json
✅ Generated README.md
✅ Generated tsconfig.json
✅ Generated .gitignore

✨ Example repository created successfully!

📚 Next steps:
   cd ./examples/royalty-distribution
   npm install
   npm run compile
   npm run test
```

### generate-docs.ts

**Purpose**: Auto-generate GitBook-compatible documentation

**Functionality**:
- Extracts contract source code
- Includes test suite code
- Generates formatted markdown documentation
- Creates SUMMARY.md for GitBook navigation
- Includes FHEVM concept explanations
- Provides usage instructions and resources

**Usage**:
```bash
# Using npm scripts
npm run generate-docs <example-name>
npm run generate-all-docs

# Direct execution
ts-node scripts/generate-docs.ts <example-name>
ts-node scripts/generate-docs.ts --all

# Examples
npm run generate-docs music-royalty
npm run generate-all-docs
ts-node scripts/generate-docs.ts fhe-counter
```

**Documentation Configuration**:
```typescript
const DOC_CONFIG: DocConfig = {
  "music-royalty": {
    title: "Private Music Royalty Distribution",
    category: "advanced",
    concepts: [
      "Encrypted State Variables",
      "Access Control",
      "Encrypted Computation",
      ...
    ],
    description: "...",
    contractFile: "contracts/PrivateMusicRoyalty.sol",
    testFile: "test/PrivateMusicRoyalty.test.ts"
  }
};
```

**Generated Output Structure**:
```
examples/
├── SUMMARY.md           # GitBook table of contents
├── README.md            # Introduction and concepts
├── music-royalty.md     # Generated documentation
├── fhe-counter.md       # Generated documentation
└── ...
```

**Generated Document Includes**:
- Title and description
- Key concepts list
- Full contract code with syntax highlighting
- Complete test suite code
- FHEVM pattern explanations
- Running instructions
- Learning resources

**Example Output**:
```markdown
# Private Music Royalty Distribution

## Overview
A privacy-preserving music royalty distribution system...

**Category:** `advanced`

## Key Concepts
- Encrypted State Variables
- Access Control
- ...

## Smart Contract
\`\`\`solidity
[full contract code]
\`\`\`

## Test Suite
\`\`\`typescript
[full test code]
\`\`\`

## FHEVM Patterns
...
```

## Adding New Examples

### Step 1: Add Configuration to create-fhevm-example.ts

```typescript
const EXAMPLES_CONFIG: Record<string, ExampleConfig> = {
  // ... existing examples ...
  "your-example": {
    name: "your-example",
    title: "Your Example Title",
    description: "What this example demonstrates",
    contractPath: "contracts/YourExample.sol",
    testPath: "test/YourExample.test.ts",
    category: "basic",  // or "advanced"
    concepts: [
      "concept-1",
      "concept-2"
    ]
  }
};
```

### Step 2: Add Configuration to generate-docs.ts

```typescript
const DOC_CONFIG: DocConfig = {
  // ... existing examples ...
  "your-example": {
    title: "Your Example Title",
    category: "basic",
    concepts: ["Concept 1", "Concept 2"],
    description: "Detailed description of what this teaches",
    contractFile: "contracts/YourExample.sol",
    testFile: "test/YourExample.test.ts"
  }
};
```

### Step 3: Create the Contract and Tests

- Create `contracts/YourExample.sol` with detailed comments
- Create `test/YourExample.test.ts` with comprehensive test coverage

### Step 4: Test Everything

```bash
npm run compile
npm run test
npm run generate-docs your-example
npm run create-example your-example ./test-output/your-example
```

## Available Examples

### Currently Configured Examples

#### music-royalty
- **Category**: Advanced
- **Concepts**: Encrypted state variables, access control, encrypted computation
- **Description**: Privacy-preserving music royalty distribution system
- **Files**:
  - Contract: `contracts/PrivateMusicRoyalty.sol`
  - Tests: `test/PrivateMusicRoyalty.test.ts`

#### fhe-counter
- **Category**: Basic
- **Concepts**: FHE basics, encryption, arithmetic operations
- **Description**: Simple encrypted counter demonstrating FHE fundamentals
- **Files**:
  - Contract: `contracts/FHECounter.sol`
  - Tests: `test/FHECounter.test.ts`

## Script Configuration Details

### EXAMPLES_CONFIG Structure

```typescript
interface ExampleConfig {
  name: string;              // Unique identifier (kebab-case)
  title: string;             // Display title
  description: string;       // Brief description
  contractPath: string;      // Path to contract file (relative to project root)
  testPath: string;          // Path to test file (relative to project root)
  category: string;          // Category: "basic", "advanced", etc.
  concepts: string[];        // List of FHEVM concepts demonstrated
}
```

### DOC_CONFIG Structure

```typescript
interface DocConfig {
  [key: string]: {
    title: string;         // Documentation title
    category: string;      // Example category
    concepts: string[];    // FHEVM concepts
    description: string;   // Detailed description
    contractFile: string;  // Contract file path
    testFile: string;      // Test file path
  };
}
```

## Troubleshooting

### Script Not Found
**Error**: `ts-node: command not found`
**Solution**: Install dependencies: `npm install`

### File Not Found
**Error**: `Error reading file: contracts/NonExistent.sol`
**Solution**: Verify file paths in configuration match actual file locations

### Generation Failed
**Error**: `Example "invalid-name" not found`
**Solution**: Check example name is in EXAMPLES_CONFIG, verify configuration exists

### Output Already Exists
**Error**: Directory already exists
**Solution**: Delete the output directory or use a different output path

## Performance Tips

- Use relative paths for file locations
- Keep contracts focused on demonstrating one concept
- Test locally before generating examples
- Regenerate documentation after contract changes

## Best Practices

### For Contract Code
- Include detailed JSDoc comments
- Demonstrate best practices
- Show common pitfalls
- Use clear variable names

### For Test Code
- Mark successful tests with ✅
- Mark failing tests with ❌
- Include descriptive test descriptions
- Cover edge cases

### For Documentation
- Write for beginners
- Include code examples
- Explain the "why", not just the "what"
- Link to relevant resources

## Integration with Development Workflow

```bash
# 1. Create contract and tests
# Add files to contracts/ and test/

# 2. Update script configurations
# Add entries to EXAMPLES_CONFIG and DOC_CONFIG

# 3. Compile and test
npm run compile
npm run test

# 4. Generate documentation
npm run generate-docs your-example

# 5. Create standalone example
npm run create-example your-example ./test-output

# 6. Verify standalone project works
cd test-output/your-example
npm install
npm run compile
npm run test
```

## Resources

- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Zama GitHub](https://github.com/zama-ai)
- [Community Forum](https://www.zama.ai/community)

## Maintenance

### Updating Dependencies

When updating `@fhevm/solidity`:

1. Update package.json
2. Regenerate examples: `npm run create-example music-royalty ./test`
3. Test generation: `cd ./test && npm run test`
4. Regenerate docs: `npm run generate-all-docs`

### Adding New Categories

To add a new category:

1. Create directory: `contracts/your-category/`
2. Add examples to EXAMPLES_CONFIG with `category: "your-category"`
3. Examples will be automatically categorized in documentation

---

**For questions or issues, see the [DEVELOPER_GUIDE.md](../DEVELOPER_GUIDE.md)**
