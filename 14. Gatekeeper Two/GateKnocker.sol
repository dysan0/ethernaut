// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IGatekeeperTwo  {
  function enter(bytes8 _gateKey) external  returns (bool);
}

contract GateKnocker {
    IGatekeeperTwo public gko = IGatekeeperTwo(0x255588A97E82b3998B229d154b596FE39fC20f7d);

    constructor() public  {
      bytes8 _gateKey;
      _gateKey = bytes8(calGateKey(address(this)));
      gko.enter(_gateKey);
    }

    function calGateKey(address x) public pure returns (uint64){
      return (~uint64(bytes8(keccak256(abi.encodePacked(x)))));
    }

}
