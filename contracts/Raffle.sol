// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

error Raffle__NotEnoughETH();
error Raffle__TransferFailed();
error Raffle__RaffleNotOpen();

contract Raffle is VRFConsumerBaseV2, KeeperCompatibleInterface {
    // Enum creates a new data type ( uint256 0 = OPEN, 1 = PROCESSING)
    enum RaffleState {
        OPEN,
        PROCESSING
    }

    // State variables //
    uint256 private immutable i_ticketPrice;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callBackGasLimit;
    uint32 private constant NUM_WORDS = 1;
    uint16 private constant BLOCK_CONFIRMATIONS = 3;
    uint256 private immutable i_interal;

    // Lottery Variables //
    address private s_recentWinner;
    RaffleState private s_raffleState;

    // Events //
    event RaffleEntry(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event RaffleWinners(address indexed raffleWinners);

    constructor(
        address vrfCoordinatorV2,
        uint256 ticketPrice,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 updateInterval
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_ticketPrice = ticketPrice;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callBackGasLimit = callbackGasLimit;
        i_interal = updateInterval;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() public payable {
        if (msg.value < i_ticketPrice) {
            revert Raffle__NotEnoughETH();
        }

        // Checks if raffle is open
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntry(msg.sender);
    }

    function checkUpKeep(
        bytes calldata /*checkData*/
    ) external override {}

    // function performUpkeep() external returns () {}

    function requestRandomWinner() external {
        s_raffleState = RaffleState.PROCESSING;

        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            BLOCK_CONFIRMATIONS,
            i_callBackGasLimit,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(
        uint256,
        /*requestId*/
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;

        //Changes state back to open.
        s_raffleState = RaffleState.OPEN;

        //Resets the player address array
        s_players = new address payable[](0);
        // Sending ETH to winner
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }

        emit RaffleWinners(recentWinner);
    }

    // Function returns the price set the ticket price set by the deployer
    function getTicketPrice() public view returns (uint256) {
        return i_ticketPrice;
    }

    // Function returns the player using their index in array
    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    // Function returns the address of latest raffle winner
    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }
}
