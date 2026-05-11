// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/fundme.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // anything before vm.startBroadcast it is not recording in the transaction
        HelperConfig helpconfig = new HelperConfig();
        address ethUSDtoINRPriceFeed = helpconfig.activeChainConfig();
        // anything after vm.startBroadcast it is recording in the transaction
        vm.startBroadcast();
        // mock price feed without forked URL
        FundMe fundME = new FundMe(ethUSDtoINRPriceFeed);
        vm.stopBroadcast();
        return fundME;
    }
}
