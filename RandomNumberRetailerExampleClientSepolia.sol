pragma solidity ^0.8.7;

import "./RandomNumberRetailerInterface.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

// SPDX-License-Identifier: MIT

contract RandomNumberRetailerExampleClient
{
    // Points to the official RandomNumberRetailer contract.
    RandomNumberRetailerInterface public constant RANDOM_NUMBER_RETAILER = RandomNumberRetailerInterface(0xd058eA7e3DfE100775Ce954F15bB88257CC10191);

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

        require(
            msg.value >= (amountOfRandomNumbersToRequest * priceOfARandomNumberInWei()), 
            "FAILURE: You didn't pay enough for the random numbers. Please increase the value of your transaction."
        );

        _;
    } 

    // requestRandomNumbersSynchronous
    //
    // Uses the standard method of retrieving random numbers from the official RandomNumberRetailer contract.
    // It is extremely easy to use and much cheaper than Chainlink VRF v2.
    // The user pays for random numbers with ETH instead of LINK.
    // The random numbers are returned instantly so you don't need to wait for a callback.
    // Unlike Chainlink, you do need to generate some random seeds for safety.
    // In JavaScript using web3.js, you can create the randomSeedArray using this code:
    //
	//		const randomSeedArrayLength = 5;
	//		
	//		let randomSeedArray = [];
	//		
	//		for(let i=0; i < randomSeedArrayLength; i++){
	//		    randomSeedArray.push(
	//			    web3.utils.hexToNumber(
	//				    web3.utils.randomHex(32)
	//				)
	//			);
	//		}

    function requestRandomNumbersSynchronous(
        uint256 amountOfRandomNumbersToRequest, 
        uint256[] memory randomSeedArray
    ) external payable checkIfValidRequest(amountOfRandomNumbersToRequest) returns (uint256[] memory randomNumbersToReturn){
        require(
            randomSeedArray.length > 0,
            "FAILURE: randomSeedArray cannot be empty."
        );

        randomNumbersToReturn = RANDOM_NUMBER_RETAILER.requestRandomNumbersSynchronous{value: msg.value}(amountOfRandomNumbersToRequest, randomSeedArray);
        emit RandomNumberRetailerInterface.RandomWordsReturnedSync(msg.sender, msg.value, amountOfRandomNumbersToRequest);
    }

    // requestRandomNumbersSynchronousUsingVRFv2Seed
    //
    // Uses the advanced method of retrieving random numbers from the official RandomNumberRetailer contract.
    // With this method, the user must generate a Chainlink VRF v2 compatible proof and request commitment.
    // Random Number Retailer LLC is happy to assist anyone who wishes to use this advanced method.
    // Please contact randomnumberretailer@gmail.com to learn more.

    function requestRandomNumbersSynchronousUsingVRFv2Seed(
        uint256 amountOfRandomNumbersToRequest, 
        RandomNumberRetailerInterface.Proof memory proof, 
        RandomNumberRetailerInterface.RequestCommitment memory rc
    ) external payable checkIfValidRequest(amountOfRandomNumbersToRequest) returns (uint256[] memory randomNumbersToReturn){
        randomNumbersToReturn = RANDOM_NUMBER_RETAILER.requestRandomNumbersSynchronousUsingVRFv2Seed{value: msg.value}(amountOfRandomNumbersToRequest, proof, rc);
        emit RandomNumberRetailerInterface.RandomWordsReturnedSync(msg.sender, msg.value, amountOfRandomNumbersToRequest);
    }
}

contract Deployer {
   event ContractDeployed(address deployedContractAddress);

   constructor() {
      emit ContractDeployed(
        Create2.deploy(
            0, 
            "RNR Example Client v1.0", 
            type(RandomNumberRetailerExampleClient).creationCode
        )
      );
   }
}
