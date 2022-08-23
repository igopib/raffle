// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

error Raffle__NotEnoughETH();

contract Raffle {
    
    // State variables //
    uint256  private s_ticketPrice;
    address payable[] private s_players;

    // Events //
    event RaffleEntry(address indexed player);

    constructor(uint256 ticketPrice) {
        s_ticketPrice = ticketPrice;
    }

    function enterRaffle()  public payable {
        if(msg.value < s_ticketPrice){revert Raffle__NotEnoughETH();}
        s_players.push(payable(msg.sender));
        emit RaffleEntry(msg.sender);
    }

    // function pickWinner() private {

    // }

    // Function returns the price set the ticket price set by the deployer
    function getTicketPrice() public view returns(uint256) {
        return s_ticketPrice;
    }

    // Function returns the player using their index in array
    function getPlayer(uint256 index) public view returns(address) {
        return s_players[index];
    }
}