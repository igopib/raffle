const { ethers } = require("hardhat")

// Enternance fee can be edited according to which network its being deployed on.

const networkConfig = {
    4: {
        name: "rinkeby",
        vrfCoordinator: "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
        enteranceFee: ethers.utils.parseEther("0.02"),
        gasLane:
            "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
    },
    31337: {
        name: "hardhat",
        enteranceFee: ethers.utils.parseEther("0.02"),
        gasLane:
            "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
    },
}

const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains,
}
