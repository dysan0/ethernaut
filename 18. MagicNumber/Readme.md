# MagicNumber
Difficulty 6/10

To solve this level, you only need to provide the Ethernaut with a `Solver`, a contract that responds to `whatIsTheMeaningOfLife()` with the right number.

Easy right? Well... there's a catch.

The solver's code needs to be really tiny. Really reaaaaaallly tiny. Like freakin' really really itty-bitty tiny: 10 opcodes at most.

Hint: Perhaps its time to leave the comfort of the Solidity compiler momentarily, and build this one by hand O_o. That's right: Raw EVM bytecode.

Good luck!

``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract MagicNum {

  address public solver;

  constructor() public {}

  function setSolver(address _solver) public {
    solver = _solver;
  }

  /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
  */
}
```

# Solution
This was a challenging level. First you need to know that `whatIsTheMeaningOfLife()` is `42` or `0x2a` in hex (from hitchhiker guide to the galaxy). Then you will need to learn about EVM, bytecode, op codes, storage,etc... I learned that EVM operates on last in first out for the instructions (LIFO). 

Here are the resources that was very helpful in solving this challenge:

* [ethervm.io](https://ethervm.io/)


We need to write this function, but it needs to be less than 10 opcodes:

``` solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Solution{
    function whatIsTheMeaningOfLife() pure external returns(uint){
      return 42;
    }
}
```

So we can write this in assembly and it would look like this:

``` solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Solution{
    function whatIsTheMeaningOfLife() pure external returns(uint){
        assembly { 
            mstore(0x00, 0x2a) // Store 42 in memory address 0
            return(0x00, 0x20) // return memory at address 0 with 0x20 length
        }
    }
}
```

From remix you can get the opcode for the above code:

```
PUSH1 0x80 PUSH1 0x40 MSTORE CALLVALUE DUP1 ISZERO PUSH1 0xF JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH1 0x8C DUP1 PUSH2 0x1E PUSH1 0x0 CODECOPY PUSH1 0x0 RETURN INVALID PUSH1 0x80 PUSH1 0x40 MSTORE CALLVALUE DUP1 ISZERO PUSH1 0xF JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH1 0x4 CALLDATASIZE LT PUSH1 0x28 JUMPI PUSH1 0x0 CALLDATALOAD PUSH1 0xE0 SHR DUP1 PUSH4 0x650500C1 EQ PUSH1 0x2D JUMPI JUMPDEST PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH1 0x33 PUSH1 0x49 JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 DUP3 DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST PUSH1 0x0 PUSH1 0x2A PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 RETURN INVALID LOG2 PUSH5 0x6970667358 0x22 SLT KECCAK256 CALLDATACOPY MSTORE8 SSTORE 0xA5 DIFFICULTY EXP PUSH11 0xDE6A298A158D834660B3AE SUB LOG1 SMOD RETURNDATASIZE SWAP14 0x22 0xD7 0x28 PUSH4 0xA44ED072 PUSH22 0x64736F6C634300060300330000000000000000000000 
```

It turns out even the above code is too large. So we need to get it smaller. If you look in the above code and look for `mstore` and `0x2a`, you see the following sequence `PUSH1 0x2A PUSH1 0x0 MSTORE`.  Also if you look for the return, you will see the following sequence `PUSH1 0x20 PUSH1 0x0 RETURN`.

Cleaning this up we get

```
PUSH1 0x2A //this pushes 0x2A to the stack
PUSH1 0x0  //this pushes 0x0 to the stack
MSTORE //this calls mstore with the two parameters that were stored in the stack.
```
and 

```
PUSH1 0x20 //this pushes 0x20 to the stack
PUSH1 0x0 //this pushes 0x0 to the stack
RETURN
```

So putting these two set together we get:

```
PUSH1 0x2A  //this pushes 0x2A to the stack
PUSH1 0x0   //this pushes 0x0 to the stack
MSTORE      //this calls mstore with the two parameters that were stored in the stack.
PUSH1 0x20  //this pushes 0x20 to the stack
PUSH1 0x0   //this pushes 0x0 to the stack
RETURN
```

This code will store return 42.

Each instruction has associated number opcode, you can view these code on ethervm.io. The above code:

```
PUSH1 - 60
MSTORE - 52
Return - F3
```

Replacing the code with the numerical representations:

```
60 2A   //this pushes 0x2A to the stack
60 00   //this pushes 0x0 to the stack
52      //this calls mstore with the two parameters that were stored in the stack.
60 20   //this pushes 0x20 to the stack
60 00   //this pushes 0x0 to the stack
F3      //Return
```

Putting the above together we get `602A60005260206000F3`. This OPCode will return 42. This opcode is 10 (0x0a) bytes. We need to create a contract with this opcode as the main contract.

The easy way to do this is to create a contract that the constructor returns `0x602A60005260206000F3`. This will create a contract with `0x602A60005260206000F3` as the main contract. The code for this is provided in `solver.sol`.

Deploy this contract and set the solver by running `await contract.setSolver('addressofsolvercontract')`, eg. `await contract.setSolver('0x9ec65413078413081C50D12093E2D0A55B3E5Be1')`. Submit the instance to solve the level.


# Completion Message
```
Level completed!

Congratulations! If you solved this level, consider yourself a Master of the Universe.

Go ahead and pierce a random object in the room with your Magnum look. Now, try to move it from afar; Your telekinesis abilities might have just started working.
```

