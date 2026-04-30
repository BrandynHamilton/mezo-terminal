"""Tests for BTCVaultFactory -- deployment, tracking, views."""

import pytest
from web3 import Web3
from conftest import (
    FACTORY_ART,
    VAULT_ART,
    ROLE_CLIENT,
    ROLE_BANK,
    ROLE_CUSTODIAN,
    ONE_BTC,
    _deploy,
)


class TestFactoryCreateVault:
    def test_create_vault_returns_address(self, factory, w3, client, bank, custodian):
        owners = [client, bank, custodian]
        roles = [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN]

        tx = factory.functions.createVault(owners, roles, 2).transact(
            {"from": client}
        )
        receipt = w3.eth.get_transaction_receipt(tx)
        assert receipt["status"] == 1

        # Parse VaultCreated event
        events = factory.events.VaultCreated().process_receipt(receipt)
        assert len(events) == 1
        vault_addr = events[0]["args"]["vault"]
        assert vault_addr != "0x0000000000000000000000000000000000000000"

    def test_created_vault_is_initialized(self, factory, w3, client, bank, custodian):
        owners = [client, bank, custodian]
        roles = [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN]

        tx = factory.functions.createVault(owners, roles, 2).transact(
            {"from": client}
        )
        receipt = w3.eth.get_transaction_receipt(tx)
        vault_addr = factory.events.VaultCreated().process_receipt(receipt)[0]["args"]["vault"]

        vault = w3.eth.contract(address=vault_addr, abi=VAULT_ART["abi"])
        assert vault.functions.initialized().call() is True
        assert vault.functions.requiredSignatures().call() == 2
        assert vault.functions.ownerCount().call() == 3

    def test_created_vault_has_mezo_configured(self, factory, w3, client, bank, custodian):
        owners = [client, bank, custodian]
        roles = [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN]

        tx = factory.functions.createVault(owners, roles, 2).transact(
            {"from": client}
        )
        receipt = w3.eth.get_transaction_receipt(tx)
        vault_addr = factory.events.VaultCreated().process_receipt(receipt)[0]["args"]["vault"]

        vault = w3.eth.contract(address=vault_addr, abi=VAULT_ART["abi"])
        assert vault.functions.mezoConfigured().call() is True

    def test_created_vault_accepts_deposits(self, factory, w3, client, bank, custodian):
        owners = [client, bank, custodian]
        roles = [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN]

        tx = factory.functions.createVault(owners, roles, 2).transact(
            {"from": client}
        )
        receipt = w3.eth.get_transaction_receipt(tx)
        vault_addr = factory.events.VaultCreated().process_receipt(receipt)[0]["args"]["vault"]

        vault = w3.eth.contract(address=vault_addr, abi=VAULT_ART["abi"])
        vault.functions.deposit().transact({"from": client, "value": ONE_BTC})
        assert vault.functions.vaultBalance().call() == ONE_BTC


class TestFactoryTracking:
    def test_total_vaults(self, factory, client, bank, custodian):
        owners = [client, bank, custodian]
        roles = [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN]

        assert factory.functions.totalVaults().call() == 0
        factory.functions.createVault(owners, roles, 2).transact({"from": client})
        assert factory.functions.totalVaults().call() == 1
        factory.functions.createVault(owners, roles, 1).transact({"from": client})
        assert factory.functions.totalVaults().call() == 2

    def test_is_vault(self, factory, w3, client, bank, custodian):
        owners = [client, bank, custodian]
        roles = [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN]

        tx = factory.functions.createVault(owners, roles, 2).transact(
            {"from": client}
        )
        receipt = w3.eth.get_transaction_receipt(tx)
        vault_addr = factory.events.VaultCreated().process_receipt(receipt)[0]["args"]["vault"]

        assert factory.functions.isVault(vault_addr).call() is True
        assert factory.functions.isVault(client).call() is False

    def test_get_all_vaults(self, factory, w3, client, bank, custodian):
        owners = [client, bank, custodian]
        roles = [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN]

        factory.functions.createVault(owners, roles, 2).transact({"from": client})
        factory.functions.createVault(owners, roles, 1).transact({"from": client})

        all_vaults = factory.functions.getAllVaults().call()
        assert len(all_vaults) == 2

    def test_get_vaults_by_creator(self, factory, w3, client, bank, custodian):
        owners = [client, bank, custodian]
        roles = [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN]

        factory.functions.createVault(owners, roles, 2).transact({"from": client})
        factory.functions.createVault(owners, roles, 2).transact({"from": bank})

        client_vaults = factory.functions.getVaultsByCreator(client).call()
        bank_vaults = factory.functions.getVaultsByCreator(bank).call()
        assert len(client_vaults) == 1
        assert len(bank_vaults) == 1


class TestFactoryAdmin:
    def test_set_mezo_defaults(self, factory, deployer):
        zero = "0x0000000000000000000000000000000000000000"
        factory.functions.setMezoDefaults(
            zero, zero, zero, zero, zero
        ).transact({"from": deployer})
        assert factory.functions.defaultBorrowerOperations().call() == zero

    def test_non_admin_cannot_set_defaults(self, factory, outsider):
        zero = "0x0000000000000000000000000000000000000000"
        with pytest.raises(Exception):
            factory.functions.setMezoDefaults(
                zero, zero, zero, zero, zero
            ).transact({"from": outsider})

    def test_factory_without_mezo_skips_config(self, w3, deployer, client, bank, custodian):
        """If factory has zero addresses for Mezo, vaults are created without Mezo config."""
        zero = "0x0000000000000000000000000000000000000000"
        f = _deploy(
            w3,
            FACTORY_ART,
            constructor_args=[deployer, zero, zero, zero, zero, zero],
            sender=deployer,
        )
        owners = [client, bank, custodian]
        roles = [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN]
        tx = f.functions.createVault(owners, roles, 2).transact({"from": client})
        receipt = w3.eth.get_transaction_receipt(tx)
        vault_addr = f.events.VaultCreated().process_receipt(receipt)[0]["args"]["vault"]
        vault = w3.eth.contract(address=vault_addr, abi=VAULT_ART["abi"])

        assert vault.functions.initialized().call() is True
        assert vault.functions.mezoConfigured().call() is False
