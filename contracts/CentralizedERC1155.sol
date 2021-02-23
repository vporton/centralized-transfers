//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { Chain } from "./Chain.sol";

abstract contract CentralizedERC1155 is Chain, ERC1155 {
    constructor(string memory uri_)
        ERC1155(uri_)
    { }
}
