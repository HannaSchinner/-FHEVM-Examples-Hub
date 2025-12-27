# Developer Guide

This guide explains how to add new examples, maintain the project, and keep up with dependency updates.

## Project Structure

```
PrivateMusicRoyalty/
├── contracts/                    # Smart contract examples
│   └── PrivateMusicRoyalty.sol
├── test/                         # Test files for contracts
│   └── PrivateMusicRoyalty.test.ts
├── scripts/                      # Automation tools (TypeScript)
│   ├── create-fhevm-example.ts   # Repository generator
│   ├── generate-docs.ts          # Documentation generator
│   └── deploy.js                 # Deployment script
├── examples/                     # Generated GitBook documentation
│   ├── SUMMARY.md
│   ├── README.md
│   └── *.md                      # Auto-generated example docs
├── public/                       # Frontend files (if applicable)
├── hardhat.config.js             # Hardhat configuration
├── package.json                  # Dependencies and scripts
├── tsconfig.json                 # TypeScript configuration
├── bounty-description.md         # Bounty requirements
└── README.md                     # Main project documentation
```

## Adding a New Example

### Step 1: Create the Smart Contract

Create a new Solidity file in `contracts/` following FHEVM patterns:

```solidity
// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";
import { SepoliaConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/// @title Example Contract
/// @notice Demonstrates [specific FHEVM concept]
contract ExampleContract is SepoliaConfig {
    // Implementation
}
```

**Best Practices:**
- Include detailed JSDoc comments explaining FHE concepts
- Show both correct usage and common pitfalls
- Keep the contract focused on one concept
- Include access control examples

### Step 2: Create Comprehensive Tests

Create a test file in `test/` following the pattern:

```typescript
import { expect } from "chai";
import { ethers } from "hardhat";

/**
 * @title Example Contract Tests
 * @notice Comprehensive test suite demonstrating FHEVM concepts
 */
describe("ExampleContract", function () {
  // Test implementation
});
```

**Test Coverage Should Include:**
- ✅ Successful operations with correct permissions
- ❌ Failed operations with incorrect inputs
- Access control verification
- Edge cases
- FHE-specific patterns (allowThis, allow, etc.)

### Step 3: Update Automation Scripts

Add your example to the configuration in `scripts/create-fhevm-example.ts`:

```typescript
const EXAMPLES_CONFIG: Record<string, ExampleConfig> = {
  // ... existing examples ...
  "your-example": {
    name: "your-example",
    title: "Your Example Title",
    description: "Brief description of what this demonstrates",
    contractPath: "contracts/YourExample.sol",
    testPath: "test/YourExample.test.ts",
    category: "basic", // or "advanced"
    concepts: [
      "encryption",
      "access-control",
      // ... relevant FHEVM concepts
    ]
  }
};
```

Also add to `scripts/generate-docs.ts`:

```typescript
const DOC_CONFIG: DocConfig = {
  // ... existing examples ...
  "your-example": {
    title: "Your Example Title",
    category: "basic",
    concepts: ["Encryption", "Access Control"],
    description: "Detailed description...",
    contractFile: "contracts/YourExample.sol",
    testFile: "test/YourExample.test.ts"
  }
};
```

### Step 4: Generate Documentation

```bash
npm run generate-docs your-example
```

This creates `examples/your-example.md` with:
- Full contract code
- Complete test suite
- Explanation of key concepts
- Usage instructions

### Step 5: Test Everything

```bash
# Compile contracts
npm run compile

# Run tests
npm run test

# Generate standalone example
npm run create-example your-example ./test-output/your-example

# Navigate and verify
cd test-output/your-example
npm install
npm run compile
npm run test

# Should all pass!
```

## Managing Dependencies

### Updating @fhevm/solidity

When a new version of `@fhevm/solidity` is released:

1. **Update package.json:**
   ```bash
   npm install @fhevm/solidity@latest
   ```

2. **Test all examples:**
   ```bash
   npm run compile
   npm run test
   ```

3. **Check for breaking changes:**
   - Review [FHEVM Release Notes](https://github.com/zama-ai/fhevm/releases)
   - Update imports if necessary
   - Update examples if APIs changed

4. **Regenerate examples:**
   ```bash
   npm run create-example music-royalty ./test-output/royalty
   cd test-output/royalty && npm install && npm run test
   ```

5. **Update documentation:**
   ```bash
   npm run generate-all-docs
   ```

### Updating TypeScript Dependencies

Keep TypeScript and related packages updated:

```bash
npm update
npm audit fix  # For security vulnerabilities
npm run type-check  # Verify TypeScript compilation
```

## Maintenance Checklist

### Weekly
- [ ] Review new issues and discussions
- [ ] Test latest examples compile without warnings

### Monthly
- [ ] Check for dependency updates
- [ ] Regenerate documentation
- [ ] Verify all tests pass

### Quarterly
- [ ] Review and update documentation
- [ ] Add new examples based on community requests
- [ ] Update FHEVM library to latest version
- [ ] Review and refactor automation scripts

## Common Tasks

### Generate All Documentation

```bash
npm run generate-all-docs
```

Creates markdown files for all examples in the `examples/` directory with a `SUMMARY.md` index.

### Create a Standalone Repository

```bash
npm run create-example music-royalty /path/to/output
```

Creates a complete, standalone Hardhat project ready to clone and use:
- Copies contract and test files
- Generates package.json with correct dependencies
- Creates hardhat.config.ts
- Includes .gitignore

### Run Type Checking

```bash
npm run type-check
```

Verifies TypeScript compilation without errors.

### Build Automation Scripts

```bash
npm run build:scripts
```

Compiles TypeScript scripts to JavaScript in the `dist/` directory.

## Code Quality Standards

### Contract Code
- Use natspec comments (`///`, `//`)
- Include `@title`, `@notice`, `@dev` annotations
- Demonstrate FHE concepts clearly
- Include practical examples

### Test Code
- Use JSDoc/TSDoc comments
- Mark successful tests with ✅
- Mark failing tests with ❌
- Include descriptive test names
- Cover happy path and error cases

### Documentation
- Write in clear, accessible language
- Include code examples
- Explain why, not just what
- Link to relevant resources

## Best Practices for Examples

### ✅ DO

- ✅ Keep examples focused on one concept
- ✅ Include comprehensive comments
- ✅ Show correct usage patterns
- ✅ Demonstrate permission requirements
- ✅ Include error handling examples
- ✅ Write thorough tests
- ✅ Document assumptions

### ❌ DON'T

- ❌ Create overly complex examples
- ❌ Mix multiple concepts in one example
- ❌ Omit important security considerations
- ❌ Assume reader knowledge of FHE
- ❌ Skip test coverage
- ❌ Leave code without comments

## Troubleshooting

### Tests Failing After Dependency Update

1. Check FHEVM release notes for breaking changes
2. Update imports and API calls
3. Review error messages carefully
4. Test with simpler examples first

### Documentation Generation Issues

1. Verify files exist at specified paths
2. Check file syntax is valid
3. Ensure DOC_CONFIG entries match file paths
4. Review console output for error details

### Example Repository Creation Failed

1. Ensure example name is in EXAMPLES_CONFIG
2. Verify contract and test files exist
3. Check file paths are relative to project root
4. Review error messages for specific issues

## Contributing to the Hub

To contribute a new example:

1. Create contract and tests following this guide
2. Add to automation script configurations
3. Generate documentation
4. Create a pull request with:
   - Description of the concept demonstrated
   - Test results
   - Generated documentation

## Resources

- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Zama GitHub](https://github.com/zama-ai)
- [Community Forum](https://www.zama.ai/community)
- [Discord Chat](https://discord.com/invite/zama)

---

**Questions?** Reach out on the [Zama Community Forum](https://www.zama.ai/community)
