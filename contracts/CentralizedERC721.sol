//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Centralized } from "./Centralized.sol";
import { ServerAddressQuery } from "./ServerAddressQuery.sol";

contract CentralizedERC721 is Centralized, ERC721 {
    constructor(ServerAddressQuery _serverAddressQuery, string memory name_, string memory symbol_)
        Centralized(_serverAddressQuery) ERC721(name_, symbol_)
    { }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual override returns (bool) {
        return super._isApprovedOrOwner(spender, tokenId) && canTransfer(spender);
    }
}
