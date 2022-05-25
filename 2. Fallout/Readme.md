# Fallout
Difficulty: 2/10

Claim ownership of the contract below to complete this level.

Things that might help

* Solidity Remix IDE


``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract Fallout {
  
  using SafeMath for uint256;
  mapping (address => uint) allocations;
  address payable public owner;


  /* constructor */
  function Fal1out() public payable {
    owner = msg.sender;
    allocations[owner] = msg.value;
  }

  modifier onlyOwner {
	        require(
	            msg.sender == owner,
	            "caller is not the owner"
	        );
	        _;
	    }

  function allocate() public payable {
    allocations[msg.sender] = allocations[msg.sender].add(msg.value);
  }

  function sendAllocation(address payable allocator) public {
    require(allocations[allocator] > 0);
    allocator.transfer(allocations[allocator]);
  }

  function collectAllocations() public onlyOwner {
    msg.sender.transfer(address(this).balance);
  }

  function allocatorBalance(address allocator) public view returns (uint) {
    return allocations[allocator];
  }
}
```


# Solution
The contract code above has a typo in it. The constructor is spelled out `Fal1out()` instead of `Fallout()`. Due to this typo and the fact the function has the modifier public, it can be called from outside of the contract at any time. Typically constructors are called at the time of contract deployment.

First, check to see who the owner is by using the command `await contract.owner()`. This shows you owner is address(0), which makes sense, cause the constructor was never actually called due to the typo.

You want to call the Fal1out() by running the command 
`await contract.Fal1out.sendTransaction({value:1})`.

You can check to see if that worked by checking your allocations by running the command `(await contract.allocatorBalance(player)).toString()`.

Now collect allocations by running `(await contract.collectAllocations())`.


# Completion Message
```
Level completed!

That was silly wasn't it? Real world contracts must be much more secure than this and so must it be much harder to hack them right?

Well... Not quite.

The story of Rubixi is a very well known case in the Ethereum ecosystem. The company changed its name from 'Dynamic Pyramid' to 'Rubixi' but somehow they didn't rename the constructor method of its contract:

contract Rubixi {
  address private owner;
  function DynamicPyramid() { owner = msg.sender; }
  function collectAllFees() { owner.transfer(this.balance) }
  ...

This allowed the attacker to call the old constructor and claim ownership of the contract, and steal some funds. Yep. Big mistakes can be made in smartcontractland.
```

