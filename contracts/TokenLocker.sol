//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { ServerAddressQuery } from "./ServerAddressQuery.sol";

// TODO: Do we need maxLockTime? The user could choose himself. But we may hold his privkey in the game app.
// FIXME: `set*` functions need to require that the request comes from a DAO.
abstract contract TokenLocker is Context {
    ServerAddressQuery serverAddressQuery;

    uint public maxLockTime;
    uint public maxLockTimeHardLimit;

    mapping(address => uint) public userUnlockTimes;

    constructor(ServerAddressQuery _serverAddressQuery) {
        serverAddressQuery = _serverAddressQuery;
    }

    function setServerAddressQuery(ServerAddressQuery _serverAddressQuery) public {
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
        uint _newLockThreshold = block.timestamp + _lockTime;
        require(userUnlockTimes[_msgSender()] <= _newLockThreshold, "Attempt to shorten a lock."); // either unlocked or we prolong
        userUnlockTimes[_msgSender()] = _newLockThreshold;
        emit LockUser(_msgSender(), _lockTime);
    }

    function unlockUser(address _account) onlyServer public {
        userUnlockTimes[_account] = 0;
        emit UnlockUser(_account);
    }

    function isUserLocked(address _account) public view returns (bool) {
        return userUnlockTimes[_account] != 0 && userUnlockTimes[_account] > block.timestamp;
    }

    function isServer() public view returns (bool) {
        return address(serverAddressQuery) != address(0) && _msgSender() == serverAddressQuery.server();
    }

    function canTransfer(address _account) public view returns (bool) {
        return isUserLocked(_account) ? isServer() : _msgSender() == _account;
    }

    modifier onlyServer {
        require(isServer(), "Only server.");
        _;
    }

    event SetMaxLockTime(uint _maxLockTime);

    event SetMaxLockTimeHardLimit(uint maxLockTimeHardLimit);

    event LockUser(address account, uint lockTime);

    /// Not emitted on timer unlocks.
    event UnlockUser(address account);
}
