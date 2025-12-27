# FHEVM Examples Documentation

Welcome to the FHEVM Examples Hub! This comprehensive documentation covers Fully Homomorphic Encryption implementations using Zama's FHEVM protocol.

## What is FHEVM?

FHEVM (Fully Homomorphic Encryption Virtual Machine) is a groundbreaking technology that enables computation on encrypted data without decryption. This allows smart contracts to:

- **Preserve Privacy**: Sensitive data remains encrypted throughout computation
- **Enable Confidential Computing**: Perform mathematical operations on encrypted values
- **Maintain Security**: Only authorized parties can decrypt results

## Key Concepts

### Encrypted Data Types

FHEVM provides encrypted integer types:
- `euint8`, `euint16`, `euint32`, `euint64` - Encrypted unsigned integers
- `eint8`, `eint16`, `eint32`, `eint64` - Encrypted signed integers
- `ebool` - Encrypted booleans

### Operations on Encrypted Values

```solidity
euint32 a = FHE.asEuint32(value1);
euint32 b = FHE.asEuint32(value2);

// Arithmetic operations
euint32 sum = FHE.add(a, b);
euint32 product = FHE.mul(a, b);
euint32 difference = FHE.sub(a, b);

// Comparison operations
ebool isEqual = FHE.eq(a, b);
ebool isGreater = FHE.gt(a, b);
```

### Access Control with FHE

The FHE.allow() and FHE.allowThis() functions manage who can decrypt values:

```solidity
// Grant contract permission to use the value
FHE.allowThis(encryptedValue);

// Grant user permission to decrypt
FHE.allow(encryptedValue, userAddress);
```

## Example Categories

### Basic Examples
These examples demonstrate fundamental FHEVM concepts:
- Simple FHE Counter
- Encryption and Decryption
- Basic Arithmetic Operations
- Comparison Operations

### Advanced Examples
These showcase complex real-world use cases:
- Private Music Royalty Distribution
- Confidential Auctions
- Private Voting Systems
- Blind Signatures

## Getting Started

### Prerequisites

- Node.js v16+
- npm or yarn
- Basic Solidity knowledge
- Understanding of FHE concepts

### Installation

```bash
npm install
```

### Compilation

```bash
npm run compile
```

### Running Tests

```bash
npm run test
```

### Generating Examples

Create a standalone example repository:

```bash
npm run create-example music-royalty ./examples/royalty
```

### Generating Documentation

Auto-generate documentation:

```bash
npm run generate-docs music-royalty
npm run generate-all-docs
```

## Common Patterns

### Pattern 1: Encrypted Storage

```solidity
// Store encrypted sensitive data
euint32 private encryptedSecret;

function setSecret(externalEuint32 value, bytes calldata proof) external {
    euint32 secret = FHE.fromExternal(value, proof);
    FHE.allowThis(secret);
    FHE.allow(secret, msg.sender);
    encryptedSecret = secret;
}
```

### Pattern 2: Encrypted Computation

```solidity
// Perform computation without decryption
function calculatePayment(euint32 amount, euint32 percentage) internal pure returns (euint32) {
    return FHE.mul(amount, percentage) / 100;
}
```

### Pattern 3: Access Control

```solidity
// Only allow decryption to authorized users
function getEncryptedBalance(address user) external view returns (euint64) {
    require(msg.sender == user || msg.sender == admin, "Unauthorized");
    return encryptedBalances[user];
}
```

## Important Notes

### ✅ DO's

- ✅ Always use `FHE.allowThis()` before `FHE.allow()`
- ✅ Match encryption signers with transaction signers
- ✅ Test encrypted operations thoroughly
- ✅ Document permission requirements

### ❌ DON'Ts

- ❌ Don't use view functions with encrypted returns
- ❌ Don't forget `FHE.allowThis()` permissions
- ❌ Don't assume automatic decryption
- ❌ Don't expose unencrypted sensitive data

## Troubleshooting

### Common Issues

**Issue**: "Missing permission" errors
**Solution**: Ensure both `FHE.allowThis()` and `FHE.allow()` are called

**Issue**: Signer mismatch
**Solution**: Use the same signer for encryption and contract call

**Issue**: View function returns encrypted values
**Solution**: Move logic to external functions, not view functions

## Resources

- [Official FHEVM Docs](https://docs.zama.ai/fhevm)
- [Zama GitHub](https://github.com/zama-ai)
- [Community Discord](https://discord.com/invite/zama)
- [Developer Forum](https://www.zama.ai/community)

## Contributing

To contribute new examples:

1. Create a new contract in `contracts/`
2. Create tests in `test/`
3. Update EXAMPLES_CONFIG in automation scripts
4. Run `npm run generate-docs <example-name>`
5. Submit a pull request

## License

All examples are provided under the MIT License.

---

**Built with ❤️ using FHEVM by Zama**
