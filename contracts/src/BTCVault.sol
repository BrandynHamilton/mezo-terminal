// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// ---------------------------------------------------------------------------
//  Mezo mUSD Protocol Interfaces
//  Derived from the Liquity/THUSD fork documented at:
//    https://mezo.org/docs/developers/musd/
//    https://github.com/mezo-org/musd
// ---------------------------------------------------------------------------

interface IBorrowerOperations {
    /// @notice Open a new collateralised debt position (trove).
    ///         BTC collateral is sent as msg.value.
    /// @param _MUSDAmount  Amount of mUSD debt to draw.
    /// @param _upperHint   Upper hint for sorted-trove insertion.
    /// @param _lowerHint   Lower hint for sorted-trove insertion.
    function openTrove(
        uint256 _MUSDAmount,
        address _upperHint,
        address _lowerHint
    ) external payable;

    /// @notice Add collateral to an existing trove. BTC sent as msg.value.
    function addColl(address _upperHint, address _lowerHint) external payable;

    /// @notice Withdraw collateral from a trove.
    function withdrawColl(
        uint256 _amount,
        address _upperHint,
        address _lowerHint
    ) external;

    /// @notice Repay mUSD debt.
    function repayMUSD(
        uint256 _amount,
        address _upperHint,
        address _lowerHint
    ) external;

    /// @notice Close the trove entirely (repay all debt, reclaim all collateral).
    function closeTrove() external;

    /// @notice Estimate borrowing fee on a given debt amount.
    function getBorrowingFee(uint256 _MUSDAmount) external view returns (uint256);
}

interface ITroveManager {
    /// @notice Get the current collateral and debt for a trove owner.
    function getTroveDebt(address _borrower) external view returns (uint256);
    function getTroveColl(address _borrower) external view returns (uint256);

    /// @notice Gas compensation constant (mUSD kept in GasPool per trove).
    function MUSD_GAS_COMPENSATION() external view returns (uint256);

    /// @notice Check whether a trove is active.
    function getTroveStatus(address _borrower) external view returns (uint256);
}

interface ISortedTroves {
    /// @notice Find the correct insertion hints for a given NICR.
    function findInsertPosition(
        uint256 _NICR,
        address _prevId,
        address _nextId
    ) external view returns (address, address);
}

interface IHintHelpers {
    /// @notice Get an approximate hint address for a given NICR.
    function getApproxHint(
        uint256 _CR,
        uint256 _numTrials,
        uint256 _inputRandomSeed
    ) external view returns (address, uint256, uint256);
}

/**
 * @title BTCVault
 * @notice Multi-signature Bitcoin treasury vault for institutional custody on Mezo.
 *
 *         Ported from the sBTC-Vault Clarity contract with:
 *           - Role-based access (Client / Custodian / Bank)
 *           - Separated approval and execution
 *           - Real Mezo mUSD integration via BorrowerOperations.openTrove
 *
 *         On Mezo, BTC is the native gas token (18 decimals). This vault
 *         accepts native BTC deposits and can open a Mezo trove to borrow
 *         mUSD against the deposited collateral.
 *
 * Core flow:
 *   1. initialize    -- set owners (up to 10), roles, and signature threshold
 *   2. deposit       -- send native BTC into the vault
 *   3. propose       -- any owner creates a BTC transfer proposal
 *   4. approve       -- owners sign; threshold tracked, does NOT auto-execute
 *   5. execute       -- separate call once threshold is met
 *   6. borrowMUSD    -- open/top-up a Mezo trove against vault BTC
 *   7. repayMUSD     -- repay mUSD debt and reclaim BTC collateral
 */
contract BTCVault is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ----------------------------------------------------------------
    //  Enums
    // ----------------------------------------------------------------

    enum Role {
        Client,
        Custodian,
        Bank
    }

    // ----------------------------------------------------------------
    //  Structs
    // ----------------------------------------------------------------

    struct Proposal {
        address payable to;
        uint256 amount;
        address[] signatures;
        bool executed;
        bool cancelled;
        uint256 createdAt;
    }

    // ----------------------------------------------------------------
    //  Constants / Errors
    // ----------------------------------------------------------------

    uint256 public constant MAX_OWNERS = 10;

    error NotOwner();
    error ProposalNotFound();
    error AlreadySigned();
    error AlreadyExecuted();
    error AlreadyCancelled();
    error AlreadyInitialized();
    error InvalidOwnerCount();
    error InvalidThreshold();
    error DuplicateOwner();
    error ZeroAddress();
    error ZeroAmount();
    error InsufficientVaultBalance();
    error ThresholdNotMet();
    error TransferFailed();
    error TroveAlreadyOpen();
    error TroveNotOpen();
    error MezoNotConfigured();

    // ----------------------------------------------------------------
    //  Events
    // ----------------------------------------------------------------

    event VaultInitialized(address[] owners, uint256 requiredSignatures);
    event Deposited(address indexed from, uint256 amount);
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        address to,
        uint256 amount
    );
    event ProposalApproved(
        uint256 indexed proposalId,
        address indexed signer,
        uint256 currentSignatures
    );
    event ProposalExecuted(
        uint256 indexed proposalId,
        address indexed to,
        uint256 amount
    );
    event ProposalCancelled(
        uint256 indexed proposalId,
        address indexed cancelledBy
    );
    event TroveOpened(uint256 collateral, uint256 debtDrawn, uint256 fee);
    event DebtRepaid(uint256 amount);
    event TroveClosed();
    event MezoContractsConfigured(
        address borrowerOperations,
        address troveManager,
        address sortedTroves,
        address hintHelpers,
        address musdToken
    );

    // ----------------------------------------------------------------
    //  State
    // ----------------------------------------------------------------

    address public deployer; // factory or EOA that deployed this vault

    bool public initialized;
    uint256 public requiredSignatures;
    uint256 public nextProposalId;

    mapping(address => bool) public isOwner;
    mapping(address => Role) public roles;
    address[] public ownerList;

    mapping(uint256 => Proposal) internal _proposals;
    mapping(uint256 => mapping(address => bool)) public hasSigned;

    // --- Mezo protocol references ---
    IBorrowerOperations public borrowerOperations;
    ITroveManager public troveManager;
    ISortedTroves public sortedTroves;
    IHintHelpers public hintHelpers;
    IERC20 public musdToken;
    bool public mezoConfigured;

    // ----------------------------------------------------------------
    //  Modifiers
    // ----------------------------------------------------------------

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert NotOwner();
        _;
    }

    modifier onlyOnce() {
        if (initialized) revert AlreadyInitialized();
        _;
    }

    // ----------------------------------------------------------------
    //  Constructor
    // ----------------------------------------------------------------

    /**
     * @dev On Mezo, BTC is the native token so the vault holds native BTC.
     *      Mezo protocol addresses can be set post-deploy via configureMezo().
     *      The deployer (factory or EOA) is recorded so it can call
     *      configureMezo() before any owner has interacted.
     */
    constructor() {
        deployer = msg.sender;
    }

    /// @notice Accept native BTC transfers (Mezo's gas token).
    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    // ----------------------------------------------------------------
    //  Initialization  (maps to Clarity: initialize-wallet)
    // ----------------------------------------------------------------

    /**
     * @notice Set up the vault with an owner list, their roles, and the
     *         minimum number of signatures required to execute a proposal.
     * @param _owners         Ordered list of owner addresses (max 10).
     * @param _roles          Parallel array of roles for each owner.
     * @param _minSignatures  Quorum threshold.
     */
    function initialize(
        address[] calldata _owners,
        Role[] calldata _roles,
        uint256 _minSignatures
    ) external onlyOnce {
        // Only the deployer (factory or direct deployer) can initialize
        if (msg.sender != deployer) revert NotOwner();
        uint256 len = _owners.length;

        if (len == 0 || len > MAX_OWNERS) revert InvalidOwnerCount();
        if (_roles.length != len) revert InvalidOwnerCount();
        if (_minSignatures == 0 || _minSignatures > len)
            revert InvalidThreshold();

        for (uint256 i = 0; i < len; i++) {
            address owner = _owners[i];
            if (owner == address(0)) revert ZeroAddress();
            if (isOwner[owner]) revert DuplicateOwner();

            isOwner[owner] = true;
            roles[owner] = _roles[i];
            ownerList.push(owner);
        }

        requiredSignatures = _minSignatures;
        initialized = true;

        emit VaultInitialized(_owners, _minSignatures);
    }

    // ----------------------------------------------------------------
    //  Configure Mezo Protocol Addresses
    // ----------------------------------------------------------------

    /**
     * @notice Wire up the Mezo mUSD protocol contract addresses.
     *         Can only be called once, by an owner OR the deployer (factory).
     */
    function configureMezo(
        address _borrowerOperations,
        address _troveManager,
        address _sortedTroves,
        address _hintHelpers,
        address _musdToken
    ) external {
        if (!isOwner[msg.sender] && msg.sender != deployer) revert NotOwner();
        if (mezoConfigured) revert AlreadyInitialized();
        if (
            _borrowerOperations == address(0) ||
            _troveManager == address(0) ||
            _sortedTroves == address(0) ||
            _hintHelpers == address(0) ||
            _musdToken == address(0)
        ) revert ZeroAddress();

        borrowerOperations = IBorrowerOperations(_borrowerOperations);
        troveManager = ITroveManager(_troveManager);
        sortedTroves = ISortedTroves(_sortedTroves);
        hintHelpers = IHintHelpers(_hintHelpers);
        musdToken = IERC20(_musdToken);
        mezoConfigured = true;

        emit MezoContractsConfigured(
            _borrowerOperations,
            _troveManager,
            _sortedTroves,
            _hintHelpers,
            _musdToken
        );
    }

    // ----------------------------------------------------------------
    //  Deposit  (native BTC)
    // ----------------------------------------------------------------

    /**
     * @notice Deposit native BTC into the vault.
     *         Anyone can deposit (e.g. a client funding their treasury).
     */
    function deposit() external payable nonReentrant {
        if (msg.value == 0) revert ZeroAmount();
        emit Deposited(msg.sender, msg.value);
    }

    // ----------------------------------------------------------------
    //  Propose  (maps to Clarity: propose-transaction)
    // ----------------------------------------------------------------

    /**
     * @notice Create a new BTC transfer proposal. Only owners may propose.
     * @param to       Recipient address.
     * @param amount   BTC amount (in wei) to transfer if executed.
     * @return proposalId The ID of the newly created proposal.
     */
    function propose(address payable to, uint256 amount)
        external
        onlyOwner
        returns (uint256 proposalId)
    {
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();

        proposalId = nextProposalId++;

        Proposal storage p = _proposals[proposalId];
        p.to = to;
        p.amount = amount;
        p.createdAt = block.timestamp;

        emit ProposalCreated(proposalId, msg.sender, to, amount);
    }

    // ----------------------------------------------------------------
    //  Approve  (maps to Clarity: sign-proposal)
    // ----------------------------------------------------------------

    /**
     * @notice Approve (sign) a proposal. Auto-executes when threshold is met.
     * @param proposalId The proposal to approve.
     */
    function approve(uint256 proposalId) external onlyOwner {
        Proposal storage p = _proposals[proposalId];
        if (p.to == address(0)) revert ProposalNotFound();
        if (p.executed) revert AlreadyExecuted();
        if (p.cancelled) revert AlreadyCancelled();
        if (hasSigned[proposalId][msg.sender]) revert AlreadySigned();

        hasSigned[proposalId][msg.sender] = true;
        p.signatures.push(msg.sender);

        uint256 currentSignatures = p.signatures.length;
        emit ProposalApproved(proposalId, msg.sender, currentSignatures);

        if (currentSignatures >= requiredSignatures && address(this).balance >= p.amount) {
            _executeProposal(proposalId);
        }
    }

    // ----------------------------------------------------------------
    //  Internal execute function
    // ----------------------------------------------------------------

    function _executeProposal(uint256 proposalId) internal {
        Proposal storage p = _proposals[proposalId];
        p.executed = true;

        (bool sent, ) = p.to.call{value: p.amount}("");
        if (!sent) revert TransferFailed();

        emit ProposalExecuted(proposalId, p.to, p.amount);
    }

    // ----------------------------------------------------------------
    //  Execute  (maps to Clarity: execute-transaction)
    // ----------------------------------------------------------------

    /**
     * @notice Execute a proposal after enough approvals. Sends native BTC.
     * @param proposalId The proposal to execute.
     */
    function execute(uint256 proposalId) external onlyOwner nonReentrant {
        Proposal storage p = _proposals[proposalId];
        if (p.to == address(0)) revert ProposalNotFound();
        if (p.executed) revert AlreadyExecuted();
        if (p.cancelled) revert AlreadyCancelled();
        if (p.signatures.length < requiredSignatures) revert ThresholdNotMet();
        if (address(this).balance < p.amount) revert InsufficientVaultBalance();

        _executeProposal(proposalId);
    }

    // ----------------------------------------------------------------
    //  Cancel
    // ----------------------------------------------------------------

    /**
     * @notice Cancel a pending proposal. Any owner can cancel.
     */
    function cancel(uint256 proposalId) external onlyOwner {
        Proposal storage p = _proposals[proposalId];
        if (p.to == address(0)) revert ProposalNotFound();
        if (p.executed) revert AlreadyExecuted();
        if (p.cancelled) revert AlreadyCancelled();

        p.cancelled = true;
        emit ProposalCancelled(proposalId, msg.sender);
    }

    // ----------------------------------------------------------------
    //  Borrow mUSD  --  Mezo BorrowerOperations.openTrove integration
    // ----------------------------------------------------------------

    /**
     * @notice Borrow mUSD against vault BTC by opening a Mezo trove.
     *
     *         This calls BorrowerOperations.openTrove(), sending BTC as
     *         msg.value (native collateral on Mezo). The minted mUSD is
     *         sent to this contract and can be withdrawn via a proposal.
     *
     *         The minimum collateral ratio is 110%. For safety this function
     *         requires callers to choose their own debt amount -- it does
     *         NOT auto-max. Hints are computed on-chain via HintHelpers.
     *
     * @param collateralAmount  BTC (wei) from vault balance to pledge.
     * @param debtAmount        mUSD to borrow (before the 0.1% fee).
     */
    function borrowMUSD(uint256 collateralAmount, uint256 debtAmount)
        external
        onlyOwner
        nonReentrant
    {
        if (!mezoConfigured) revert MezoNotConfigured();
        if (collateralAmount == 0 || debtAmount == 0) revert ZeroAmount();
        if (address(this).balance < collateralAmount)
            revert InsufficientVaultBalance();

        // Check that the vault doesn't already have an open trove
        // TroveManager status: 1 = active
        uint256 troveStatus = troveManager.getTroveStatus(address(this));
        if (troveStatus == 1) revert TroveAlreadyOpen();

        // Compute the fee and gas compensation to determine expected NICR
        uint256 fee = borrowerOperations.getBorrowingFee(debtAmount);
        uint256 gasComp = troveManager.MUSD_GAS_COMPENSATION();
        uint256 totalDebt = debtAmount + fee + gasComp;

        // Nominal ICR = collateral * 1e20 / totalDebt
        uint256 nicr = (collateralAmount * 1e20) / totalDebt;

        // Get approximate hint
        (address approxHint, , ) = hintHelpers.getApproxHint(
            nicr,
            15, // numTrials
            42 // seed
        );

        // Find exact insertion position
        (address upperHint, address lowerHint) = sortedTroves
            .findInsertPosition(nicr, approxHint, approxHint);

        // Open the trove -- BTC sent as msg.value
        borrowerOperations.openTrove{value: collateralAmount}(
            debtAmount,
            upperHint,
            lowerHint
        );

        emit TroveOpened(collateralAmount, debtAmount, fee);
    }

    // ----------------------------------------------------------------
    //  Repay mUSD  --  pay down trove debt
    // ----------------------------------------------------------------

    /**
     * @notice Repay mUSD debt on the vault's Mezo trove.
     *         The caller must ensure this contract holds enough mUSD
     *         (e.g. transferred in via a proposal or direct transfer).
     *
     * @param amount mUSD to repay.
     */
    function repayMUSD(uint256 amount) external onlyOwner nonReentrant {
        if (!mezoConfigured) revert MezoNotConfigured();
        if (amount == 0) revert ZeroAmount();

        uint256 troveStatus = troveManager.getTroveStatus(address(this));
        if (troveStatus != 1) revert TroveNotOpen();

        // Approve BorrowerOperations to pull mUSD from the vault
        musdToken.safeIncreaseAllowance(address(borrowerOperations), amount);

        // Compute hints for the new position after repayment
        uint256 currentDebt = troveManager.getTroveDebt(address(this));
        uint256 currentColl = troveManager.getTroveColl(address(this));
        uint256 gasComp = troveManager.MUSD_GAS_COMPENSATION();
        uint256 newDebt = currentDebt - amount; // will revert on underflow
        uint256 nicr = (currentColl * 1e20) / (newDebt > gasComp ? newDebt : 1);

        (address approxHint, , ) = hintHelpers.getApproxHint(nicr, 15, 42);
        (address upperHint, address lowerHint) = sortedTroves
            .findInsertPosition(nicr, approxHint, approxHint);

        borrowerOperations.repayMUSD(amount, upperHint, lowerHint);

        emit DebtRepaid(amount);
    }

    // ----------------------------------------------------------------
    //  Close Trove  --  fully repay and reclaim all collateral
    // ----------------------------------------------------------------

    /**
     * @notice Close the vault's Mezo trove entirely.
     *         Requires the vault to hold enough mUSD to cover outstanding debt.
     *         All BTC collateral is returned to this contract.
     */
    function closeTrove() external onlyOwner nonReentrant {
        if (!mezoConfigured) revert MezoNotConfigured();

        uint256 troveStatus = troveManager.getTroveStatus(address(this));
        if (troveStatus != 1) revert TroveNotOpen();

        // Approve full debt repayment
        uint256 debt = troveManager.getTroveDebt(address(this));
        musdToken.safeIncreaseAllowance(address(borrowerOperations), debt);

        borrowerOperations.closeTrove();

        emit TroveClosed();
    }

    // ----------------------------------------------------------------
    //  View / Getter functions
    // ----------------------------------------------------------------

    /// @notice Get full proposal data.
    function getProposal(uint256 proposalId)
        external
        view
        returns (
            address to,
            uint256 amount,
            address[] memory signatures,
            bool executed,
            bool cancelled,
            uint256 createdAt
        )
    {
        Proposal storage p = _proposals[proposalId];
        return (
            p.to,
            p.amount,
            p.signatures,
            p.executed,
            p.cancelled,
            p.createdAt
        );
    }

    /// @notice Number of signatures collected so far.
    function getSignatureCount(uint256 proposalId)
        external
        view
        returns (uint256)
    {
        return _proposals[proposalId].signatures.length;
    }

    /// @notice Whether the proposal has met the approval threshold.
    function isApproved(uint256 proposalId) external view returns (bool) {
        return _proposals[proposalId].signatures.length >= requiredSignatures;
    }

    /// @notice Vault's native BTC balance.
    function vaultBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Vault's mUSD token balance (borrowed mUSD sitting in vault).
    function musdBalance() external view returns (uint256) {
        if (!mezoConfigured) return 0;
        return musdToken.balanceOf(address(this));
    }

    /// @notice Current trove debt on Mezo (0 if no trove).
    function troveDebt() external view returns (uint256) {
        if (!mezoConfigured) return 0;
        return troveManager.getTroveDebt(address(this));
    }

    /// @notice Current trove collateral on Mezo (0 if no trove).
    function troveCollateral() external view returns (uint256) {
        if (!mezoConfigured) return 0;
        return troveManager.getTroveColl(address(this));
    }

    /// @notice Whether the vault has an active Mezo trove.
    function hasTrove() external view returns (bool) {
        if (!mezoConfigured) return false;
        return troveManager.getTroveStatus(address(this)) == 1;
    }

    /// @notice Full owner list.
    function getOwners() external view returns (address[] memory) {
        return ownerList;
    }

    /// @notice Number of owners.
    function ownerCount() external view returns (uint256) {
        return ownerList.length;
    }

    /// @notice Role of a given address.
    function getRole(address account) external view returns (Role) {
        return roles[account];
    }
}
