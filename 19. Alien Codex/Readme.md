# Alien Codex
Difficulty: 7/10

You've uncovered an Alien contract. Claim ownership to complete the level.

Things that might help

* Understanding how array storage works
* Understanding ABI [specifications](https://solidity.readthedocs.io/en/v0.4.21/abi-spec.html)
* Using a very underhanded approach


``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import '../helpers/Ownable-05.sol';

contract AlienCodex is Ownable {

  bool public contact;
  bytes32[] public codex;

  modifier contacted() {
    assert(contact);
    _;
  }
  
  function make_contact() public {
    contact = true;
  }

  function record(bytes32 _content) contacted public {
  	codex.push(_content);
  }

  function retract() contacted public {
    codex.length--;
  }

  function revise(uint i, bytes32 _content) contacted public {
    codex[i] = _content;
  }
}
```

# Solution
This challenge teaches you about solidity EVM storage.

Solidity EVM storage consists of `slots`. The slots are 32 bytes (256 bits). There are 2^256 slots available. The first slot is Slot #0, and the last slot is Slot # 2^256-1. The data in the storage units are stored in (key, value) pairs. The key is the slot number, and the solidity contract data is stored in value.

There are 3 different properties associated to each slot. 
* Slot # or Slot Key (key) [range: 0 to 2^256-1]
* Slot Value
* Object location(address?) [equals to SHA-3(key) or keccak256(key)]

Solidity starts storing data from Slot #0 (Slot Key=0). The value you store in a slot (ex. Slot #0), will be assigned to Slot Value. The object location is derived from calculating the SHA3 of the slot key `keccak256(key)`.

Here are the object location for the first 4 slots.
```
Slot # - keccak256 (key)
Slot 0 - keccak256(0) - 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
Slot 1 - keccak256(1) - 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
Slot 2 - keccak256(2) - 0x405787fa12a823e0f2b7631cc41b3ba8828b3321ca811111fa75cd3aa3bb5ace
Slot 3 - keccak256(3) - 0xc2575a0e9e593c00f959f8c92f12db2869c3395a3b0502d05e2516446f71f85b
```

When declaring arrays in solidity, the evm stores the array length in the next available slot (for example slot #X (key=X)). The first element of the array (array[0]) will be located in slot number [keccak256(slot #X)+0] (i.e. key=keccak256(slot #X)+0 with object location of keccak256(key)). The second element of the array (array[1]) will be located in slot number [keccak256(slot #X)+1] (i.e. key=keccak256(slot #X)+1 with object location of keccak256(key)), and so on.

In summary, for arrays:
* array declaration stores array.length in next available slot # (lets say slot #X)
* array[0]:
  * Slot number: keccak256(slot #X)+0 
  * Key=keccak256(slot #X)+0 
  * Object location=keccak256(key) = keccak256(keccak256(slot #X)+0)
* array[1]:
  * Slot number: keccak256(slot #X)+1 
  * Key=keccak256(slot #X)+1 
  * Object location=keccak256(key) = keccak256(keccak256(slot #X)+1)
* array[2]:
  * Slot number: keccak256(slot #X)+2
  * Key=keccak256(slot #X)+2 
  * Object location=keccak256(key) = keccak256(keccak256(slot #X)+2)

To better understand the storage mechanism for solidity review `storage.sol`.

The other key note is that if you're trying to access a value at index Y, the length of the array needs to be greater than index Y.

Now reviewing the solidity code for this challenge, you see it is decrementing condex.length `codex.length--`. If the length is 0 and you decrement this value, it will cause an underflow (ex. 0x0-0x1 = 0xF). So You can cause a underflow by calling the function `retract()`. This function has a modifier `contacted`


The `contacted` modifier checks to see if the value `contact` has been set to true. You can set this value by calling the function `make_contact()`. 

So running the following commands will cause an underflow:

``` javascript
await contract.make_contact()
await contract.retract()
```

The `codex.length` will be 0xFFF..FFF (32bytes). This condition allows us to overwrite any slot number we want using the `revise(uint i, bytes32 _content)` function. The `contact` bool variable and the owner are stored in slot #0. You can view what's stored in slot 0 by deploying the contract in remix and using the debug feature to view the storage. Slot 0 contains `0x000000000000000000000001<owneraddress>`. The `1` before the `<owneraddress>`, is the `contact` value, and it's packed in the same slot as `<owneraddress>`.

To solve this challenge you need to overwrite slot # 0, with `0x000000000000000000000001<your wallet address>`, after you've `make_contact` and `retract`. 

To overwrite slot #0, you need to call `revise` with the correct `uint i` and `bytes32 _content`. The `_content` will be `0x000000000000000000000001<your wallet address>`.

To calculate `i`, you need to figure out the slot number (key) codex[0] is stored in. Once you find the slot slot number, you need to find how many slots you need to add to get the last slot number + 1 (which is slot #0). The `codex.length` is stored in slot #1. Based on how solidity stores arrays, the slot number for codex[0] is:

```
uint codex_memory_address = uint(keccak256(abi.encode(1))); //slot 1 memory address => key of codex[0] - slot # for codex[0]
```

We know the last slot is `uint last_slot = 2**256-1;`. Relative to codex[0], we can derive that slot 0 is `uint i= last_slot - codex_memory_address + 1`.

Putting it all together we have the following function to calculate `i`:

``` solidity
function calUnderflow() contacted public view returns (uint) {
    uint codex_memory_address = uint(keccak256(abi.encode(1))); //slot 1 memory address => key of codex[0] - slot # for codex[0]
    uint last_slot = 2**256-1; //2^256 - 1 , 32 bytes addresses - 256 bits - max possibilities 2^256, as it starts from 0, it's 2^256-1
    
    uint i= last_slot - codex_memory_address + 1;
    return i;
}

```

This function returns i, `35707666377435648211887908874984608119992236509074197713628505308453184860938`.

To overwrite slot 0 and add yourself as the owner (where my wallet address is `d69DFe5AE027B4912E384B821afeB946592fb648`), you need to call

``` javascript
await contract.make_contact()
await contract.retract()
await contract.revise('35707666377435648211887908874984608119992236509074197713628505308453184860938', '0x000000000000000000000001d69DFe5AE027B4912E384B821afeB946592fb648')
```

The code for `calUnderflow()` is provided in `AlienCodex.sol`. 

# Completion Message
```
Level completed!

This level exploits the fact that the EVM doesn't validate an array's ABI-encoded length vs its actual payload.

Additionally, it exploits the arithmetic underflow of array length, by expanding the array's bounds to the entire storage area of 2^256. The user is then able to modify all contract storage.

Both vulnerabilities are inspired by 2017's [Underhanded coding contest](https://medium.com/@weka/announcing-the-winners-of-the-first-underhanded-solidity-coding-contest-282563a87079)
```

