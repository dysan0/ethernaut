//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DelegationCheat {
    function encode() public pure returns (bytes memory) {
        return abi.encodeWithSignature("pwn()");
    }
}
