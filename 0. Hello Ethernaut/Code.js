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