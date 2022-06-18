# Shop
Difficulty: 4/10

Сan you get the item from the shop for less than the price asked?
Things that might help:

* Shop expects to be used from a Buyer
* Understanding restrictions of view functions


``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}
```

# Solution
The above contract assumes the buyer can't change the price as the `price()` function is a view function. The vulnerability lies in the fact taht the output of the view function `price()` can change based on the `isSold` variable. 

Basically you want to return the price to be `100` or more when it's called the first time, and then `0` when it's called the second time.

To solve this, you need to deploy the `CandyShop.sol` contract and call `callShop()` function.

# Completion Message
```
Level completed!

Difficulty 4/10

Contracts can manipulate data seen by other contracts in any way they want.

It's unsafe to change the state based on external and untrusted contracts logic.
```

