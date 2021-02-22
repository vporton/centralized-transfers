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
        emit SetMaxLockTime(_maxLockTime);
    }

    function setMaxLockTimeHardLimit(uint _maxLockTimeHardLimit) public {
        require(_maxLockTimeHardLimit > maxLockTimeHardLimit, "Trying to increase the hard limit.");
        maxLockTimeHardLimit = _maxLockTimeHardLimit;
        emit SetMaxLockTimeHardLimit(_maxLockTimeHardLimit);
    }

    function lockUser(uint _lockTime) public {
        require(_lockTime <= maxLockTime, "maxLockTime violated.");
        userUnlockTimes[_msgSender()] = block.timestamp + _lockTime;
        emit LockUser(_msgSender(), _lockTime);
    }

    function unlockUser(address _account) onlyServer public {
        userUnlockTimes[_account] = 0;
        emit UnlockUser(_account);
    }

    function isUserLocked(address _account) internal view returns (bool) {
        return userUnlockTimes[_account] != 0 && userUnlockTimes[_account] > block.timestamp;
    }

    function isServer() internal view returns (bool) {
        return _msgSender() == serverAddressQuery.server();
    }

    function canTransfer(address _account) internal view returns (bool) {
        return isUserLocked(_account) ? isServer() : _msgSender() == _account;
    }

    modifier onlyUnlocked {
        require(!isUserLocked(_msgSender()), "Transfers are locked.");
        _;
    }

    modifier onlyServer {
        require(isServer(), "Only server.");
        _;
    }

    modifier transferPermit(address _account) {
        require(canTransfer(_account), "Transfers locked.");
        _;
    }

    event SetMaxLockTime(uint _maxLockTime);

    event SetMaxLockTimeHardLimit(uint maxLockTimeHardLimit);

    event LockUser(address account, uint lockTime);

    /// Not emitted on timer unlocks.
    event UnlockUser(address account);
}
