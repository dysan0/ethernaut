//check to make sure it's locked
await contract.locked()

//slot 0
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 0))
//data: 0x0000000000000000000000000000000000000000000000000000000000000001

//slot 1
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 1))
//data: 0x00000000000000000000000000000000000000000000000000000000628f882c

//slot 2
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 2))
//data: 0x00000000000000000000000000000000000000000000000000000000882cff0a

//slot 3
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 3))
//data: 0xefa462674ed8f6c39fd549bf075ccb60cef1b4b9ead03b9347fbb034af24c12c

//slot 4
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 4))
//data: 0x0211f939955aef04bafbc13bacaf670d029bfe3fb949c008ddf9ec7c8db261ac

//slot 5
await (web3.eth.getStorageAt('0x40d4c2d338769cE929CdeD0D243e24cb878b772A', 5))
//data: 0x8a50c9600ba5a2b18ed9f751574ea6973a16eab5d2b9784e8b5af49b8cafd27b

await contract.unlock('0x8a50c9600ba5a2b18ed9f751574ea697')

//check to make sure it's unlocked
await contract.locked()
