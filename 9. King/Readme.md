# King

Difficulty 6/10

The contract below represents a very simple game: whoever sends it an amount of ether that is larger than the current prize becomes the new king. On such an event, the overthrown king gets paid the new prize, making a bit of ether in the process! As ponzi as it gets xD

Such a fun game. Your goal is to break it.

When you submit the instance back to the level, the level is going to reclaim kingship. You will beat the level if you can avoid such a self proclamation.

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract King {

  address payable king;
  uint public prize;
  address payable public owner;

  constructor() public payable {
    owner = msg.sender;
    king = msg.sender;
    prize = msg.value;
  }

  receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    king.transfer(msg.value);
    king = msg.sender;
    prize = msg.value;
  }

  function _king() public view returns (address payable) {
    return king;
  }
}
```

# Solution

In solidity there are 3 ways to send eth:

1.  `transfer()`

    - Notes: (2300 gas, throws errors (reverts))

    - Example: `payable(msg.sender).transfer(address(this).balance);`

1.  `send()`

    - Notes: (2300 gas, returns a boolean (won't reverts if send fails))

    - Example:

      ```Solidity
      bool sendSuccess = payable(msg.sender).send(address(this).balance);
      require (sendSuccess, "Send failed");
      ```

1.  `call()`

    - Notes:
      - lower level command, can call any function
      - forward all gas or set gas, returns bool
    - Example:
      ```Solidity
      (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("");
      require (callSuccess, "Call failed");
      ```

This challenge is using `transfer()`, which means if it fails it `reverts()` the call.

To solve this challenge, we want to become king and prevent others from becoming king (essentially breaking the contract). This can be done by making a contract the king, then revert whenever the contract receives any ether.

You can check the `prize` state variable to see how much wei you need to send to become the king, ` ie. (await contract.prize()).toString()`. You need to send `1000000000000000` wei.

The solution is provided in `KingAttack.sol`. When you deploy the contract, you need to call `makeMeKing()` send `1000000000000000` wei. Make sure you set metamask or your wallet to send enough gas to complete the transaction for `makeMeKing()`.

Once you're the king, submit the level to solve the challenge.

# Completion Message

```
Level completed!

Difficulty 6/10

Most of Ethernaut's levels try to expose (in an oversimplified form of course) something that actually happened — a real hack or a real bug.

In this case, see: King of the Ether and King of the Ether Postmortem. (https://www.kingoftheether.com/thrones/kingoftheether/index.html), (http://www.kingoftheether.com/postmortem.html)
```
