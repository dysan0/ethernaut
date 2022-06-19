# Dex
Difficulty 3/10

The goal of this level is for you to hack the basic DEX contract below and steal the funds by price manipulation.

You will start with 10 tokens of token1 and 10 of token2. The DEX contract starts with 100 of each token.

You will be successful in this level if you manage to drain all of at least 1 of the 2 tokens from the contract, and allow the contract to report a "bad" price of the assets.

 
Quick note

Normally, when you make a swap with an ERC20 token, you have to approve the contract to spend your tokens for you. To keep with the syntax of the game, we've just added the approve method to the contract itself. So feel free to use contract.approve(contract.address, <uint amount>) instead of calling the tokens directly, and it will automatically approve spending the two tokens by the desired amount. Feel free to ignore the SwappableToken contract otherwise.

Things that might help:

* How is the price of the token calculated?
* How does the swap method work?
* How do you approve a transaction of an ERC20?

``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Dex is Ownable {
  using SafeMath for uint;
  address public token1;
  address public token2;
  constructor() public {}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }
  
  function addLiquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  
  function swap(address from, address to, uint amount) public {
    require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapPrice(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  }

  function getSwapPrice(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint amount) public {
    SwappableToken(token1).approve(msg.sender, spender, amount);
    SwappableToken(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableToken is ERC20 {
  address private _dex;
  constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply) public ERC20(name, symbol) {
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
The best way to start with this channel is to deploy the contract on remix and play around with adding liquidity and swapping the tokens. 

We have a set of 10 initial tokens. We want to use the Dex to drain the liquidity. 

I started working on the solution in remix. I would deploying the contracts on remix as follow:

1. Deploy Dex contract
2. Deploy SwapToken1
3. Deploy SwapToken2
4. Update `Dex-ter.sol` solution with the new addresses for Dex, Token1, Token2.
5. Transfer ownership of dex contract to the `Dex-ter.sol` contract.
6. Transfer all the tokens to `Dex-ter.sol` contract.
7. Call `s_balanceof()` function, it will return the contract's balance of both tokens.
8. Call `s_addliquidity()` to approve withdrawal of tokens by Dex, and add liquidity.
9. Call `s_swap()` to drain the dex liquidity. 
10. Call `s_balanceof` to check contract's balance of tokens.

So here is a table of how things will look like after each time all of token1 is swapped for token 2 (back and forth). Count is the number of times tokens have been swapped. It takes about 6 trades to drain the dex liquidity for one of the tokens. The last trade (count=6) has to be a partial trade. You can only trade 45 token 1s for 110 token 2s. As the Dex doesn't have enough tokens for a full swap.

| | | | | | |
|---|---|---|---|---|---|
| Count |token1 balance contract| token2 balance contract| dex_balance_token1| dex_balance_token2| swapprice next count (amount*to/from)|
| 0 | 10 | 10 | 100 | 100 | 10  = (10*100/100) |
| 1 | 20 | 0 | 90 | 110 | 24 = (20*110/90) |
| 2 | 0 | 24 | 110 | 86 | 30  = (24*110/86) |
| 3 | 30 | 0 | 80 | 110 | 41 = (30*110/80) |
| 4 | 0 | 41 | 110 | 69 | 65 = (41*110/69) |
| 5 | 65 | 0 | 45 | 110 | 158 = (65*110/45) |
| 6 | Reverts
| 6 (Fixed) | 20 | 110 | 90 | 0 | ...
| | | | | | |

If you look at the numbers above you notice that the dex is leaking tokens. This is due to the fact that the contract is doing integer division and not real number division.

Metamask seems to have a freezing issue performing the approval `approve()` for this challenge. The issue seems to be around approving two tokens. You can use a different wallet or follow this [solution](https://www.youtube.com/watch?v=5ZLgOUCmgb8). Basically use remix to `import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol"` and add the contract at address of token1 and token2. You then can call the `approval()` from the remix or `transfer()`.

The `Dexter.sol` contract automates the solution, however you need to transfer the tokens from your account to the `Dexter.sol` contract. You need to add the two ERC20 token contracts in remix and transfer the tokens to the deployed `Dexter.sol` contract. You can use the `ERC20Helper.sol` contract to add the two tokens at the specific address and do the transfer.

Prior to deplying `Dexter.sol`, you need to update the `_dex`, `_token1` and `_token2` addresses in the `Dexter.sol` contract. Deploy the contract and call `s_swap()` 6 times.

You can get the token1 and token2 addresses by running `token1= await contract.token1()` and `token2= await contract.token2()` in the browser. The dex address is `contract.address`

The `Dexter.sol` contract contains a few helper functions that helps solving the challenge in remix and understanding the vulnerability better.

# Completion Message
```
Level completed!

Difficulty 3/10

The integer math portion aside, getting prices or any sort of data from any single source is a massive attack vector in smart contracts.

You can clearly see from this example, that someone with a lot of capital could manipulate the price in one fell swoop, and cause any applications relying on it to use the the wrong price.

The exchange itself is decentralized, but the price of the asset is centralized, since it comes from 1 dex. This is why we need oracles. Oracles are ways to get data into and out of smart contracts. We should be getting our data from multiple independent decentralized sources, otherwise we can run this risk.

Chainlink Data Feeds are a secure, reliable, way to get decentralized data into your smart contracts. They have a vast library of many different sources, and also offer secure randomness, ability to make any API call, modular oracle network creation, upkeep, actions, and maintainance, and unlimited customization.

Uniswap TWAP Oracles relies on a time weighted price model called TWAP. While the design can be attractive, this protocol heavily depends on the liquidity of the DEX protocol, and if this is too low, prices can be easily manipulated.
```

