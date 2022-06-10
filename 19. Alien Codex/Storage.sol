//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Storage {
    //slot 0
    bytes32 slot0 = 0x1111111111111111111111111111111111111111111111111111111111111111;
    
    //slot 1
    bytes32[] public codex;

    constructor() public{
        bytes32 slot1_mem_address = keccak256(abi.encode(1));
        bytes32 array_mem_address = keccak256(abi.encode( slot1_mem_address ));
        
        //codex[0] - slot # {slot1_mem_address}
        codex.push(array_mem_address); //codex[0] = object addrs of codex[0]; key = slot1_mem_address, value=object addrs of codex[0]
        
        
        bytes32 element1_key = bytes32(uint(slot1_mem_address)+1);
        //codex[1] -- slot # {element1_key}
        codex.push(element1_key); //codex[1] = key => value=key

        bytes32 element2_key = bytes32(uint(slot1_mem_address)+2);
        //codex[2] -- slot # {element2_key}
        codex.push(element2_key); //codex[2] = key => value=key

        bytes32 element3_key = bytes32(uint(slot1_mem_address)+3);
        array_mem_address = keccak256(abi.encode( element3_key ));
        //codex[3] -- slot # {element3_key}
        codex.push(array_mem_address); //codex[3] = object addrs of codex[3]; key = element2_key, value=object addrs of codex[3]

        bytes32 element4_key = bytes32(uint(slot1_mem_address)+4);
        //codex[4] -- slot # {element4_key}
        array_mem_address = keccak256(abi.encode( element4_key ));
        codex.push(array_mem_address); //codex[4] = object addrs of codex[4]; key = element3_key, value=object addrs of codex[4]
        
    }


//keccak256(i)
//0 - 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
//1 - 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
//2 - 0x405787fa12a823e0f2b7631cc41b3ba8828b3321ca811111fa75cd3aa3bb5ace
//3 - 0xc2575a0e9e593c00f959f8c92f12db2869c3395a3b0502d05e2516446f71f85b

//storage is key->value based
//slot# = key
//object location = keccak256(key)
//for arrays, 
// array declaration stores array.length in next available slot # (lets say slot #X)
// array element [0] is stored in slot number keccak256(slot #X)+0, key=keccak256(slot #X)+0, object location = keccak256(key)
// array element [1] is stored in slot number keccak256(slot #X)+1, key=keccak256(slot #X)+1, object location = keccak256(key)
// array element [2] is stored in slot number keccak256(slot #X)+2, key=keccak256(slot #X)+2, object location = keccak256(key)


//storage map
//slot# 0 - bytes32 slot0
//    Object: keccak256(key) = keccak256(0)
//    0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
//    key: 
//    0x0000000000000000000000000000000000000000000000000000000000000000
//    value:
//    0x1111111111111111111111111111111111111111111111111111111111111111

//storage map
//slot# 1 - bytes32[] public codex.length
//    Object:	keccak256(key) = keccak256(1)
//    0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
//    key:
//    0x0000000000000000000000000000000000000000000000000000000000000001
//    value:
//    0x0000000000000000000000000000000000000000000000000000000000000005

//storage map - codex[0]
//slot# 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6 
//    Object:	keccak256(key) = keccak256(0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6)
//    0xb5d9d894133a730aa651ef62d26b0ffa846233c74177a591a4a896adfda97d22
//    key:
//    0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6 
//    value:
//    0xb5d9d894133a730aa651ef62d26b0ffa846233c74177a591a4a896adfda97d22

//storage map - codex[1]
//slot# 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf7 
//    Object:	keccak256(key) = keccak256(0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf7) 
//    0xea7809e925a8989e20c901c4c1da82f0ba29b26797760d445a0ce4cf3c6fbd31
//    key:
//    0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf7 
//    value:
//    0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf7

//storage map - codex[2]
//slot# 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf8
//    Object:	keccak256(key) = keccak256(0xb32787652f8eacc66cda8b4b73a1b9c31381474fe9e723b0ba866bfbd5dde02b)
//    0xb32787652f8eacc66cda8b4b73a1b9c31381474fe9e723b0ba866bfbd5dde02b
//    key:
//    0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf8
//    value:
//    0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf8

//storage map - codex[3]
//slot# 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf9
//    Object:	keccak256(key) = keccak256(0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf9)
//    0xeec2ab63f4cd97b3799d9fb76fab247ec6b49ef064d9b5e6c242d49631a19ee9
//    key:
//    0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf9
//    value:
//    0xeec2ab63f4cd97b3799d9fb76fab247ec6b49ef064d9b5e6c242d49631a19ee9

//storage map - codex[4]
//slot# 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cfa
//    Object:	keccak256(key) = keccak256(0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cfa)
//    0x83fae7d88d3202765861d3bf8af4fff3ab5293dab6070c6fa8f55d3c5e93a72c
//    key:
//    0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cfa
//    value:
//    0xeec2ab63f4cd97b3799d9fb76fab247ec6b49ef064d9b5e6c242d49631a19ee9

}