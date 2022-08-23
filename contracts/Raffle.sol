// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

error Raffle__NotEnoughETH();

contract Raffle is VRFConsumerBaseV2 {
    // State variables //
    uint256 private s_ticketPrice;
    address payable[] private s_players;

    // Events //
    event RaffleEntry(address indexed player);

    constructor(address vrfCoordinatorV2, uint256 ticketPrice)
        VRFConsumerBaseV2(vrfCoordinatorV2)
    {
        s_ticketPrice = ticketPrice;
    }

    function enterRaffle() public payable {
        if (msg.value < s_ticketPrice) {
            revert Raffle__NotEnoughETH();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntry(msg.sender);
    }

    // function pickWinner() external {

    // }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {}

    // Function returns the price set the ticket price set by the deployer
    function getTicketPrice() public view returns (uint256) {
        return s_ticketPrice;
    }

    // Function returns the player using their index in array
    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }
}
