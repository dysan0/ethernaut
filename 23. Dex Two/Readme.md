# Dex Two
Difficulty 4/10

This level will ask you to break DexTwo, a subtlely modified Dex contract from the previous level, in a different way.

You need to drain all balances of token1 and token2 from the DexTwo contract to succeed in this level.

You will still start with 10 tokens of token1 and 10 of token2. The DEX contract still starts with 100 of each token.

Things that might help:

*  How has the swap method been modified?
*  Could you use a custom token contract in your attack?


``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract DexTwo is Ownable {
  using SafeMath for uint;
  address public token1;
  address public token2;
  constructor() public {}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }

  function add_liquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  
  function swap(address from, address to, uint amount) public {
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapAmount(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  } 

  function getSwapAmount(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint amount) public {
    SwappableTokenTwo(token1).approve(msg.sender, spender, amount);
    SwappableTokenTwo(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableTokenTwo is ERC20 {
  address private _dex;
  constructor(address dexInstance, string memory name, string memory symbol, uint initialSupply) public ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public returns(bool){
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}
```

# Solution
If you compare the Dex2 code vs the Dex code, you will notice a the difference between the swap functions:

Difference (this line is removed in Dex2):

`require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");`

This difference introduces a vulnerability that any token can be swapped for the token1 or token2.

The denominator for the `getSwapAmount()` function divides by the balance of `from` tokens in the contract address. We could arbitrary send 1 fake token to this contract and swap 1 fake token to drain all of the selected token. Basically we want to make sure `amount/ERC20(from).balanceOf(address(this))` equals to `1`. As shown here:

`return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));`

To solve this challenge, I created a fake token `DBZ`. Sent 1 Fake token to the DEX, and swapped 1 `DBZ` token to drain all of token 1. Then I swapped 2 'DBZ' tokens to drain all of token 2.

The code can be found in `DexterTwo.sol`


# Completion Message
```
Dex Two
Level completed!

Difficulty 4/10

As we've repeatedly seen, interaction between contracts can be a source of unexpected behavior.

Just because a contract claims to implement the ERC20 spec does not mean it's trust worthy.

Some tokens deviate from the ERC20 spec by not returning a boolean value from their transfer methods. See Missing return value bug - At least 130 tokens affected (https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca).

Other ERC20 tokens, especially those designed by adversaries could behave more maliciously.

If you design a DEX where anyone could list their own tokens without the permission of a central authority, then the correctness of the DEX could depend on the interaction of the DEX contract and the token contracts being traded.
```

