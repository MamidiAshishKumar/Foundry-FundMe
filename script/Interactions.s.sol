// Programitically Interact with the functions on a deployed contract using script
// Fund and withdraw

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/fundme.sol";


contract InteractWithFundMeFunction is Script {

    uint256 constant SEND_VALUE = 0.1 ether;

    function fundingToFundMe(address mostRecentDeployedSmartContract) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedSmartContract)).FundMoney{value: SEND_VALUE}(); // wrapping this up in FundME() will tell the compilier that FundMoney is a function to map it to 4-byte selector
        vm.stopBroadcast();
        console.log("Funded with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentDeployedSmartContract = DevOpsTools.get_most_recent_deployment(
            "FundMe", 
            block.chainid
        );
        fundingToFundMe(mostRecentDeployedSmartContract);  
    }

}

contract InteractWithWithDrawFunction is Script {
    
    function WithdrawFundMe(address mostRecentDeployedSmartContract) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedSmartContract)).WithDrawMoney();  
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployedSmartContract = DevOpsTools.get_most_recent_deployment(
            "FundMe", 
            block.chainid
        );
        WithdrawFundMe(mostRecentDeployedSmartContract);
    }
}