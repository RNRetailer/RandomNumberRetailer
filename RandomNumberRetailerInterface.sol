pragma solidity ^0.8.7;

// SPDX-License-Identifier: MIT

interface RandomNumberRetailerInterface {
    struct Proof {
        uint256[2] pk;
        uint256[2] gamma;
        uint256 c;
        uint256 s;
        uint256 seed;
        address uWitness;
        uint256[2] cGammaWitness;
        uint256[2] sHashWitness;
        uint256 zInv;
    }

    struct RequestCommitment {
        uint64 blockNum;
        uint256 subId;
        uint32 callbackGasLimit;
        uint32 numWords;
        address sender;
        bytes extraArgs;
    }

    event RandomWordsReturnedSync(address indexed requestor, uint256 weiPaid, uint256 amountOfRandomNumbersReturned);

    function priceOfARandomNumberInWei() external view returns (uint256 priceOfARandomNumberInWei);

    function randomNumbersAvailable() external view returns (uint256 amountOfRandomNumbersAvailable);

    function requestRandomNumbersSynchronous(
        uint256 amountOfRandomNumbersToRequest, 
        uint256[] memory randomSeedArray
    ) external payable returns (uint256[] memory randomNumbersToReturn);

    function requestRandomNumbersSynchronousUsingVRFv2Seed(
        uint256 amountOfRandomNumbersToRequest, 
        Proof memory proof, 
        RequestCommitment memory rc
    ) external payable returns (uint256[] memory randomNumbersToReturn);
}
