//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import './Improvements/ImprovementNFT.sol';
import './IHEXRGameLogic.sol';
import './HEXRGameData.sol';
import './GameStructs.sol';
import './HEXRToken.sol';
import './TileNFT.sol';

// An interface for the logic that is performed on a smart contract.
contract HEXRGameLogicV1 is Context, IHEXRGameLogic, GameStructs, ReentrancyGuard {

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
        uint tokensToClaim = claimableTokens(tileId);
        gameData.resetLastClaimed(tileId);
        gameData.transferTokens(_msgSender(), tokensToClaim);
        emit TokenClaim(tileId, tokensToClaim, claimer);
    }
    
    /**
     *  Returns the time difference between the current block and the time given.
     */
    function _timeDifference(uint lastTokenClaim) internal view returns(uint) {
        if(lastTokenClaim >= block.timestamp) return 0;
        return block.timestamp - lastTokenClaim;
    }    



    /**
     *  Allows users to claim tokens from tiles that they own.
     */
    function claimTokensFromTile(uint tileId) override external nonReentrant isTileOwner(tileId) {
        _claimTokens(tileId, _msgSender());
    }

    /**
     *  Returns the claimable tokens from a tile.
    */
    function claimableTokens(uint tileId) override public view returns(uint) {
        TileMetadata memory meta = gameData.getTileData(tileId);
        uint timeDif = _timeDifference(meta.lastTokenClaim);

        // Token generation starts as 100. Tile level starts at 15.
        // 1 day is 86400 seconds.
        // (100 + 15) * 1e11 / 1e18 * 86400 = .993 tokens per day

        uint baseTokenGen = meta.tokenGeneration;
        baseTokenGen += meta.tileLevel * 15;
        baseTokenGen *= 1e11;
        baseTokenGen *= (meta.tokenGenerationPercentageBoost + 100);
        baseTokenGen *= timeDif;
        baseTokenGen /= 100;
        return baseTokenGen;
    }
    
    /**
     *  Applies an improvement to a tile. Most of the logic is within the ImprovementNFT.
     */
    function applyImprovementToTile(uint tileId, ImprovementNFT nft, uint nftId) 
    override external isTileOwner(tileId) nonReentrant {
        require(gameData.validImprovements(address(nft)), "Must be a valid improvement.");
        require(nft.ownerOf(nftId) == _msgSender(), "Must own the improvement.");
        require(!nft.isApplied(nftId), "The nft must not be applied.");
        nft.applyNFTToTile(gameData.getTileData(tileId));
    }
    
    /**
     *  Allows the owner of a tile to upgrade the tile for a HEXR price.
     */
    function upgradeTile(uint tileId) override external isTileOwner(tileId) nonReentrant {
        _token().transferFrom(_msgSender(), address(gameData), tileUpgradeCost(tileId));
        _claimTokens(tileId, _msgSender());
        gameData.upgradeTile(tileId);
    }
    

    function tileUpgradeCost(uint tileId) override public view returns(uint) {
        TileMetadata memory meta = gameData.getTileData(tileId);
        
        // Level 1 -> Level 2 upgrade: 1 + .05 = 1.05.
        // Level 1 -> Level 2 rewards: +0.12 generation per day

        // Level 10 -> Level 11 upgrade: 1 + .5 = 1.5
        // level 10 -> Level 11 rewars: +0.12 generation per day

        uint baseCost = 1 ether;
        baseCost += meta.tileLevel * tileLevelUpgradeModifier();
        baseCost *= (meta.upgradeIncreasePercentageBoost + 100);
        baseCost /= 100;
        return baseCost;
    }

    // required to be a function because of a compiler issue???
    function tileLevelUpgradeModifier() private pure returns (uint) {
        return 1 ether / 20;
    }
    
    function colonizeTile(uint tileId, uint neighboringOwnedTileId) override external 
    isTileOwner(neighboringOwnedTileId) nonReentrant {
        
        (int16 cX, int16 cY, , , ,) = 
            _tiles().tileData(tileId);
        (int16 nX, int16 nY, , , , ) = 
            _tiles().tileData(neighboringOwnedTileId);
        int16 xDif = nX - cX;
        int16 yDif = nY - cY;
        int16 xAbs = abs(xDif);
        int16 yAbs = abs(yDif);
        bool isNeighbor = xAbs == 1 && yAbs == 0; // covers (+1, 0) and (-1, 0)
        isNeighbor = isNeighbor || (xAbs == 0 && yAbs == 1); // covers (0, +1) and (0, -1)
        if(cX % 2 == 0) { // if it's even
            isNeighbor = isNeighbor || (xDif == -1 && yDif == 1); // covers (-1, 1)
            isNeighbor = isNeighbor || (xDif == 1 && yDif == 1); // covers (1, 1) 
        }
        else { // if it's odd
            isNeighbor = isNeighbor || (xDif == 1 && yDif == -1); // covers (1, -1)
            isNeighbor = isNeighbor || (xDif == -1 && yDif == -1); // covers (-1, -1)
        }
        require(isNeighbor, "Needs to own neighboring tile!");
        
        address tileOwner = _tiles().ownerOf(tileId);

        // requires an initialization of a non colonized tile
        if(gameData.getTileData(tileId).tileLevel == 0) {
            gameData.initializeTile(tileId);
        }

        // TODO: require the neighboring owned tile to be nearby

        // sends fee back into game
        uint onePercentCost = tileColonizeCost(tileId) / 100;
        _token().transferFrom(_msgSender(), tileOwner, onePercentCost * 90);
        _token().transferFrom(_msgSender(), address(gameData), onePercentCost * 10);

        // TODO: increase the tile colonization cost

        gameData.forciblyTransferTile(tileId, _msgSender());
    }

    function abs(int16 val) private pure returns(int16) {
        return val < 0 ? -(val) : val;
    }
    
    function tileColonizeCost(uint tileId) override public view returns(uint) {
        TileMetadata memory meta = gameData.getTileData(tileId);
        uint baseCost = (meta.tileLevel + 3) * 1 ether;
        baseCost += meta.priceIncrease * tileColonizeModifier();
        baseCost *= (meta.priceIncreasePercentageBoost + 100);
        baseCost /= 100;
        return baseCost;
    }

    // required to be a function because of a compiler issue???
    function tileColonizeModifier() private pure returns (uint) {
        return 1 ether / 100;
    }

    function killContract() override external {
        require(msg.sender == address(gameData));
        selfdestruct(payable(address(0)));
    }
}