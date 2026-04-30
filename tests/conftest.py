"""
Shared fixtures for BTCVault / BTCVaultFactory tests.

Uses web3.py's EthereumTesterProvider for a fast, in-process EVM.
Hardhat-compiled artifacts (JSON with abi + bytecode) are loaded from
the artifacts/ directory produced by `npx hardhat compile`.
"""

import json
import pathlib
import pytest
from web3 import Web3
from eth_account import Account

# ---------------------------------------------------------------------------
#  Paths
# ---------------------------------------------------------------------------

ROOT = pathlib.Path(__file__).resolve().parent.parent
ARTIFACTS = ROOT / "artifacts" / "contracts"


def _load_artifact(subpath: str) -> dict:
    """Load a Hardhat artifact JSON and return {abi, bytecode}."""
    path = ARTIFACTS / subpath
    raw = json.loads(path.read_text())
    return {"abi": raw["abi"], "bytecode": raw["bytecode"]}


# ---------------------------------------------------------------------------
#  Contract artifacts (loaded once)
# ---------------------------------------------------------------------------

VAULT_ART = _load_artifact("BTCVault.sol/BTCVault.json")
FACTORY_ART = _load_artifact("BTCVaultFactory.sol/BTCVaultFactory.json")
MOCK_MUSD_ART = _load_artifact("mocks/MockMUSD.sol/MockMUSD.json")
MOCK_TROVE_MGR_ART = _load_artifact("mocks/MockMezo.sol/MockTroveManager.json")
MOCK_BORROWER_OPS_ART = _load_artifact("mocks/MockMezo.sol/MockBorrowerOperations.json")
MOCK_SORTED_ART = _load_artifact("mocks/MockMezo.sol/MockSortedTroves.json")
MOCK_HINTS_ART = _load_artifact("mocks/MockMezo.sol/MockHintHelpers.json")

# ---------------------------------------------------------------------------
#  Roles enum (must match BTCVault.Role)
# ---------------------------------------------------------------------------

ROLE_CLIENT = 0
ROLE_CUSTODIAN = 1
ROLE_BANK = 2

# ---------------------------------------------------------------------------
#  Helpers
# ---------------------------------------------------------------------------

ONE_BTC = Web3.to_wei(1, "ether")  # 1e18 -- same decimals as Mezo BTC


def _deploy(w3, art, constructor_args=None, sender=None, value=0):
    """Deploy a contract and return the contract instance."""
    if sender is None:
        sender = w3.eth.accounts[0]
    contract = w3.eth.contract(abi=art["abi"], bytecode=art["bytecode"])
    args = constructor_args or []
    tx_hash = contract.constructor(*args).transact({"from": sender, "value": value})
    receipt = w3.eth.get_transaction_receipt(tx_hash)
    assert receipt["status"] == 1, "deploy failed"
    return w3.eth.contract(address=receipt["contractAddress"], abi=art["abi"])


# ---------------------------------------------------------------------------
#  Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture(scope="session")
def w3():
    """In-process EVM via EthereumTesterProvider."""
    from web3 import EthereumTesterProvider
    provider = EthereumTesterProvider()
    _w3 = Web3(provider)
    # Fund all default accounts generously (they already start with 1M ETH)
    return _w3


@pytest.fixture(scope="session")
def accounts(w3):
    """Return the default test accounts."""
    return w3.eth.accounts


@pytest.fixture(scope="session")
def deployer(accounts):
    return accounts[0]


@pytest.fixture(scope="session")
def client(accounts):
    return accounts[1]


@pytest.fixture(scope="session")
def bank(accounts):
    return accounts[2]


@pytest.fixture(scope="session")
def custodian(accounts):
    return accounts[3]


@pytest.fixture(scope="session")
def outsider(accounts):
    """An address that is NOT an owner."""
    return accounts[4]


@pytest.fixture(scope="session")
def recipient(accounts):
    return accounts[5]


# --- Mock Mezo contracts (session-scoped, deployed once) ---

@pytest.fixture(scope="session")
def mock_musd(w3, deployer):
    return _deploy(w3, MOCK_MUSD_ART, sender=deployer)


@pytest.fixture(scope="session")
def mock_trove_manager(w3, deployer):
    return _deploy(w3, MOCK_TROVE_MGR_ART, sender=deployer)


@pytest.fixture(scope="session")
def mock_sorted_troves(w3, deployer):
    return _deploy(w3, MOCK_SORTED_ART, sender=deployer)


@pytest.fixture(scope="session")
def mock_hint_helpers(w3, deployer):
    return _deploy(w3, MOCK_HINTS_ART, sender=deployer)


@pytest.fixture(scope="session")
def mock_borrower_ops(w3, deployer, mock_musd, mock_trove_manager):
    return _deploy(
        w3,
        MOCK_BORROWER_OPS_ART,
        constructor_args=[mock_musd.address, mock_trove_manager.address],
        sender=deployer,
    )


@pytest.fixture(scope="session")
def mezo_addresses(mock_borrower_ops, mock_trove_manager, mock_sorted_troves, mock_hint_helpers, mock_musd):
    """Tuple of all 5 Mezo mock addresses, in configureMezo() order."""
    return (
        mock_borrower_ops.address,
        mock_trove_manager.address,
        mock_sorted_troves.address,
        mock_hint_helpers.address,
        mock_musd.address,
    )


# --- BTCVault (fresh per test function) ---

@pytest.fixture()
def vault(w3, deployer, client, bank, custodian):
    """Deploy + initialize a 2-of-3 BTCVault (client, bank, custodian)."""
    v = _deploy(w3, VAULT_ART, sender=deployer)
    owners = [client, bank, custodian]
    roles = [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN]
    v.functions.initialize(owners, roles, 2).transact({"from": deployer})
    return v


@pytest.fixture()
def vault_with_mezo(vault, w3, deployer, mezo_addresses):
    """A vault that already has Mezo contracts configured."""
    vault.functions.configureMezo(*mezo_addresses).transact({"from": deployer})
    return vault


@pytest.fixture()
def funded_vault(vault_with_mezo, w3, client):
    """A vault with Mezo configured + 10 BTC deposited."""
    w3.eth.send_transaction({
        "from": client,
        "to": vault_with_mezo.address,
        "value": ONE_BTC * 10,
    })
    return vault_with_mezo


# --- BTCVaultFactory ---

@pytest.fixture()
def factory(w3, deployer, mezo_addresses):
    """Deploy a factory with mock Mezo defaults."""
    return _deploy(
        w3,
        FACTORY_ART,
        constructor_args=[deployer, *mezo_addresses],
        sender=deployer,
    )
