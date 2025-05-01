pragma solidity ^0.8.7;

import "./RandomNumberRetailerInterface.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT

// Points to RANDO token
IERC20 constant randoToken = IERC20(0xf0Be8f2232f1a048Bd6ded29e436c28acd732B04);

// RNR Contract Address
address constant RNRContractAddress = 0xC235095838e55A28eC57468CEbBFAFB455F363E3;

address constant owner = 0x5F13FF49EF06a108c66D45C2b1F1211dBdE154CD;

contract RandomNumberRetailerExampleClient
{
    // Points to the official RandomNumberRetailer contract.
    RandomNumberRetailerInterface public constant RANDOM_NUMBER_RETAILER = RandomNumberRetailerInterface(RNRContractAddress);

    function priceOfARandomNumberInWei() public view returns (uint256 _priceOfARandomNumberInWei){
        _priceOfARandomNumberInWei = RANDOM_NUMBER_RETAILER.priceOfARandomNumberInWei();
    }

    function randomNumbersAvailable() public view returns (uint256 amountOfRandomNumbersAvailable){
        amountOfRandomNumbersAvailable = RANDOM_NUMBER_RETAILER.randomNumbersAvailable();
    }

    // Modifier that helps verify that your request is valid.
    modifier checkIfValidRequest(uint256 amountOfRandomNumbersToRequest) {
        require(
            amountOfRandomNumbersToRequest > 0,
            "FAILURE: You must request at least one random number."
        );

        require(
            amountOfRandomNumbersToRequest <= randomNumbersAvailable(),
            "FAILURE: You requested more random numbers than are available."
        );

        _;
    } 

    // Buy random numbers using the native token.

    function requestRandomNumbersSynchronousUsingNativeToken(
        uint256 amountOfRandomNumbersToRequest, 
        RandomNumberRetailerInterface.Proof memory proof, 
        RandomNumberRetailerInterface.RequestCommitment memory rc
    ) external payable checkIfValidRequest(amountOfRandomNumbersToRequest) returns (uint256[] memory randomNumbersToReturn){
        require(
            msg.value >= (amountOfRandomNumbersToRequest * priceOfARandomNumberInWei()), 
            "FAILURE: You didn't pay enough for the random numbers. Please increase the value of your transaction."
        );

        randomNumbersToReturn = RANDOM_NUMBER_RETAILER.requestRandomNumbersSynchronousUsingVRFv2Seed{value: msg.value}(amountOfRandomNumbersToRequest, proof, rc, false);
        emit RandomNumberRetailerInterface.RandomWordsReturnedSync(msg.sender, msg.value, amountOfRandomNumbersToRequest);
    }

    // Buy random numbers using RANDO token. 
    // Remember to approve the RANDOM_NUMBER_RETAILER contract spending your RANDO before calling this.

    function requestRandomNumbersSynchronousUsingRando(
        uint256 amountOfRandomNumbersToRequest, 
        RandomNumberRetailerInterface.Proof memory proof, 
        RandomNumberRetailerInterface.RequestCommitment memory rc
    ) external checkIfValidRequest(amountOfRandomNumbersToRequest) returns (uint256[] memory randomNumbersToReturn){

        uint256 randoToTransfer = amountOfRandomNumbersToRequest * ((10 ** 18) / 10);

        require(
            randoToken.transferFrom(msg.sender, address(this), randoToTransfer), 
            "FAILURE: Failed to transfer RANDO from user to RNR contract."
        );
        
        randomNumbersToReturn = RANDOM_NUMBER_RETAILER.requestRandomNumbersSynchronousUsingVRFv2Seed(amountOfRandomNumbersToRequest, proof, rc, true);
        emit RandomNumberRetailerInterface.RandomWordsReturnedSync(msg.sender, 0, amountOfRandomNumbersToRequest);
    }

    function refreshMaximumRNRContractAllowanceForRandoTokens() external {
        require(
            msg.sender == owner, 
            "ERROR: Only owner can call this function."
        );

        require(
            randoToken.approve(RNRContractAddress, type(uint256).max),
            "FAILURE: Failed to give RNR contract access to the maximum amount of the client contract's RANDO"
        );
    }

    constructor() {
        require(
            randoToken.approve(RNRContractAddress, type(uint256).max),
            "FAILURE: Failed to give RNR contract access to the client contract's RANDO upon contract deployment."
        );
    }
}

contract Deployer {
   event ContractDeployed(address deployedContractAddress);

   constructor() {
      emit ContractDeployed(
        Create2.deploy(
            0, 
            "RNR Example Client v5", 
            type(RandomNumberRetailerExampleClient).creationCode
        )
      );
   }
}