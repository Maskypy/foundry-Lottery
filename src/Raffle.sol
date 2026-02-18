/* Layout of Contract:
 version
 imports
 errors
 interfaces, libraries, contracts
 Type declarations
 State variables
 Events
 Modifiers
 Functions

 Layout of Functions:
 constructor
 receive function (if exists)
 fallback function (if exists)
 external
 public
 internal
 private
 view & pure functions
*/
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title Raffle
 * @author 0xMasky
 * @notice A simple raffle contract where users can enter by paying a fee, and a winner is randomly selected to
 *         receive the prize pool.
 * @dev This contract uses Chainlink VRF for randomness and Chainlink Keepers for automation.
 *         It includes functions for entering the raffle, selecting a winner, and withdrawing funds.
 */

contract Raffle is VRFConsumerBaseV2Plus {
    /* Errors */
    error Raffle__NotEnoughETHEntered();
    error Raffle__IntervalNotPassed();
    error Raffle__TransferFailed();

    /* State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3; // Number of confirmations for Chainlink VRF
    uint32 private constant NUM_WORDS = 1; // Number of random words to request from Chainlink VRF
    uint256 private immutable i_entranceFee; // The fee required to enter the raffle
    uint256 private immutable i_interval; // Time interval for selecting a winner
    bytes32 private immutable i_keyHash; // Key hash for Chainlink VRF
    uint256 private immutable i_subscriptionId; // Subscription ID for Chainlink VRF
    uint32 private immutable i_callbackGasLimit; // Gas limit for the callback function
    address payable[] private s_players; // List of players who have entered the raffle
    address private s_recentWinner; // The most recent winner of the raffle
    uint256 private s_lastTimeStamp; // Timestamp of the last winner selection
    /* Events */
    event RaffleEntered(address indexed player);

    constructor(
        uint256 _entranceFee,
        uint256 _interval,
        address vrfCoordinator,
        bytes32 _keyHash,
        uint256 _subscriptionId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = _entranceFee;
        i_subscriptionId = _subscriptionId;
        i_interval = _interval;
        i_callbackGasLimit = _callbackGasLimit;
        i_keyHash = _keyHash;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        // Function to allow users to enter the raffle by paying a fee
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHEntered();
        }
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external {
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            revert Raffle__IntervalNotPassed();
        }
        // Function to select a winner using Chainlink VRF
        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        // Function to handle the random words returned by Chainlink VRF and select a winner
        uint256 winnerIndex = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[winnerIndex];
        s_recentWinner = recentWinner;
        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    // Getter functions
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
