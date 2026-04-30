"""Tests for BTCVault -- Mezo mUSD integration (borrow, repay, close trove)."""

import pytest
from web3 import Web3
from conftest import ONE_BTC, VAULT_ART, _deploy, ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN


class TestConfigureMezo:
    def test_configure_mezo_by_deployer(self, vault, deployer, mezo_addresses):
        vault.functions.configureMezo(*mezo_addresses).transact({"from": deployer})
        assert vault.functions.mezoConfigured().call() is True

    def test_configure_mezo_by_owner(self, w3, deployer, client, bank, custodian, mezo_addresses):
        v = _deploy(w3, VAULT_ART, sender=deployer)
        v.functions.initialize(
            [client, bank, custodian],
            [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN],
            2,
        ).transact({"from": deployer})
        # Owner (client) should also be allowed
        v.functions.configureMezo(*mezo_addresses).transact({"from": client})
        assert v.functions.mezoConfigured().call() is True

    def test_cannot_configure_twice(self, vault_with_mezo, deployer, mezo_addresses):
        with pytest.raises(Exception):
            vault_with_mezo.functions.configureMezo(*mezo_addresses).transact(
                {"from": deployer}
            )

    def test_outsider_cannot_configure(self, vault, outsider, mezo_addresses):
        with pytest.raises(Exception):
            vault.functions.configureMezo(*mezo_addresses).transact(
                {"from": outsider}
            )

    def test_configure_zero_address_reverts(self, vault, deployer, mezo_addresses):
        zero = "0x0000000000000000000000000000000000000000"
        bad = list(mezo_addresses)
        bad[0] = zero  # zero borrowerOps
        with pytest.raises(Exception):
            vault.functions.configureMezo(*bad).transact({"from": deployer})


class TestBorrowMUSD:
    def test_borrow_opens_trove(self, funded_vault, client, mock_musd):
        collateral = ONE_BTC * 2
        debt = Web3.to_wei(30000, "ether")  # 30k mUSD

        funded_vault.functions.borrowMUSD(collateral, debt).transact({"from": client})

        assert funded_vault.functions.hasTrove().call() is True
        # Vault should now hold mUSD
        musd_bal = mock_musd.functions.balanceOf(funded_vault.address).call()
        assert musd_bal == debt

    def test_borrow_reduces_vault_balance(self, funded_vault, client):
        bal_before = funded_vault.functions.vaultBalance().call()
        collateral = ONE_BTC * 2
        debt = Web3.to_wei(30000, "ether")

        funded_vault.functions.borrowMUSD(collateral, debt).transact({"from": client})

        bal_after = funded_vault.functions.vaultBalance().call()
        assert bal_before - bal_after == collateral

    def test_cannot_borrow_without_mezo_config(self, vault, client):
        vault.functions.deposit().transact({"from": client, "value": ONE_BTC * 5})
        with pytest.raises(Exception):
            vault.functions.borrowMUSD(ONE_BTC, Web3.to_wei(1000, "ether")).transact(
                {"from": client}
            )

    def test_cannot_borrow_zero_collateral(self, funded_vault, client):
        with pytest.raises(Exception):
            funded_vault.functions.borrowMUSD(
                0, Web3.to_wei(1000, "ether")
            ).transact({"from": client})

    def test_cannot_borrow_zero_debt(self, funded_vault, client):
        with pytest.raises(Exception):
            funded_vault.functions.borrowMUSD(ONE_BTC, 0).transact({"from": client})

    def test_cannot_borrow_insufficient_balance(self, funded_vault, client):
        huge = ONE_BTC * 1000  # vault only has 10 BTC
        with pytest.raises(Exception):
            funded_vault.functions.borrowMUSD(
                huge, Web3.to_wei(1000, "ether")
            ).transact({"from": client})

    def test_cannot_open_second_trove(self, funded_vault, client):
        funded_vault.functions.borrowMUSD(
            ONE_BTC, Web3.to_wei(1000, "ether")
        ).transact({"from": client})
        with pytest.raises(Exception):
            funded_vault.functions.borrowMUSD(
                ONE_BTC, Web3.to_wei(1000, "ether")
            ).transact({"from": client})

    def test_non_owner_cannot_borrow(self, funded_vault, outsider):
        with pytest.raises(Exception):
            funded_vault.functions.borrowMUSD(
                ONE_BTC, Web3.to_wei(1000, "ether")
            ).transact({"from": outsider})


class TestRepayMUSD:
    def _open_trove(self, vault, client):
        """Helper: borrow so the vault has a trove + mUSD."""
        collateral = ONE_BTC * 3
        debt = Web3.to_wei(30000, "ether")
        vault.functions.borrowMUSD(collateral, debt).transact({"from": client})
        return debt

    def test_repay_reduces_debt(self, funded_vault, w3, client, mock_musd):
        debt = self._open_trove(funded_vault, client)
        repay_amount = Web3.to_wei(10000, "ether")

        # The vault needs to approve BorrowerOps to pull mUSD.
        # repayMUSD does safeIncreaseAllowance internally, so just call it.
        funded_vault.functions.repayMUSD(repay_amount).transact({"from": client})

        new_debt = funded_vault.functions.troveDebt().call()
        # MockTroveManager records totalDebt = debt + fee + gasComp
        # After repay, debt should decrease by repay_amount
        assert new_debt < (debt + Web3.to_wei(200, "ether"))  # less than original total

    def test_cannot_repay_without_trove(self, funded_vault, client):
        # No trove opened
        with pytest.raises(Exception):
            funded_vault.functions.repayMUSD(
                Web3.to_wei(1000, "ether")
            ).transact({"from": client})

    def test_cannot_repay_zero(self, funded_vault, client):
        self._open_trove(funded_vault, client)
        with pytest.raises(Exception):
            funded_vault.functions.repayMUSD(0).transact({"from": client})

    def test_non_owner_cannot_repay(self, funded_vault, client, outsider):
        self._open_trove(funded_vault, client)
        with pytest.raises(Exception):
            funded_vault.functions.repayMUSD(
                Web3.to_wei(1000, "ether")
            ).transact({"from": outsider})


class TestCloseTrove:
    def _open_trove(self, vault, client):
        collateral = ONE_BTC * 3
        debt = Web3.to_wei(30000, "ether")
        vault.functions.borrowMUSD(collateral, debt).transact({"from": client})
        return debt

    def test_close_trove_returns_collateral(self, funded_vault, w3, client, mock_musd):
        self._open_trove(funded_vault, client)

        bal_before = funded_vault.functions.vaultBalance().call()

        # Mint enough mUSD to cover gas compensation (mock needs it)
        # The vault already has 30k mUSD from borrowing; closeTrove needs
        # to repay totalDebt - gasComp. Mock gasComp = 200 mUSD.
        # totalDebt = 30000 + fee(30) + gasComp(200) = 30230
        # repayable = 30230 - 200 = 30030
        # We have 30000, need 30 more for fee
        mock_musd.functions.mint(
            funded_vault.address, Web3.to_wei(1000, "ether")
        ).transact({"from": w3.eth.accounts[0]})

        funded_vault.functions.closeTrove().transact({"from": client})

        assert funded_vault.functions.hasTrove().call() is False
        bal_after = funded_vault.functions.vaultBalance().call()
        assert bal_after > bal_before  # collateral returned

    def test_cannot_close_without_trove(self, funded_vault, client):
        with pytest.raises(Exception):
            funded_vault.functions.closeTrove().transact({"from": client})

    def test_non_owner_cannot_close(self, funded_vault, client, outsider):
        self._open_trove(funded_vault, client)
        with pytest.raises(Exception):
            funded_vault.functions.closeTrove().transact({"from": outsider})


class TestMezoViews:
    def test_trove_debt_zero_without_config(self, vault):
        assert vault.functions.troveDebt().call() == 0

    def test_trove_collateral_zero_without_config(self, vault):
        assert vault.functions.troveCollateral().call() == 0

    def test_has_trove_false_without_config(self, vault):
        assert vault.functions.hasTrove().call() is False

    def test_musd_balance_zero_without_config(self, vault):
        assert vault.functions.musdBalance().call() == 0
