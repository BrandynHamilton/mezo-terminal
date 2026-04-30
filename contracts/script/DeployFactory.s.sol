// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BTCVaultFactory.sol";
import "../src/BTCVault.sol";

/**
 * @title DeployFactory
 * @notice Deploy BTCVaultFactory with real MUSD protocol addresses.
 *
 * The MUSD protocol is a Bitcoin-backed stablecoin system based on Liquity/Threshold USD.
 * Key concepts:
 *   - Trove: A collateralized debt position (CDP) with BTC collateral
 *   - NICR: Nominal Individual Collateral Ratio (used for sorted trove insertion)
 *   - Hints: Gas optimization - suggest trove's position in sorted list
 *   - Gas Compensation: 200 mUSD kept per trove as insurance
 *   - Borrowing Fee: 0.1% (governable) added as debt
 *
 * Integration flow:
 *   1. Get hints via HintHelpers.getApproxHint() using NICR
 *   2. Find exact position via SortedTroves.findInsertPosition()
 *   3. Call BorrowerOperations.openTrove() with hints
 *   4. Trove is tracked by TroveManager
 *
 * Usage:
 *   Testnet:
 *     forge script script/DeployFactory.s.sol --rpc-url $MEZO_TESTNET_RPC --private-key $PRIVATE_KEY --broadcast
 *
 *   Mainnet:
 *     forge script script/DeployFactory.s.sol --rpc-url $MEZO_MAINNET_RPC --private-key $PRIVATE_KEY --broadcast
 *
 * Environment variables (from .env):
 *   ADMIN_ADDRESS              Address that can update MUSD contract defaults
 *   BANK_ACCOUNT               Bank account address to inject into vaults
 *   BORROWER_OPERATIONS        MUSD BorrowerOperations contract (core borrowing)
 *   TROVE_MANAGER              MUSD TroveManager contract (trove state tracking)
 *   SORTED_TROVES              MUSD SortedTroves contract (sorted trove list)
 *   HINT_HELPERS               MUSD HintHelpers contract (hint calculation)
 *   MUSD_TOKEN                 MUSD stablecoin token contract
 *
 * Reference:
 *   - MUSD Docs: https://mezo.org/docs/developers/musd/
 *   - GitHub: https://github.com/mezo-org/musd
 */
contract DeployFactory is Script {
    function run() external {
        // Load environment variables
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address bankAccount = vm.envAddress("BANK_ACCOUNT");
        address borrowerOps = vm.envAddress("BORROWER_OPERATIONS");
        address troveManager = vm.envAddress("TROVE_MANAGER");
        address sortedTroves = vm.envAddress("SORTED_TROVES");
        address hintHelpers = vm.envAddress("HINT_HELPERS");
        address musdToken = vm.envAddress("MUSD_TOKEN");

        require(admin != address(0), "ADMIN_ADDRESS not set");
        require(bankAccount != address(0), "BANK_ACCOUNT not set");
        require(borrowerOps != address(0), "BORROWER_OPERATIONS not set");
        require(troveManager != address(0), "TROVE_MANAGER not set");
        require(sortedTroves != address(0), "SORTED_TROVES not set");
        require(hintHelpers != address(0), "HINT_HELPERS not set");
        require(musdToken != address(0), "MUSD_TOKEN not set");

        vm.startBroadcast();

        // Deploy factory with Mezo addresses
        BTCVaultFactory factory = new BTCVaultFactory(
            admin,
            borrowerOps,
            troveManager,
            sortedTroves,
            hintHelpers,
            musdToken
        );

        // Set bank account
        factory.setBankAccount(bankAccount);

        vm.stopBroadcast();

        console.log("BTCVaultFactory deployed at:", address(factory));
        console.log("Admin:", admin);
        console.log("Bank Account:", bankAccount);
        console.log("BorrowerOperations:", borrowerOps);
        console.log("TroveManager:", troveManager);
    }
}
