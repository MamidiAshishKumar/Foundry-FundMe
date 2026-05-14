// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/fundme.sol";
import {PriceConverter} from "../../src/PriceConverter.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {InteractWithFundMeFunction, InteractWithWithDrawFunction} from "../../script/Interactions.s.sol";

contract FundMeIntegration is Test {
    FundMe fundME;
    address testUser = makeAddr("testUser");
    uint256 constant SEND_VALUE = 1e18; // 1 ETHER
    uint256 constant FAKE_BALANCE_TEST_USER = 100e18; // 100 ETHER

    
    function setUp() external {
        DeployFundMe deployfundme = new DeployFundMe();
        fundME = deployfundme.run();
        vm.deal(testUser, FAKE_BALANCE_TEST_USER);
    }

    function testInteractWithFundMeInteractions() public {
        InteractWithFundMeFunction interactWithFundMeFunction = new InteractWithFundMeFunction();
        interactWithFundMeFunction.fundingToFundMe(address(fundME));

        InteractWithWithDrawFunction withdrawfundme = new InteractWithWithDrawFunction();
        withdrawfundme.WithdrawFundMe(address(fundME));

        assert(address(fundME).balance == 0);
    }

}