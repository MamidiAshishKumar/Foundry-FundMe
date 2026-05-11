// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

library PriceConverter {
    function GetETHPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //address - 0x694AA1769357215DE4FAC081bf1f309aDC325306 smart contract address for getting 1 ETH in dollars
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // returns a value just like this - 200000000000 but the price with decimal should be 2000.0000000 USD
        return uint256(price * 1e10);
    }

    function getConvertedETH_to_INR(
        uint EthAmount,
        AggregatorV3Interface priceFeed
    ) public view returns (uint256) {
        // input will be - what is the INR price of 1 ETH?
        // below statement will get the current price of 1 ETH
        uint256 EthPrice = GetETHPrice(priceFeed);
        // uint EthPrice = 231900000000000000000;
        // (2000_00000000000000000 * 1_000000000000000000) / 1e18
        // $2000 USD
        uint256 EthAmountInUSD = (EthPrice * EthAmount) / 1e18;
        uint256 ETHAmountInINR = EthAmountInUSD * 94;
        return ETHAmountInINR;
    }
}
