// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/WeatherInsurance.sol";

contract WeatherInsuranceTest is Test {
    WeatherInsurance public weatherInsurance;
    address mockSignSigner = address(1);

    function setUp() public {
        weatherInsurance = new WeatherInsurance(address(0), mockSignSigner);
    }

    function testVerifyIdentity() public {
        // This is a mock signature for testing purposes
        bytes memory signature = abi.encodePacked(bytes32(0), bytes32(0), uint8(27));
        vm.prank(mockSignSigner);
        weatherInsurance.verifyIdentity(signature);
        assertTrue(weatherInsurance.verified(address(this)));
    }

    function testPurchaseInsurance() public {
        // First, verify the identity
        bytes memory signature = abi.encodePacked(bytes32(0), bytes32(0), uint8(27));
        vm.prank(mockSignSigner);
        weatherInsurance.verifyIdentity(signature);

        // Then purchase insurance
        weatherInsurance.purchaseInsurance{value: 0.1 ether}();
        assertTrue(weatherInsurance.insured(address(this)));
    }

    function testFailPurchaseInsuranceWithoutVerification() public {
        weatherInsurance.purchaseInsurance{value: 0.1 ether}();
    }

    function testFailPurchaseInsuranceIncorrectAmount() public {
        // First, verify the identity
        bytes memory signature = abi.encodePacked(bytes32(0), bytes32(0), uint8(27));
        vm.prank(mockSignSigner);
        weatherInsurance.verifyIdentity(signature);

        // Then try to purchase insurance with incorrect amount
        weatherInsurance.purchaseInsurance{value: 0.05 ether}();
    }
}