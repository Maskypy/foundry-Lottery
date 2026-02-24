// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {
    VRFCoordinatorV2_5Mock
} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract HelperConfig is Script {
    error HelperConfig__NoConfigForChainId(uint256 chainId);

    uint256 private constant SEPOLIA_CHAINID = 11155111;
    uint256 private constant ANVIL_CHAINID = 31337;

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
    }

    constructor() {
        networkConfigs[SEPOLIA_CHAINID] = getSepoliaEthConfig();
        networkConfigs[ANVIL_CHAINID] = getOrCreateAnvilConfig();

        if (block.chainid == SEPOLIA_CHAINID) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    NetworkConfig public activeNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == ANVIL_CHAINID) {
            return getOrCreateAnvilConfig();
        } else {
            revert HelperConfig__NoConfigForChainId(chainId);
        }
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,
            callbackGasLimit: 500000
        });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        // check if we already have a config for Anvil, if so, return it
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }
        // Deploy mocks
        vm.startBroadcast();
        /**
         * @param _baseFee The amount you want to charge for each request.
         * @param _gasPrice The price you want to charge for each gas unit.
         * @param _weiPerUnitLink The conversion rate between LINK and the native token (e.g., ETH).
         */
        VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(0.1 ether, 1e9, 1e18);
        vm.stopBroadcast();
        // Return the config struct
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorV2_5Mock),
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0, // fix later
            callbackGasLimit: 500000
        });
    }
}
