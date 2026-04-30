# tBTC Terminal

A comprehensive Bitcoin vault solution with multi-signature custody and MUSD stablecoin integration on the Mezo network.

## Project Overview

This project provides a complete infrastructure for managing Bitcoin treasuries with institutional-grade custody features:

- **Multi-signature vaults** for secure Bitcoin custody
- **Role-based access control** (Client, Custodian, Bank)
- **MUSD stablecoin integration** for borrowing against BTC collateral
- **Forge-based smart contracts** for the Mezo network
- **Python CLI tools** for vault operations

## Quick Start

### 1. Setup Environment

```bash
# Copy the environment template
cp contracts/.env.example contracts/.env

# Edit .env with your configuration
# Required:
# - ADMIN_ADDRESS: Address that can update protocol parameters
# - BANK_ACCOUNT: Bank account to inject into vaults
# - PRIVATE_KEY: Your deployment wallet (never commit this!)
```

### 2. Deploy to Testnet

```bash
cd contracts

forge script script/DeployFactory.s.sol \
  --rpc-url https://rpc.test.mezo.org \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### 3. Interact with Python CLI

```bash
# Check vault balance
python btc_vault_cli.py balance \
  --rpc-url http://localhost:8545 \
  --vault-address 0x...

# Create a new vault
python btc_vault_cli.py create_vault \
  --rpc-url http://localhost:8545 \
  --private-key YOUR_PRIVATE_KEY \
  --factory-address FACTORY_ADDRESS \
  --owners "OWNER1,OWNER2,OWNER3" \
  --roles "Client,Custodian,Bank" \
  --threshold 2
```

## Project Structure

```
tbtc-terminal/
├── contracts/                      # Smart contracts directory
│   ├── src/
│   │   ├── BTCVault.sol           # Multi-sig vault contract
│   │   ├── BTCVaultFactory.sol    # Factory for creating vaults
│   │   └── mocks/                 # Mock contracts for testing
│   ├── script/
│   │   └── DeployFactory.s.sol    # Forge deployment script
│   ├── test/                       # Test files
│   ├── lib/                        # Dependencies
│   ├── .env.example                # Configuration template
│   ├── foundry.toml                # Forge configuration
│   └── README.md                   # Contracts documentation
│
├── btc_vault_cli.py               # Python CLI tool
├── pyproject.toml                 # Python project config
├── package.json                   # Node dependencies
├── hardhat.config.js              # Hardhat configuration
└── README.md                       # This file
```

## Key Components

### Smart Contracts

**BTCVault.sol** - Core multi-signature vault
- Multi-owner governance (up to 10 owners)
- Role-based access control
- Proposal-based BTC transfers with quorum execution
- MUSD protocol integration for borrowing

**BTCVaultFactory.sol** - Factory for vault deployment
- Deploy new vaults per client
- Auto-inject bank account as signer
- Configurable MUSD protocol addresses
- Track all created vaults

### Python CLI

`btc_vault_cli.py` - Command-line interface for vault operations:
- Deposit/withdraw BTC
- Create and manage vaults
- Set bank account
- Check balances

## Networks

### Mezo Testnet (Recommended for Development)

| Parameter | Value |
|-----------|-------|
| Chain ID | 31611 |
| RPC | https://rpc.test.mezo.org |
| Explorer | https://explorer.test.mezo.org |
| Faucet | https://faucet.test.mezo.org |
| Native Token | BTC (18 decimals) |

### Mezo Mainnet (Production)

| Parameter | Value |
|-----------|-------|
| Chain ID | 31612 |
| RPC | https://rpc-http.mezo.boar.network |
| Explorer | https://explorer.mezo.org |
| Native Token | BTC (18 decimals) |

## MUSD Protocol Integration

The vaults integrate with the MUSD stablecoin protocol to enable borrowing against BTC collateral.

### Key Concepts

- **Trove**: A collateralized debt position with BTC collateral and MUSD debt
- **NICR**: Nominal Individual Collateral Ratio for efficient trove insertion
- **Hints**: Gas optimization for sorted trove operations
- **Collateral Ratio**: Minimum 110% (liquidation threshold)

### Mainnet MUSD Addresses

```
BorrowerOperations: 0x44b1bac67dDA612a41a58AAf779143B181dEe031
TroveManager:       0x94AfB503dBca74aC3E4929BACEeDfCe19B93c193
SortedTroves:       0x8C5DB4C62BF29c1C4564390d10c20a47E0b2749f
HintHelpers:        0xD267b3bE2514375A075fd03C3D9CBa6b95317DC3
MUSD Token:         0xdD468A1DDc392dcdbEf6db6e34E89AA338F9F186
```

### Testnet MUSD Addresses

```
BorrowerOperations: 0xCdF7028ceAB81fA0C6971208e83fa7872994beE5
TroveManager:       0xE47c80e8c23f6B4A1aE41c34837a0599D5D16bb0
SortedTroves:       0x722E4D24FD6Ff8b0AC679450F3D91294607268fA
HintHelpers:        0x4e4cBA3779d56386ED43631b4dCD6d8EacEcBCF6
MUSD Token:         0x118917a40FAF1CD7a13dB0Ef56C86De7973Ac503
```

## Documentation

For detailed documentation, see the `contracts/` directory:

- **[contracts/README.md](./contracts/README.md)** - Complete setup and deployment guide
- **[contracts/DEPLOYMENT.md](./contracts/DEPLOYMENT.md)** - Step-by-step deployment instructions
- **[contracts/CONTRACT_ADDRESSES.md](./contracts/CONTRACT_ADDRESSES.md)** - Official contract addresses and methods
- **[contracts/FINDING_ADDRESSES.md](./contracts/FINDING_ADDRESSES.md)** - Address discovery reference

## Pre-Deployment Checklist

Before deploying to testnet or mainnet:

- [ ] Install dependencies: `npm install` and `pip install -r requirements.txt`
- [ ] Get testnet BTC from https://faucet.test.mezo.org
- [ ] Copy and configure `.env` file with your addresses
- [ ] Review smart contract code in `contracts/src/`
- [ ] Test deployment on testnet first
- [ ] Verify all MUSD addresses match official documentation

## Deployment Commands

### Build Contracts

```bash
cd contracts && forge build
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

## Vault Features

- **Multi-Signature Security**: Up to 10 owners with configurable threshold
- **Role-Based Access**: Client, Custodian, Bank roles with different permissions
- **Proposal-Based Execution**: Separation of proposal creation and execution
- **Native Bitcoin Custody**: Direct BTC deposits and withdrawals
- **MUSD Stablecoin**: Borrow against collateral with 110% minimum ratio
- **Reentrancy Protection**: Guards against reentrancy attacks

## Important Notes

1. **BTC is Native Token**: On Mezo, BTC is the gas currency with 18 decimals
2. **All MUSD Addresses are Proxies**: Use "Read/Write as Proxy" tabs in explorers
3. **Minimum Collateral Ratio**: 110% (liquidation threshold)
4. **Borrowing Fee**: 0.1% added to debt
5. **Redemption Fee**: 0.75% when redeeming MUSD for BTC
6. **Minimum Debt**: 1,800 MUSD per trove
7. **Gas Compensation**: 200 MUSD reserved per trove

## Troubleshooting

### "Cannot redeem when TCR < MCR"
System collateral ratio is below 110%. Wait for recovery.

### Transaction runs out of gas
Adjust `_maxIterations` parameter or split into smaller transactions.

### Hints are out of date
Get fresh hints immediately before redeeming (they become stale quickly).

## Resources

- **MUSD Documentation**: https://mezo.org/docs/developers/musd/
- **Mezo Docs**: https://mezo.org/docs/developers/
- **MUSD Redemptions Guide**: https://mezo.org/docs/developers/musd/musd-redemptions/
- **MUSD GitHub**: https://github.com/mezo-org/musd
- **Discord Community**: https://discord.mezo.org
- **Testnet Faucet**: https://faucet.test.mezo.org

## Support

- See detailed documentation in the `contracts/` directory
- Check MUSD protocol documentation for integration questions
- Join the Mezo Discord community for support
- Report issues on the MUSD GitHub repository

---

**Status**: ✅ Ready for Deployment  
**Last Updated**: April 29, 2026  
**Contract Version**: Solidity 0.8.20  
**Networks**: Mezo Mainnet (31612) & Testnet (31611)
