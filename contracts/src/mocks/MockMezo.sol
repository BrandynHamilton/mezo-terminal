// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MockMUSD.sol";

/**
 * @title MockBorrowerOperations
 * @notice Simulates Mezo's BorrowerOperations for local testing.
 *         openTrove accepts BTC (msg.value) and mints mock mUSD to the caller.
 *         closeTrove burns mUSD from the caller and returns BTC.
 *         repayMUSD burns mUSD from the caller.
 */
contract MockBorrowerOperations {
    MockMUSD public musd;
    MockTroveManager public troveManagerRef;

    uint256 public constant BORROWING_RATE = 1; // 0.1% = 1/1000

    constructor(address _musd, address _troveManager) {
        musd = MockMUSD(_musd);
        troveManagerRef = MockTroveManager(_troveManager);
    }

    function getBorrowingFee(uint256 _MUSDAmount) external pure returns (uint256) {
        return (_MUSDAmount * BORROWING_RATE) / 1000;
    }

    function openTrove(
        uint256 _MUSDAmount,
        address, /* _upperHint */
        address  /* _lowerHint */
    ) external payable {
        require(msg.value > 0, "No collateral");
        require(_MUSDAmount > 0, "No debt");

        // Record trove in mock TroveManager
        uint256 fee = (_MUSDAmount * BORROWING_RATE) / 1000;
        uint256 gasComp = troveManagerRef.MUSD_GAS_COMPENSATION();
        uint256 totalDebt = _MUSDAmount + fee + gasComp;

        troveManagerRef.setTrove(msg.sender, msg.value, totalDebt);

        // Mint mUSD to the borrower (the vault contract)
        musd.mint(msg.sender, _MUSDAmount);
    }

    function addColl(address, address) external payable {
        require(msg.value > 0, "No collateral");
        (uint256 coll, uint256 debt) = troveManagerRef.getTrove(msg.sender);
        troveManagerRef.setTrove(msg.sender, coll + msg.value, debt);
    }

    function withdrawColl(uint256 _amount, address, address) external {
        (uint256 coll, uint256 debt) = troveManagerRef.getTrove(msg.sender);
        require(coll >= _amount, "Not enough coll");
        troveManagerRef.setTrove(msg.sender, coll - _amount, debt);
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Transfer failed");
    }

    function repayMUSD(uint256 _amount, address, address) external {
        (uint256 coll, uint256 debt) = troveManagerRef.getTrove(msg.sender);
        require(debt >= _amount, "Repay exceeds debt");
        // Burn mUSD from the caller
        // In real Mezo, BorrowerOps pulls mUSD. Here we just burn from caller.
        musd.transferFrom(msg.sender, address(this), _amount);
        troveManagerRef.setTrove(msg.sender, coll, debt - _amount);
    }

    function closeTrove() external {
        (uint256 coll, uint256 debt) = troveManagerRef.getTrove(msg.sender);
        uint256 gasComp = troveManagerRef.MUSD_GAS_COMPENSATION();
        uint256 repayable = debt > gasComp ? debt - gasComp : debt;

        // Pull mUSD to cover debt
        if (repayable > 0) {
            musd.transferFrom(msg.sender, address(this), repayable);
        }

        // Close the trove
        troveManagerRef.closeTrove(msg.sender);

        // Return collateral
        if (coll > 0) {
            (bool sent, ) = msg.sender.call{value: coll}("");
            require(sent, "Transfer failed");
        }
    }

    receive() external payable {}
}

/**
 * @title MockTroveManager
 * @notice Tracks trove state for testing.
 */
contract MockTroveManager {
    uint256 public constant MUSD_GAS_COMPENSATION = 200e18; // 200 mUSD

    struct Trove {
        uint256 coll;
        uint256 debt;
        uint256 status; // 0 = nonexistent, 1 = active, 2 = closedByOwner
    }

    mapping(address => Trove) public troves;

    function setTrove(address _borrower, uint256 _coll, uint256 _debt) external {
        troves[_borrower] = Trove(_coll, _debt, 1);
    }

    function closeTrove(address _borrower) external {
        troves[_borrower].status = 2;
        troves[_borrower].coll = 0;
        troves[_borrower].debt = 0;
    }

    function getTroveDebt(address _borrower) external view returns (uint256) {
        return troves[_borrower].debt;
    }

    function getTroveColl(address _borrower) external view returns (uint256) {
        return troves[_borrower].coll;
    }

    function getTroveStatus(address _borrower) external view returns (uint256) {
        return troves[_borrower].status;
    }

    function getTrove(address _borrower) external view returns (uint256 coll, uint256 debt) {
        Trove storage t = troves[_borrower];
        return (t.coll, t.debt);
    }
}

/**
 * @title MockSortedTroves
 * @notice Returns dummy hints -- sufficient for testing.
 */
contract MockSortedTroves {
    function findInsertPosition(
        uint256, /* _NICR */
        address, /* _prevId */
        address  /* _nextId */
    ) external pure returns (address, address) {
        return (address(0), address(0));
    }
}

/**
 * @title MockHintHelpers
 * @notice Returns dummy hints -- sufficient for testing.
 */
contract MockHintHelpers {
    function getApproxHint(
        uint256, /* _CR */
        uint256, /* _numTrials */
        uint256  /* _inputRandomSeed */
    ) external pure returns (address, uint256, uint256) {
        return (address(0), 0, 0);
    }
}
