// SPDX-License-Identifier: UNLICENSED

// ~~~~~~~~~~~~~~~Random Number Retailer: Random Numbers Just Got a Whole Lot Cheaper... And Easier Too!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// |                                                                                                                                                                                                                                                                                                       |
// |  This program has two major aims:                                                                                                                                                                                                                                                                     |
// |                                                                                                                                                                                                                                                                                                       |
// |  1. Reduce the price of verifiably random numbers on chain when requested in small batches.                                                                                                                                                                                                           |
// |                                                                                                                                                                                                                                                                                                       |
// |     As of 2/29/24, Chainlink VRF v2 charges a similar amount for anywhere between one and five hundred random numbers.                                                                                                                                                                                |
// |     This means that getting a single random number is about as expensive as getting five hundred random numbers!                                                                                                                                                                                      |
// |                                                                                                                                                                                                                                                                                                       |                                                                                                                                                         |
// |     This smart contract charges a set price per random number, making requests for small amounts of random numbers much cheaper.                                                                                                                                                                      |
// |     The price we charge per random number is determined by priceOfARandomNumberInWei.                                                                                                                                                                                                                 |
// |                                                                                                                                                                                                                                                                                                       |
// |     We will try to keep the price much lower for small batches of random numbers than if the caller purchased them from Chainlink VRF v2.                                                                                                                                                             |
// |     Additionally, we accept ETH for the random numbers instead of LINK, which makes our contract way easier to use than Chainlink VRF v2 and saves the caller a ton of gas.                                                                                                                           |
// |     For many applications, we expect the cost savings to be significant.                                                                                                                                                                                                                              |
// |                                                                                                                                                                                                                                                                                                       |
// |  2. Convert Chainlink VRF v2 from async to sync, drastically improving its ease of use.                                                                                                                                                                                                               |
// |                                                                                                                                                                                                                                                                                                       |
// |     By design, Chainlink VRF v2 is asynchronous: first, you make a transaction to the VRF v2 coordinator to request the random numbers.                                                                                                                                                               |
// |     Then, some unknowable time in the future, Chainlink **might** call the callback method on your smart contract with the random numbers you've requested.                                                                                                                                           |
// |     This asynchronous design makes using verifiable randomness on the blockchain extremely awkward and cumbersome.                                                                                                                                                                                    |
// |                                                                                                                                                                                                                                                                                                       |
// |     This smart contract allows the caller to request random numbers in a completely synchronous fashion.                                                                                                                                                                                              |
// |     The random numbers are returned instantly from this contract when requested, drastically improving on Chainlink's ease of use and flexibility.                                                                                                                                                    |
// |     With this smart contract, there is no need for a callback method, and no need to wait for a second transaction.                                                                                                                                                                                   |
// |     You will receive your random numbers immediately with no hassle.                                                                                                                                                                                                                                  |
// |                                                                                                                                                                                                                                                                                                       |
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// |                                                                                                                                                                                                                                                                                                       |
// |  Instructions for using this contract:                                                                                                                                                                                                                                                                |
// |                                                                                                                                                                                                                                                                                                       |
// |  1. Begin by checking randomNumbersAvailable to see how many random numbers are available for purchase.                                                                                                                                                                                               |
// |     Then, create a uint256 specifying how many random numbers you wish to buy.                                                                                                                                                                                                                        |
// |     Let's call that amountOfRandomNumbersToRequest.                                                                                                                                                                                                                                                   |
// |     Remember that other callers can buy random numbers during the same block, so it's possible the amount of random numbers you can buy is lower than randomNumbersAvailable.                                                                                                                         |
// |     However, we constantly supply additional random numbers to this contract when randomNumbersAvailable goes below minimumHealthyLengthOfRandomNumbersArray.                                                                                                                                         |
// |     As long as this contract is active, it should usually have a healthy supply of random numbers available for purchase.                                                                                                                                                                             |
// |                                                                                                                                                                                                                                                                                                       |
// |  2. Next, multiply priceOfARandomNumberInWei by amountOfRandomNumbersToRequest.                                                                                                                                                                                                                       |
// |     We'll call that totalPrice.                                                                                                                                                                                                                                                                       |
// |     This is the amount of ETH in wei that you must explicitly pay when requesting random numbers from this smart contract.                                                                                                                                                                            |
// |                                                                                                                                                                                                                                                                                                       |
// |  3. Generate an array of uint256 random seeds. Let's call it randomSeedArray.                                                                                                                                                                                                                         |
// |     To maximize safety and randomness, you should ideally generate your random seeds off of the blockchain, in a traditional programming language.                                                                                                                                                    |
// |     If the user is calling your smart contract in a web browser, you can use JavaScript to generate different random seeds for each call.                                                                                                                                                             |
// |     If you are calling the smart contract from a server, you should generate the random seeds in your programming language of choice.                                                                                                                                                                 |
// |     It is possible to generate pseudorandom seeds on the blockchain, but it is not ideal.                                                                                                                                                                                                             |
// |     If your random seeds are too easily guessable, a validator or MEV bot could attack your smart contract.                                                                                                                                                                                           |
// |                                                                                                                                                                                                                                                                                                       |
// |  4. Call requestRandomNumbersSynchronous(amountOfRandomNumbersToRequest, randomSeedArray) and set the value of the transaction to totalPrice.                                                                                                                                                         |
// |     If the call succeeds, an array of verifiably random uint256 numbers will be returned.                                                                                                                                                                                                             |
// |     The length of the returned array will be equal to amountOfRandomNumbersToRequest.                                                                                                                                                                                                                 |
// |     Now, you can use verifiably random numbers in your smart contract in an easy, affordable, and synchronous manner!                                                                                                                                                                                 |
// |                                                                                                                                                                                                                                                                                                       |
// |   Advanced users can call requestRandomNumbersSynchronousUsingVRFv2Seed instead to swap their Chainlink VRFv2 proof for our verifiably random numbers.                                                                                                                                                |
// |                                                                                                                                                                                                                                                                                                       |
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// |                                                                                                                                                                                                                                                                                                       |
// |  Future plans:                                                                                                                                                                                                                                                                                        |
// |                                                                                                                                                                                                                                                                                                       |
// |   1. Deployment on other blockchains                                                                                                                                                                                                                                                                  |
// |                                                                                                                                                                                                                                                                                                       |
// |      We are planning on deploying a version of this contract on all blockchains that support Chainlink VRF v2.                                                                                                                                                                                        |
// |      Currently, that includes Ethereum, Arbitrum, Polygon (Matic), Avalanche, BNB Chain, and Fantom.                                                                                                                                                                                                  |
// |      We will also deploy contracts to each blockchain's respective testnets.                                                                                                                                                                                                                          |
// |      We will try to keep the owner / deployer and server addresses consistent across blockchains so you can verify the legitimacy of the smart contracts.                                                                                                                                             |
// |      We may also deploy to additional blockchains as needed.                                                                                                                                                                                                                                          |
// |                                                                                                                                                                                                                                                                                                       |
// |   2. Token airdrop                                                                                                                                                                                                                                                                                    |
// |                                                                                                                                                                                                                                                                                                       |
// |      At some point, we plan on releasing an ERC20 token that rewards the use of our smart contracts.                                                                                                                                                                                                  |
// |      The more random numbers you've purchased from one of our smart contracts on a given blockchain, the larger the airdrop you'll receive on that blockchain.                                                                                                                                        |
// |      Testnets will not receive the airdrop.                                                                                                                                                                                                                                                           |
// |                                                                                                                                                                                                                                                                                                       |
// |      Tokens will be airdropped on all non-testnet blockchains that contain one of our smart contracts.                                                                                                                                                                                                |
// |      The tokens should be able to flow seamlessly between all supported blockchains.                                                                                                                                                                                                                  |
// |                                                                                                                                                                                                                                                                                                       |
// |      These tokens are not securities and you should not expect us to try to increase their price.                                                                                                                                                                                                     |
// |                                                                                                                                                                                                                                                                                                       |
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// |                                                                                                                                                                                                                                                                                                       |
// |  Verifying the legitimacy of this smart contract:                                                                                                                                                                                                                                                     |                                                                                                                                                                                                                                                                                  |
// |     The owner / deployer address is 0x8Fb9bcdde589059a87eE1056f5bc3F52782d55BB                                                                                                                                                                                                                        |
// |     The server address is 0xD16512fdBb90096B1f1888Cae6152177065FdA62                                                                                                                                                                                                                                  |
// |                                                                                                                                                                                                                                                                                                       |
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// |                                                                                                                                                                                                                                                                                                       |
// |  Legal:                                                                                                                                                                                                                                                                                               |
// |                                                                                                                                                                                                                                                                                                       |
// |  Random Number Retailer LLC Copyright 2024                                                                                                                                                                                                                                                            |
// |  Random Number Retailer LLC is a Limited Liability Company registered in the state of New Mexico, United States of America.                                                                                                                                                                           |
// |                                                                                                                                                                                                                                                                                                       |
// |  Anyone who is not sanctioned by the United States of America is allowed to read the public variables of this smart contract.                                                                                                                                                                         |
// |                                                                                                                                                                                                                                                                                                       |
// |  Anyone who is not sanctioned by the United States of America can call the following methods by submitting a transaction to the blockchain on which this smart contract resides:                                                                                                                      |
// |      randomNumbersAvailable                                                                                                                                                                                                                                                                           |
// |      requestRandomNumbersSynchronous                                                                                                                                                                                                                                                                  |
// |      requestRandomNumbersSynchronousUsingVRFv2Seed                                                                                                                                                                                                                                                    |
// |                                                                                                                                                                                                                                                                                                       |
// |  Anyone processing transactions for the blockchain on which this smart contract resides can process any transaction associated with this smart contract in the standard manner. No special behavior is required.                                                                                      |
// |                                                                                                                                                                                                                                                                                                       |
// |  No person or entity other than Random Number Retailer LLC is allowed to call any method with the modifiers onlyServer or onlyOwner by submitting a transaction to the blockchain on which this smart contract resides without the explicit consent of Random Number Retailer LLC.                    |
// |                                                                                                                                                                                                                                                                                                       |
// |  The code for the "RandomNumberRetailer" contract is available to view publicly, but no party other than Random Number Retailer LLC can reuse any of this proprietary code in a separate smart contract or program of any sort without the explicit consent of Random Number Retailer LLC.            |
// |                                                                                                                                                                                                                                                                                                       |
// |  Any person or entity who reuses any part of this code in a separate smart contract or program without the explicit consent of Random Number Retailer LLC may be subject to legal action.                                                                                                             |
// |                                                                                                                                                                                                                                                                                                       |
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// |                                                                                                                                                                                                                                                                                                       |
// |  Contact:                                                                                                                                                                                                                                                                                             |
// |                                                                                                                                                                                                                                                                                                       |
// |  As of 2/29/24, Random Number Retailer LLC uses a gmail account for most correspondence.                                                                                                                                                                                                              |
// |  Please email randomnumberretailer@gmail.com with any proposals, feedback, etc.                                                                                                                                                                                                                       |
// |  Keep up with our announcements on Twitter / X: https://twitter.com/RNRetailer or https://x.com/RNRetailer                                                                                                                                                                                            |
// |                                                                                                                                                                                                                                                                                                       |
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "./VRF.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

// BlockhashStoreInterface is from Chainlink
interface BlockhashStoreInterface {
    function getBlockhash(uint256 number) external view returns (bytes32);
}

contract RandomNumberRetailer is VRF, ConfirmedOwner
{
    uint256 public minimumHealthyLengthOfRandomNumbersArray = 5000;
    uint256 public priceOfARandomNumberInWei = 439;
    uint256 public minimumViablePriceOfARandomNumberInWei = 10;
    uint256 public mostRecentRequestId = 0;
    uint256 private mostRecentlyReturnedRandomNumber = 0;
    uint256 private minimumServerBalanceInWei = 1000000000000000000;
    uint256 private maximumCostOfSendInWei = 50000000000000000;
    uint256 private amountOfGasUsedForAFulfillRandomNumbersTransaction = 11524416;
    uint32 private maximumNumbersThatCanBeFulfilledInOneTransaction = 500;

    address public replacementContractAddress = address(0);
    bool public contractIsPaused = false;
    uint8 public priceMultiplier = 5;

    error BlockhashNotInStore(uint256 blockNum);  // from Chainlink
    BlockhashStoreInterface public constant BLOCKHASH_STORE = BlockhashStoreInterface(0x1159E1889754a1F0862F8EC0E109F169aECBCD6f);  // from Chainlink

    event RandomWordsFulfilled(uint256 indexed requestId, uint256 outputSeed, uint96 payment, bool success); // from Chainlink
    event RandomWordsReturnedSync(address indexed requestor, uint256 weiPaid, uint256 amountOfRandomNumbersReturned);

    address private constant ownerAddress = 0x8Fb9bcdde589059a87eE1056f5bc3F52782d55BB; // prod owner
    //address private constant ownerAddress = 0x6D615F78382314B9Aa388975a51e20Cbc65Ae6b5; // test owner
    address private constant serverAddress = 0xD16512fdBb90096B1f1888Cae6152177065FdA62;

    struct RequestCommitment {
        uint64 blockNum;
        uint256 subId;
        uint32 callbackGasLimit;
        uint32 numWords;
        address sender;
        bytes extraArgs;
    }

    uint256[] private randomNumbersArray = new uint256[](0);

    constructor()
        ConfirmedOwner(ownerAddress)
    {}

    modifier onlyServer() {
        require(
            msg.sender == serverAddress, 
            "FAILURE: Only the server can call this method."
        );

        _;
    }

    modifier checkIfPaused() {
        require(
            !contractIsPaused,
            "FAILURE: The contract is paused."
        );

        _;
    }

    modifier checkIfDeprecated(){
        require(
            replacementContractAddress == address(0),
            "FAILURE: This contract is deprecated. Please check replacementContractAddress for the new contract address."
        );

        _;
    }

    function setMaximumNumbersThatCanBeFulfilledInOneTransaction(
        uint32 _maximumNumbersThatCanBeFulfilledInOneTransaction
    ) external onlyOwner{
        maximumNumbersThatCanBeFulfilledInOneTransaction = _maximumNumbersThatCanBeFulfilledInOneTransaction;
    }

    function setAmountOfGasUsedForAFulfillRandomNumbersTransaction(
        uint256 _amountOfGasUsedForAFulfillRandomNumbersTransaction
    ) external onlyOwner{
        amountOfGasUsedForAFulfillRandomNumbersTransaction = _amountOfGasUsedForAFulfillRandomNumbersTransaction;
    }
    
    function setMaximumCostOfSendInWei(
        uint256 _maximumCostOfSendInWei
    ) external onlyOwner{
        maximumCostOfSendInWei = _maximumCostOfSendInWei;
    }

    function setMinimumServerBalanceInWei(
        uint256 _minimumServerBalanceInWei
    ) external onlyOwner{
        minimumServerBalanceInWei = _minimumServerBalanceInWei;
    }

    function setMinimumViablePriceOfARandomNumberInWei(
        uint256 _minimumViablePriceOfARandomNumberInWei
    ) external onlyOwner{
        minimumViablePriceOfARandomNumberInWei = _minimumViablePriceOfARandomNumberInWei;
    }

    function setMinimumHealthyLengthOfRandomNumbersArray(
        uint256 _minimumHealthyLengthOfRandomNumbersArray
    ) external onlyOwner{
        minimumHealthyLengthOfRandomNumbersArray = _minimumHealthyLengthOfRandomNumbersArray;
    }

    function setPriceOfARandomNumberInWei(
        uint256 _priceOfARandomNumberInWei
    ) internal onlyServer checkIfPaused{
        require(
            _priceOfARandomNumberInWei >= minimumViablePriceOfARandomNumberInWei, 
            "FAILURE: Server tried to set priceOfARandomNumberInWei lower than minimumViablePriceOfARandomNumberInWei."
        );

        priceOfARandomNumberInWei = _priceOfARandomNumberInWei;
    }

    function requestRandomNumbersSynchronous(
        uint256 amountOfRandomNumbersToRequest, 
        uint256[] memory randomSeedArray
    ) public payable checkIfPaused checkIfDeprecated returns (uint256[] memory randomNumbersToReturn){
        uint256 currentRandomNumbersArrayLength = randomNumbersArray.length;

        require(
            amountOfRandomNumbersToRequest > 0,
            "FAILURE: You must request at least one random number."
        );

        require(
            amountOfRandomNumbersToRequest <= currentRandomNumbersArrayLength,
            "FAILURE: You requested more random numbers than we have available. Please check randomNumbersAvailable before making your request."
        );

        require(
            msg.value >= priceOfARandomNumberInWei * amountOfRandomNumbersToRequest,
            "FAILURE: You did not pay enough ETH for that amount of random numbers."
        );

        randomNumbersToReturn = new uint256[](amountOfRandomNumbersToRequest);

        uint256 currentRandomNumber = mostRecentlyReturnedRandomNumber;
        uint256 randomSeedArrayLength = randomSeedArray.length;

        uint256 randomSeed;
        uint256 randomNumbersArrayIndex;
        
        for (uint256 i = 0; i < amountOfRandomNumbersToRequest; i++){
            randomSeed = randomSeedArray[
                currentRandomNumber % randomSeedArrayLength
            ];

            randomNumbersArrayIndex = randomSeed % currentRandomNumbersArrayLength;
            
            currentRandomNumber = randomNumbersArray[randomNumbersArrayIndex];
            randomNumbersToReturn[i] = currentRandomNumber;

            randomNumbersArray[randomNumbersArrayIndex] = randomNumbersArray[--currentRandomNumbersArrayLength];
            randomNumbersArray.pop();
        }

        mostRecentlyReturnedRandomNumber = currentRandomNumber;

        emit RandomWordsReturnedSync(msg.sender, msg.value, amountOfRandomNumbersToRequest);

        return randomNumbersToReturn;
    }

    function requestRandomNumbersSynchronousUsingVRFv2Seed(
        uint256 amountOfRandomNumbersToRequest, 
        Proof memory proof, 
        RequestCommitment memory rc
    ) external payable checkIfPaused checkIfDeprecated returns (uint256[] memory randomNumbersToReturn){
      uint256 randomness;

      (, randomness) = getRandomnessFromProof(proof, rc);

      uint256[] memory randomSeedArray = new uint256[](rc.numWords);

      for (uint256 i = 0; i < rc.numWords; i++) {
		randomSeedArray[i] = uint256(keccak256(abi.encode(randomness, i)));
      }

      randomNumbersToReturn = requestRandomNumbersSynchronous(
        amountOfRandomNumbersToRequest, 
        randomSeedArray
      );

      return randomNumbersToReturn;
    }

    // Chainlink derived code starts here:

    /**
   * @notice Returns the proving key hash key associated with this public key
   * @param publicKey the key to return the hash of
   */
    function hashOfKey(uint256[2] memory publicKey) public pure returns (bytes32) {
        return keccak256(abi.encode(publicKey));
    }
  
    function getRandomnessFromProof(Proof memory proof, RequestCommitment memory rc)
    private
    view
    returns (
      uint256 requestId,
      uint256 randomness
    )
    {
        bytes32 keyHash = hashOfKey(proof.pk);
        requestId = uint256(keccak256(abi.encode(keyHash, proof.seed)));

        bytes32 blockHash = blockhash(rc.blockNum);
        
        if (blockHash == bytes32(0)) {
            blockHash = BLOCKHASH_STORE.getBlockhash(rc.blockNum);
            
            if (blockHash == bytes32(0)) {
                revert BlockhashNotInStore(rc.blockNum);
            }
        }

        // The seed actually used by the VRF machinery, mixing in the blockhash
        uint256 actualSeed = uint256(keccak256(abi.encodePacked(proof.seed, blockHash)));
        randomness = VRF.randomValueFromVRFProof(proof, actualSeed); // Reverts on failure
    }

    function fulfillRandomWords(Proof memory proof, RequestCommitment memory rc) external onlyServer {
      require(
        rc.numWords <= maximumNumbersThatCanBeFulfilledInOneTransaction, 
        "FAILURE: You cannot fulfill that many random numbers."
      );

      uint256 randomness;

      (mostRecentRequestId, randomness) = getRandomnessFromProof(proof, rc);
	
      for (uint256 i = 0; i < rc.numWords; i++) {
		randomNumbersArray.push(
			 uint256(keccak256(abi.encode(randomness, i)))
		);
      }

      uint256 prospectivePriceOfARandomNumberInWei = (
        (tx.gasprice * amountOfGasUsedForAFulfillRandomNumbersTransaction) / uint256(rc.numWords)
      ) * uint256(priceMultiplier);

      if (prospectivePriceOfARandomNumberInWei >= minimumViablePriceOfARandomNumberInWei){
        setPriceOfARandomNumberInWei(prospectivePriceOfARandomNumberInWei);
      }

      topUpServerBalance();

      emit RandomWordsFulfilled(mostRecentRequestId, randomness, 0, true);  // from Chainlink
    }

    // Chainlink derived code ends here

    function withdrawETHToOwner(
        uint256 weiToWithdraw
    ) external onlyOwner {
        require(
            address(this).balance > weiToWithdraw,
            "FAILURE: There is not enough ETH in this contract to complete the withdrawal."
        );

        require(
            payable(ownerAddress).send(weiToWithdraw),
            "FAILURE: Failed to withdraw ETH to the owner."
        );
    }

    function topUpServerBalance() internal onlyServer {
        uint256 serverBalanceInWei = serverAddress.balance;

        if(serverBalanceInWei >= minimumServerBalanceInWei){
            return;
        }

        uint256 weiToWithdraw = minimumServerBalanceInWei - serverBalanceInWei;

        if ((weiToWithdraw + maximumCostOfSendInWei) > address(this).balance){
            return;
        }

        require(
            payable(serverAddress).send(weiToWithdraw),
            "FAILURE: Failed to withdraw ETH to the server."
        );
    }

    function setReplacementContractAddress(
        address _replacementContractAddress
    ) external onlyOwner {
        replacementContractAddress = _replacementContractAddress;
    }

    function setPriceMultiplier(
        uint8 _priceMultiplier
    ) external onlyOwner {
        priceMultiplier = _priceMultiplier;
    }

    function pauseOrUnpauseContract(
        bool shouldBePaused
    ) external onlyOwner {
        contractIsPaused = shouldBePaused;
    }

    function randomNumbersAvailable() external view returns (uint256 amountOfRandomNumbersAvailable){
        return randomNumbersArray.length;
    }
}

contract Deployer {
   event ContractDeployed(address deployedContractAddress);

   constructor() {
      emit ContractDeployed(
        Create2.deploy(
            0, 
            "RNR v1", 
            type(RandomNumberRetailer).creationCode
        )
      );
   }
}