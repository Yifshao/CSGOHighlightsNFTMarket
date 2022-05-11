//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

//Here I use ERC721URIStorage, which is ERC721 token with storage based token URI management,to mint new NFT token and store tokenURI.
contract NFT_CSGO is ERC721URIStorage{
    uint public tokenCount;
// Here CSGONFT is the name of token and CSGO is the symbol of token.
    constructor() ERC721("CSGONFT", "CSGO"){}

//mint function mints a new NFT token and returns the id of token.
    function mint(string memory _tokenURI) external returns(uint){
        tokenCount = tokenCount + 1;
        _safeMint(msg.sender, tokenCount);
        _setTokenURI(tokenCount, _tokenURI);
        return(tokenCount);
    }
}