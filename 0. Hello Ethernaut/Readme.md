# Hello Ethernaut 
Difficulty: 0/10

This level teaches the basics of how to play the game. 

&nbsp;
# Solution

1. Setup MetaMask

   For this part you need install MetaMask and set your network to 'Rinkeby test network'

1. Open the browser's console
   
    Use the option `Tools>Developer Tools` and click on `console`.

1. Use the console helpers
    
    `getBalance(player)` - Returns user's balance.

    `help()` - returns the help.

    Use `await` to make the console output cleaner.
1. The ethernaut contract
    
    type `ethernaut` to see the contract object.
1. Interact with the ABI
   
    `await ethernaut.owner()` - returns owner of the contract.
1. Get test ether

    You can get some test ether from [here](https://faucets.chain.link/rinkeby). 
1. Getting a level instance
    
    Click the blue button on top to create a level instance
1. Inspect the contract
   
   You can inspect the contract by `contract.abi`. This will return the abi for the contract.

1. Interact with the contract to complete the level
   
   Type `await contract.info()` to start solving this level.

Here are the commands that I ran to solve this challenge (you have to review the abi to find the password):

``` js
//gets player balance
await getBalance(player)

ethernaut

//gets contract owner
await ethernaut.owner()

await contract.info()
await contract.info1()
await contract.info2("hello")

//toString() will convert the big number to a number that can be displayed in console
(await contract.infoNum()).toString()

await contract.info42()
await contract.theMethodName()
await contract.method7123949()

//returns the contract abi object
await contract.abi

//will return the password
await contract.password()

//submit the password to solve challenge
contract.authenticate("ethernaut0") 

//will return true if you've solved the challenge
await contract.getCleared() 
```


&nbsp;
# Completion Message
```
Level completed!

Congratulations! You have completed the tutorial. Have a look at the Solidity code for the contract you just interacted with below.

You are now ready to complete all the levels of the game, and as of now, you're on your own.

Godspeed!!
```

