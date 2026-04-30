# BTC Vault and BTC Vault Factory Deployment & Usage Guide

## Overview
This guide explains how to deploy the BTC Vault and BTC Vault Factory smart contracts with bank account injection feature and interact with them using the provided Python CLI tool.

## Prerequisites
- Node.js and npm
- Ganache or similar local Ethereum testnet
- Python 3.7+
- pip packages: web3, click, eth-account

## Contract Deployment

### 1. Install Dependencies
```bash
npm install -g truffle
pip install web3 click eth-account
```

### 2. Smart Contract Structure
The contracts consist of:
- `BTCVault.sol` - Core vault contract for holding BTC
- `BTCVaultFactory.sol` - Factory contract for creating vault instances

### 3. Deploy Using Truffle
Create a `truffle-config.js` file:

```javascript
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    }
  },
  compilers: {
    solc: {
      version: "0.8.0"
    }
  }
};
```

Deploy with:
```bash
truffle migrate --network development
```

### 4. Contract Addresses
After deployment, note the addresses:
- BTC Vault Factory Address
- BTC Vault Implementation Address

## Setting Up Bank Account Injection

### 1. Set Bank Account
After deployment, you must set the bank account address that will be automatically injected into all created vaults:

```bash
python btc_vault_cli.py set_bank_account \
  --rpc-url http://localhost:8545 \
  --private-key ADMIN_PRIVATE_KEY \
  --factory-address FACTORY_CONTRACT_ADDRESS \
  --bank-account BANK_ACCOUNT_ADDRESS
```

This bank account will be automatically added as a "Bank" role signer to every vault created by the factory.

## Using the Python CLI

### 1. Setup
Install required Python packages:
```bash
pip install web3 click eth-account
```

### 2. CLI Commands

#### Deposit BTC
```bash
python btc_vault_cli.py deposit \
  --rpc-url http://localhost:8545 \
  --private-key YOUR_PRIVATE_KEY \
  --vault-address VAULT_CONTRACT_ADDRESS \
  --amount 0.5
```

#### Withdraw BTC
```bash
python btc_vault_cli.py withdraw \
  --rpc-url http://localhost:8545 \
  --private-key YOUR_PRIVATE_KEY \
  --vault-address VAULT_CONTRACT_ADDRESS \
  --amount 0.2
```

#### Check Balance
```bash
python btc_vault_cli.py balance \
  --rpc-url http://localhost:8545 \
  --vault-address VAULT_CONTRACT_ADDRESS
```

#### Set Bank Account
```bash
python btc_vault_cli.py set_bank_account \
  --rpc-url http://localhost:8545 \
  --private-key ADMIN_PRIVATE_KEY \
  --factory-address FACTORY_CONTRACT_ADDRESS \
  --bank-account BANK_ACCOUNT_ADDRESS
```

#### Create New Vault
```bash
python btc_vault_cli.py create_vault \
  --rpc-url http://localhost:8545 \
  --private-key ADMIN_PRIVATE_KEY \
  --factory-address FACTORY_CONTRACT_ADDRESS \
  --owners "OWNER1_ADDRESS,OWNER2_ADDRESS,OWNER3_ADDRESS" \
  --roles "Client,Custodian,Bank" \
  --threshold 2
```

Note: The factory will automatically inject the bank account as the first owner with "Bank" role.

### 3. Environment Variables
Set up environment variables for common parameters:
```bash
export RPC_URL=http://localhost:8545
export VAULT_ADDRESS=0x...
export PRIVATE_KEY=0x...
```

## Vault Creation Process

When creating a vault with the factory:
1. The bank account is automatically injected as the first owner with "Bank" role
2. Additional owners are added after the bank account
3. The minimum signatures threshold is automatically incremented by 1
4. This creates a proper multi-signature structure for institutional custody

Example vault creation:
- Input Owners: [Client, Custodian] 
- Input Roles: [Client, Custodian]
- Input Threshold: 2
- Final Owners: [Bank Account, Client, Custodian] 
- Final Roles: [Bank, Client, Custodian]
- Final Threshold: 3 (required bank + 2 more signers)

## Testing
Run tests using Truffle:
```bash
truffle test
```

## Security Considerations
- Never expose private keys in scripts or logs
- Use secure key management solutions for production
- Validate all inputs before sending transactions
- Test thoroughly on testnets before mainnet deployment

## Troubleshooting
- Ensure your Ethereum node is running
- Verify contract addresses are correct
- Check that accounts have sufficient ETH for gas fees
- Confirm private keys are valid and have funds
- Make sure the bank account is set before creating vaults