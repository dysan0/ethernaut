# Delegation

Difficulty 4/10

The goal of this level is for you to claim ownership of the instance you are given.

Things that might help

- Look into Solidity's documentation on the delegatecall low level function, how it works, how it can be used to delegate operations to on-chain libraries, and what implications it has on execution scope.
- Fallback methods
- Method ids

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Delegate {

  address public owner;

  constructor(address _owner) public {
    owner = _owner;
  }

  function pwn() public {
    owner = msg.sender;
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  constructor(address _delegateAddress) public {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

  fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
      this;
    }
  }
}
```

# Solution

This challenge is trying to teach us how to use delegatecall and fallback method.

The `fallback()` function is doing a delegatecall with the parameter `msg.data`.

The contract `Delegate` gets called with the storage context of `Delegation`, so basically, `msg.sender` in `Delegate` contract is `msg.sender` in `Delegation`.

You can use `DelegationCheat.sol` to calculate the function signature for `pwn()` function (which is `0xdd365b8b`).

The solution for this challenge is `await contract.sendTransaction({data:'0xdd365b8b'})`

# Completion Message

```
Level completed!

Difficulty 4/10

Usage of delegatecall is particularly risky and has been used as an attack vector on multiple historic hacks. With it, your contract is practically saying "here, -other contract- or -other library-, do whatever you want with my state". Delegates have complete access to your contract's state. The delegatecall function is a powerful feature, but a dangerous one, and must be used with extreme care.

Please refer to the The Parity Wallet Hack (https://blog.openzeppelin.com/on-the-parity-wallet-multisig-hack-405a8c12e8f7) Explained article for an accurate explanation of how this idea was used to steal 30M USD.
```
