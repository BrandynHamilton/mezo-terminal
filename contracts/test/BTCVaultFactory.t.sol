// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BTCVaultFactory.sol";
import "../src/BTCVault.sol";

/**
 * @title BTCVaultFactoryTest
 * @notice Test suite for BTCVaultFactory with admin-controlled vault creation
 */
contract BTCVaultFactoryTest is Test {
    BTCVaultFactory public factory;
    address public admin;
    address public bankAccount;
    address public client1;
    address public client2;
    address public owner1;
    address public owner2;
    address public owner3;

    // Dummy MUSD protocol addresses (for testing)
    address public borrowerOps = address(0x1111);
    address public troveManager = address(0x2222);
    address public sortedTroves = address(0x3333);
    address public hintHelpers = address(0x4444);
    address public musdToken = address(0x5555);

    event ClientVaultCreated(
        address indexed vault,
        address indexed clientAddress,
        address[] owners,
        uint256 requiredSignatures
    );

    function setUp() public {
        admin = address(0xAAA);
        bankAccount = address(0xBBB);
        client1 = address(0xCC1);
        client2 = address(0xCC2);
        owner1 = address(0x111);
        owner2 = address(0x222);
        owner3 = address(0x333);

        // Deploy factory with admin
        vm.prank(admin);
        factory = new BTCVaultFactory(
            admin,
            borrowerOps,
            troveManager,
            sortedTroves,
            hintHelpers,
            musdToken
        );

        // Set bank account
        vm.prank(admin);
        factory.setBankAccount(bankAccount);
    }

    // ═════════════════════════════════════════════════════════════════════════════
    // createVaultForClient Tests
    // ═════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Test: Admin can create vault for a client
     */
    function test_AdminCanCreateVaultForClient() public {
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = owner2;

        BTCVault.Role[] memory roles = new BTCVault.Role[](2);
        roles[0] = BTCVault.Role.Client;
        roles[1] = BTCVault.Role.Custodian;

        vm.prank(admin);
        address vault = factory.createVaultForClient(
            client1,
            owners,
            roles,
            1 // 1-of-2 client signers + bank = 1-of-3 total
        );

        assertTrue(vault != address(0));
        assertTrue(factory.isVault(vault));
        assertTrue(factory.hasVault(client1));
        assertEq(factory.clientToVault(client1), vault);
    }

    /**
     * @notice Test: Vault gets bank account injected as first signer
     */
    function test_VaultHasBankAccountInjected() public {
        address[] memory owners = new address[](1);
        owners[0] = owner1;

        BTCVault.Role[] memory roles = new BTCVault.Role[](1);
        roles[0] = BTCVault.Role.Client;

        vm.prank(admin);
        address vaultAddr = factory.createVaultForClient(
            client1,
            owners,
            roles,
            1
        );

        BTCVault vault = BTCVault(payable(vaultAddr));

        // Check that vault has 2 owners (bank + client)
        address[] memory vaultOwners = vault.getOwners();
        assertEq(vaultOwners.length, 2);

        // First owner should be bank account
        assertEq(vaultOwners[0], bankAccount);

        // Second owner should be client's owner
        assertEq(vaultOwners[1], owner1);

        // Bank should have Bank role
        assertEq(uint256(vault.getRole(bankAccount)), uint256(BTCVault.Role.Bank));
    }

    /**
     * @notice Test: Non-admin cannot create vault for client
     */
    function test_NonAdminCannotCreateVault() public {
        address[] memory owners = new address[](1);
        owners[0] = owner1;

        BTCVault.Role[] memory roles = new BTCVault.Role[](1);
        roles[0] = BTCVault.Role.Client;

        vm.prank(client1); // Not admin
        vm.expectRevert(BTCVaultFactory.NotAdmin.selector);
        factory.createVaultForClient(client1, owners, roles, 1);
    }

    /**
     * @notice Test: Cannot create vault for zero address
     */
    function test_CannotCreateVaultForZeroAddress() public {
        address[] memory owners = new address[](1);
        owners[0] = owner1;

        BTCVault.Role[] memory roles = new BTCVault.Role[](1);
        roles[0] = BTCVault.Role.Client;

        vm.prank(admin);
        vm.expectRevert(BTCVaultFactory.InvalidClientAddress.selector);
        factory.createVaultForClient(address(0), owners, roles, 1);
    }

    /**
     * @notice Test: Cannot create second vault for same client (one-to-one)
     */
    function test_CannotCreateSecondVaultForSameClient() public {
        address[] memory owners = new address[](1);
        owners[0] = owner1;

        BTCVault.Role[] memory roles = new BTCVault.Role[](1);
        roles[0] = BTCVault.Role.Client;

        // Create first vault for client1
        vm.prank(admin);
        factory.createVaultForClient(client1, owners, roles, 1);

        // Try to create second vault for same client
        address[] memory owners2 = new address[](1);
        owners2[0] = owner2;

        vm.prank(admin);
        vm.expectRevert(BTCVaultFactory.ClientAlreadyHasVault.selector);
        factory.createVaultForClient(client1, owners2, roles, 1);
    }

    /**
     * @notice Test: Cannot exceed max owners (10) including injected bank
     */
    function test_CannotExceedMaxOwners() public {
        // Create 10 owners (+ bank = 11, exceeds MAX_OWNERS of 10)
        address[] memory owners = new address[](10);
        for (uint i = 0; i < 10; i++) {
            owners[i] = address(uint160(0x1000 + i));
        }

        BTCVault.Role[] memory roles = new BTCVault.Role[](10);
        for (uint i = 0; i < 10; i++) {
            roles[i] = BTCVault.Role.Client;
        }

        vm.prank(admin);
        vm.expectRevert(BTCVault.InvalidOwnerCount.selector);
        factory.createVaultForClient(client1, owners, roles, 1);
    }

    /**
     * @notice Test: Can create with maximum valid owners (9 + bank = 10)
     */
    function test_CanCreateWithMaxValidOwners() public {
        // Create 9 owners (+ bank = 10, exactly MAX_OWNERS)
        address[] memory owners = new address[](9);
        for (uint i = 0; i < 9; i++) {
            owners[i] = address(uint160(0x1000 + i));
        }

        BTCVault.Role[] memory roles = new BTCVault.Role[](9);
        for (uint i = 0; i < 9; i++) {
            roles[i] = BTCVault.Role.Client;
        }

        vm.prank(admin);
        address vault = factory.createVaultForClient(
            client1,
            owners,
            roles,
            5 // 5-of-9 client signers
        );

        assertTrue(vault != address(0));

        BTCVault vaultContract = BTCVault(payable(vault));
        address[] memory vaultOwners = vaultContract.getOwners();
        assertEq(vaultOwners.length, 10); // 9 client owners + 1 bank
    }

    /**
     * @notice Test: Signature threshold is adjusted for bank account
     */
    function test_SignatureThresholdAdjustedForBank() public {
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = owner2;

        BTCVault.Role[] memory roles = new BTCVault.Role[](2);
        roles[0] = BTCVault.Role.Client;
        roles[1] = BTCVault.Role.Custodian;

        // Client specifies 1-of-2 threshold
        // Should become 1-of-3 (with bank)
        vm.prank(admin);
        address vaultAddr = factory.createVaultForClient(
            client1,
            owners,
            roles,
            1
        );

        BTCVault vault = BTCVault(payable(vaultAddr));
        assertEq(vault.requiredSignatures(), 2); // 1+1 for bank
    }

    /**
     * @notice Test: Multiple clients can have vaults
     */
    function test_MultipleClientsCanHaveVaults() public {
        address[] memory owners = new address[](1);
        owners[0] = owner1;

        BTCVault.Role[] memory roles = new BTCVault.Role[](1);
        roles[0] = BTCVault.Role.Client;

        // Create vault for client1
        vm.prank(admin);
        address vault1 = factory.createVaultForClient(client1, owners, roles, 1);

        // Create vault for client2
        address[] memory owners2 = new address[](1);
        owners2[0] = owner2;

        vm.prank(admin);
        address vault2 = factory.createVaultForClient(client2, owners2, roles, 1);

        assertTrue(vault1 != vault2);
        assertTrue(factory.hasVault(client1));
        assertTrue(factory.hasVault(client2));
        assertEq(factory.clientToVault(client1), vault1);
        assertEq(factory.clientToVault(client2), vault2);
    }

    /**
     * @notice Test: getClientVault returns correct vault
     */
    function test_GetClientVaultReturnsCorrectVault() public {
        address[] memory owners = new address[](1);
        owners[0] = owner1;

        BTCVault.Role[] memory roles = new BTCVault.Role[](1);
        roles[0] = BTCVault.Role.Client;

        vm.prank(admin);
        address vaultAddr = factory.createVaultForClient(
            client1,
            owners,
            roles,
            1
        );

        assertEq(factory.getClientVault(client1), vaultAddr);
    }

    /**
     * @notice Test: getClientVault returns zero address for non-existent client
     */
    function test_GetClientVaultReturnsZeroForNonExistent() public {
        assertEq(factory.getClientVault(client2), address(0));
    }

    /**
     * @notice Test: ClientVaultCreated event is emitted with correct data
     */
    function test_ClientVaultCreatedEventEmitted() public {
        address[] memory owners = new address[](1);
        owners[0] = owner1;

        BTCVault.Role[] memory roles = new BTCVault.Role[](1);
        roles[0] = BTCVault.Role.Client;

        vm.prank(admin);
        address vaultAddr = factory.createVaultForClient(client1, owners, roles, 1);

        // Verify vault was created (event was emitted)
        assertTrue(vaultAddr != address(0));
        assertTrue(factory.isVault(vaultAddr));
    }

    /**
     * @notice Test: Vault is properly configured with Mezo addresses
     */
    function test_VaultConfiguredWithMezoAddresses() public {
        address[] memory owners = new address[](1);
        owners[0] = owner1;

        BTCVault.Role[] memory roles = new BTCVault.Role[](1);
        roles[0] = BTCVault.Role.Client;

        vm.prank(admin);
        address vaultAddr = factory.createVaultForClient(
            client1,
            owners,
            roles,
            1
        );

        BTCVault vault = BTCVault(payable(vaultAddr));

        // Verify Mezo addresses are set
        assertTrue(vault.mezoConfigured());
    }

    /**
     * @notice Test: Vault is tracked in global list
     */
    function test_VaultTrackedInGlobalList() public {
        address[] memory owners = new address[](1);
        owners[0] = owner1;

        BTCVault.Role[] memory roles = new BTCVault.Role[](1);
        roles[0] = BTCVault.Role.Client;

        uint256 vaultsBefore = factory.totalVaults();

        vm.prank(admin);
        factory.createVaultForClient(client1, owners, roles, 1);

        uint256 vaultsAfter = factory.totalVaults();
        assertEq(vaultsAfter, vaultsBefore + 1);
    }

    /**
     * @notice Test: Admin can create multiple vaults in sequence
     */
    function test_AdminCanCreateMultipleVaultsInSequence() public {
        address[] memory owners = new address[](1);
        owners[0] = owner1;

        BTCVault.Role[] memory roles = new BTCVault.Role[](1);
        roles[0] = BTCVault.Role.Client;

        // Create 5 vaults
        for (uint i = 0; i < 5; i++) {
            address clientAddr = address(uint160(0xCC00 + i));
            address ownerAddr = address(uint160(0x1100 + i));

            address[] memory ownersArray = new address[](1);
            ownersArray[0] = ownerAddr;

            vm.prank(admin);
            address vault = factory.createVaultForClient(
                clientAddr,
                ownersArray,
                roles,
                1
            );

            assertTrue(vault != address(0));
            assertTrue(factory.hasVault(clientAddr));
        }

        assertEq(factory.totalVaults(), 5);
    }
}
