// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockMUSD
 * @notice Minimal ERC-20 mock for the mUSD stablecoin used in tests.
 */
contract MockMUSD is ERC20 {
    constructor() ERC20("Mock mUSD", "mUSD") {}

    /// @notice Anyone can mint (test only).
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
