//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import './Improvements/ImprovementNFT.sol';
import './IHEXRGameLogic.sol';
import './HEXRGameData.sol';
import './GameStructs.sol';
import './HEXRToken.sol';
import './TileNFT.sol';

// An interface for the logic that is performed on a smart contract.
contract HEXRGameLogicV1 is Context, IHEXRGameLogic, GameStructs {

    /**
     *  @dev Emitted when an improvement is added to the register.
     */
    event TokenClaim(uint id, uint amount, address claimer);

    HEXRGameData private gameData;

    constructor(HEXRGameData _gameData) {
        gameData = _gameData;
    }

    function _tiles() internal view returns(TileNFT) {
        return gameData.tiles();
    }

    function _token() internal view returns(HEXRToken) {
        return gameData.token();
    }

    modifier isTileOwner(uint256 tileId) {
        require(_tiles().ownerOf(tileId) == _msgSender(), "Not owner of specified tile.");
        _;
    }



    /**
     *  Claims the tokens from the tile specified & emits an event.
     */
    function _claimTokens(uint tileId, address claimer) internal {
        gameData.resetLastClaimed(tileId);
        uint tokensToClaim = claimableTokens(tileId);
        gameData.transferTokens(_msgSender(), tokensToClaim);
        emit TokenClaim(tileId, tokensToClaim, claimer);
    }
    
    /**
     *  Returns the time difference between the current block and the time given.
     */
    function _timeDifference(uint lastTokenClaim) internal view returns(uint) {
        return lastTokenClaim - block.timestamp;
    }
    


    /**
     *  Allows users to claim tokens from tiles that they own.
     */
    function claimTokensFromTile(uint tileId) override external isTileOwner(tileId) {
        _claimTokens(tileId, _msgSender());
    }

    /**
     *  Returns the claimable tokens from a tile.
    */
    function claimableTokens(uint tileId) override public view returns(uint) {
        TileMetadata memory meta = gameData.getTileData(tileId);
        uint timeDif = _timeDifference(meta.lastTokenClaim);
        if(timeDif < 1 hours) return 0;
        else {
            return 
                ((uint256(meta.tokenGeneration * 10 ** 10) + uint256(meta.tileLevel)) * 
                uint256(meta.tokenGenerationPercentageBoost) / 100) * 
                timeDif;
        }
    }
    
    function applyImprovementToTile(uint tileId, ImprovementNFT nft, uint nftId) override external isTileOwner(tileId) {
        // lol let's do that later
    }
    
    /**
     *  Allows the owner of a tile to upgrade the tile for a HEXR price.
     */
    function upgradeTile(uint tileId) override external isTileOwner(tileId) {
        _token().transferFrom(_msgSender(), address(gameData), tileUpgradeCost(tileId));
        _claimTokens(tileId, _msgSender());
        gameData.upgradeTile(tileId);
    }
    

    function tileUpgradeCost(uint tileId) override public view returns(uint) {
        TileMetadata memory meta = gameData.getTileData(tileId);
        return ((ONE_TOKEN * 5 + (ONE_TOKEN / 20) * meta.tileLevel) * meta.tileLevel);
    }
    
    function colonizeTile(uint tileId, uint neighboringOwnedTileId) override external isTileOwner(neighboringOwnedTileId) {
        address tileOwner = _tiles().ownerOf(tileId);
        require(tileOwner == address(_tiles()));

        uint onePercentCost = tileColonizeCost(tileId) / 100;
        _token().transferFrom(_msgSender(), tileOwner, onePercentCost * 90);
        _token().transferFrom(_msgSender(), address(gameData), onePercentCost * 10);
        gameData.forciblyTransferTile(tileId, _msgSender());
    }
    
    function tileColonizeCost(uint tileId) override public view returns(uint) {
        TileMetadata memory meta = gameData.getTileData(tileId);
        return ((meta.tileLevel * ONE_TOKEN + meta.priceIncrease) / 100) * meta.priceIncreasePercentageBoost;
    }
}