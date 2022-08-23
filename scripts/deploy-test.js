const { ethers } = require("hardhat")

async function main() {
    const raffleContractFactory = await ethers.getContractFactory("Raffle")
    console.log("Deploying Contract ...")

    const ticketPrice = ethers.utils.parseEther("1");
    const raffleContract = await raffleContractFactory.deploy(ticketPrice)

    await raffleContract.deployed()
    console.log(`Contract deployed to ${raffleContract.address}`)

//     const _getTicketPrice = raffleContract.getTicketPrice();
//     console.log("Ticket Price:", ethers.utils.formatEther(_getTicketPrice));
}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
