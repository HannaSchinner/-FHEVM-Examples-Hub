# Contributing to FHEVM Examples Hub

Thank you for your interest in contributing to the FHEVM Examples Hub! This guide explains how to add new examples and contribute to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Adding a New Example](#adding-a-new-example)
- [Code Standards](#code-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)
- [Submission Process](#submission-process)

---

## Code of Conduct

Be respectful, inclusive, and constructive in all interactions. We're building a community to advance FHEVM and privacy-preserving smart contracts.

---

## Getting Started

### Prerequisites

- Node.js v16+
- npm or yarn
- Basic knowledge of Solidity
- Understanding of FHE concepts (read the docs first!)

### Setup for Development

```bash
# Clone the repository
git clone <repository-url>
cd PrivateMusicRoyalty

# Install dependencies
npm install

# Compile contracts
npm run compile

# Run tests
npm run test
```

---

## Adding a New Example

### Step 1: Choose Your Example Type

**Basic Examples** (Teaching fundamental FHEVM concepts):
- Encryption/Decryption
- Arithmetic operations
- Comparisons
- Access control basics
- Input validation

**Advanced Examples** (Real-world applications or complex patterns):
- Privacy-preserving applications
- Multi-party interactions
- Complex access control
- Integration patterns

### Step 2: Create the Smart Contract

1. Create your contract in the appropriate directory:
   - Basic: `contracts/basic/YourExample.sol`
   - Advanced: `contracts/advanced/YourExample.sol`

2. Use this template structure:

```solidity
// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Your Example Title
 * @notice Brief description of what this demonstrates
 * @dev Covered concepts:
 *      - Concept 1
 *      - Concept 2
 */
contract YourExample is ZamaEthereumConfig {
    // Implementation
}
```

3. **Writing High-Quality Code**:
   - Include comprehensive JSDoc/NatSpec comments
   - Explain WHY, not just WHAT
   - Show both correct usage patterns
   - Highlight potential pitfalls
   - Include real-world use cases

4. **Example: Good Comments**

```solidity
/**
 * @notice Performs encrypted addition
 * @param a First encrypted value
 * @param b Second encrypted value
 * @return The encrypted sum
 *
 * ✅ KEY CONCEPT: Homomorphic Addition
 * Two encrypted numbers can be added without decryption
 * Result remains encrypted and can be used in further operations
 *
 * USE CASE: Private balance updates
 */
function add(euint32 a, euint32 b) external pure returns (euint32) {
    return FHE.add(a, b);
}
```

### Step 3: Create Comprehensive Tests

1. Create tests in: `test/<category>/YourExample.test.ts`

2. Test structure:

```typescript
import { expect } from "chai";
import { ethers } from "hardhat";

/**
 * @title Your Example Tests
 * @notice Comprehensive test suite for the example
 */
describe("YourExample", function () {
  let contract: YourExample;
  let owner: HardhatEthersSigner;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();
    const YourExample = await ethers.getContractFactory("YourExample");
    contract = await YourExample.deploy();
    await contract.waitForDeployment();
  });

  describe("Feature Name", function () {
    it("✅ Should work correctly", async function () {
      // Test successful operation
      expect(await contract.someFunction()).to.equal(expectedValue);
    });

    it("❌ Should handle edge case", async function () {
      // Test error cases
      await expect(contract.failingFunction()).to.be.revertedWith("Error message");
    });
  });
});
```

3. **Test Coverage Guidelines**:
   - ✅ Successful operations
   - ❌ Error conditions and edge cases
   - Access control scenarios
   - Permission management
   - Encrypted vs plain value handling

### Step 4: Update Automation Scripts

#### Update create-fhevm-example.ts

Add to `EXAMPLES_CONFIG`:

```typescript
"your-example": {
  name: "your-example",
  title: "Your Example Title",
  description: "Clear description of what this demonstrates",
  contractPath: "contracts/basic/YourExample.sol",  // or advanced/
  testPath: "test/basic/YourExample.test.ts",
  category: "basic",  // or "advanced"
  concepts: [
    "concept-1",
    "concept-2"
  ]
}
```

#### Update generate-docs.ts

Add to `DOC_CONFIG`:

```typescript
"your-example": {
  title: "Your Example Title",
  category: "basic",
  concepts: ["Concept 1", "Concept 2"],
  description: "Detailed description for documentation",
  contractFile: "contracts/basic/YourExample.sol",
  testFile: "test/basic/YourExample.test.ts"
}
```

### Step 5: Test Everything

```bash
# Compile
npm run compile

# Run tests
npm run test

# Generate documentation
npm run generate-docs your-example

# Test standalone generation
npm run create-example your-example ./test-output/your-example
cd test-output/your-example
npm install
npm run compile
npm run test
```

---

## Code Standards

### Solidity Standards

✅ **DO:**
- Use clear, descriptive names for variables and functions
- Include comprehensive comments explaining FHE concepts
- Show both correct and incorrect patterns
- Include practical examples and use cases
- Document security considerations

❌ **DON'T:**
- Use vague or abbreviated names
- Assume reader knowledge of FHE
- Skip error handling documentation
- Mix concepts in a single contract
- Forget permission management explanations

### TypeScript Standards

✅ **DO:**
- Use explicit types
- Include JSDoc comments
- Follow Hardhat testing patterns
- Test both success and failure cases
- Mark tests with ✅ and ❌

❌ **DON'T:**
- Use `any` types
- Skip error message testing
- Assume default behaviors
- Test multiple unrelated concepts
- Forget permission scenarios

### Documentation Standards

- Write for beginners and experts
- Explain the "why" not just the "what"
- Include concrete examples
- Link to relevant resources
- Highlight common pitfalls

---

## Testing Guidelines

### Unit Tests Requirements

```
✅ Positive cases
  - Successful operation
  - Valid inputs
  - Expected outputs

❌ Negative cases
  - Invalid inputs
  - Permission violations
  - Edge cases
  - Underflow/overflow scenarios

🔍 FHEVM-Specific
  - Encryption/decryption patterns
  - Permission grants (allowThis, allow)
  - Input proof validation
  - Multi-party scenarios
```

### Test Naming Convention

```typescript
// ✅ Clear test names
it("✅ Should increment encrypted counter correctly", async function () { ... });
it("❌ Should reject increment without proper permissions", async function () { ... });

// ❌ Vague test names
it("test1", async function () { ... });
it("should work", async function () { ... });
```

### Test Coverage Goals

- Aim for 80%+ code coverage
- Cover all public functions
- Test error paths
- Verify permission scenarios
- Document edge cases

---

## Documentation Standards

### Contract Comments

```solidity
/**
 * @title Clear Title
 * @notice What this does
 * @dev Implementation details and FHEVM concepts
 *
 * @param paramName Description
 * @return returnName What is returned
 */
```

### Markdown Documentation

1. **Include sections**:
   - Overview/Purpose
   - Key Concepts
   - Code Examples
   - Use Cases
   - Security Considerations
   - Resources

2. **Structure**:
   - Clear headings
   - Code blocks with syntax highlighting
   - Links to resources
   - Practical examples

---

## Submission Process

### Before Submitting

- [ ] Code compiles without warnings: `npm run compile`
- [ ] All tests pass: `npm run test`
- [ ] Documentation generates: `npm run generate-docs your-example`
- [ ] Standalone example works:
  ```bash
  npm run create-example your-example ./test-output
  cd test-output && npm install && npm run test
  ```
- [ ] Code follows standards
- [ ] Comments are comprehensive
- [ ] Tests cover success and failure cases

### Submission Steps

1. **Fork the repository** (if external contributor)

2. **Create a feature branch**:
   ```bash
   git checkout -b feature/add-your-example
   ```

3. **Make your changes**:
   - Add contract in `contracts/<category>/`
   - Add tests in `test/<category>/`
   - Update automation script configs
   - Create documentation

4. **Test thoroughly**:
   ```bash
   npm run compile
   npm run test
   npm run generate-docs your-example
   ```

5. **Commit with clear messages**:
   ```bash
   git commit -m "feat: Add YourExample demonstrating [concepts]"
   ```

6. **Push to your fork**:
   ```bash
   git push origin feature/add-your-example
   ```

7. **Create a Pull Request**:
   - Title: "Add YourExample"
   - Description: Explain what it demonstrates
   - Include: Concept coverage, use cases, testing approach

### Pull Request Checklist

- [ ] Code follows style guidelines
- [ ] Documentation is comprehensive
- [ ] Tests are included and passing
- [ ] No breaking changes
- [ ] Automation scripts updated
- [ ] Standalone example generation works
- [ ] Comments explain FHE concepts

### Review Process

1. Automated checks (compilation, tests)
2. Code review (quality, standards, clarity)
3. Documentation review (clarity, completeness)
4. Example generation verification
5. Approval and merge

---

## Common Contribution Types

### Adding a Basic Example

**What to include**:
- Single FHEVM concept focus
- Clear, simple contract
- Comprehensive tests
- Beginner-friendly comments

**Time estimate**: 2-4 hours

### Adding an Advanced Example

**What to include**:
- Multiple related concepts
- Complex interaction patterns
- Real-world scenario
- Advanced documentation

**Time estimate**: 4-8 hours

### Improving Documentation

**What to do**:
- Clarify existing examples
- Add more code comments
- Create usage guides
- Link to additional resources

**Time estimate**: 1-2 hours

### Fixing Bugs or Issues

1. Identify the issue
2. Create a test that reproduces it
3. Fix the code
4. Verify tests pass
5. Document the fix

---

## Questions or Issues?

- Check [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md)
- Review [bounty-description.md](./bounty-description.md)
- Ask in [Zama Discord](https://discord.com/invite/zama)
- Open a discussion on GitHub

---

## Recognition

Contributors will be:
- Listed in the project README
- Credited in documentation
- Recognized for significant contributions
- Invited to participate in future development

---

## License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to advance the FHEVM ecosystem!** 🎉

Built with ❤️ for the privacy-preserving future
