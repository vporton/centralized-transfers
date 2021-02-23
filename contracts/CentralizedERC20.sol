//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Chain } from "./Chain.sol";

abstract contract CentralizedERC20 is Chain, ERC20 {
    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    { }
}
