# DoubleEntryPoint

Difficulty 4/10

This level features a CryptoVault with special functionality, the sweepToken function. This is a common function to retrieve tokens stuck in a contract. The CryptoVault operates with an underlying token that can't be swept, being it an important core's logic component of the CryptoVault, any other token can be swept.

The underlying token is an instance of the DET token implemented in DoubleEntryPoint contract definition and the CryptoVault holds 100 units of it. Additionally the CryptoVault also holds 100 of LegacyToken LGT.

In this level you should figure out where the bug is in CryptoVault and protect it from being drained out of tokens.

The contract features a Forta contract where any user can register its own detection bot contract. Forta is a decentralized, community-based monitoring network to detect threats and anomalies on DeFi, NFT, governance, bridges and other Web3 systems as quickly as possible. Your job is to implement a detection bot and register it in the Forta contract. The bot's implementation will need to raise correct alerts to prevent potential attacks or bug exploits.

Things that might help:

* How does a double entry point work for a token contract ?


``` Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface DelegateERC20 {
  function delegateTransfer(address to, uint256 value, address origSender) external returns (bool);
}

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

interface IForta {
    function setDetectionBot(address detectionBotAddress) external;
    function notify(address user, bytes calldata msgData) external;
    function raiseAlert(address user) external;
}

contract Forta is IForta {
  mapping(address => IDetectionBot) public usersDetectionBots;
  mapping(address => uint256) public botRaisedAlerts;

  function setDetectionBot(address detectionBotAddress) external override {
      require(address(usersDetectionBots[msg.sender]) == address(0), "DetectionBot already set");
      usersDetectionBots[msg.sender] = IDetectionBot(detectionBotAddress);
  }

  function notify(address user, bytes calldata msgData) external override {
    if(address(usersDetectionBots[user]) == address(0)) return;
    try usersDetectionBots[user].handleTransaction(user, msgData) {
        return;
    } catch {}
  }

  function raiseAlert(address user) external override {
      if(address(usersDetectionBots[user]) != msg.sender) return;
      botRaisedAlerts[msg.sender] += 1;
  } 
}

contract CryptoVault {
    address public sweptTokensRecipient;
    IERC20 public underlying;

    constructor(address recipient) public {
        sweptTokensRecipient = recipient;
    }

    function setUnderlying(address latestToken) public {
        require(address(underlying) == address(0), "Already set");
        underlying = IERC20(latestToken);
    }

    /*
    ...
    */

    function sweepToken(IERC20 token) public {
        require(token != underlying, "Can't transfer underlying token");
        token.transfer(sweptTokensRecipient, token.balanceOf(address(this)));
    }
}

contract LegacyToken is ERC20("LegacyToken", "LGT"), Ownable {
    DelegateERC20 public delegate;

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function delegateToNewContract(DelegateERC20 newContract) public onlyOwner {
        delegate = newContract;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        if (address(delegate) == address(0)) {
            return super.transfer(to, value);
        } else {
            return delegate.delegateTransfer(to, value, msg.sender);
        }
    }
}

contract DoubleEntryPoint is ERC20("DoubleEntryPointToken", "DET"), DelegateERC20, Ownable {
    address public cryptoVault;
    address public player;
    address public delegatedFrom;
    Forta public forta;

    constructor(address legacyToken, address vaultAddress, address fortaAddress, address playerAddress) public {
        delegatedFrom = legacyToken;
        forta = Forta(fortaAddress);
        player = playerAddress;
        cryptoVault = vaultAddress;
        _mint(cryptoVault, 100 ether);
    }

    modifier onlyDelegateFrom() {
        require(msg.sender == delegatedFrom, "Not legacy contract");
        _;
    }

    modifier fortaNotify() {
        address detectionBot = address(forta.usersDetectionBots(player));

        // Cache old number of bot alerts
        uint256 previousValue = forta.botRaisedAlerts(detectionBot);

        // Notify Forta
        forta.notify(player, msg.data);

        // Continue execution
        _;

        // Check if alarms have been raised
        if(forta.botRaisedAlerts(detectionBot) > previousValue) revert("Alert has been triggered, reverting");
    }

    function delegateTransfer(
        address to,
        uint256 value,
        address origSender
    ) public override onlyDelegateFrom fortaNotify returns (bool) {
        _transfer(origSender, to, value);
        return true;
    }
}
```

# Solution

I had a hard time understanding this challenge.

I had to review some of the solutions for this challenge to solve it:

https://github.com/maAPPsDEV/double-entry-point-attack

Prior to having proxy contracts, contracts had to come up with their own logic to replace old contracts/tokens with new ones. 

There are two tokens in this challenge, LegacyToken ("LGT") and DoubleEntryPointToken ("DET"). The DET token is the new token that has replaced the LGT token. LGT has been deprecated, but people may still send LGT to the CryptoVault. The CryptoVault handles this scenario by having a sweepToken function that allows sweeping of the legacy token (to `sweptTokensRecipient`). The `sweptTokensRecipient` is set in the `constructor()` during initialization. The sweepToken function has a require statement to prevent sweeping of the new token (DET). The address of the new token is set by calling the `setUnderlying()` function. 

The `sweepToken()` function is calling `token.transfer`. `token` is the contract address of the Legacy token (passed by the user through function parameters). 

The LegacyToken contract has a few different functions, `mint()`, `delegateToNewContract()` and `transfer()`. The `delegateToNewContract()` allows the upgradable functionality for the token. It allows a new contract to take over the token. The address of the latest token is stored in the state variable `delegate`

The function `transfer()` is calling `delegrateTransfer()` on the address `delegate`. In this scenario, it will call `delegrateTransfer()` on DET token.


The `delegrateTransfer()` function in the DET contract will transfer DET tokens, and not the legacy token. Also, it has the following a modifier that has the following require statement:

``` Solidity
require(msg.sender == delegatedFrom, "Not legacy contract");
```

The `delegateTransfer()` for DET contract has to be called from the Legacy contract.

The bug in this challenge is if you try to sweep the Legacy token (by calling sweepToken()), it will actually sweep the new token, DET, because it's calling the `delegateTransfer()` for the DET token.

Now this challenge is using a Forta which is similar to a `Intrusion prevention system (IPS)` system. It basically allows a Detection bot contract to examine the `msg.data` to ensure it doesn't contain certain signatures. If it contains the signature, it will raise an alert. This will cause a revert on the transaction, stopping the malicious transaction.

To solve this challenge, you need to write a detection bot to prevent CryptoVault from calling `delegrateTransfer()` through the Legacy token contract.

Here is calldata layout based on this [link](https://github.com/maAPPsDEV/double-entry-point-attack/blob/main/contracts/DetectionBot.sol):
| calldata offset | length | element                                | type    | example value                                                      |
|-----------------|--------|----------------------------------------|---------|--------------------------------------------------------------------|
| 0x00            | 4      | function signature (handleTransaction) | bytes4  | 0x220ab6aa                                                         |
| 0x04            | 32     | user                                   | address | 0x000000000000000000000000XxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXx |
| 0x24            | 32     | offset of msgData                      | uint256 | 0x0000000000000000000000000000000000000000000000000000000000000040 |
| 0x44            | 32     | length of msgData                      | uint256 | 0x0000000000000000000000000000000000000000000000000000000000000064 |
| 0x64            | 4      | function signature (delegateTransfer)  | bytes4  | 0x9cd1a121                                                         |
| 0x68            | 32     | to                                     | address | 0x000000000000000000000000XxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXx |
| 0x88            | 32     | value                                  | uint256 | 0x0000000000000000000000000000000000000000000000056bc75e2d63100000 |
| 0xA8            | 32     | origSender                             | address | 0x000000000000000000000000XxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXx |
| 0xC8            | 28     | padding                                | bytes   | 0x00000000000000000000000000000000000000000000000000000000         |

To get the addresses require to solve this challenge, you can run the following commands:

CryptoVault:
`await contract.cryptoVault()`.

Forta:
`await contract.forta()`

The code for solving solution can be found in `DetectionBot.sol`.

To solve:

1. Deploy `DetectionBot.sol` and get the Forta address.
2. Deploy `IForta` at Forta address from 1.
3. In the deployed IForta contract add the `DetectionBot.sol` Address as a DetectionBot.
4. Run `swishswish()` in `DetectionBot.sol`.

# Completion Message
```
Level completed!

Difficulty 4/10

Congratulations!

This is the first experience you have with a Forta bot. (https://docs.forta.network/en/latest/)

Forta comprises a decentralized network of independent node operators who scan all transactions and block-by-block state changes for outlier transactions and threats. When an issue is detected, node operators send alerts to subscribers of potential risks, which enables them to take action.

The presented example is just for educational purpose since Forta bot is not modeled into smart contracts. In Forta, a bot is a code script to detect specific conditions or events, but when an alert is emitted it does not trigger automatic actions - at least not yet. In this level, the bot's alert effectively trigger a revert in the transaction, deviating from the intended Forta's bot design.

Detection bots heavily depends on contract's final implementations and some might be upgradeable and break bot's integrations, but to mitigate that you can even create a specific bot to look for contract upgrades and react to it. Learn how to do it here. (https://docs.forta.network/en/latest/quickstart/)

You have also passed through a recent security issue that has been uncovered during OpenZeppelin's latest collaboration with Compound protocol. (https://compound.finance/governance/proposals/76)

Having tokens that present a double entry point is a non-trivial pattern that might affect many protocols. This is because it is commonly assumed to have one contract per token. But it was not the case this time :) You can read the entire details of what happened here. (https://blog.openzeppelin.com/compound-tusd-integration-issue-retrospective/)

```
