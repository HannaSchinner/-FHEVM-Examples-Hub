# Bounty Track December 2025: Build The FHEVM Example Hub

**December 2, 2025**
The Zama Team

## Overview

The Zama Bounty Program aims to inspire and incentivize the developer community to contribute to the Zama Confidential Blockchain Protocol.

Each season, we introduce a new bounty that addresses a specific challenge. With this initiative, we invite developers to collaborate with us in advancing the FHE ecosystem.

For this season, the challenge is to build a set of standalone, Hardhat-based FHEVM example repositories, each demonstrating one clear concept (e.g., access control, public decryption, user decryption), with clean tests, automated scaffolding, and self-contained documentation. **The prize pool for this challenge is $10,000.**

## Important Dates

- **Start date**: December 1, 2025
- **Submission deadline**: December 31, 2025 (23:59, Anywhere On Earth)

## Project Goal

The goal of this bounty is to create a comprehensive repository including standalone FHEVM examples that help developers learn and implement privacy-preserving smart contracts using Fully Homomorphic Encryption.

This project demonstrates:

- Automated scaffolding tools for generating example repositories
- Documentation generation from code annotations
- Category-based project generation
- Complete implementation of the bounty requirements

## How to Participate

Participants should create a repository containing:

1. **Automation scripts** - TypeScript-based CLI tools for generating example repositories
2. **Example contracts** - Well-documented Solidity contracts demonstrating FHEVM concepts
3. **Comprehensive tests** - Test suites showing both correct usage and common pitfalls
4. **Documentation generator** - Tool to create GitBook-compatible documentation
5. **Base template** - Using Hardhat template which can be cloned and slightly customized

## Requirements

### 1. Project Structure & Simplicity

- Use only Hardhat for all examples
- One repo per example, no monorepo
- Keep each repo minimal: `contracts/`, `test/`, `hardhat.config.ts`, etc.
- Use a shared base-template that can be cloned/scaffolded
- Generate documentation similar to the official FHEVM examples

### 2. Scaffolding / Automation

Create a CLI or script (`create-fhevm-example`) to:

- Clone and slightly customize the base Hardhat template
- Insert a specific Solidity contract into `contracts/`
- Generate matching tests
- Auto-generate documentation from annotations in code

### 3. Types of Examples to Include

Each of these becomes a standalone repo:

#### Basic Examples
- Simple FHE counter
- Arithmetic (FHE.add, FHE.sub)
- Equality comparison (FHE.eq)

#### Encryption
- Encrypt single value
- Encrypt multiple values

#### User Decryption
- User decrypt single value
- User decrypt multiple values

#### Public Decryption
- Single value public decrypt
- Multi value public decrypt

#### Additional Examples
- Access control (FHE.allow, FHE.allowTransient)
- Input proof explanation
- Anti-patterns (common mistakes)
- Understanding handles
- OpenZeppelin confidential contracts (ERC7984, wrappers, swaps, vesting)
- Advanced examples (blind auction, etc.)

### 4. Documentation Strategy

- Use JSDoc/TSDoc-style comments in TS tests
- Auto-generate markdown README per repo
- Tag key examples into docs: "chapter: access-control", "chapter: relayer", etc.
- Generate GitBook-compatible documentation

## Bonus Points

- Creative examples - Implementing additional examples beyond the requirements
- Advanced patterns - Demonstrating complex FHEVM patterns and use cases
- Clean automation - Particularly elegant and maintainable automation scripts
- Comprehensive documentation - Exceptional documentation with detailed explanations
- Testing coverage - Extensive test coverage including edge cases
- Error handling - Examples demonstrating common pitfalls and how to avoid them

## Judging Criteria

All submissions must include a demonstration video as a mandatory requirement. The video should clearly showcase your project's setup, key features, example execution, and automation scripts in action.

Judging will be based on:

- Code quality
- Automation completeness
- Example quality
- Documentation
- Ease of maintenance on new version changes
- Innovation

## Deliverables

Your submission must include:

1. **base-template/** - Complete Hardhat template with @fhevm/solidity
2. **Automation scripts** - create-fhevm-example and related tools in TypeScript
3. **Example repositories** - Multiple fully working example repos (or category-based projects)
4. **Documentation** - Auto-generated documentation per example
5. **Developer guide** - Guide for adding new examples and updating dependencies
6. **Automation tools** - Complete set of tools for scaffolding and documentation generation

## Reference Repositories

- Base template: https://github.com/zama-ai/fhevm-hardhat-template
- dApps and hardhat examples (outdated): https://github.com/zama-ai/dapps
- OpenZeppelin's confidential contracts repo: https://github.com/OpenZeppelin/openzeppelin-confidential-contracts
- Example implementation: https://github.com/poppyseedDev/zama-bounty-11-example-project

## Resources

- Zama Developer Program on Guild: https://guild.xyz/zama/bounty-program
- Zama Community Forum: https://www.zama.ai/community
- Zama Discord: https://discord.com/invite/zama
- Zama on X: https://twitter.com/zama_fhe
- Zama on Telegram: https://t.me/zama_on_telegram

---

**Built with ❤️ using FHEVM by Zama**
