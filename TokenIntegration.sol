// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyERC721.sol";
import "./MyERC20.sol";

contract TokenIntegration {
    MyERC721 public erc721Token;
    MyERC20 public erc20Token;
    uint256 public erc20TokensToTransfer;
    mapping(uint256 => uint256) public erc721ToErc20;

    event TokenMapped(uint256 indexed erc721TokenId, uint256 erc20TokenAmount);

    constructor(address erc721Address, address erc20Address) {
        erc721Token = MyERC721(erc721Address);
        erc20Token = MyERC20(erc20Address);
    }

    function mintERC721WithErc20Tokens(address to, uint256 erc721TokenId) public {

        require(erc721Token.ownerOf(erc721TokenId) == msg.sender, "ERC721 token is not held by the integration contract");

        // Mint associated ERC20 tokens (1000 ERC20 tokens per ERC721 token)
        uint256 erc20TokensToMint = 1000;
        erc20Token.mint(to, erc20TokensToMint);

        // Map ERC721 token to ERC20 token balance
        erc721ToErc20[erc721TokenId] = erc20TokensToMint;

        emit TokenMapped(erc721TokenId, erc20TokensToMint);
    }

     function transferERC721WithErc20Tokens(address to, uint256 erc721TokenId) public payable {
       require(
        erc721Token.ownerOf(erc721TokenId) == msg.sender,
        "Caller is not the owner or approved to transfer the ERC721 token"
       );

        // Transfer ERC721 token
        
        erc721Token.safeTransferFrom(msg.sender, to, erc721TokenId);

        // Transfer associated ERC20 tokens
        erc20TokensToTransfer = erc721ToErc20[erc721TokenId];
        erc20Token.transferFrom(msg.sender, to, erc20TokensToTransfer);

        // Update ERC721 token-to-ERC20 token mapping
        erc721ToErc20[erc721TokenId] = 0;
    }
}
