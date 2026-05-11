// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Mocks
// 1. Deploy mocks when we are on a local anvil chain
// 2. keep track of contract address across different chains
// so every chain has a different address i.e.
// In Sepolia for converting ETH -> USD has a seperate address
// In ETH mainnet for converting ETH -> USD has a seperate address

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    // if we are on a local anvil chain, we deploy mocks
    // Otherwise, grab the exisiting address from the live network

    struct NetworkConfig {
        address priceFeed; // ETH -> USD price feed address
    }

    NetworkConfig public activeChainConfig;

    constructor() {
        if (
            block.chainid == 11155111
        ) // block.chainid is a global variable and chainid 11155111 is sepolia
        {
            activeChainConfig = getSepoliaEthConfig();
        } else {
            activeChainConfig = getAnvilConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // Sepolia chain related configuration (gas price, vrf address)
        // we need price feed address
        NetworkConfig memory SepConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return SepConfig;
    }

    // if we wanted to work with another chain
    //   function getEthMainnetConfig() public pure returns (NetworkConfig memory) {
    //     // Sepolia chain related configuration (gas price, vrf address)
    //     // we need price feed address
    //     NetworkConfig memory SepConfig = NetworkConfig({
    //         priceFeed: <Address of the mainnet>
    //     });

    // mocks
    function getAnvilConfig() public returns (NetworkConfig memory) {
        // 1. deploy the mocks - mocked contract is a dummy contract
        //2. return mocked contract
        vm.startBroadcast();

        vm.stopBroadcast();
    }
}
