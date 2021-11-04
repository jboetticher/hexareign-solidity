//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TileNFT.sol";
import "./HEXRGameData.sol";

// Using this contract:
// First the auctioneer must approve this contract. Preferrably for all tokens.
// Then the auctioneer must activate the openAuction for each NFT they intend to auction.

contract TileSale is Ownable {

    constructor(TileNFT _tiles, HEXRGameData _data, uint _tilePrice) {
        tiles = _tiles;
        data = _data;
        tilePrice = _tilePrice;
    }

    TileNFT tiles;
    HEXRGameData data;
    uint public tilePrice;

    function purchaseTile(uint tileId) external payable {
        require(msg.value >= tilePrice);
        data.initializeTile(tileId);
        tiles.transferFrom(address(this), msg.sender, tileId);
    }

    function setTilePrice(uint _tilePrice) external onlyOwner {
        tilePrice = _tilePrice;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

}