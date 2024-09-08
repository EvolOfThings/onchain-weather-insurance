// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@sismo-core/sign-protocol/contracts/utils/SignatureValidator.sol";

contract WeatherInsurance is SignatureValidator {
    AggregatorV3Interface internal priceFeed;
    address public signSigner;
    
    uint256 public constant PREMIUM = 0.1 ether;
    uint256 public constant PAYOUT = 1 ether;
    uint256 public constant TEMPERATURE_THRESHOLD = 35; // 35°C
    
    mapping(address => bool) public insured;
    mapping(address => bool) public verified;
    
    constructor(address _priceFeed, address _signSigner) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        signSigner = _signSigner;
    }
    
    function verifyIdentity(bytes memory signature) public {
        require(!verified[msg.sender], "Already verified");
        bytes32 message = keccak256(abi.encodePacked(msg.sender, "VERIFIED"));
        require(isValidSignature(signSigner, message, signature), "Invalid signature");
        verified[msg.sender] = true;
    }
    
    function purchaseInsurance() public payable {
        require(verified[msg.sender], "Not verified");
        require(msg.value == PREMIUM, "Incorrect premium amount");
        insured[msg.sender] = true;
    }
    
    function checkTemperature() public view returns (int) {
        (,int temperature,,,) = priceFeed.latestRoundData();
        return temperature;
    }
    
    function claimInsurance() public {
        require(insured[msg.sender], "No active insurance");
        int temperature = checkTemperature();
        require(temperature > int(TEMPERATURE_THRESHOLD * 10), "Temperature not high enough for payout");
        
        insured[msg.sender] = false;
        payable(msg.sender).transfer(PAYOUT);
    }
}