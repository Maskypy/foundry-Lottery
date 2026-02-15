//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Raffle
 * @author 0xMasky
 * @notice A simple raffle contract where users can enter by paying a fee, and a winner is randomly selected to
 *         receive the prize pool.
 * @dev This contract uses Chainlink VRF for randomness and Chainlink Keepers for automation.
 *         It includes functions for entering the raffle, selecting a winner, and withdrawing funds.
 */

contract Raffle {
    uint256 private immutable i_entranceFee;

    constructor(uint256 _entranceFee) {
        i_entranceFee = _entranceFee;
    }

    function enterRaffle() external payable {
        // Function to allow users to enter the raffle by paying a fee
    }

    function pickWinner() external {
        // Function to select a winner using Chainlink VRF
    }

    // Getter functions
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
