// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/WeatherInsurance.sol";

contract DeployWeatherInsurance is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        address signSignerAddress = 0x0987654321098765432109876543210987654321;

        WeatherInsurance weatherInsurance = new WeatherInsurance(priceFeedAddress, signSignerAddress);

        vm.stopBroadcast();
    }
}