// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PriceConverter, AggregatorV3Interface} from "./PriceConverter.sol";

// import {AggregatorV3Interface} from "@chainlink-brownie-contracts/blob/main/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; // importing npm packages through @

// solhint-disable-next-line interface-starts-with-i
// interface AggregatorV3Interface {
//   function decimals() external view returns (uint8);

//   function description() external view returns (string memory);

//   function version() external view returns (uint256);

//   function getRoundData(
//     uint80 _roundId
//   ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

//   function latestRoundData()
//     external
//     view
//     returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
// }

contract FundMe {
    address private OwnerOfSmartContract;
    AggregatorV3Interface private priceFeed;

    constructor(address passed_priceFeed) {
        OwnerOfSmartContract = msg.sender; // deployer of the contract
        priceFeed = AggregatorV3Interface(passed_priceFeed);
    }

    using PriceConverter for uint256; // All the uint256 have access to the functions to the library we have imported
    // uint public number;
    address[] private Funders;
    mapping(address => uint) private addressToAmountFunded;
    uint public MinimumSpendRupees = 10000e18;

    function FundMoney() public payable {
        // require(getConvertedETH_to_INR(msg.value) >= MinimumSpendRupees, "Did not received the Tokens, Please provide more than 1 ETH");
        require(
            msg.value.getConvertedETH_to_INR(priceFeed) >= MinimumSpendRupees,
            "Did not received the Tokens, insufficient funds"
        );
        // number = msg.value.getConvertedETH_to_INR(); //msg.value will be also sent to getConvertedETH_to_INR first parameter
        Funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
        //msg.sender is a global variable for getting the sender wallet address
        // msg.value returns in WEI and in UINT256
        // Get real price of ethereum through chainlink data feeds
    }

    function GetVersion() external view returns (uint256) {
        return priceFeed.version();
    }

    function GasOptimisatedWithdrawMoney() public OnwerFunction {
        uint256 FunderArrayLength = Funders.length;
        for (uint256 funderIndex = 0; funderIndex < FunderArrayLength; funderIndex++) {
            address funder = Funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        Funders = new address[](0);
        (bool CallStatus, bytes memory DataReturned) = payable(msg.sender).call{
            value: address(this).balance
        }(""); // value This tells the EVM how much Ether (in Wei) to send.
        require(CallStatus, "Funding Failed");

    }

    function WithDrawMoney() public OnwerFunction {
        // for loop
        for (
            uint256 funderIndex = 0;
            funderIndex < Funders.length; // storage variable and we are everytime looping through the code we are reading from the storage slot (oh no!!)
            funderIndex++
        ) {
            address funder = Funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        Funders = new address[](0); // resetting the funders array to length zero

        // withdraw funds
        // there are three different ways of sending ETH funds i.e. Tranfer, Send, Call
        // 1) Transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // 2) send
        // bool PaymentStatus = payable(msg.sender).send(address(this).balance);
        // require(PaymentStatus, "Payment Failed");
        // 3) call - preferred way
        (bool CallStatus, bytes memory DataReturned) = payable(msg.sender).call{
            value: address(this).balance
        }(""); // value This tells the EVM how much Ether (in Wei) to send.
        require(CallStatus, "Payment Failed");
    }

    modifier OnwerFunction() {
        require(
            msg.sender == OwnerOfSmartContract,
            "You cannot withdraw you cheeky bastard, You must be the Owner"
        );
        _; // after the above statements add whatever is in the function
    }


    // view/pure getter functions better than having storage variables as public
    
    function getAddressToAmountFunded (address fundingAddress) external view returns(uint256)
    {
        return addressToAmountFunded[fundingAddress];
    }

    function getFunderAddress (uint256 index) external view returns (address)
    {
        return Funders[index];
    }

    function getOwnerOfSmartContract () external view returns(address)
    {
        return OwnerOfSmartContract;
    }
}
