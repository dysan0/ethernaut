# Vault

Difficulty 3/10

Unlock the vault to pass the level!

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Vault {
  bool public locked;
  bytes32 private password;

  constructor(bytes32 _password) public {
    locked = true;
    password = _password;
  }

  function unlock(bytes32 _password) public {
    if (password == _password) {
      locked = false;
    }
  }
}
```

# Solution

This challenge is based on the fact that storage slots in solidity can be accessed. The blockchain is public so all the secrets and variables can be accessed.

Solidity EVM stores state variables in slots. In this contract two slots are used (Slot 0 and Slot 1).

```
bool public locked - Slot 0
bytes32 private password - Slot 1
```

To access the storage slots of a contract you can use `web3.eth.getStorageAt(contractAddress, slotNumber)` function.

To solve this challenge, run the following command in the browser console to get the password stored in Slot 1, `await web3.eth.getStorageAt(contract.address, 1)`. The result of this is `0x412076657279207374726f6e67207365637265742070617373776f7264203a29`.

Submit the password using the `unlock()` function, `contract.unlock("0x412076657279207374726f6e67207365637265742070617373776f7264203a29")`

# Completion Message

```
Level completed!

Difficulty 3/10

It's important to remember that marking a variable as private only prevents other contracts from accessing it. State variables marked as private and local variables are still publicly accessible.

To ensure that data is private, it needs to be encrypted before being put onto the blockchain. In this scenario, the decryption key should never be sent on-chain, as it will then be visible to anyone who looks for it. zk-SNARKs provide a way to determine whether someone possesses a secret parameter, without ever having to reveal the parameter. (https://blog.ethereum.org/2016/12/05/zksnarks-in-a-nutshell/)
```
