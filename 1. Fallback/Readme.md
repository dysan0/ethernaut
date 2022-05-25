# Fallback
Difficulty: 1/10

Look carefully at the contract's code below.

You will beat this level if

* you claim ownership of the contract
* you reduce its balance to 0

Things that might help

* How to send ether when interacting with an ABI
* How to send ether outside of the ABI
* Converting to and from wei/ether units (see help() command)
* Fallback methods


``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract Fallback {

  using SafeMath for uint256;
  mapping(address => uint) public contributions;
  address payable public owner;

  constructor() public {
    owner = msg.sender;
    contributions[msg.sender] = 1000 * (1 ether);
  }

  modifier onlyOwner {
        require(
            msg.sender == owner,
            "caller is not the owner"
        );
        _;
    }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    owner.transfer(address(this).balance);
  }

  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
}
```


# Solution
## fallback vs receive()
First part to understand for solving this challenge is what is the difference between fallback() and receive() functions. 

fallback or receive is the function that is called when a function to call does not exist.

Here is the flow chart on which is called based on the scenario:([smartcontract.engineer](https://www.smartcontract.engineer)):

```
/*
Which function is called, fallback() or receive()?

    Ether is sent to contract
               |
        is msg.data empty?
              / \\
            yes  no
            /     \\
receive() exists?  fallback()
         /   \\
        yes   no
        /      \\
    receive()   fallback()
*/
```

The second part is to review the contract provided in this challenge, more specifically the receive() function.

``` Solidity
  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
```

This function will set owner to the msg.sender (the address calling the contract) if the condition in the require statement are met. To make sure this condition is met, you need to make sure you send some eth to the receive function and also `contributions[msg.sender]` is greater than 0.

You can contribute to the contract by using the command `contract.contribute.sendTransaction({value:1)`

You can check your contribution by running `(await contract.getContribution()).toString()` or `(await contract.contributions(player)).toString()`.

Now to call the receive() function we use the command `await contract.sendTransaction({value: 1})`

You can check to see if you're now the owner by running the command `(await contract.owner() === player)`. This should return true if you're the owner.

The objective of this challenge is to reduce the balance of the contract to 0. So now, you need to withdraw the funds using the command `await contract.withdraw()`


# Completion Message
```
Level completed!

You know the basics of how ether goes in and out of contracts, including the usage of the fallback method.

You've also learnt about OpenZeppelin's Ownable contract, and how it can be used to restrict the usage of some methods to a privileged address.

Move on to the next level when you're ready!
```

