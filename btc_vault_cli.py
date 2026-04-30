import click
import json
from web3 import Web3
from eth_account import Account

# Configuration
@click.group()
def cli():
    """BTC Vault CLI - Interact with BTC Vault and BTC Vault Factory contracts"""
    pass

@cli.command()
@click.option('--rpc-url', default='http://localhost:8545', help='RPC URL for Ethereum node')
@click.option('--private-key', required=True, help='Private key for transactions')
@click.option('--vault-address', required=True, help='BTC Vault contract address')
@click.option('--amount', type=float, required=True, help='Amount to deposit (BTC)')
def deposit(rpc_url, private_key, vault_address, amount):
    """Deposit BTC into a vault"""
    # Connect to Ethereum node
    w3 = Web3(Web3.HTTPProvider(rpc_url))
    
    # Set up account
    account = Account.from_key(private_key)
    w3.eth.default_account = account.address
    
    # Load vault ABI (simplified)
    vault_abi = [
        {
            "constant": False,
            "inputs": [{"name": "amount", "type": "uint256"}],
            "name": "deposit",
            "outputs": [],
            "payable": False,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": True,
            "inputs": [{"name": "account", "type": "address"}],
            "name": "balanceOf",
            "outputs": [{"name": "", "type": "uint256"}],
            "payable": False,
            "stateMutability": "view",
            "type": "function"
        }
    ]
    
    # Create contract instance
    vault_contract = w3.eth.contract(address=vault_address, abi=vault_abi)
    
    # Convert BTC to wei (assuming 1 BTC = 10^18 wei)
    amount_wei = int(amount * 10**18)
    
    try:
        # Send transaction
        tx_hash = vault_contract.functions.deposit(amount_wei).transact()
        receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        
        click.echo(f"Successfully deposited {amount} BTC")
        click.echo(f"Transaction hash: {tx_hash.hex()}")
        click.echo(f"Block number: {receipt.blockNumber}")
    except Exception as e:
        click.echo(f"Error: {str(e)}")

@cli.command()
@click.option('--rpc-url', default='http://localhost:8545', help='RPC URL for Ethereum node')
@click.option('--private-key', required=True, help='Private key for transactions')
@click.option('--vault-address', required=True, help='BTC Vault contract address')
@click.option('--amount', type=float, required=True, help='Amount to withdraw (BTC)')
def withdraw(rpc_url, private_key, vault_address, amount):
    """Withdraw BTC from a vault"""
    # Connect to Ethereum node
    w3 = Web3(Web3.HTTPProvider(rpc_url))
    
    # Set up account
    account = Account.from_key(private_key)
    w3.eth.default_account = account.address
    
    # Load vault ABI (simplified)
    vault_abi = [
        {
            "constant": False,
            "inputs": [{"name": "amount", "type": "uint256"}],
            "name": "withdraw",
            "outputs": [],
            "payable": False,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": True,
            "inputs": [{"name": "account", "type": "address"}],
            "name": "balanceOf",
            "outputs": [{"name": "", "type": "uint256"}],
            "payable": False,
            "stateMutability": "view",
            "type": "function"
        }
    ]
    
    # Create contract instance
    vault_contract = w3.eth.contract(address=vault_address, abi=vault_abi)
    
    # Convert BTC to wei
    amount_wei = int(amount * 10**18)
    
    try:
        # Send transaction
        tx_hash = vault_contract.functions.withdraw(amount_wei).transact()
        receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        
        click.echo(f"Successfully withdrew {amount} BTC")
        click.echo(f"Transaction hash: {tx_hash.hex()}")
        click.echo(f"Block number: {receipt.blockNumber}")
    except Exception as e:
        click.echo(f"Error: {str(e)}")

@cli.command()
@click.option('--rpc-url', default='http://localhost:8545', help='RPC URL for Ethereum node')
@click.option('--vault-address', required=True, help='BTC Vault contract address')
def balance(rpc_url, vault_address):
    """Check vault balance"""
    # Connect to Ethereum node
    w3 = Web3(Web3.HTTPProvider(rpc_url))
    
    # Load vault ABI (simplified)
    vault_abi = [
        {
            "constant": True,
            "inputs": [{"name": "account", "type": "address"}],
            "name": "balanceOf",
            "outputs": [{"name": "", "type": "uint256"}],
            "payable": False,
            "stateMutability": "view",
            "type": "function"
        }
    ]
    
    # Create contract instance
    vault_contract = w3.eth.contract(address=vault_address, abi=vault_abi)
    
    try:
        # Get balance
        balance_wei = vault_contract.functions.balanceOf(w3.eth.default_account).call()
        balance_btc = balance_wei / 10**18
        
        click.echo(f"Vault balance: {balance_btc} BTC")
    except Exception as e:
        click.echo(f"Error: {str(e)}")

@cli.command()
@click.option('--rpc-url', default='http://localhost:8545', help='RPC URL for Ethereum node')
@click.option('--private-key', required=True, help='Private key for transactions')
@click.option('--factory-address', required=True, help='BTC Vault Factory contract address')
@click.option('--bank-account', required=True, help='Bank account address to be injected')
def set_bank_account(rpc_url, private_key, factory_address, bank_account):
    """Set the bank account address on the factory"""
    # Connect to Ethereum node
    w3 = Web3(Web3.HTTPProvider(rpc_url))
    
    # Set up account
    account = Account.from_key(private_key)
    w3.eth.default_account = account.address
    
    # Load factory ABI (simplified)
    factory_abi = [
        {
            "constant": False,
            "inputs": [{"name": "_bankAccount", "type": "address"}],
            "name": "setBankAccount",
            "outputs": [],
            "payable": False,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": True,
            "inputs": [],
            "name": "bankAccount",
            "outputs": [{"name": "", "type": "address"}],
            "payable": False,
            "stateMutability": "view",
            "type": "function"
        }
    ]
    
    # Create factory contract instance
    factory_contract = w3.eth.contract(address=factory_address, abi=factory_abi)
    
    try:
        # Send transaction to set bank account
        tx_hash = factory_contract.functions.setBankAccount(bank_account).transact()
        receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        
        click.echo(f"Successfully set bank account to {bank_account}")
        click.echo(f"Transaction hash: {tx_hash.hex()}")
        click.echo(f"Block number: {receipt.blockNumber}")
    except Exception as e:
        click.echo(f"Error: {str(e)}")

@cli.command()
@click.option('--rpc-url', default='http://localhost:8545', help='RPC URL for Ethereum node')
@click.option('--private-key', required=True, help='Private key for transactions')
@click.option('--factory-address', required=True, help='BTC Vault Factory contract address')
@click.option('--owners', required=True, help='Comma-separated list of owner addresses')
@click.option('--roles', required=True, help='Comma-separated list of roles (Client,Custodian,Bank)')
@click.option('--threshold', type=int, required=True, help='Minimum number of signatures required')
def create_vault(rpc_url, private_key, factory_address, owners, roles, threshold):
    """Create a new BTC vault with bank account injected"""
    # Connect to Ethereum node
    w3 = Web3(Web3.HTTPProvider(rpc_url))
    
    # Set up account
    account = Account.from_key(private_key)
    w3.eth.default_account = account.address
    
    # Parse owners and roles
    owner_list = [addr.strip() for addr in owners.split(',')]
    role_list = [role.strip() for role in roles.split(',')]
    
    # Load factory ABI (simplified)
    factory_abi = [
        {
            "constant": False,
            "inputs": [
                {"name": "_owners", "type": "address[]"},
                {"name": "_roles", "type": "uint8[]"},  # Note: This needs to be updated to match actual enum types
                {"name": "_minSignatures", "type": "uint256"}
            ],
            "name": "createVault",
            "outputs": [{"name": "vault", "type": "address"}],
            "payable": False,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": True,
            "inputs": [],
            "name": "bankAccount",
            "outputs": [{"name": "", "type": "address"}],
            "payable": False,
            "stateMutability": "view",
            "type": "function"
        }
    ]
    
    # Create factory contract instance
    factory_contract = w3.eth.contract(address=factory_address, abi=factory_abi)
    
    try:
        # Convert roles to numeric values (this is simplified - in reality this would need proper enum handling)
        # For now, we'll convert to integers assuming Client=0, Custodian=1, Bank=2
        role_values = []
        for role in role_list:
            if role.lower() == "client":
                role_values.append(0)
            elif role.lower() == "custodian":
                role_values.append(1)
            elif role.lower() == "bank":
                role_values.append(2)
            else:
                raise ValueError(f"Unknown role: {role}")
        
        # Send transaction to create vault
        tx_hash = factory_contract.functions.createVault(
            owner_list,
            role_values,
            threshold
        ).transact()
        receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        
        # Get the created vault address from logs or events
        # Note: In a real implementation, you'd parse the event logs
        click.echo(f"Successfully created new BTC vault")
        click.echo(f"Transaction hash: {tx_hash.hex()}")
        click.echo(f"Block number: {receipt.blockNumber}")
        
        # Note: This would require parsing the event logs to get the vault address
        # For now, we just tell the user to check the transaction receipt
        click.echo("Check the transaction receipt for the new vault address")
        
    except Exception as e:
        click.echo(f"Error: {str(e)}")

if __name__ == '__main__':
    cli()