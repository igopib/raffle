const connectButton = document.getElementById("connectButton")
connectButton.onclick = connectWallet

let provider = new ethers.providers.Web3Provider(window.ethereum)
let signer

async function connectWallet() {
    await provider.send("eth_requestAccounts", [])
    signer = provider.getSigner()
    connectButton.innerHTML("Connected")
}
