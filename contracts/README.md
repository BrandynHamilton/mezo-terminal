# BTCVault on Mezo - Complete Reference

**Status**: ✅ READY FOR DEPLOYMENT  
**Last Updated**: April 29, 2026  
**Contract Version**: Solidity 0.8.20

---

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Directory Structure](#directory-structure)
4. [Deployment Guide](#deployment-guide)
5. [Contract Addresses](#contract-addresses)
6. [Network Details](#network-details)
7. [Smart Contracts](#smart-contracts)
8. [Environment Configuration](#environment-configuration)
9. [Pre-Deployment Checklist](#pre-deployment-checklist)
10. [Deployment Commands](#deployment-commands)
11. [Vault Operations](#vault-operations)
12. [MUSD Protocol Integration](#musd-protocol-integration)
13. [Important Notes](#important-notes)
14. [Troubleshooting](#troubleshooting)
15. [Resources](#resources)

---

## Overview

You have a fully configured, production-ready Forge project for deploying BTCVault (a multi-sig Bitcoin treasury) on the Mezo network, with built-in MUSD stablecoin integration for borrowing against Bitcoin collateral.

### Key Features

- **Multi-signature vault** for secure Bitcoin custody
- **Role-based access control** (Client, Custodian, Bank)
- **Proposal-based execution** with quorum requirements
- **MUSD integration** to borrow stablecoins against BTC
- **Institutional-grade security** with reentrancy protection
- **Factory pattern** for deploying multiple vault instances

---

## Quick Start (3 Steps)

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Edit .env with your addresses and private key
# ADMIN_ADDRESS=0x...
# BANK_ACCOUNT=0x...
# PRIVATE_KEY=...

# 3. Deploy to testnet
forge script script/DeployFactory.s.sol \
  --rpc-url https://rpc.test.mezo.org \
  --private-key $PRIVATE_KEY \
  --broadcast
```

---

## Directory Structure

```
contracts/
├── src/
│   ├── BTCVault.sol              # Multi-sig vault contract (641 lines)
│   ├── BTCVaultFactory.sol       # Factory for creating vaults (249 lines)
│   └── mocks/
│       ├── MockMezo.sol          # Mock MUSD protocol (local testing)
│       └── MockMUSD.sol          # Mock stablecoin (local testing)
├── script/
│   └── DeployFactory.s.sol       # Forge deployment script
├── test/                         # Add tests here
├── lib/                          # Dependencies (forge-std, openzeppelin)
│
├── .env.example                  # Configuration template (COPY THIS)
├── foundry.toml                  # Forge configuration
└── README.md                     # Comprehensive reference (this file)
```

---

## Deployment Guide

### 1. Setup Environment

```bash
# Copy the template
cp .env.example .env

# Edit .env with your configuration
nano .env
```

**Required Environment Variables:**

- `ADMIN_ADDRESS` - Address that can update protocol parameters
- `BANK_ACCOUNT` - Bank account to inject into vaults
- `BORROWER_OPERATIONS` - MUSD BorrowerOperations contract
- `TROVE_MANAGER` - MUSD TroveManager contract
- `SORTED_TROVES` - MUSD SortedTroves contract
- `HINT_HELPERS` - MUSD HintHelpers contract
- `MUSD_TOKEN` - MUSD stablecoin token
- `PRIVATE_KEY` - Your deployment wallet (never commit this!)

### 2. Deploy to Testnet

```bash
forge script script/DeployFactory.s.sol \
  --rpc-url https://rpc.test.mezo.org \
  --private-key c7236ddbfee8cbf6b1f142cc2b922ac8e4c93f48f57fa803b3fd0f5ce6e34881 \
  --broadcast

forge flatten src/BTCVaultFactory.sol -o flattened/BTCVaultFactory.sol
forge flatten src/BTCVault.sol -o flattened/BTCVault.sol


```

### 3. Deploy to Mainnet

```bash
forge script script/DeployFactory.s.sol \
  --rpc-url https://rpc-http.mezo.boar.network \
  --private-key $PRIVATE_KEY \
  --broadcast
```

---

## Contract Addresses

### ✅ All Addresses Found and Verified

**Source**: https://mezo.org/docs/developers/musd/musd-redemptions/#contract-addresses

---

### Mainnet (Chain ID: 31612)

| Contract | Address | Role |
|----------|---------|------|
| **BorrowerOperations** | `0x44b1bac67dDA612a41a58AAf779143B181dEe031` | Opens/closes troves, manages collateral |
| **TroveManager** | `0x94AfB503dBca74aC3E4929BACEeDfCe19B93c193` | Tracks trove state, liquidations, redemptions |
| **SortedTroves** | `0x8C5DB4C62BF29c1C4564390d10c20a47E0b2749f` | Maintains sorted list for efficient operations |
| **HintHelpers** | `0xD267b3bE2514375A075fd03C3D9CBa6b95317DC3` | Gas optimization hints |
| **PriceFeed** | `0xc5aC5A8892230E0A3e1c473881A2de7353fFcA88` | BTC price oracle |
| **MUSD Token** | `0xdD468A1DDc392dcdbEf6db6e34E89AA338F9F186` | Stablecoin ERC-20 |

**RPC Endpoints:**
- `https://rpc-http.mezo.boar.network` (Boar)
- `https://rpc_evm-mezo.imperator.co` (Imperator)
- `https://mainnet.mezo.public.validationcloud.io` (Validation Cloud)
- `https://mezo.drpc.org` (dRPC NodeCloud)

**Explorer**: https://explorer.mezo.org

---

### Testnet (Chain ID: 31611)

| Contract | Address | Role |
|----------|---------|------|
| **BorrowerOperations** | `0xCdF7028ceAB81fA0C6971208e83fa7872994beE5` | Opens/closes troves, manages collateral |
| **TroveManager** | `0xE47c80e8c23f6B4A1aE41c34837a0599D5D16bb0` | Tracks trove state, liquidations, redemptions |
| **SortedTroves** | `0x722E4D24FD6Ff8b0AC679450F3D91294607268fA` | Maintains sorted list for efficient operations |
| **HintHelpers** | `0x4e4cBA3779d56386ED43631b4dCD6d8EacEcBCF6` | Gas optimization hints |
| **PriceFeed** | `0x86bCF0841622a5dAC14A313a15f96A95421b9366` | BTC price oracle |
| **MUSD Token** | `0x118917a40FAF1CD7a13dB0Ef56C86De7973Ac503` | Stablecoin ERC-20 |

**RPC Endpoint**: `https://rpc.test.mezo.org`  
**Explorer**: https://explorer.test.mezo.org  
**Faucet**: https://faucet.test.mezo.org

---

### Integration Notes

All addresses are **proxy contracts**. When interacting through block explorers:
- Use "**Read as Proxy**" for read-only calls
- Use "**Write as Proxy**" for transactions

#### Key Contract Methods

**BorrowerOperations:**
- `openTrove(uint256 _MUSDAmount, address _upperHint, address _lowerHint)` - Borrow MUSD
- `closeTrove()` - Close position
- `repayMUSD(uint256 _amount, address _upperHint, address _lowerHint)` - Repay debt
- `getBorrowingFee(uint256 _MUSDAmount)` - Get fee (0.1%)

**TroveManager:**
- `getTroveDebt(address _borrower)` - Get trove debt
- `getTroveColl(address _borrower)` - Get collateral
- `getTroveStatus(address _borrower)` - Check if active (1=active, 0=closed)
- `MUSD_GAS_COMPENSATION()` - Get gas comp (200 MUSD)
- `getTCR()` - Get total collateral ratio
- `redeemCollateral(uint256 _amount, ...)` - Redeem MUSD for BTC

**SortedTroves:**
- `findInsertPosition(uint256 _NICR, address _prevId, address _nextId)` - Get insertion hints

**HintHelpers:**
- `getApproxHint(uint256 _CR, uint256 _numTrials, uint256 _inputRandomSeed)` - Get approximate hint
- `getRedemptionHints(uint256 _amount, uint256 _price, uint256 _maxIterations)` - Redemption hints

**PriceFeed:**
- `fetchPrice()` - Get current BTC price (with 18 decimals)

---

### Quick Reference for BTCVault Integration

For the BTCVault smart contract, use these addresses in your deployment:

```solidity
// Mainnet
address borrowerOps = 0x44b1bac67dDA612a41a58AAf779143B181dEe031;
address troveManager = 0x94AfB503dBca74aC3E4929BACEeDfCe19B93c193;
address sortedTroves = 0x8C5DB4C62BF29c1C4564390d10c20a47E0b2749f;
address hintHelpers = 0xD267b3bE2514375A075fd03C3D9CBa6b95317DC3;
address musdToken = 0xdD468A1DDc392dcdbEf6db6e34E89AA338F9F186;
```

---

## Network Details

### Testnet (Recommended for Development)

| Parameter | Value |
|-----------|-------|
| Chain ID | 31611 |
| RPC Endpoint | https://rpc.test.mezo.org |
| Explorer | https://explorer.test.mezo.org |
| Faucet | https://faucet.test.mezo.org |
| Native Token | BTC (18 decimals) |

### Mainnet (Production)

| Parameter | Value |
|-----------|-------|
| Chain ID | 31612 |
| RPC Endpoint | https://rpc-http.mezo.boar.network |
| Explorer | https://explorer.mezo.org |
| Native Token | BTC (18 decimals) |

### Network Parameters

| Parameter | Mainnet | Testnet |
|-----------|---------|---------|
| **Chain ID** | 31612 | 31611 |
| **Native Token** | BTC | BTC |
| **Decimals** | 18 | 18 |
| **Gas Currency** | BTC | BTC |

---

## Smart Contracts

### BTCVault.sol (641 lines)

**Purpose**: Multi-sig Bitcoin treasury vault for institutional custody

**Key Features:**
- Multi-owner governance (up to 10 owners)
- Role-based access (Client, Custodian, Bank)
- Proposal-based BTC transfers
- Quorum-based execution
- MUSD protocol integration
- Native BTC collateral support

**Main Functions:**
- `initialize()` - Set owners and roles
- `deposit()` - Receive BTC
- `propose()` - Create transfer proposal
- `approve()` - Sign proposal
- `execute()` - Execute approved proposal
- `borrowMUSD()` - Borrow against BTC collateral
- `repayMUSD()` - Repay MUSD debt
- `closeTrove()` - Close borrowing position

### BTCVaultFactory.sol (249 lines)

**Purpose**: Deploy and manage BTCVault instances

**Key Features:**
- Deploys new vaults per client
- Auto-injects bank account as signer
- Configurable MUSD protocol addresses
- Tracks all created vaults
- Admin-controlled settings

**Main Functions:**
- `createVault()` - Deploy new vault with owners
- `setBankAccount()` - Set auto-injected signer
- `setMezoDefaults()` - Update protocol addresses

---

## Environment Configuration

The `.env.example` file contains all necessary configuration:

```bash
# Deployment addresses
ADMIN_ADDRESS=0x...          # Can update protocol addresses
BANK_ACCOUNT=0x...           # Auto-injected into vaults
PRIVATE_KEY=...              # For deployment (NEVER commit!)

# Mainnet MUSD addresses (already filled)
BORROWER_OPERATIONS=0x44b1bac67dDA612a41a58AAf779143B181dEe031
TROVE_MANAGER=0x94AfB503dBca74aC3E4929BACEeDfCe19B93c193
SORTED_TROVES=0x8C5DB4C62BF29c1C4564390d10c20a47E0b2749f
HINT_HELPERS=0xD267b3bE2514375A075fd03C3D9CBa6b95317DC3
MUSD_TOKEN=0xdD468A1DDc392dcdbEf6db6e34E89AA338F9F186

# Testnet MUSD addresses (already filled)
BORROWER_OPERATIONS_TESTNET=0xCdF7028ceAB81fA0C6971208e83fa7872994beE5
TROVE_MANAGER_TESTNET=0xE47c80e8c23f6B4A1aE41c34837a0599D5D16bb0
SORTED_TROVES_TESTNET=0x722E4D24FD6Ff8b0AC679450F3D91294607268fA
HINT_HELPERS_TESTNET=0x4e4cBA3779d56386ED43631b4dCD6d8EacEcBCF6
MUSD_TOKEN_TESTNET=0x118917a40FAF1CD7a13dB0Ef56C86De7973Ac503

# RPC endpoints (already filled)
MEZO_MAINNET_RPC=https://rpc-http.mezo.boar.network
MEZO_TESTNET_RPC=https://rpc.test.mezo.org
```

---

## Pre-Deployment Checklist

Before deploying, ensure you have:

- [ ] BTC on the network for gas fees
  - **Testnet**: Get from https://faucet.test.mezo.org
  - **Mainnet**: Bridged BTC on Mezo
- [ ] Updated `.env` with your addresses
- [ ] Set a secure `PRIVATE_KEY` in `.env`
- [ ] Understood the vault's multi-sig mechanism
- [ ] Reviewed the smart contract code
- [ ] Tested on testnet first (before mainnet)

---

## Deployment Commands

### Build the Contracts

```bash
forge build
```

### Deploy to Testnet

```bash
forge script script/DeployFactory.s.sol \
  --rpc-url https://rpc.test.mezo.org \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### Deploy to Mainnet

```bash
forge script script/DeployFactory.s.sol \
  --rpc-url https://rpc-http.mezo.boar.network \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### Verify on Explorer (Optional)

After deployment, you can verify your contracts on the explorer:
- Copy the deployment address
- Go to explorer (testnet/mainnet)
- Search for the address
- Click "Verify Contract"
- Provide source code

---

## Vault Operations

### After Deployment

Once deployed, you'll have:

1. **BTCVaultFactory** - Factory contract that creates new vaults
2. **Bank Account Signer** - Automatically injected into each vault
3. **Multiple BTCVaults** - Each is an independent multi-sig treasury

### Creating Your First Vault

Use the factory to create a new vault:

```solidity
// Call factory.createVault() with:
address[] memory owners = [owner1, owner2, owner3];
BTCVault.Role[] memory roles = [
    BTCVault.Role.Client,
    BTCVault.Role.Custodian,
    BTCVault.Role.Client
];
uint256 threshold = 2; // 2 of 3 required to execute

address newVault = factory.createVault(owners, roles, threshold);
```

### Vault Operations

1. **Deposit BTC**: Send BTC directly to vault address
2. **Create Proposal**: Owner calls `propose(recipient, amount)`
3. **Approve**: Other owners call `approve(proposalId)`
4. **Execute**: Once threshold met, call `execute(proposalId)`
5. **Borrow MUSD**: Call `borrowMUSD(collateral, debtAmount)`
6. **Repay MUSD**: Call `repayMUSD(amount)`

### Vault Features

- **Multi-Signature**: Up to 10 owners, configurable threshold
- **Role-Based Access**: Client, Custodian, Bank roles
- **Proposal-Based Execution**: Separated proposal and execution
- **Bitcoin Custody**: Native BTC deposits
- **MUSD Integration**: Borrow stablecoin against BTC
- **Reentrancy Protected**: Uses ReentrancyGuard

---

## MUSD Protocol Integration

The BTCVault contracts integrate with the MUSD protocol, which is a Bitcoin-backed stablecoin system based on Liquity/Threshold USD.

### Key Concepts

**Trove**: A collateralized debt position (CDP) with BTC collateral and MUSD debt.

**NICR**: Nominal Individual Collateral Ratio - used for efficient sorted trove insertion
- Formula: `NICR = (collateral * 1e20) / totalDebt`
- Higher NICR = better collateralization

**Hints**: Gas optimization to help the contract find where to insert a new trove in the sorted list
- Computed via `HintHelpers.getApproxHint()`
- Refined via `SortedTroves.findInsertPosition()`

**Gas Compensation**: 200 MUSD kept per trove as insurance against liquidation costs

**Borrowing Fee**: 0.1% (governable) added as debt to incentivize quick repayment

### Integration Flow

When borrowing MUSD against BTC collateral:

```
1. Calculate expected total debt (including gas comp + fee)
   totalDebt = debtAmount + fee + gasCompensation

2. Calculate NICR
   nicr = (collateralAmount * 1e20) / totalDebt

3. Get approximate hint from HintHelpers
   approxHint = hintHelpers.getApproxHint(nicr, 15, 42)

4. Find exact insertion position
   (upperHint, lowerHint) = sortedTroves.findInsertPosition(nicr, approxHint, approxHint)

5. Open the trove
   borrowerOperations.openTrove(debtAmount, upperHint, lowerHint, {value: collateralAmount})
```

### Collateralization Requirements

- **Minimum Collateral Ratio**: 110% (can be liquidated if below this)
- **Recovery Mode**: Triggered if Total Collateral Ratio < 150%
- **Redemption**: MUSD can always be redeemed for BTC at 1:1 ratio

---

## Important Notes

1. **BTC is Native Token**: On Mezo, BTC is the gas currency (18 decimals)
2. **Proxy Contracts**: All MUSD addresses are proxy contracts
3. **Minimum Collateral Ratio**: 110% (liquidation threshold)
4. **Borrowing Fee**: 0.1% (added to debt)
5. **Redemption Fee**: 0.75% (when redeeming MUSD for BTC)
6. **Minimum Debt**: 1,800 MUSD per trove
7. **Gas Compensation**: 200 MUSD reserved per trove

### Common Requirements

- **Minimum Collateral Ratio**: 110% (liquidation threshold)
- **Recovery Mode Threshold**: 150% (system-wide)
- **Borrowing Fee**: 0.1% (added to debt)
- **Redemption Fee**: 0.75% (deducted from BTC received)
- **Minimum Debt**: 1,800 MUSD (per trove)
- **Gas Compensation**: 200 MUSD (reserved per trove)

---

## Troubleshooting

### "Cannot redeem when TCR < MCR"
System collateral ratio is below 110%. Wait for recovery.

### Transaction runs out of gas
Adjust `_maxIterations` parameter or split into smaller transactions.

### Hints are out of date
Get fresh hints immediately before redeeming (they become stale quickly).

---

## Resources

- **Official Docs**: https://mezo.org/docs/
- **MUSD Documentation**: https://mezo.org/docs/developers/musd/
- **MUSD Redemptions Guide**: https://mezo.org/docs/developers/musd/musd-redemptions/
- **MUSD GitHub**: https://github.com/mezo-org/musd
- **Liquity Documentation**: https://docs.liquity.org/
- **Mezo Explorer**: https://explorer.mezo.org/
- **Discord**: https://discord.mezo.org

---

**Project Status**: ✅ Ready for Deployment  
**Last Verified**: April 29, 2026  
**Contract Version**: Solidity 0.8.20  
**Network**: Mezo Mainnet (31612) & Testnet (31611)
