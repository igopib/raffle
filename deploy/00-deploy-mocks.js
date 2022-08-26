const { network } = require("hardhat")
const { deploymentChains } = require("../helper-hardhat-config")

/* VRFCoordinatorV2Mock Args */
const BASE_FEE = ethers.utils.parseEther("0.25") // It is premium of 0.25 LINK to request random number.
const GAS_PRICE_LINK = 1e9 // Link per gas. Nodes pay eth h=gas fee

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = getNamedAccounts()
    const args = [BASE_FEE, GAS_PRICE_LINK]

    const chainId = network.config.chainId

    if (deploymentChains.includes(network.name)) {
        log("Local network detected! Deploying Mocks")
        //Deploy VRF Mock
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            log: true,
            args: args,
        })

        log("Mock Deployed!")
        log("----------------------------")
    }
}

module.exports.tags = ["all", "mocks"]
