// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

error Raffle__NotEnoughETH();
error Raffle__TransferFailed();
error Raffle__RaffleNotOpen();
error Raffle__UpkeepNotNeeded(
    uint256 currentBalance,
    uint256 numPlayers,
    uint256 raffleState
);

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

    // Lottery Variables //
    address private s_recentWinner;
    RaffleState private s_raffleState;
    uint256 private s_lastTimeStamp;
    uint256 private immutable i_interval;

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
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp; // Tracks last timestamp
        i_interval = updateInterval;
    }

    /* 
        Function to enter raffle
        *Checks if the passed value is no lower than the set ticket price.
        *Also checks if the raffle state is open when person tries to enter.
    */
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

    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        bool isOpen = (RaffleState.OPEN == s_raffleState);
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasPlayers = (s_players.length > 0);
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (isOpen && timePassed && hasPlayers && hasBalance);
    }

    /*
        Function uses chainlink vrf and requests for a random number as requestId
        Sets raffle state to processing upon executing.
    */
    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }

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

    /**
     * @dev This is the function that Chainlink VRF node
     * calls to send the money to the random winner.
     */

    function fulfillRandomWords(
        uint256,
        /*requestId*/
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN; //Changes state back to open.
        s_players = new address payable[](0); //Resets the player address array
        s_lastTimeStamp = block.timestamp; //Updates timestamp
        // Sending ETH to winner
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }

        emit RaffleWinners(recentWinner);
    }

    /*   View / Pure functions  */

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

    function prizePool() public view returns (uint256) {
        return address(this).balance;
    }

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    function numberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }
}
