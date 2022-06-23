# Puzzle Wallet

Difficulty 7/10

Nowadays, paying for DeFi operations is impossible, fact.

A group of friends discovered how to slightly decrease the cost of performing multiple transactions by batching them in one transaction, so they developed a smart contract for doing this.

They needed this contract to be upgradeable in case the code contained a bug, and they also wanted to prevent people from outside the group from using it. To do so, they voted and assigned two people with special roles in the system: The admin, which has the power of updating the logic of the smart contract. The owner, which controls the whitelist of addresses allowed to use the contract. The contracts were deployed, and the group was whitelisted. Everyone cheered for their accomplishments against evil miners.

Little did they know, their lunch money was at risk…

You'll need to hijack this wallet to become the admin of the proxy.

Things that might help::

* Understanding how delegatecalls work and how msg.sender and msg.value behaves when performing one.
* Knowing about proxy patterns and the way they handle storage variables.


``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/UpgradeableProxy.sol";

contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;
    address public admin;

    constructor(address _admin, address _implementation, bytes memory _initData) UpgradeableProxy(_implementation, _initData) public {
        admin = _admin;
    }

    modifier onlyAdmin {
      require(msg.sender == admin, "Caller is not the admin");
      _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    using SafeMath for uint256;
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
      require(address(this).balance == 0, "Contract balance is not 0");
      maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
      require(address(this).balance <= maxBalance, "Max balance reached");
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] = balances[msg.sender].sub(value);
        (bool success, ) = to.call{ value: value }(data);
        require(success, "Execution failed");
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}
```

# Solution
There are a few different of things going on in this challenge. 

## Delegatecall
As in the previous challenges we learned that `delegatecall` does a call to a function within the storage context of the contract that called `delegatecall`. So if contract A does delegatecall to contract b, `msg.value` and `msg.sender` would be the `msg.value` and `msg.sender` of contract A.

## Proxy Contracts
As contracts in solidity are immutable, there is no way to update them unless you've thought about the update at the time of deployment.

Proxy contracts are patterns that allow some upgradeability for contracts. Here is a helpful video on [proxy contracts](https://piped.kavin.rocks/watch?v=bdXJmWajZRY).

An important thing to know is that proxy patterns share storage between the proxy and the logic of the contract. Therefore it's important that the declaration of variables in logic contract are identical to the proxy contract. As the logic contract can overwrite variables in the proxy contract (which is the same storage). This challenge is a transparent upgradable proxy pattern. In other words the two above contract `PuzzleWallet()` and `PuzzleProxy()` share the same storage.

If you map the storage of the two contracts, you see that `pendingAdmin` and `owner` are stored in the same storage slot. This means by setting `pendingAdmin`, you can set `owner` of the `PuzzleWallet()`.

```
Slot #1: 
(PuzzleProxy()) address public pendingAdmin => (PuzzleWallet()) address public owner
```

The objective of this challenge is to take over the admin in the`PuzzleProxy()` contract (or storage slot #2). The storage slot #2, can be accessed by accessing `maxBalance` in the `PuzzleWallet()`.

The function `setMaxBalance()` allows setting of `maxBalance`. This function has the modifier `onlyWhitelisted`. This modifier enforces that only whitelisted addresses can call a function with this modifier. The function `addToWhitelist()` allows to add new addresses to the whitelist. The function  `addToWhitelist()` can only be called by the owner due to the require statement in the function.

A contract can become the owner of `PuzzleWallet()` by setting `pendingAdmin` in `PuzzleProxy()`. The owner of `PuzzleWallet()` can then whitelist any address to call any function that has the `onlyWhitelisted()` modifier.

Another thing to note is that the function `setMaxBalance()` can only set `maxBalance` if the current contract balance is 0. The contract balance starts with `0.001 ether` or `1000000000000000 wei`. 

The function `deposit()` in `PuzzleWallet()` allows whitelisted users to deposit eth into the contract.

The function `execute()` allows users to withdraw their balance.

The function `multicall()` allows whitelisted users to make multiple calls to the `PuzzleWallet()` contract.

## Vulnerability
The vulnerability lies in the fact that `multicall()` can delegatecall `deposit()` multiple times. This means the contract would incorrectly track a users balance, due to the fact that `msg.value` and `msg.sender` for delegate call are same with the `multicall()`.

The `multicall()` function has a require statement that only allows calling `deposit()` once. However the vulnerability is that you can actually call deposit multiple times by utilizing multicall(deposit()). Basically you need to create a multicall bytes[] array that contains two calls:

```
1st call - deposit() with the value that is stored in the contract (0.001 ether).
2nd call - multicall(abi.encodeWithSignature("deposit()")) 
```

Both calls will have the same `msg.value` which would result the user balance to be 2x what they actually deposited or what's in the contract. So when the user calls withdraw, they can withdraw 2x their deposit and drain the contract.

To create the muticall bytes[] array, you can calculate the function selector for `deposit()` by selecting the first 4 bytes of `abi.encodeWithSignature("deposit()")`, which is ` 0xd0e30db0`.

To calculate the bytes representation of `multicall(abi.encodeWithSignature("deposit()"))` you can call multicall function in remix with bytes[] `0xd0e30db0` and copying the bytes input from the call logs. This input is:

```
0xac9650d8
0000000000000000000000000000000000000000000000000000000000000020
0000000000000000000000000000000000000000000000000000000000000001
0000000000000000000000000000000000000000000000000000000000000020
0000000000000000000000000000000000000000000000000000000000000004
d0e30db000000000000000000000000000000000000000000000000000000000
```

`0xac9650d8` is the function selector for multicall, and the rest of the data is a bytes[1] array that contains function selector for `deposit()`, `0xd0e30db0`.

## Putting it together
To put the solution together, you need to:

1. call proposeNewAdmin(attacker_address)
2. call addToWhitelist(attacker_address)
3. build your multicall_data for calling deposit() and multicall(deposit())
4. call multicall{value:0.001 ether}(multicall_data) to exploit vulnerability
5. call execute(attacker_address,0.002 ether, hex"") to withdraw funds
6. call setMaxBalance(uint(attacker_address));

You can view the solution in `Walletsnatcher.sol`, deploy the contract and call snatch() with 1000000000000000 wei.

# Completion Message
```
Puzzle Wallet
Level completed!

Difficulty 7/10

Next time, those friends will request an audit before depositing any money on a contract. Congrats!

Frequently, using proxy contracts is highly recommended to bring upgradeability features and reduce the deployment's gas cost. However, developers must be careful not to introduce storage collisions, as seen in this level.

Furthermore, iterating over operations that consume ETH can lead to issues if it is not handled correctly. Even if ETH is spent, msg.value will remain the same, so the developer must manually keep track of the actual remaining amount on each iteration. This can also lead to issues when using a multi-call pattern, as performing multiple delegatecalls to a function that looks safe on its own could lead to unwanted transfers of ETH, as delegatecalls keep the original msg.value sent to the contract.

Move on to the next level when you're ready!
```
