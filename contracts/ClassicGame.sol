//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;
import '../TileNFT';

/**
 * Map Functionality:
 * Reference + Generate the TileNFT, which define which are proper map tiles.
 * Distribute Token to tile holders.
 * Hold the Token.
 * 
 * On Claiming an NFT: 
 *      Send previous owner the tokens they are entitled to
 *      Send tax to creator
 * 
 * Claim NFTs next to owned NFTs for a token price.
 */
 
 
 
// Maybe we should make this an ERC20 to really make it a tile.
contract ClassicGame {
    
    // A list of valid improvements.
    mapping(address=>uint16) improvements;
    
    // The valid tiles in the game.
    TileNFT tiles;
    
    // Metadata for each tile. This affects the token loadout.
    struct TileMetadata {
        uint16 tileLevel;
        uint32 tokenGeneration;
        int16 tokenGenerationPercentageBoost;
    }
    
    constructor(TileNFT _tiles) {
        tiles = _tiles;
    }
}