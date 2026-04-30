// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 >=0.6.2 ^0.8.20;

// lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC-1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct Int256Slot {
        int256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Int256Slot` with member `value` located at `slot`.
     */
    function getInt256Slot(bytes32 slot) internal pure returns (Int256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns a `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }
}

// lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

// lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

// lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.5.0) (utils/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 *
 * IMPORTANT: Deprecated. This storage-based reentrancy guard will be removed and replaced
 * by the {ReentrancyGuardTransient} variant in v6.0.
 *
 * @custom:stateless
 */
abstract contract ReentrancyGuard {
    using StorageSlot for bytes32;

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REENTRANCY_GUARD_STORAGE =
        0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _reentrancyGuardStorageSlot().getUint256Slot().value = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    /**
     * @dev A `view` only version of {nonReentrant}. Use to block view functions
     * from being called, preventing reading from inconsistent contract state.
     *
     * CAUTION: This is a "view" modifier and does not change the reentrancy
     * status. Use it only on view functions. For payable or non-payable functions,
     * use the standard {nonReentrant} modifier instead.
     */
    modifier nonReentrantView() {
        _nonReentrantBeforeView();
        _;
    }

    function _nonReentrantBeforeView() private view {
        if (_reentrancyGuardEntered()) {
            revert ReentrancyGuardReentrantCall();
        }
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        _nonReentrantBeforeView();

        // Any calls to nonReentrant after this point will fail
        _reentrancyGuardStorageSlot().getUint256Slot().value = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _reentrancyGuardStorageSlot().getUint256Slot().value = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _reentrancyGuardStorageSlot().getUint256Slot().value == ENTERED;
    }

    function _reentrancyGuardStorageSlot() internal pure virtual returns (bytes32) {
        return REENTRANCY_GUARD_STORAGE;
    }
}

// lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1363.sol)

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.5.0) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        if (!_safeTransfer(token, to, value, true)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        if (!_safeTransferFrom(token, from, to, value, true)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _safeTransfer(token, to, value, false);
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _safeTransferFrom(token, from, to, value, false);
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        if (!_safeApprove(token, spender, value, false)) {
            if (!_safeApprove(token, spender, 0, true)) revert SafeERC20FailedOperation(address(token));
            if (!_safeApprove(token, spender, value, true)) revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that relies on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that relies on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Oppositely, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity `token.transfer(to, value)` call, relaxing the requirement on the return value: the
     * return value is optional (but if data is returned, it must not be false).
     *
     * @param token The token targeted by the call.
     * @param to The recipient of the tokens
     * @param value The amount of token to transfer
     * @param bubble Behavior switch if the transfer call reverts: bubble the revert reason or return a false boolean.
     */
    function _safeTransfer(IERC20 token, address to, uint256 value, bool bubble) private returns (bool success) {
        bytes4 selector = IERC20.transfer.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(to, shr(96, not(0))))
            mstore(0x24, value)
            success := call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
        }
    }

    /**
     * @dev Imitates a Solidity `token.transferFrom(from, to, value)` call, relaxing the requirement on the return
     * value: the return value is optional (but if data is returned, it must not be false).
     *
     * @param token The token targeted by the call.
     * @param from The sender of the tokens
     * @param to The recipient of the tokens
     * @param value The amount of token to transfer
     * @param bubble Behavior switch if the transfer call reverts: bubble the revert reason or return a false boolean.
     */
    function _safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value,
        bool bubble
    ) private returns (bool success) {
        bytes4 selector = IERC20.transferFrom.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(from, shr(96, not(0))))
            mstore(0x24, and(to, shr(96, not(0))))
            mstore(0x44, value)
            success := call(gas(), token, 0, 0x00, 0x64, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
            mstore(0x60, 0)
        }
    }

    /**
     * @dev Imitates a Solidity `token.approve(spender, value)` call, relaxing the requirement on the return value:
     * the return value is optional (but if data is returned, it must not be false).
     *
     * @param token The token targeted by the call.
     * @param spender The spender of the tokens
     * @param value The amount of token to transfer
     * @param bubble Behavior switch if the transfer call reverts: bubble the revert reason or return a false boolean.
     */
    function _safeApprove(IERC20 token, address spender, uint256 value, bool bubble) private returns (bool success) {
        bytes4 selector = IERC20.approve.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(spender, shr(96, not(0))))
            mstore(0x24, value)
            success := call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
        }
    }
}

// src/BTCVault.sol

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
     * @notice Approve (sign) a proposal. Does NOT auto-execute.
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

        emit ProposalApproved(proposalId, msg.sender, p.signatures.length);
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

        p.executed = true;

        (bool sent, ) = p.to.call{value: p.amount}("");
        if (!sent) revert TransferFailed();

        emit ProposalExecuted(proposalId, p.to, p.amount);
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

// src/BTCVaultFactory.sol

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
