# Recovery
Difficulty 6/10

A contract creator has built a very simple token factory contract. Anyone can create new tokens with ease. After deploying the first token contract, the creator sent 0.001 ether to obtain more tokens. They have since lost the contract address.

This level will be completed if you can recover (or remove) the 0.001 ether from the lost contract address.

``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts@3.4/math/SafeMath.sol';

contract Recovery {

  //generate tokens
  function generateToken(string memory _name, uint256 _initialSupply) public {
    new SimpleToken(_name, msg.sender, _initialSupply);
  
  }
}

contract SimpleToken {

  using SafeMath for uint256;
  // public variables
  string public name;
  mapping (address => uint) public balances;

  // constructor
  constructor(string memory _name, address _creator, uint256 _initialSupply) public {
    name = _name;
    balances[_creator] = _initialSupply;
  }

  // collect ether in return for tokens
  receive() external payable {
    balances[msg.sender] = msg.value.mul(10);
  }

  // allow transfers of tokens
  function transfer(address _to, uint _amount) public { 
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = _amount;
  }

  // clean up after ourselves
  function destroy(address payable _to) public {
    selfdestruct(_to);
  }
}
```

# Solution
There are different ways to solve this one.

## Initial Solution
Initially, I used etherscan to solve this. After you create the instance, you receive the instance address, in my case `0x72B69B34e89fCDA5555754B311d8FB4407D3647A`. Looking at this address in etherscan (under internal tx), I can see this contract creates 1 other contract.

* 0x5b32719703714fd92a316a5ed4bf1d0153eb447f

Viewing this address, `0x5B32719703714fd92A316a5ED4BF1d0153eB447F`, in etherscan shows that it holds '0.001` ether. This is likely the missing contract address.

Add the above solidity code in remix and add the contract 'SimpleToken' that's deployed at address `0x5B32719703714fd92A316a5ED4BF1d0153eB447F`.

Call the `destory()` with your address to recover the funds.

After I solved the solution, the completion messaged referred to a post by Martin Swende. This blog post no longer exists, so I used way back machine to access the [article](https://web.archive.org/web/20180217184613/http://martin.swende.se/blog/Ethereum_quirks_and_vulns.html).

## Solution 2
Okay, so after I read the article, I tried solving it the way the blog wanted us to solve it. It took my a while and I had to look at other solutions.

Basically, we need to drive the contract addresses from the level instance address '0x72B69B34e89fCDA5555754B311d8FB4407D3647A'.
   
So the formula to derive the new contract address is `address = sha3(rlp_encode(creator_account, creator_account_transaction_nonce))[12:]`, or the rightmost 160bits (20 bytes) of the Keccak hash of the RLP encoding of the address and the account transaction nonce. I don't fully understand what RLP encoding is, other than the fact it's a type of encoding. Once I will have some time, I will have to dig into RLP encoding to better understand it.


```
Essentially, a contract's address is just the keccak256 hash of the account that created it concatenated with the accounts transaction nonce[^2]. The same is true for contracts, except contracts nonce's start at 1 whereas address's transaction nonce's start at 0.
[^2]: A transaction nonce is like a transaction counter. It increments ever time a transaction is sent from your account.
```
[ref](https://modex.tech/developers/idiana96/solidity-security-blog#keyless-eth)

I used this [website](https://toolkit.abdk.consulting/ethereum#rlp) to calculate rlp_encode(creator_account,nonce) (ex. `"0x72B69B34e89fCDA5555754B311d8FB4407D3647A","0x01"`. The result is for nonce `0x01` is:

```
rlp("0x72B69B34e89fCDA5555754B311d8FB4407D3647A","0x01")=0xd69472b69b34e89fcda5555754b311d8fb4407d3647a01
```

I took the result and put it inside the following code to get the keccak and the right most 20 bytes (40 digits from the right). 

`'0x' + web3.utils.sha3("0xd69472b69b34e89fcda5555754b311d8fb4407d3647a01").slice(-40)`

This returned `0x5B32719703714fd92A316a5ED4BF1d0153eB447F`, the address to the lost contract.

Also, you can use [this](https://github.com/nikeshnazareth/ethernaut-attempt/blob/master/migrations/level18.js) code to calculate the address in javascript.

``` Javascript
    const targetAddress = '72B69B34e89fCDA5555754B311d8FB4407D3647A';
    const encodeNonce = '01';
    
    // encodeAddr = "94<targetAddress>" or "9472B69B34e89fCDA5555754B311d8FB4407D3647A" 
    const encodeAddr = (0x80 + targetAddress.length / 2).toString(16) + targetAddress;

    //for 2 digit Nonce encodeList = "d69472B69B34e89fCDA5555754B311d8FB4407D3647A01"
    const encodeList = (0xc0 + encodeAddr.length / 2 + encodeNonce.length / 2).toString(16) + encodeAddr + encodeNonce;

    const tokenContractAddress = '0x' + (await web3.utils.keccak256(`0x${encodeList}`)).slice(26); // skip '0x' + 12 bytes * 2 hex characters
```

Another solution I've seen that simplified the above calculation is the following:

``` Javascript
'0x'+ web3.utils.soliditySha3("0xd6","0x94","address","nonce").slice(-40)
```

Running this `'0x'+ web3.utils.soliditySha3("0xd6","0x94","0x72B69B34e89fCDA5555754B311d8FB4407D3647A","0x01").slice(-40)` returns `0x5B32719703714fd92A316a5ED4BF1d0153eB447F`.

Things to do, is learn more about RPL and implement this solution in solidity. 

# Completion Message
```
Level completed!

Difficulty 6/10

Contract addresses are deterministic and are calculated by keccack256(address, nonce) where the address is the address of the contract (or ethereum address that created the transaction) and nonce is the number of contracts the spawning contract has created (or the transaction nonce, for regular transactions).

Because of this, one can send ether to a pre-determined address (which has no private key) and later create a contract at that address which recovers the ether. This is a non-intuitive and somewhat secretive way to (dangerously) store ether without holding a private key.

An interesting blog(http://martin.swende.se/blog/Ethereum_quirks_and_vulns.html) post by Martin Swende details potential use cases of this.

If you're going to implement this technique, make sure you don't miss the nonce, or your funds will be lost forever.
```

