# Force

Difficulty 5/10

Some contracts will simply not take your money ¯\_(ツ)\_/¯

The goal of this level is to make the balance of the contract greater than zero.

Things that might help:

- Fallback methods
- Sometimes the best way to attack a contract is with another contract.
- See the Help page above, section "Beyond the console"

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}
```

# Solution

After doing a little bit of research there are 3 ways to send a contract ether:

1. via payable functions
2. receiving mining reward
3. from a destroyed contract

When you call `selfdestruct(address)`, the contract will delete itself and send the balance to the address specified. This address could be a contract address.

To solve this challenge, you need to create a contract and fund it with some eth, then `selfdestruct()` the contract with the instance address. This will cause the contract to send the eth to the instance address.

The solution is provided in `ForcePay.sol` contract. Deploy this contract and fund it with some eth by calling `collect()`. You can then call `close()` to selfdestruct the contract and send the eth to the instance level.

# Completion Message

```
Level completed!

Difficulty 5/10

In solidity, for a contract to be able to receive ether, the fallback function must be marked payable.

However, there is no way to stop an attacker from sending ether to a contract by self destroying. Hence, it is important not to count on the invariant address(this).balance == 0 for any contract logic.
```
