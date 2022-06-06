// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract LibraryContract1 {

  // public library contracts 
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint public storedTime;

  function setTime(uint _time) public {
    owner = tx.origin;
  }
}