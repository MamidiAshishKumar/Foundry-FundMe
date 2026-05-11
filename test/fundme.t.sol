// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/fundme.sol";
import {PriceConverter} from "../src/PriceConverter.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

// there are 4 types of tests
// 1. unit - testing a specfic part of the code
// 2. Integration - testing how our code works with other parts of code
// 3. forked - testing our code on a simulated real environment
// 4. staging - testing our code in a real environment that is not prod

contract fundme is Test {
    // bool Decision = true;
    FundMe fundME;

    // first function to be executed when we run "forge test" and it is essentail
    function setUp() external {
        // Decision = false;
        // fundME = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployfundme = new DeployFundMe();
        fundME = deployfundme.run();
    }

    function testMinimumSpendRupees() public view {
        // console.log(Decision);
        // test MinimumSpendRupees if the value is 10000e18 in fundme contract
        assertEq(fundME.MinimumSpendRupees(), 10000e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundME.OwnerOfSmartContract());
        console.log(msg.sender);
        // assertEq(fundME.OwnerOfSmartContract(), address(this));
        assertEq(fundME.OwnerOfSmartContract(), msg.sender);
    }

    function testETHVersion() public {
        uint256 version = fundME.GetVersion();
        console.log(version);
    }

    // we want to have modular deployments and testing
}
