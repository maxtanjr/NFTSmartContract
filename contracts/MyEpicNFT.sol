// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

// we inherit the contract we imported. This means we will have access to the contract's methods
contract MyEpicNFT is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // number of NFTs minted by each approved wallet so far
    mapping(address => uint8) public numNFTsOwnedMap;
    // uint[] userOwnedNFTArray;

    // the token IDs that each wallet holds
    mapping(address => uint[]) public tokenIdsMap;

    // our SVG code. All we need to change is the word that is displayed. Everything else stays the same.
    // Hence, we make a baseSvg variable here that all our NFTs can use
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // I create three arrays, each with their own theme of random words
    string[] firstWords = ["Pie", "Pleb", "Moo", "Cake", "Extra", "Fierce", "Toy", "Ass", "Eternal", "Mother", "Kool", "Impressive", "King", "Annoying"];
    string[] secondWords = ["Cream", "Cum", "Turtle", "Majestic", "Anaconda", "Toilet", "Scrub", "Shit", "Goat", "Sand", "Durian", "Coder", "Breast"];
    string[] thirdWords = ["Filthy", "Happy", "Sex", "Horny", "Psychopath", "Pedophile", "Degenerate", "Gambler", "Adultery", "Smelly", "Lazy"];

    // specify event so that we can retrieve the token ID from the frontend!
    event NewEpicNFTMinted(address sender, uint256 tokenId);

    // we need to pass the name of our NFTs token and its symbol
    constructor() ERC721("ThreeRandomWords", "TRWS") {
        console.log("This is the Fatcats NFT contract!");
    }

    // function that randomly picks a word from each array
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // seed the random generator
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        // squash the # between 0 and the length of the array to avoid going out of bounds
        rand = rand % firstWords.length;
        return firstWords[rand];

    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }



    function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
    }

    function _updateTokenIdsMap(uint tokenId) private {
        tokenIdsMap[msg.sender].push(tokenId);
        
    }

    function _updatedNumNFTsOwnedMap() private {
        numNFTsOwnedMap[msg.sender] += 1;
    }

    function getTokenIdsByAddress(address _address) public view returns (uint[] memory) {
        return tokenIdsMap[_address];
    }

    modifier notReachedMaximumAllowableMints() {
        require(numNFTsOwnedMap[msg.sender] < 10, "User has reached the maximum number of mints allowed!");
        _;
    }

    // a function our user will execute to get their NFT
    function mintNFT() public notReachedMaximumAllowableMints {

        // get the current tokenId. This starts at 0
        uint256 newItemId = _tokenIds.current();

        // randomly grab one word from each array   
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // concatenate it all together, and then close the <text> and <svg> tags
        string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

        // get all the JSON metadata in place by concatenating various strings, and base64 encode it
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A collection of three-word phrases.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // concatenate the application/json suffix with the base64 encoded string which contains our JSON metadata (which in turn contains our base64 encoded SVG string)
        string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

        console.log("\n--------------------");
        console.log(
            string(abi.encodePacked(
                "https://nftpreview.0xdev.codes/?code=",
                finalTokenUri
            ))
        );
        console.log("--------------------\n");

        // mint the NFT to the sender using msg.sender
        _safeMint(msg.sender, newItemId);

        // set the NFT's metadata
        _setTokenURI(newItemId, finalTokenUri);

        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        // increment the counter for when the next NFT is created
        _tokenIds.increment();

        // update maps
        _updatedNumNFTsOwnedMap();
        _updateTokenIdsMap(newItemId);

        console.log("The wallet %s has minted %d tokens so far \n", msg.sender, numNFTsOwnedMap[msg.sender]);

        uint[] memory tokenIdArr = getTokenIdsByAddress(msg.sender);

        for (uint i=0; i < tokenIdArr.length; i++) {
             console.log("The wallet %s owns NFT token with ID %d \n", msg.sender, tokenIdArr[i]);
        }

        // emit event so that we can pick it up on our frontend
        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}