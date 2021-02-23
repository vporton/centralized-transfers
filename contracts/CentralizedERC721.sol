//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Chain } from "./Chain.sol";

abstract contract CentralizedERC721 is Chain, ERC721 {
    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    { }
}
