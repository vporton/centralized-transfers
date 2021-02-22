//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Centralized } from "./Centralized.sol";
import { ServerAddressQuery } from "./ServerAddressQuery.sol";

contract CentralizedERC20 is Centralized, ERC20 {
    constructor(ServerAddressQuery _serverAddressQuery, string memory name_, string memory symbol_)
        Centralized(_serverAddressQuery) ERC20(name_, symbol_)
    { }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        require(isServer() || !isUserLocked(from), "Centralized transfers mode.");
        super._beforeTokenTransfer(from, to, amount);
    }
}
