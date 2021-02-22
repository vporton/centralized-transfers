//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { ServerAddressQuery } from "./ServerAddressQuery.sol";

abstract contract Centralized is Context {
    ServerAddressQuery serverAddressQuery;

    uint public maxLockTime;
    uint public maxLockTimeHardLimit;

    mapping(address => uint) public userUnlockTimes;

    constructor(ServerAddressQuery _serverAddressQuery) {
        serverAddressQuery = _serverAddressQuery;
    }

    function setMaxLockTime(uint _maxLockTime) public {
        require(_maxLockTime <= maxLockTimeHardLimit, "Trying to violate the hard time limit.");
        maxLockTime = _maxLockTime;
    }

    function setmaxLockTimeHardLimit(uint _maxLockTimeHardLimit) public {
        require(_maxLockTimeHardLimit > maxLockTimeHardLimit, "Trying to increase the hard limit.");
        maxLockTimeHardLimit = _maxLockTimeHardLimit;
    }

    function lockUser(uint _lockTime) public {
        require(_lockTime <= maxLockTime, "maxLockTime violated.");
        userUnlockTimes[_msgSender()] = block.timestamp + _lockTime;
    }

    function unlockUser(address _account) onlyServer public {
        userUnlockTimes[_account] = 0;
    }

    function isUserLocked(address _account) public view returns (bool) {
        return userUnlockTimes[_account] != 0 && userUnlockTimes[_account] > block.timestamp;
    }

    modifier onlyUnlocked {
        require(!isUserLocked(_msgSender()), "Transfers are locked.");
        _;
    }

    modifier onlyServer {
        require(_msgSender() == serverAddressQuery.server(), "Only server.");
        _;
    }
}
