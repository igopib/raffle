const { network, ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = getNamedAccounts()
    const chainId = network.config.chainId
    let vrfCoordinatorV2Address

    if (developmentChains.includes(network.name)) {
        const vrfCoordinatorV2Mock = await ethers.getContract(
            "VRFCoordinatorV2mock"
        )
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
    } else {
        vrfCoordinatorV2Address = networkConfig[chainId]["vrfCoordiantorV2"]
    }

    const enteranceFee = networkConfig[chainId]["enternaceFee"]
    const args = [vrfCoordinatorV2Address, enteranceFee]

    const raffle = await deploy("Raffle", {
        from: deploy,
        args: args,
        log: true,
        waitConfirmations: network.config.blocConfirmations || 1,
    })
}
