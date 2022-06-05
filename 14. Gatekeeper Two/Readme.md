# Gatekeeper Two
Difficulty: 6/10

This gatekeeper introduces a few new challenges. Register as an entrant to pass this level.
Things that might help:

* Remember what you've learned from getting past the first gatekeeper - the first gate is the same.
* The assembly keyword in the second gate allows a contract to access functionality that is not native to vanilla Solidity. See here for more information. The extcodesize call in this gate will get the size of a contract's code at a given address - you can learn more about how and when this is set in section 7 of the yellow paper.
* The ^ character in the third gate is a bitwise operation (XOR), and is used here to apply another common bitwise operation (see here). The Coin Flip level is also a good place to start when approaching this challenge.


``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }
    require(x == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == uint64(0) - 1);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}
```


# Solution
Similar to last level, this level has 3 gates that need to be bypassed.

## gateOne()
The solution for gateOne() is identical to the solution from level 13. This means the function enter needs to be called by a contract. `tx.origin` is original wallet address, and `msg.sender` is the contract address. 

## gateTwo()
This is an interesting gate. The assembly code `extcodesize()` returns the size of the contract code. The address for the contract is passed to the function as a parameter. In this instance, caller() is passed, which is equivalent to `msg.sender()`. 

This modifier requires the size of the contract that calls it to be equal to 0. Searching the [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf) for `extcodesize` returns the following:

```
During initialization code execution, EXTCODESIZE on the address should return zero, which is the length of the code of the account while CODESIZE should return the length of the initialization code (as defined in H.2).
```

Basically if the contract is being initialized (running the constructor), the function `extcodesize` will return `0`. Having this piece of information, to solve gateTwo(), we would have to  want to call gateTwo() from the constructor of the solution contract.


## gateThree()
This version of solidity doesn't have safe math, so `uint64(0) - 1` will cause an underflow `0xffffffffffffffff`. So we have to xor `uint64(bytes8(keccak256(abi.encodePacked(msg.sender))))` with `uint64(_gateKey)` to get `0xffffffffffffffff`. 

A little about XOR, we know that:

`1 ^ 1 = 0`

`0 ^ 0 = 0`

`1 ^ 0 = 1`

`0 ^ 1 = 1`

Basically, if we XOR a number by bitwise NOT of itself, it will give us `1`, ex. `1 ^ !(1) = 1`, `1 ^ !(0) = 1`.

So if we XOR `uint64(bytes8(keccak256(abi.encodePacked(msg.sender))))` with it's bitwise NOT, it should give us the uint64 bit version of the key.

The code can be viewed in `GateKnocker.sol`.

As you deploy the contract, the conttructor is ran and solves the level. 

You can verify you've been added as an entrant by running `await contract.entrant()` to see if your wallet address has been added.

# Completion Message
```
Level completed!

Way to go! Now that you can get past the gatekeeper, you have what it takes to join theCyber, a decentralized club on the Ethereum mainnet. Get a passphrase by contacting the creator on reddit or via email and use it to register with the contract at gatekeepertwo.thecyber.eth (be aware that only the first 128 entrants will be accepted by the contract).
```

