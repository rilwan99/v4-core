// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {Currency, CurrencyLibrary} from "./types/Currency.sol";
import {IMinimalBalance} from "./interfaces/IMinimalBalance.sol";

/// An intentionally barebone balance mapping only supporting mint/burn/transfer
contract MinimalBalance is IMinimalBalance {
    using CurrencyLibrary for Currency;
    // Mapping from Currency id to account balances

    mapping(uint256 => mapping(address => uint256)) public balances;

    /// @inheritdoc IMinimalBalance
    function balanceOf(address account, Currency currency) public view returns (uint256) {
        return balances[currency.toId()][account];
    }

    /**
     * @notice Mint `amount` of `id` and send it to `to`
     *     @param to The address to send the minted tokens to
     *     @param id The id of the token to mint
     *     @param amount The amount to mint
     */
    function _mint(address to, uint256 id, uint256 amount) internal {
        balances[id][to] += amount;
        emit Mint(to, id, amount);
    }

    /**
     * @notice Burn `amount` of `id` from `msg.sender`
     *     @param id The id of the token to burn
     *     @param amount The amount to burn
     *  @dev Will revert if the sender does not have enough balance
     */
    function _burn(uint256 id, uint256 amount) internal {
        balances[id][msg.sender] -= amount;
        emit Burn(msg.sender, id, amount);
    }

    /// @inheritdoc IMinimalBalance
    function transfer(address to, Currency currency, uint256 amount) public {
        uint256 id = currency.toId();
        balances[id][msg.sender] -= amount;
        balances[id][to] += amount;
        emit Transfer(msg.sender, to, id, amount);
    }
}
