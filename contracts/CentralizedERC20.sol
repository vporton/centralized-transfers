//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Instant } from "./Instant.sol";

abstract contract CentralizedERC20 is Centralized, ERC20 {
    using SafeMath for uint256;

    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    { }
}
