//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract Chain is Context {
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(bytes("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"));
    function chainId() internal pure virtual returns (uint256);
    function myAppName() internal pure virtual returns (string memory);
    function myAppVersion() internal pure virtual returns (string memory);
    function verifyingContract() internal pure virtual returns (address);
    function salt() internal pure virtual returns (bytes32);
    // string private constant EIP712_DOMAIN = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)";
    function DOMAIN_SEPARATOR() internal pure returns(bytes32) {
        return keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes(myAppName())),
            keccak256(bytes(myAppVersion())),
            chainId(),
            verifyingContract(),
            salt()
        ));
    }

    // TODO: What about several chains of signatures per user? It can be used if we have several servers.
    mapping(address => bytes32) public lastSignatures;

    // TODO: Why so complex?
    function hash(bytes32 _previousSignature, bytes memory _data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\\x19\\x01",
            DOMAIN_SEPARATOR(),
            keccak256(abi.encode(
                    // BID_TYPEHASH,
                    _previousSignature,
                    _data
                    // hashIdentity(bid.bidder)
                ))
            ));
    }

    function calculateAddress(bytes32 _previousSignature, bytes memory _data, bytes32 sigR, bytes32 sigS, uint8 sigV) internal pure returns (address) {
        return ecrecover(hash(_previousSignature, _data), sigV, sigR, sigS);
    }

    function verify(address _initiator, bytes32 _previousSignature, bytes memory _data, bytes32 sigR, bytes32 sigS, uint8 sigV) internal pure returns (bool) {
        return _initiator == calculateAddress(_previousSignature, _data, sigR, sigS, sigV);
    }

    function checkSignature(address _initiator, bytes32 _previousSignature, bytes memory _data, bytes32 sigR, bytes32 sigS, uint8 sigV) internal pure {
        require(verify(_initiator, _previousSignature, _data, sigR, sigS, sigV), "Wrong signature.");
    }

    modifier commitOperation(address _initiator, bytes memory _data, bytes32 sigR, bytes32 sigS, uint8 sigV)
        /*onlyServer*/
    {
        bytes32 _previousSignature = lastSignatures[_initiator];
        checkSignature(_initiator, _previousSignature, _data, sigR, sigS, sigV);
        bytes32 _signature = keccak256(abi.encodePacked(_previousSignature, _data));
        _;
        lastSignatures[_initiator] = _signature;
    }
}
