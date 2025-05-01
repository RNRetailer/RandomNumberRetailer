pragma solidity ^0.8.7;

import "./RandomNumberRetailerInterface.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

// SPDX-License-Identifier: MIT

contract RandomNumberRetailerExampleClient
{
    // Points to the official RandomNumberRetailer contract.
    RandomNumberRetailerInterface public constant RANDOM_NUMBER_RETAILER = RandomNumberRetailerInterface(0x5f46734C0239C0Aeb239f6f2140FaBa05f7C29E9);

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
        randomNumbersToReturn = RANDOM_NUMBER_RETAILER.requestRandomNumbersSynchronousUsingVRFv2Seed{value: 0}(amountOfRandomNumbersToRequest, proof, rc, true);
        emit RandomNumberRetailerInterface.RandomWordsReturnedSync(msg.sender, msg.value, amountOfRandomNumbersToRequest);
    }
}

contract Deployer {
   event ContractDeployed(address deployedContractAddress);

   constructor() {
      emit ContractDeployed(
        Create2.deploy(
            0, 
            "RNR Example Client v2.0", 
            type(RandomNumberRetailerExampleClient).creationCode
        )
      );
   }
}
