//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { Centralized } from "./Centralized.sol";
import { ServerAddressQuery } from "./ServerAddressQuery.sol";

contract CentralizedERC1155 is Centralized, ERC1155 {
    constructor(ServerAddressQuery _serverAddressQuery, string memory uri_)
        Centralized(_serverAddressQuery) ERC1155(uri_)
    { }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        transferPermit(from)
        internal virtual override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
