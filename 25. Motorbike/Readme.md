# Motorbike

Difficulty 6/10

Ethernaut's motorbike has a brand new upgradeable engine design.

Would you be able to selfdestruct its engine and make the motorbike unusable ?

Things that might help:

* [EIP-1967](https://eips.ethereum.org/EIPS/eip-1967)
* [UUPS upgradeable pattern](https://forum.openzeppelin.com/t/uups-proxies-tutorial-solidity-javascript/7786)
* [Initializable contract](https://github.com/OpenZeppelin/openzeppelin-upgrades/blob/master/packages/core/contracts/Initializable.sol)


``` Solidity
// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/proxy/Initializable.sol";

contract Motorbike {
    // keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    
    struct AddressSlot {
        address value;
    }
    
    // Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
    constructor(address _logic) public {
        require(Address.isContract(_logic), "ERC1967: new implementation is not a contract");
        _getAddressSlot(_IMPLEMENTATION_SLOT).value = _logic;
        (bool success,) = _logic.delegatecall(
            abi.encodeWithSignature("initialize()")
        );
        require(success, "Call failed");
    }

    // Delegates the current call to `implementation`.
    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    // Fallback function that delegates calls to the address returned by `_implementation()`. 
    // Will run if no other function in the contract matches the call data
    fallback () external payable virtual {
        _delegate(_getAddressSlot(_IMPLEMENTATION_SLOT).value);
    }

    // Returns an `AddressSlot` with member `value` located at `slot`.
    function _getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r_slot := slot
        }
    }
}

contract Engine is Initializable {
    // keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    address public upgrader;
    uint256 public horsePower;

    struct AddressSlot {
        address value;
    }

    function initialize() external initializer {
        horsePower = 1000;
        upgrader = msg.sender;
    }

    // Upgrade the implementation of the proxy to `newImplementation`
    // subsequently execute the function call
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable {
        _authorizeUpgrade();
        _upgradeToAndCall(newImplementation, data);
    }

    // Restrict to upgrader role
    function _authorizeUpgrade() internal view {
        require(msg.sender == upgrader, "Can't upgrade");
    }

    // Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) internal {
        // Initial upgrade and setup call
        _setImplementation(newImplementation);
        if (data.length > 0) {
            (bool success,) = newImplementation.delegatecall(data);
            require(success, "Call failed");
        }
    }
    
    // Stores a new address in the EIP1967 implementation slot.
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        
        AddressSlot storage r;
        assembly {
            r_slot := _IMPLEMENTATION_SLOT
        }
        r.value = newImplementation;
    }
}
```

# Solution
To learn about upgrading smart contracts watch this [video](https://piped.kavin.rocks/watch?v=bdXJmWajZRY).


* Proxies Terms
  * Implementation Contract - has the Logic of our protocol. When we upgrade we launch brand new implementation contract.
  * Proxy Contract - points to implementation is the "correct" one, and routes to correct implementation contract.
  * user makes calls through proxy.
  * Admin allows upgrade.
  * All storage variables are stored in proxy contract.

Proxy Gotchas:
* Storage Clashes
  * Both proxy and implmentation contract use the same storage
* Function Selector Clashes
  * Possible both contracts have the same selector

Four common upgrade patterns:
* Social YEET/Migration - people migration
* Transparent Proxy Patter:
  * Admins can't call implementation contract functions.
  * Users can only call implementation contract functions
  * Implementations can't have constructor, it needs to have initializer. 
* Universal Upgradable Proxys (UUPS) -
  * All the logic of upgrading is in the implementation 
  * A little smaller and saves gas
* Diamond Patten
  * Allows for multiple implementation contract
  * A lot more complicated code
  * Very advance

The contract in this challenge is using a UUPS proxy pattern. This means the upgrade logic is in the implementation contract.

The vulnerability lies that the Proxy contract points to the implementation contract, and the implementation contract itself is never initialized (directly). The implementation contract is initialized through the proxy contract, which means the data is stored in the proxy contract. This means someone could directly initialize the implementation contract and make a call to upgrade and call a self destruct function in another contract. This would break the proxy contract.

You can find the implementation contract address by running `await web3.eth.getStorageAt('0xc0f42A2A2e30B7d189cDBe72492D22a3372EAF7A','0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc')` where `0xc0f42A2A2e30B7d189cDBe72492D22a3372EAF7A` is your level address.

The code for doing this is available in `Mechanic.sol`. Replace the Implementation address with the correct address. Deploy this contract and call the `Fix()` function to self destruct the implementation contract.

# Completion Message
```
Level completed!

Difficulty 6/10

The advantage of following an UUPS pattern is to have very minimal proxy to be deployed. The proxy acts as storage layer so any state modification in the implementation contract normally doesn't produce side effects to systems using it, since only the logic is used through delegatecalls.

This doesn't mean that you shouldn't watch out for vulnerabilities that can be exploited if we leave an implementation contract uninitialized.

This was a slightly simplified version of what has really been discovered after months of the release of UUPS pattern.

Takeways: never leaves implementation contracts uninitialized ;)

If you're interested in what happened, read more [here](https://forum.openzeppelin.com/t/uupsupgradeable-vulnerability-post-mortem/15680).
```
