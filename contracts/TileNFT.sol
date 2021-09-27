//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./HEXRGameData.sol";

/**
 * Tile Functionality:
 * Purchase/Sell NFTs
 * 
 * Cryptopunk's entire collection is on a single contract. 
 * Similarly, the entire collection will be here as well. 
 * 
 */

contract TileNFT is ERC721Enumerable, Ownable {
    
    /* Maps NFT ID to static data.
     * x - 12
     * y - 12
     * biome - 4
     * landform - 4
     * height - 8
     * meta - 8
    */
    mapping(uint => uint48) private staticTileData;
    HEXRGameData private gameContract;
    
    constructor() ERC721("Hexoreign Tile", "HEXO-TIL") { }
    
    function addTiles(uint48[] memory map) external onlyOwner {
        // Loops until the end or runs out of gas.
        require(map.length <= 40);
        uint8 i = 0;
        uint24 supply = uint24(totalSupply());
        while(i < map.length && i < type(uint24).max) {
            staticTileData[supply] = map[i];

            if(isCoreTile(supply)) _mint(_msgSender(), supply);
            else _mint(address(this), supply);

            i++;
            supply++;
        }
    }
    
    function isCoreTile(uint id) public pure returns(bool) {
        return id % 20 == 3;
    }
    
    // Sets the HEXR Game Data contract. Can only be set once by the developer.
    function setHEXRGameData(HEXRGameData newContract) external onlyOwner {
        require(address(gameContract) == address(0), "The game contract can only be set once.");
        gameContract = newContract;
    }
    
    // Transfer function that should be used by the gameContract.
    function forceTransfer(uint id, address newOwner) external {
        require(address(gameContract) != address(0), "HEXR game contract not set.");
        require(_msgSender() == address(gameContract), "Not allowed.");
        _safeTransfer(ownerOf(id), newOwner, id, "");
    }
    
    function tileData(uint id) external view
    returns(int16 x, int16 y, uint8 biome, uint8 landform, uint8 height, uint16 meta)
    {
        require(_exists(id), "tileData requested for tile that does not exist.");
        uint48 storedData = staticTileData[id];
        x = _decodeU16to12(uint16(storedData >> 36));
        y = _decodeU16to12(uint16((storedData >> 24) & 0x0FFF));
        biome = uint8(storedData >> 20 & 0x0F);
        landform = uint8(storedData >> 16 & 0x0F);
        height = uint8(storedData >> 8);
        meta = uint8(storedData);
    }
    
    function _decodeU16to12(uint16 e) internal pure returns(int16) {
        if(e >= 2048) e = e | 0xF000;
        return int16(e);
    }
    
}