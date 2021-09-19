//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import './IHEXRGameLogic.sol';
import './GameStructs.sol';
import './HEXRToken.sol';
import './TileNFT.sol';

// This contract should get/set a bunch of values.
// The actual logic should be handled by another contract, in case that contract needs to be replaced.
contract HEXRGameData is Context, Ownable, GameStructs {
    
    /**
     *  @dev Emitted when an improvement is added to the register.
     */
    event ImprovementAdded(address improvement);
    
    /**
     *  @dev Emitted when an improvement is removed from the register.
     */
    event ImprovementRemoved(address improvement);

    /**
     *  @dev Emmitted when a forced tile NFT transfer occurs.
     */
    event ForcibleTransfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    
    
    IHEXRGameLogic public gameLogic;
    
    // A list of valid improvements.
    mapping(ImprovementNFT=>bool) public validImprovements;
    
    // The valid tiles in the game.
    TileNFT public tiles;

    // The HEXR token contract.
    HEXRToken public token;
    
    // The metadata of all of the tiles. Can change.
    mapping(uint=>TileMetadata) internal tileData;
    
    
    
    constructor(TileNFT _tiles) {
        tiles = _tiles;
    }
    
    modifier onlyGameLogic() {
        require(address(gameLogic) == _msgSender());
        _;
    }
    

    
    /**
     *  Sets the game logic contract.
     */
    function setGameLogic(IHEXRGameLogic newLogic) external onlyOwner {
        gameLogic = newLogic;
    }
    
    /**
     *  Adds an improvement contract from the list of approved improvements.
     */
    function addImprovement(ImprovementNFT nft) external onlyOwner {
        validImprovements[nft] = true;
        emit ImprovementAdded(address(nft));
    }
    
    /**
     *  Removes an improvement contract from the list of approved improvements.
     */
    function removeImprovement(ImprovementNFT nft) external onlyOwner {
        validImprovements[nft] = false;
        emit ImprovementRemoved(address(nft));
    }
    

    
    /**
     *  The tile data.
     */
    function getTileData(uint tileId) external view returns(TileMetadata memory) {
        require(tileId < tiles.totalSupply(), "Tile Metadata: tile does not exist.");
        return tileData[tileId];
    }

    /**
     *  Upgrades a tile's level in the metadata. That's all.
     */
    function upgradeTile(uint tileId) external onlyGameLogic { 
        if(tileData[tileId].tileLevel < type(uint16).max) tileData[tileId].tileLevel += 1;
    }

    /**
     *  Transfers a tile from one user to the other, regardless of who did it.
     */
    function forciblyTransferTile(uint tileId, address newOwner) external onlyGameLogic {
        if(tileData[tileId].tileLevel == 0) {
            tileData[tileId] = _createNewTile();
        }

        address owner = tiles.ownerOf(tileId);
        tiles.forceTransfer(tileId, newOwner);
        emit ForcibleTransfer(owner, newOwner, tileId);
    }

    /**
     *  Initializes a tile if its data hasn't been initialized yet.
     */
    function initializeTile(uint tileId) external {
        require(tileData[tileId].tileLevel == 0, "Tile has already been initialized");
        tileData[tileId] = _createNewTile();
    }

    /**
     *  Sets the TileMetadata of the specified tile.
     */
    function setTileData(uint tileId, TileMetadata memory data) external onlyGameLogic {
        tileData[tileId] = data;
    }

    /**
     *  Resets the time since a tile's last token claim to the current timestamp.
     */
    function resetLastClaimed(uint tileId) external onlyGameLogic {
        tileData[tileId].lastTokenClaim = block.timestamp;
    }

    /**
     *  Transfers token from this contract to another address.
     */
    function transferTokens(address to, uint amount) external onlyGameLogic {
        token.transfer(to, amount);
    }
}