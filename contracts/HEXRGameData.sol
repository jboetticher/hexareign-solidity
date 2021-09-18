//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;
import './TileNFT.sol';
import './IHEXRGameLogic.sol';
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/Context.sol";
import './Improvements/ImprovementNFT.sol';
 
// This contract should get/set a bunch of values.
// The actual logic should be handled by another contract, in case that contract needs to be replaced.
contract HEXRGameData is Context, Ownable {
    
    /**
     * @dev Emitted when an improvement is added to the register.
     */
    event ImprovementAdded(address improvement);
    
    /**
     * @dev Emitted when an improvement is removed from the register.
     */
    event ImprovementRemoved(address improvement);
    
    
    
    IHEXRGameLogic public gameLogic;
    
    // A list of valid improvements.
    mapping(ImprovementNFT=>bool) public validImprovements;
    
    // The valid tiles in the game.
    TileNFT public tiles;
    
    // The metadata of all of the tiles. Can change.
    mapping(uint=>TileMetadata) public tileData;
    
    struct TileMetadata {
        uint lastTokenClaim;
        uint16 tileLevel;
        uint32 tokenGeneration;
        int16 tokenGenerationPercentageBoost;
        ImprovementContainer improvements;
    }
    
    struct ImprovementContainer {
        ImprovementNFT slot1;
        ImprovementNFT slot2;
        ImprovementNFT slot3;
        uint8 improvementPoints;
    }
    
    
    
    constructor(TileNFT _tiles) {
        tiles = _tiles;
    }
    
    modifier onlyGameLogic() {
        require(address(gameLogic) == _msgSender());
        _;
    }
    
    
    
    function setGameLogic(IHEXRGameLogic newLogic) external onlyOwner {
        gameLogic = newLogic;
    }
    
    function addImprovement(ImprovementNFT nft) external onlyOwner {
        validImprovements[nft] = true;
        emit ImprovementAdded(address(nft));
    }
    
    function removeImprovement(ImprovementNFT nft) external onlyOwner {
        validImprovements[nft] = false;
        emit ImprovementRemoved(address(nft));
    }
    
    
    
    function upgradeTile(uint tileId) external onlyGameLogic { 
        if(tileData[tileId].tileLevel < type(uint16).max) tileData[tileId].tileLevel += 1;
    }
}