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
    address testUser = makeAddr("testUser");
    uint256 constant SEND_VALUE = 1e18; // 1 ETHER
    uint256 constant FAKE_BALANCE_TEST_USER = 100e18; // 100 ETHER

    // first function to be executed when we run "forge test" and it is essentail
    function setUp() external {
        // Decision = false;
        // fundME = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployfundme = new DeployFundMe();
        fundME = deployfundme.run();
        // cheatcode - vm.deal() - Sets the ETH balance of an address account to newBalance
        vm.deal(testUser, FAKE_BALANCE_TEST_USER);
    }

    function testMinimumSpendRupees() public view {
        // console.log(Decision);
        // test MinimumSpendRupees if the value is 10000e18 in fundme contract
        assertEq(fundME.MinimumSpendRupees(), 10000e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log(fundME.getOwnerOfSmartContract());
        console.log(msg.sender);
        // assertEq(fundME.OwnerOfSmartContract(), address(this));
        assertEq(fundME.getOwnerOfSmartContract(), msg.sender);
    }

    function testETHVersion() public view {
        uint256 version = fundME.GetVersion();
        console.log(version);
    }

    function testFundWithoutEnoughINR() public {
        vm.expectRevert(); // chetcode for saying the next line will be failed
        fundME.FundMoney(); // send 0 INR
    }

    function testFundingUpdates() public {
        // Cheatcodes - pranks (Sets msg.sender to the specified address for the next call.)
        vm.prank(testUser);
        fundME.FundMoney{value: SEND_VALUE}();
        uint256 amountFounded = fundME.getAddressToAmountFunded(testUser);
        assertEq(amountFounded, SEND_VALUE);
    }

    function testAddingFunderToArryOfFunders() public funded {

        address funderAddr = fundME.getFunderAddress(0);
        assertEq(funderAddr, testUser);
    }

    modifier funded() {
        vm.prank(testUser);
        fundME.FundMoney{value: SEND_VALUE}();
        _;
    }

    // we can use modifier for avoid writing repetitive code while testing

    function testOnlyOwnerCanWithdrawFunds() public funded {
        vm.expectRevert();
        vm.prank(testUser);
        fundME.WithDrawMoney();
    }

    function testWithdramFundsWithOnlyOneFunder() public funded {
        // when we are working on local anvil chain, the gas price defaults to "0" so that's why FundMeTestingBalance + OwnerBalance = EndingOwnerBalance with exact number
        // but there is a way to set the gas as a real transaction using a cheatcode txGasPrice (Sets tx.gasprice for the rest of the transaction.)
        // Test methodology - Arrange, Act, Assert
        // Arrange - Arrange the test
        uint256 OwnerBalance = fundME.getOwnerOfSmartContract().balance;
        uint256 FundMeTestingBalance = address(fundME).balance;
        uint256 GAS_PRICE = 2 gwei;

        // Act - Action on the test

        // vm.txGasPrice accepts one parameter that will set The new gas price to set (in wei)
        // TO CALCULATE HOW MUCH GAS CONSUMED BY vm.prank(fundME.getOwnerOfSmartContract()); AND fundME.WithDrawMoney();
        // vm.txGasPrice(GAS_PRICE); 
        // uint256 gasStart = gasleft();
        // vm.prank(fundME.getOwnerOfSmartContract());
        // fundME.WithDrawMoney();
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // tx.gasprice will tell the current gas price as we set in constant
        // console.log(gasUsed);

        vm.prank(fundME.getOwnerOfSmartContract());
        fundME.WithDrawMoney();
        
        //Assert - Assert the test  
        uint256 EndingOwnerBalance = fundME.getOwnerOfSmartContract().balance;
        uint256 EndingFundMeTestingBalance = address(fundME).balance;
        assertEq(EndingFundMeTestingBalance, 0);
        assertEq(FundMeTestingBalance + OwnerBalance, EndingOwnerBalance); // owner already existing funds + funded money to the owner (only owner is supposed to call)
    }

    function testWithdramFundsWithOnlyMulitpleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 7;
        uint160 startingFunderIndex = 1; // we are starting with 1 because address(0) reverts and does not do anything

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {    
            // vm.prank and vm.deal and fund the fundme contract
            // but instead of vm.prank and vm.deal we can use hoax cheatcode
            // hoax - Sets up a prank from an address that has some ether.
            // usage = hoax(<some address>, <ether to transfer>) public;
            hoax(address(i), SEND_VALUE);
            fundME.FundMoney{value: SEND_VALUE}();   
        } 

        uint256 OwnerBalance = fundME.getOwnerOfSmartContract().balance;
        uint256 FundMeTestingBalance = address(fundME).balance;
        

        // Act (BTW we can use vm.startPrank(fundME.getOwnerOfSmartContract()); -> vm.stopPrank();) 
        vm.prank(fundME.getOwnerOfSmartContract());
        fundME.WithDrawMoney();

        uint256 EndingOwnerBalance = fundME.getOwnerOfSmartContract().balance;

        // Assert 
        assert(address(fundME).balance == 0);
        assertEq(OwnerBalance + FundMeTestingBalance, EndingOwnerBalance);
    }

    function testGasOptimizedWithdramFundsWithOnlyMulitpleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 7;
        uint160 startingFunderIndex = 1; // we are starting with 1 because address(0) reverts and does not do anything

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {    
            // vm.prank and vm.deal and fund the fundme contract
            // but instead of vm.prank and vm.deal we can use hoax cheatcode
            // hoax - Sets up a prank from an address that has some ether.
            // usage = hoax(<some address>, <ether to transfer>) public;
            hoax(address(i), SEND_VALUE);
            fundME.FundMoney{value: SEND_VALUE}();   
        } 

        uint256 OwnerBalance = fundME.getOwnerOfSmartContract().balance;
        uint256 FundMeTestingBalance = address(fundME).balance;
        

        // Act (BTW we can use vm.startPrank(fundME.getOwnerOfSmartContract()); -> vm.stopPrank();) 
        vm.prank(fundME.getOwnerOfSmartContract());
        fundME.GasOptimisatedWithdrawMoney();

        uint256 EndingOwnerBalance = fundME.getOwnerOfSmartContract().balance;

        // Assert 
        assert(address(fundME).balance == 0);
        assertEq(OwnerBalance + FundMeTestingBalance, EndingOwnerBalance);
    }
    // we want to have modular deployments and testing
}
