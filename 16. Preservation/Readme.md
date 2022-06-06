# Preservation
Difficulty: 8/10

This contract utilizes a library to store two different times for two different timezones. The constructor creates two instances of the library for each time to be stored.

The goal of this level is for you to claim ownership of the instance you are given.

Things that might help

* Look into Solidity's documentation on the delegatecall low level function, how it works, how it can be used to delegate operations to on-chain. libraries, and what implications it has on execution scope.
* Understanding what it means for delegatecall to be context-preserving.
* Understanding how storage variables are stored and accessed.
* Understanding how casting works between different data types.



``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Preservation {

  // public library contracts 
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) public {
    timeZone1Library = _timeZone1LibraryAddress; 
    timeZone2Library = _timeZone2LibraryAddress; 
    owner = msg.sender;
  }
 
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }
}

// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp 
  uint storedTime;  

  function setTime(uint _time) public {
    storedTime = _time;
  }
}
```

# Solution
This is a really fun challenge. 

Here are some notes on delegatecall from [smart contract engineer](https://www.smartcontract.engineer/):

```
delegatecall is like call, except the code of callee is executed inside the caller.

For example contract A calls delegatecall on contract B. Code inside B is executed using A's context such as storage, msg.sender and msg.value.

Storage layout in contract B must be the same as contract A.
```

In this level, the solidity contract is doing a delegatecall, but the storage layout for `LibraryContract` is not the same as `Preservation`. This causes the `timeZone1Library` variable to be overwritten with `storedTime` in `LibraryContract` (in a delegatecall). The variable `StoredTime` is actually a parameter that is passed to `setFirstTime` function.

This means, we can overwrite the address `timeZone1Library`, by calling `setFirstTime()` with any uint256 value. The contract calls delegate call on `timeZone1Library` address. We need to replace the `timeZone1Library` with a malicious address, so when the contract does a delegatecall to the malicious address, it overwrites the `owner` state variable (`LibraryContract1.sol` is the malicious contract).

`Level16.sol` contract calls the `setFirstTime` in the original contract with the malicious contract address. Then it calls the `setFirstTime` again. This time the `setFirstTime` function calls the malicious contract in the context of the original contract. The malicious contract sets `owner` to `tx.origin` which is the deployer address of `Level16.sol` contract. If `msg.sender` is used, then the owner is set to the `Level16.sol` contract address.

One of the challenges I had in this level, metamask was not sending enough gas to complete the delegatecall, but it would show that the transaction was a `success`. Make sure you're setting enough gas for both transactions to go through.

You can verify you've been added as an entrant by running `await contract.owner()` in the browser console to see if your wallet address is the owner. You can also run `await contract.timeZone1Library()` to see if the variable has been overwritten.

The code is provided in `Level16.sol` and `LibraryContract1.sol`. You will need to update the contract address for `LibraryContract1.sol` and Level 13 instance address.

# Completion Message
```
Level completed!

As the previous level, delegate mentions, the use of delegatecall to call libraries can be risky. This is particularly true for contract libraries that have their own state. This example demonstrates why the library keyword should be used for building libraries, as it prevents the libraries from storing and accessing state variables.
```

