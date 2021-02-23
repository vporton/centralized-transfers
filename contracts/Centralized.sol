//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { ServerAddressQuery } from "./ServerAddressQuery.sol";
import { TokenLocker } from "./TokenLocker.sol";

abstract contract Centralized is Context {
    TokenLocker public locker;

    constructor(TokenLocker _locker) {
        locker = _locker;
    }

    function isUserLocked(address _account) internal view returns (bool) {
        return locker.isUserLocked(_account);
    }

    function isServer() internal view returns (bool) {
        return locker.isServer();
    }

    function canCentralized(address _account) internal view returns (bool) {
        return locker.canCentralized(_account);
    }

    modifier onlyUnlocked {
        require(!isUserLocked(_msgSender()), "Transfers are locked.");
        _;
    }

    modifier allowCentralized(address _account) {
        require(canCentralized(_account), "Transfers locked.");
        _;
    }
}
