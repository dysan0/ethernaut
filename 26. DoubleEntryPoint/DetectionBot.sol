// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IForta {
    function setDetectionBot(address detectionBotAddress) external;
    function notify(address user, bytes calldata msgData) external;
    function raiseAlert(address user) external;
    function usersDetectionBots(address user) external returns (IDetectionBot); 
}

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

interface iDoubleEntryPoint {
    function cryptoVault() external returns (address);
    function player() external returns (address);
    function delegatedFrom() external returns (address);
    function forta() external returns (address);
}

interface iCryptoVault {
    function sweepToken(IERC20 token) external;
}


contract DetectionBot is IDetectionBot {
    address constant levelInstance = 0x2DbE5233212d548Cab1FfC213DD58CD620419F75;

    iDoubleEntryPoint DET = iDoubleEntryPoint(levelInstance);
    address fortaAddress = DET.forta();
    IERC20 legacyToken = IERC20(DET.delegatedFrom());
    address cryptoVault = DET.cryptoVault();

    IForta Forta = IForta(fortaAddress);
    iCryptoVault CryptoVault = iCryptoVault(cryptoVault);

    function getFortaAddress() public view returns (address){
        return fortaAddress;
    }

    function getLegacyToken() public view returns (address){
        return address(legacyToken);
    }


    function getCryptoVault() public view returns (address){
        return cryptoVault;
    }

    function swishswish() public { 
        CryptoVault.sweepToken(legacyToken);
    }

    ///ref: https://github.com/maAPPsDEV/double-entry-point-attack/blob/main/contracts/DetectionBot.sol
    function handleTransaction(
        address user,
        bytes calldata /* msgData */
    ) external override {
        address to;
        uint256 value;
        address origSender;
        // decode msgData params
        assembly {
            to := calldataload(0x68)
            value := calldataload(0x88)
            origSender := calldataload(0xa8)
        }
        if (origSender == cryptoVault) {
            Forta.raiseAlert(user);
        }
  }
}