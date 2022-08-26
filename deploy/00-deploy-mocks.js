const { network } = require("hardhat")
const { deploymentChains } = require("../helper-hardhat-config")

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = getNamedAccounts()

    const chainId = network.config.chainId

    if (deploymentChains.includes(network.name)) {
        log("Local network detected! Deploying Mocks")
    }
}
