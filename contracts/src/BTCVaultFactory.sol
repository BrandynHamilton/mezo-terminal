// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BTCVault.sol";

/**
 * @title BTCVaultFactory
 * @notice Deploys a new BTCVault per client. Each vault is an independent
 *         multi-sig with its own owners, threshold, and Mezo trove.
 *
 *         This factory automatically injects a bank account as a signer
 *         with a "Bank" role, and optionally a custodian role for additional
 *         oversight in institutional Bitcoin custody products.
 *
 * Usage:
 *   1. Deploy BTCVaultFactory with default Mezo protocol addresses.
 *   2. Call createVault(owners, roles, threshold) -- deploys and initializes
 *      a new BTCVault in a single transaction.
 *   3. The new vault is auto-configured with the Mezo addresses.
 *
 * All created vaults are tracked and queryable.
 */
contract BTCVaultFactory {
    // ----------------------------------------------------------------
    //  Constants
    // ----------------------------------------------------------------

    uint256 public constant MAX_OWNERS = 10;

    // ----------------------------------------------------------------
    //  Events
    // ----------------------------------------------------------------

    event VaultCreated(
        address indexed vault,
        address indexed creator,
        address[] owners,
        uint256 requiredSignatures
    );
    event MezoDefaultsUpdated(address borrowerOperations, address troveManager);
    event BankAccountSet(address bankAccount);
    event ClientVaultCreated(
        address indexed vault,
        address indexed clientAddress,
        address[] owners,
        uint256 requiredSignatures
    );

    // ----------------------------------------------------------------
    //  Errors
    // ----------------------------------------------------------------

    error NotAdmin();
    error ZeroAddress();
    error BankAccountAlreadySet();
    error ClientAlreadyHasVault();
    error InvalidClientAddress();

    // ----------------------------------------------------------------
    //  State
    // ----------------------------------------------------------------

    address public admin;
    address public bankAccount; // Automatically injected bank account

    /// @notice Default Mezo protocol addresses applied to every new vault.
    address public defaultBorrowerOperations;
    address public defaultTroveManager;
    address public defaultSortedTroves;
    address public defaultHintHelpers;
    address public defaultMusdToken;

    /// @notice Every vault ever deployed by this factory.
    address[] public vaults;

    /// @notice Vaults created by a specific address.
    mapping(address => address[]) public vaultsByCreator;

    /// @notice Quick lookup: is this address a vault we deployed?
    mapping(address => bool) public isVault;

    /// @notice Track vault per client (one-to-one mapping)
    mapping(address => address) public clientToVault;

    /// @notice Track if a client already has a vault
    mapping(address => bool) public hasVault;

    // ----------------------------------------------------------------
    //  Modifiers
    // ----------------------------------------------------------------

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }

    // ----------------------------------------------------------------
    //  Constructor
    // ----------------------------------------------------------------

    /**
     * @param _admin                  Admin who can update default Mezo addresses.
     * @param _borrowerOperations     Mezo BorrowerOperations address.
     * @param _troveManager           Mezo TroveManager address.
     * @param _sortedTroves           Mezo SortedTroves address.
     * @param _hintHelpers            Mezo HintHelpers address.
     * @param _musdToken              mUSD ERC-20 token address.
     */
    constructor(
        address _admin,
        address _borrowerOperations,
        address _troveManager,
        address _sortedTroves,
        address _hintHelpers,
        address _musdToken
    ) {
        if (_admin == address(0)) revert ZeroAddress();
        admin = _admin;
        defaultBorrowerOperations = _borrowerOperations;
        defaultTroveManager = _troveManager;
        defaultSortedTroves = _sortedTroves;
        defaultHintHelpers = _hintHelpers;
        defaultMusdToken = _musdToken;
    }

    // ----------------------------------------------------------------
    //  Set Bank Account
    // ----------------------------------------------------------------

    /**
     * @notice Set the bank account address that will be automatically
     *         injected into every vault created by this factory.
     *         This should be called once by the admin after deployment.
     */
    function setBankAccount(address _bankAccount) external onlyAdmin {
        if (bankAccount != address(0)) revert BankAccountAlreadySet();
        if (_bankAccount == address(0)) revert ZeroAddress();
        
        bankAccount = _bankAccount;
        emit BankAccountSet(_bankAccount);
    }

    // ----------------------------------------------------------------
    //  Create Vault
    // ----------------------------------------------------------------

    /**
     * @notice Deploy and fully initialize a new BTCVault.
     *         Automatically injects the bank account as a signer with "Bank" role.
     * @param _owners          Owner addresses for the new vault (max 10).
     * @param _roles           Parallel array of roles.
     * @param _minSignatures   Quorum threshold.
     * @return vault           Address of the newly deployed vault.
     */
    function createVault(
        address[] calldata _owners,
        BTCVault.Role[] calldata _roles,
        uint256 _minSignatures
    ) external returns (address vault) {
        // Ensure bank account is set
        if (bankAccount == address(0)) revert ZeroAddress();
        
        // Calculate new owner list with bank account injected
        uint256 originalLength = _owners.length;
        uint256 newLength = originalLength + 1;
        
         // Validate the new owner list won't exceed the limit
         if (newLength > MAX_OWNERS) revert BTCVault.InvalidOwnerCount();
        
        // Create new arrays with bank account injected at the beginning
        address[] memory finalOwners = new address[](newLength);
        BTCVault.Role[] memory finalRoles = new BTCVault.Role[](newLength);
        
        // Insert bank account as first owner with "Bank" role
        finalOwners[0] = bankAccount;
        finalRoles[0] = BTCVault.Role.Bank;
        
        // Copy original owners and roles
        for (uint256 i = 0; i < originalLength; i++) {
            finalOwners[i + 1] = _owners[i];
            finalRoles[i + 1] = _roles[i];
        }
        
        // Adjust minimum signatures to account for the new owner
        uint256 adjustedMinSignatures = _minSignatures;
        if (_minSignatures > 0) {
            adjustedMinSignatures = _minSignatures + 1;
        }
        
        // Deploy a fresh BTCVault
        BTCVault v = new BTCVault();

        // Initialize owners + threshold (adjusted for bank account)
        v.initialize(finalOwners, finalRoles, adjustedMinSignatures);

        // Wire up Mezo protocol addresses (if configured)
        if (defaultBorrowerOperations != address(0)) {
            v.configureMezo(
                defaultBorrowerOperations,
                defaultTroveManager,
                defaultSortedTroves,
                defaultHintHelpers,
                defaultMusdToken
            );
        }

        vault = address(v);

        // Track
        vaults.push(vault);
        vaultsByCreator[msg.sender].push(vault);
        isVault[vault] = true;

        emit VaultCreated(vault, msg.sender, finalOwners, adjustedMinSignatures);
    }

    // ----------------------------------------------------------------
    //  Create Vault For Client (Admin Only)
    // ----------------------------------------------------------------

    /**
     * @notice Deploy and initialize a new BTCVault for a specific client.
     *         ADMIN ONLY - Ensures verified clients only, one vault per client.
     *
     *         This is the institutional custody flow:
     *         1. Client undergoes KYC/AML (off-chain)
     *         2. Admin calls this function with client address
     *         3. Vault is deployed with client as owner
     *         4. Bank account automatically injected as signer
     *         5. Admin tracks vault → client mapping
     *
     * @param _clientAddress   The client who will own this vault.
     * @param _owners          Client's owner addresses for the vault (max 9, since bank is injected).
     * @param _roles           Parallel array of roles for each owner.
     * @param _minSignatures   Quorum threshold (will be increased by 1 for bank account).
     * @return vault           Address of the newly deployed vault.
     *
     * Reverts if:
     *  - Caller is not admin
     *  - Client address is zero
     *  - Client already has a vault
     *  - Owner list would exceed MAX_OWNERS with bank account injected
     */
    function createVaultForClient(
        address _clientAddress,
        address[] calldata _owners,
        BTCVault.Role[] calldata _roles,
        uint256 _minSignatures
    ) external onlyAdmin returns (address vault) {
        // Validate inputs
        if (_clientAddress == address(0)) revert InvalidClientAddress();
        if (hasVault[_clientAddress]) revert ClientAlreadyHasVault();
        if (bankAccount == address(0)) revert ZeroAddress();

        // Calculate new owner list with bank account injected
        uint256 originalLength = _owners.length;
        uint256 newLength = originalLength + 1;

        // Validate the new owner list won't exceed the limit
        if (newLength > MAX_OWNERS) revert BTCVault.InvalidOwnerCount();

        // Create new arrays with bank account injected at the beginning
        address[] memory finalOwners = new address[](newLength);
        BTCVault.Role[] memory finalRoles = new BTCVault.Role[](newLength);

        // Insert bank account as first owner with "Bank" role
        finalOwners[0] = bankAccount;
        finalRoles[0] = BTCVault.Role.Bank;

        // Copy client's owners and roles
        for (uint256 i = 0; i < originalLength; i++) {
            finalOwners[i + 1] = _owners[i];
            finalRoles[i + 1] = _roles[i];
        }

        // Adjust minimum signatures to account for the bank account
        uint256 adjustedMinSignatures = _minSignatures;
        if (_minSignatures > 0) {
            adjustedMinSignatures = _minSignatures + 1;
        }

        // Deploy a fresh BTCVault
        BTCVault v = new BTCVault();

        // Initialize owners + threshold (adjusted for bank account)
        v.initialize(finalOwners, finalRoles, adjustedMinSignatures);

        // Wire up Mezo protocol addresses (if configured)
        if (defaultBorrowerOperations != address(0)) {
            v.configureMezo(
                defaultBorrowerOperations,
                defaultTroveManager,
                defaultSortedTroves,
                defaultHintHelpers,
                defaultMusdToken
            );
        }

        vault = address(v);

        // Track client → vault mapping (one-to-one)
        clientToVault[_clientAddress] = vault;
        hasVault[_clientAddress] = true;

        // Track in global vault list
        vaults.push(vault);
        vaultsByCreator[msg.sender].push(vault);
        isVault[vault] = true;

        emit ClientVaultCreated(vault, _clientAddress, finalOwners, adjustedMinSignatures);
    }

    // ----------------------------------------------------------------
    //  Get Vault For Client
    // ----------------------------------------------------------------

    /**
     * @notice Get the vault address for a given client.
     * @param _clientAddress The client address.
     * @return The vault address, or address(0) if client has no vault.
     */
    function getClientVault(address _clientAddress) external view returns (address) {
        return clientToVault[_clientAddress];
    }

    /**
     * @notice Update the default Mezo protocol addresses for future vaults.
     *         Does NOT retroactively change existing vaults.
     */
    function setMezoDefaults(
        address _borrowerOperations,
        address _troveManager,
        address _sortedTroves,
        address _hintHelpers,
        address _musdToken
    ) external onlyAdmin {
        defaultBorrowerOperations = _borrowerOperations;
        defaultTroveManager = _troveManager;
        defaultSortedTroves = _sortedTroves;
        defaultHintHelpers = _hintHelpers;
        defaultMusdToken = _musdToken;

        emit MezoDefaultsUpdated(_borrowerOperations, _troveManager);
    }

    // ----------------------------------------------------------------
    //  View
    // ----------------------------------------------------------------

    /// @notice Total number of vaults created.
    function totalVaults() external view returns (uint256) {
        return vaults.length;
    }

    /// @notice All vaults created by a specific address.
    function getVaultsByCreator(address creator)
        external
        view
        returns (address[] memory)
    {
        return vaultsByCreator[creator];
    }

    /// @notice All vaults ever created.
    function getAllVaults() external view returns (address[] memory) {
        return vaults;
    }
}
