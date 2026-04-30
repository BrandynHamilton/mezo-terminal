"""Tests for BTCVault -- initialization, deposit, proposal lifecycle, access control."""

import pytest
from web3 import Web3
from conftest import (
    VAULT_ART,
    ROLE_CLIENT,
    ROLE_BANK,
    ROLE_CUSTODIAN,
    ONE_BTC,
    _deploy,
)

# ======================================================================
#  Initialization
# ======================================================================


class TestInitialization:
    def test_initialize_sets_owners(self, vault, client, bank, custodian):
        owners = vault.functions.getOwners().call()
        assert set(owners) == {client, bank, custodian}

    def test_initialize_sets_threshold(self, vault):
        assert vault.functions.requiredSignatures().call() == 2

    def test_initialize_sets_roles(self, vault, client, bank, custodian):
        assert vault.functions.getRole(client).call() == ROLE_CLIENT
        assert vault.functions.getRole(bank).call() == ROLE_BANK
        assert vault.functions.getRole(custodian).call() == ROLE_CUSTODIAN

    def test_initialize_sets_owner_count(self, vault):
        assert vault.functions.ownerCount().call() == 3

    def test_initialized_flag(self, vault):
        assert vault.functions.initialized().call() is True

    def test_cannot_initialize_twice(self, vault, deployer, client, bank, custodian):
        with pytest.raises(Exception):
            vault.functions.initialize(
                [client, bank, custodian],
                [ROLE_CLIENT, ROLE_BANK, ROLE_CUSTODIAN],
                2,
            ).transact({"from": deployer})

    def test_cannot_initialize_zero_owners(self, w3, deployer):
        v = _deploy(w3, VAULT_ART, sender=deployer)
        with pytest.raises(Exception):
            v.functions.initialize([], [], 1).transact({"from": deployer})

    def test_cannot_initialize_threshold_zero(self, w3, deployer, client):
        v = _deploy(w3, VAULT_ART, sender=deployer)
        with pytest.raises(Exception):
            v.functions.initialize([client], [ROLE_CLIENT], 0).transact(
                {"from": deployer}
            )

    def test_cannot_initialize_threshold_exceeds_owners(self, w3, deployer, client):
        v = _deploy(w3, VAULT_ART, sender=deployer)
        with pytest.raises(Exception):
            v.functions.initialize([client], [ROLE_CLIENT], 5).transact(
                {"from": deployer}
            )

    def test_cannot_initialize_duplicate_owners(self, w3, deployer, client):
        v = _deploy(w3, VAULT_ART, sender=deployer)
        with pytest.raises(Exception):
            v.functions.initialize(
                [client, client], [ROLE_CLIENT, ROLE_CLIENT], 1
            ).transact({"from": deployer})

    def test_cannot_initialize_zero_address_owner(self, w3, deployer):
        zero = "0x0000000000000000000000000000000000000000"
        v = _deploy(w3, VAULT_ART, sender=deployer)
        with pytest.raises(Exception):
            v.functions.initialize([zero], [ROLE_CLIENT], 1).transact(
                {"from": deployer}
            )

    def test_non_deployer_cannot_initialize(self, w3, deployer, client, outsider):
        v = _deploy(w3, VAULT_ART, sender=deployer)
        with pytest.raises(Exception):
            v.functions.initialize([client], [ROLE_CLIENT], 1).transact(
                {"from": outsider}
            )


# ======================================================================
#  Deposits
# ======================================================================


class TestDeposit:
    def test_deposit_via_function(self, vault, w3, client):
        vault.functions.deposit().transact({"from": client, "value": ONE_BTC})
        assert vault.functions.vaultBalance().call() == ONE_BTC

    def test_deposit_via_receive(self, vault, w3, client):
        w3.eth.send_transaction({
            "from": client,
            "to": vault.address,
            "value": ONE_BTC * 2,
        })
        assert vault.functions.vaultBalance().call() == ONE_BTC * 2

    def test_deposit_zero_reverts(self, vault, client):
        with pytest.raises(Exception):
            vault.functions.deposit().transact({"from": client, "value": 0})

    def test_anyone_can_deposit(self, vault, outsider):
        vault.functions.deposit().transact({"from": outsider, "value": ONE_BTC})
        assert vault.functions.vaultBalance().call() >= ONE_BTC


# ======================================================================
#  Propose
# ======================================================================


class TestPropose:
    def test_propose_creates_proposal(self, vault, client, recipient):
        tx = vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        receipt = Web3().eth.get_transaction_receipt  # not needed, just check state
        prop = vault.functions.getProposal(0).call()
        to, amount, sigs, executed, cancelled, created_at = prop
        assert to == recipient
        assert amount == ONE_BTC
        assert sigs == []
        assert executed is False
        assert cancelled is False
        assert created_at > 0

    def test_propose_increments_id(self, vault, client, recipient):
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.propose(recipient, ONE_BTC * 2).transact({"from": client})
        assert vault.functions.nextProposalId().call() == 2
        assert vault.functions.getProposal(1).call()[1] == ONE_BTC * 2

    def test_non_owner_cannot_propose(self, vault, outsider, recipient):
        with pytest.raises(Exception):
            vault.functions.propose(recipient, ONE_BTC).transact({"from": outsider})

    def test_propose_zero_address_reverts(self, vault, client):
        zero = "0x0000000000000000000000000000000000000000"
        with pytest.raises(Exception):
            vault.functions.propose(zero, ONE_BTC).transact({"from": client})

    def test_propose_zero_amount_reverts(self, vault, client, recipient):
        with pytest.raises(Exception):
            vault.functions.propose(recipient, 0).transact({"from": client})


# ======================================================================
#  Approve
# ======================================================================


class TestApprove:
    def test_approve_records_signature(self, vault, client, bank, recipient):
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.approve(0).transact({"from": client})
        assert vault.functions.getSignatureCount(0).call() == 1
        assert vault.functions.hasSigned(0, client).call() is True

    def test_multiple_approvals(self, vault, client, bank, recipient):
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.approve(0).transact({"from": client})
        vault.functions.approve(0).transact({"from": bank})
        assert vault.functions.getSignatureCount(0).call() == 2
        assert vault.functions.isApproved(0).call() is True

    def test_cannot_approve_twice(self, vault, client, recipient):
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.approve(0).transact({"from": client})
        with pytest.raises(Exception):
            vault.functions.approve(0).transact({"from": client})

    def test_cannot_approve_nonexistent(self, vault, client):
        with pytest.raises(Exception):
            vault.functions.approve(999).transact({"from": client})

    def test_non_owner_cannot_approve(self, vault, client, outsider, recipient):
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        with pytest.raises(Exception):
            vault.functions.approve(0).transact({"from": outsider})


# ======================================================================
#  Execute
# ======================================================================


class TestExecute:
    def test_execute_transfers_btc(self, vault, w3, client, bank, recipient):
        # Fund vault
        vault.functions.deposit().transact({"from": client, "value": ONE_BTC * 5})

        # Propose + approve (2 of 3)
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.approve(0).transact({"from": client})
        vault.functions.approve(0).transact({"from": bank})

        bal_before = w3.eth.get_balance(recipient)
        vault.functions.execute(0).transact({"from": client})
        bal_after = w3.eth.get_balance(recipient)

        assert bal_after - bal_before == ONE_BTC

    def test_execute_marks_executed(self, vault, w3, client, bank, recipient):
        vault.functions.deposit().transact({"from": client, "value": ONE_BTC * 5})
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.approve(0).transact({"from": client})
        vault.functions.approve(0).transact({"from": bank})
        vault.functions.execute(0).transact({"from": client})

        prop = vault.functions.getProposal(0).call()
        assert prop[3] is True  # executed

    def test_cannot_execute_twice(self, vault, w3, client, bank, recipient):
        vault.functions.deposit().transact({"from": client, "value": ONE_BTC * 5})
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.approve(0).transact({"from": client})
        vault.functions.approve(0).transact({"from": bank})
        vault.functions.execute(0).transact({"from": client})

        with pytest.raises(Exception):
            vault.functions.execute(0).transact({"from": client})

    def test_cannot_execute_below_threshold(self, vault, w3, client, recipient):
        vault.functions.deposit().transact({"from": client, "value": ONE_BTC * 5})
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.approve(0).transact({"from": client})  # only 1 of 2

        with pytest.raises(Exception):
            vault.functions.execute(0).transact({"from": client})

    def test_cannot_execute_insufficient_balance(self, vault, client, bank, recipient):
        # No deposit -- vault is empty
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.approve(0).transact({"from": client})
        vault.functions.approve(0).transact({"from": bank})

        with pytest.raises(Exception):
            vault.functions.execute(0).transact({"from": client})

    def test_non_owner_cannot_execute(self, vault, w3, client, bank, outsider, recipient):
        vault.functions.deposit().transact({"from": client, "value": ONE_BTC * 5})
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.approve(0).transact({"from": client})
        vault.functions.approve(0).transact({"from": bank})

        with pytest.raises(Exception):
            vault.functions.execute(0).transact({"from": outsider})


# ======================================================================
#  Cancel
# ======================================================================


class TestCancel:
    def test_cancel_marks_cancelled(self, vault, client, recipient):
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.cancel(0).transact({"from": client})
        prop = vault.functions.getProposal(0).call()
        assert prop[4] is True  # cancelled

    def test_cannot_approve_cancelled(self, vault, client, bank, recipient):
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.cancel(0).transact({"from": client})
        with pytest.raises(Exception):
            vault.functions.approve(0).transact({"from": bank})

    def test_cannot_execute_cancelled(self, vault, client, bank, recipient):
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.approve(0).transact({"from": client})
        vault.functions.approve(0).transact({"from": bank})
        vault.functions.cancel(0).transact({"from": client})
        with pytest.raises(Exception):
            vault.functions.execute(0).transact({"from": client})

    def test_cannot_cancel_executed(self, vault, w3, client, bank, recipient):
        vault.functions.deposit().transact({"from": client, "value": ONE_BTC * 5})
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        vault.functions.approve(0).transact({"from": client})
        vault.functions.approve(0).transact({"from": bank})
        vault.functions.execute(0).transact({"from": client})
        with pytest.raises(Exception):
            vault.functions.cancel(0).transact({"from": client})

    def test_cannot_cancel_nonexistent(self, vault, client):
        with pytest.raises(Exception):
            vault.functions.cancel(999).transact({"from": client})

    def test_non_owner_cannot_cancel(self, vault, client, outsider, recipient):
        vault.functions.propose(recipient, ONE_BTC).transact({"from": client})
        with pytest.raises(Exception):
            vault.functions.cancel(0).transact({"from": outsider})
