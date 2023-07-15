// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TreeNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Tree {
        uint256 tokenId;
        uint256 birthTime; //store the time of planting
        uint256 birthTimestamp; //store and update the value of watering  time
        string species;
        string metadata;
    }

    mapping(uint256 => Tree) private _trees;
    mapping(address => uint256[]) private _userMintedTokens;
    mapping(address => uint256[]) private _userPlantedTokens;

    constructor() ERC721("Tree NFT", "TNFT") {}

    // function for planting tree
    function plantTree(string memory species, string memory metadata) external {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        uint256 currentTimestamp = block.timestamp;

        _mint(msg.sender, newTokenId);
        _userPlantedTokens[msg.sender].push(newTokenId);
        _trees[newTokenId] = Tree(newTokenId, currentTimestamp,currentTimestamp ,species, metadata);
    }

    //function for watering
    function waterTree(uint256 tokenId) external {
        require(_exists(tokenId), "TreeNFT: Token ID does not exist");
        require(ownerOf(tokenId) == msg.sender, "TreeNFT: Caller is not the owner of the token");
        require(_trees[tokenId].birthTimestamp != 0, "TreeNFT: Token does not represent a tree");

        require(block.timestamp <= _trees[tokenId].birthTime + 15 days, "TreeNFT: Tree is matuared");
        
        //plant will die if not watered within one day
        if (block.timestamp >= _trees[tokenId].birthTimestamp + 1 days) {
            _trees[tokenId].birthTimestamp = 0;
            _burn(tokenId);
        } else {
            _trees[tokenId].birthTimestamp = block.timestamp; //last watered time updated
        }
    }
    
    //To mint NFT after 15 days
    function mintAsNFT(uint256 tokenId) external {
        require(_exists(tokenId), "TreeNFT: Token ID does not exist");
        require(ownerOf(tokenId) == msg.sender, "TreeNFT: Caller is not the owner of the token");

        require(block.timestamp >= _trees[tokenId].birthTime + 15 days, "TreeNFT: Tree has not reached maturity yet");
        
        if(_trees[tokenId].birthTime + 15 days - _trees[tokenId].birthTimestamp <= 1 days){
        _userMintedTokens[msg.sender].push(tokenId);
        _setTokenURI(tokenId, getTreeMetadata(tokenId));
        }else{
            _trees[tokenId].birthTimestamp = 0;
            _burn(tokenId);
        }
    }

    //tree details
    function getTree(uint256 tokenId) external view returns (Tree memory) {
        require(_exists(tokenId), "TreeNFT: Token ID does not exist");
        return _trees[tokenId];
    }

    //tree metadata
    function getTreeMetadata(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "TreeNFT: Token ID does not exist");
        require(block.timestamp >= _trees[tokenId].birthTimestamp + 15 days, "TreeNFT: Tree has not reached maturity yet");

        return _trees[tokenId].metadata;
    }

    // Give all the minted trees of a user
    function getUserMintedTREEs(address user) external view returns (uint256[] memory) {
        return _userMintedTokens[user];
    }

    // Give all the planted trees of a user
    function getUserPlantedTREEs(address user) external view returns (uint256[] memory) {
        return _userPlantedTokens[user];
    }

    //To burn nft 
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
    }
}
