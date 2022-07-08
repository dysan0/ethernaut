//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ForcePay {
    address payable originalAddress =
        payable(0x29055f813573C0dAE812a534BcEF3cC7156015B9);

    function collect() public payable returns (uint) {
        return address(this).balance;
    }

    function balance() public view returns (uint) {
        return address(this).balance;
    }

    function close() public {
        selfdestruct(originalAddress);
    }
}
