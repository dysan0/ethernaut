# Naught Coin
Difficulty: 6/10

NaughtCoin is an ERC20 token and you're already holding all of them. The catch is that you'll only be able to transfer them after a 10 year lockout period. Can you figure out how to get them out to another address so that you can transfer them freely? Complete this level by getting your token balance to 0.

Things that might help
* The [ERC20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) Spec
* The [OpenZeppelin](https://github.com/OpenZeppelin/zeppelin-solidity/tree/master/contracts) codebase
  
``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts@3.4/token/ERC20/ERC20.sol';

 contract NaughtCoin is ERC20 {

  // string public constant name = 'NaughtCoin';
  // string public constant symbol = '0x0';
  // uint public constant decimals = 18;
  uint public timeLock = now + 10 * 365 days;
  uint256 public INITIAL_SUPPLY;
  address public player;

  constructor(address _player) 
  ERC20('NaughtCoin', '0x0')
  public {
    player = _player;
    INITIAL_SUPPLY = 1000000 * (10**uint256(decimals()));
    // _totalSupply = INITIAL_SUPPLY;
    // _balances[player] = INITIAL_SUPPLY;
    _mint(player, INITIAL_SUPPLY);
    emit Transfer(address(0), player, INITIAL_SUPPLY);
  }
  
  function transfer(address _to, uint256 _value) override public lockTokens returns(bool) {
    super.transfer(_to, _value);
  }

  // Prevent the initial owner from transferring tokens until the timelock has passed
  modifier lockTokens() {
    if (msg.sender == player) {
      require(now > timeLock);
      _;
    } else {
     _;
    }
  } 
} 
```

# Solution
Review the above contract. You can see the developers are trying to restrict the transfer of tokens by using the modifier `lockTokens` and overridding `transfer` function.

To see how many tokens you have you can run the command `(await contract.INITIAL_SUPPLY()).toString()`. 
From the output, you can see that you have `1000000000000000000000000` tokens.


Reading the ERC20 specs, you can see that `transferfrom()` allows the transfer of tokens from the one wallet to another wallet. Which is another way to transfer tokens, other than `transfer()`.

``` Solidity
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
```

Prior to using `transferfrom()`, the token owner wallet have to approve allowance for moving the tokens. This is done using the `approve()` function. The following code is needs to be ran by the token owner, and it's approving (player) `0xd69DFe5AE027B4912E384B821afeB946592fb648` to move `1000000000000000000000000` tokens.

``` Solidity
contract.approve('0xd69DFe5AE027B4912E384B821afeB946592fb648','1000000000000000000000000')
```

Now we can use transferFrom() to empty the wallet (you can transfer them to address(0) as well):
``` Solidity
contract.transferFrom(player, '0x5A7A9517f118dCCEfAFcB6AF99ADD30b904Ce9cb','1000000000000000000000000')
```

# Completion Message
```
Level completed!

When using code that's not your own, it's a good idea to familiarize yourself with it to get a good understanding of how everything fits together. This can be particularly important when there are multiple levels of imports (your imports have imports) or when you are implementing authorization controls, e.g. when you're allowing or disallowing people from doing things. In this example, a developer might scan through the code and think that transfer is the only way to move tokens around, low and behold there are other ways of performing the same operation with a different implementation.
```