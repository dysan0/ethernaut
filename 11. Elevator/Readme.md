# Elevator

Difficulty 4/10

This elevator won't let you reach the top of your building. Right?

Things that might help:

- Sometimes solidity is not good at keeping promises.
- This Elevator expects to be used from a Building.

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Building {
  function isLastFloor(uint) external returns (bool);
}


contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

```

# Solution

The vulnerability in this contract is that it's trusting the building contract is an honest actor.

`building.isLastFloor(_floor)` can return one thing once and something else the second time it's called. In this case, we want it to return false first, then true.

The contract to implement this can be found in `Building.sol`. To solve the challenge deploy the contract and call `attack()`.

# Completion Message

```
Level completed!

Difficulty 4/10

You can use the view function modifier on an interface in order to prevent state modifications. The pure modifier also prevents functions from modifying the state. Make sure you read Solidity's documentation and learn its caveats. (http://solidity.readthedocs.io/en/develop/contracts.html#view-functions)

An alternative way to solve this level is to build a view function which returns different results depends on input data but don't modify state, e.g. gasleft().
```
