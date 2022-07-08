# Gatekeeper One

Difficulty 5/10

Make it past the gatekeeper and register as an entrant to pass this level.

Things that might help:

- Remember what you've learned from the Telephone and Token levels.
- You can learn more about the special function gasleft(), in Solidity's documentation (see here and here).

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract GatekeeperOne {

  using SafeMath for uint256;
  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(gasleft().mod(8191) == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}
```

# Solution

This challenge has 3 modifiers or "gates" to be bypassed, to register as an entrant for this challenge.

## gateOne()

This modifier requires `msg.sender != tx.origin`. This means the value of `msg.sender` can't be equal to `tx.origin`. This is true when the `msg.sender` is a contract, `tx.origin` would be the original wallet address (EOA, externally owned address). Basically, this gate is bypassed if a contract is calling `enter()` function.

## gateTwo()

This gate was one of the most time consuming gates to bypass in all of the ethernaut challenges for me.

Here is the require statement for this gate:

```solidity
require(gasleft().mod(8191) == 0);
```

This gate requires the gas left when the moded with 8191 to be 0, which means the gas left when the contract runs `gasleft()` needs to be a multiple of 8191.

To find the correct amount of gas to send, I spent a lot of time in remix debugger. After about what seemed to be eternity and tracing gasleft() calls, I found the correct gas to send is `60033`.

Things that were helpful were knowing `gas()` opcode used 2 gas. When debugging with remix, go to where the code was reverted and move back until you see the gas call or line 313(EQ). When line 313 is highlighted the top value on the stack is the result of `gasleft().mod(8191)`. You can use this number to figure out how much more or less gas you need to send. You will have to do this a few times to find the correct gas amount. What's interesting is that depending on the amount of gas sent, the gas usage changes.

## gateThree()

This gate takes an input parameter, bytes8 \_gatekey, and it has 3 require statements. We need to derive the gatekey so the require statements evaluate to true to unlock this gate.

We know the \_gatekey is bytes8, eg. `00 00 00 00 00 00 00 00`.

The gatekey: `XX XX XX XX XX XX XX XX`.

```
a byte   =>                      'XX'
a uint16 =>                   'XX XX'
a uint32 =>             'XX XX XX XX'
a uint64 => 'XX XX XX XX XX XX XX XX'
```

### First Part

This is the first require statement:

`require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");`

We know `uint16` is `2 bytes`, and `uint32` is `4 bytes`.

This require statement is basically saying the 2 bytes truncated gatekey is same as 4 bytes truncated key.

```
a uint16 =>       'XX XX'
a uint32 => 'XX XX XX XX'
```

This means the two bytes on the left of uint32 have to be `0`. From this require statement we gather:

The gatekey: `XX XX XX XX 00 00 XX XX`.

### Second Part

This is the second require statement:

`require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");`

This require statement is basically saying the 4 bytes truncated gatekey is different than the 8 bytes key. Basically, these two need to be different:

```
a uint32 =>             'XX XX XX XX'
a uint64 => 'XX XX XX XX XX XX XX XX'
```

From this require statement, we gather that one or more of the `Y` in the gatekey have to be `1`.

The gatekey: `YY YY YY YY 00 00 XX XX`.

### Third Part

This is the third require statement:

`require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three");`

This require statement is saying the 4 bytes truncated of gatekey is equal to the 2 bytes truncated of `tx.origin` (EOA, externally owned address).

So for example if my dev wallet address is `0xd69DFe5AE027B4912E384B821afeB946592fb648`. The 2 bytes truncated `tx.origin` is `b6 48`.

This would make the gatekey: `YY YY YY YY 00 00 b6 48`, where one or more of the `Y` are `1`, eg. `00 00 00 01 00 00 b6 48` or `0x000000010000b648`.

### Solving this challenge

The solution code for this challenge is provided in `GateCrushor.sol`. To solve this challenge deploy the contract and call `crush()` with the gatekey (`0x000000010000b648`), the last 2 bytes of the gatekey needs to be same as the last 2 bytes of your wallet address. You need to ensure the gas you send when calling `crush()` is set to `60033`.

# Completion Message

```
Level completed!

Difficulty 5/10

Well done! Next, try your hand with the second gatekeeper...
```
