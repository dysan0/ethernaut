# Token

Difficulty 3/10

The goal of this level is for you to hack the basic token contract below.

You are given 20 tokens to start with and you will beat the level if you somehow manage to get your hands on any additional tokens. Preferably a very large amount of tokens.

Things that might help:

- What is an odometer?

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}
```

# Solution

Earlier versions of solidity had no buffer underflow or overflow protections. OpenZeppelin's SafeMath library that automatically checks for overflows in all the mathematical operators.

In Solidity version 0.8 and later, safemath operation was included.

This challenges is using an older version of solidity (0.6.0). The statement `require(balances[msg.sender] - _value >= 0)` will cause a buffer underflow if value is greater than the balance of the user. This means this statement will always be true (eg. 0x00 - 0x01 = 0xFF)

Check to see how many tokens you have by running `(await contract.balanceOf(player)).toString()`.

The solution for this challenge:

```
await (contract.transfer('0x0000000000000000000000000000000000000000',21))
```

You can check your balance after transferring 21 tokens, it should be a very large number.

# Completion Message

```
Token
Level completed!

Difficulty 3/10

Overflows are very common in solidity and must be checked for with control statements such as:

if(a + c > a) {
  a = a + c;
}

An easier alternative is to use OpenZeppelin's SafeMath library that automatically checks for overflows in all the mathematical operators. The resulting code looks like this:

a = a.add(c);

If there is an overflow, the code will revert.

```
