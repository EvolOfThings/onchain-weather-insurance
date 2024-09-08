// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "@sismo-core/sign-protocol/contracts/utils/SignatureValidator.sol";

contract WeatherInsurance is ChainlinkClient, AutomationCompatibleInterface, SignatureValidator {
    using Chainlink for Chainlink.Request;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    uint256 public constant PREMIUM = 0.1 ether;
    uint256 public constant PAYOUT = 1 ether;
    uint256 public constant TEMPERATURE_THRESHOLD = 35; // 35°C

    int256 public currentTemperature;
    uint256 public lastTemperatureCheck;
    uint256 public temperatureCheckInterval;

    address public signSigner;
    
    mapping(address => bool) public insured;
    mapping(address => bool) public verified;

    event TemperatureUpdated(int256 temperature);
    
    constructor(address _link, address _oracle, bytes32 _jobId, uint256 _fee, address _signSigner) {
        setChainlinkToken(_link);
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
        signSigner = _signSigner;
        temperatureCheckInterval = 1 days;
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

    function requestTemperatureData() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Set the URL to perform the GET request on
        request.add("get", "http://api.weatherapi.com/v1/current.json?key=YOUR_API_KEY&q=London");
        
        // Set the path to find the desired data in the API response
        request.add("path", "current.temp_c");
        
        // Multiply the result by 100 to remove decimals
        int timesAmount = 100;
        request.addInt("times", timesAmount);
        
        // Send the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    function fulfill(bytes32 _requestId, int256 _temperature) public recordChainlinkFulfillment(_requestId) {
        currentTemperature = _temperature;
        lastTemperatureCheck = block.timestamp;
        emit TemperatureUpdated(_temperature);
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - lastTemperatureCheck) > temperatureCheckInterval;
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        if ((block.timestamp - lastTemperatureCheck) > temperatureCheckInterval) {
            lastTemperatureCheck = block.timestamp;
            requestTemperatureData();
        }
    }
    
    function claimInsurance() public {
        require(insured[msg.sender], "No active insurance");
        require(currentTemperature > TEMPERATURE_THRESHOLD * 100, "Temperature not high enough for payout");
        
        insured[msg.sender] = false;
        payable(msg.sender).transfer(PAYOUT);
    }
}