# Telephone

Difficulty 1/10

Claim ownership of the contract below to complete this level.

Things that might help

- See the Help page above, section "Beyond the console"

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Telephone {

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}
```

# Solution

The things to note here is to understand the difference between `tx.origin` and `msg.sender`. Here are some key differences([ref](https://ethereum.stackexchange.com/questions/1891/whats-the-difference-between-msg-sender-and-tx-origin)):

- tx.origin can never be a contract address.
- msg.owner can be a contract address.
- A->B->C
  - My Wallet -(calls)-> TelCheat -(calls)-> Telephone
    - Inside Telephone > msg.sender(TelCheat contract address)
    - Inside Telephone > tx.orgin (My Wallet address)

To solve this challenge, deploy the `TelCheat.sol` contract and run `cheat()` function.

The solution can be viewed in `TelCheat.sol`.

# Completion Message

```
Telephone
Level completed!

Difficulty 1/10

While this example may be simple, confusing tx.origin with msg.sender can lead to phishing-style attacks, such as [this](https://blog.ethereum.org/2016/06/24/security-alert-smart-contract-wallets-created-in-frontier-are-vulnerable-to-phishing-attacks/).

An example of a possible attack is outlined below.

    1. Use tx.origin to determine whose tokens to transfer, e.g.

function transfer(address _to, uint _value) {
  tokens[tx.origin] -= _value;
  tokens[_to] += _value;
}

    2. Attacker gets victim to send funds to a malicious contract that calls the transfer function of the token contract, e.g.

function () payable {
  token.transfer(attackerAddress, 10000);
}

    3. In this scenario, tx.origin will be the victim's address (while msg.sender will be the malicious contract's address), resulting in the funds being transferred from the victim to the attacker.

```
