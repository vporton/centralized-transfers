//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

// import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract ServerAddressQuery is Ownable {
    address public server;

    constructor(address _server) {
        server = _server;
    }

    function setServer(address _server) public {
        server = _server;
        emit ServerAddressChanged(_server);
    }

    event ServerAddressChanged(address server);
}
