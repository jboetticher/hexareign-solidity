//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;
import './Improvements/ImprovementNFT.sol';
 
// An interface for the logic that is performed on a smart contract.
interface IHEXRGameLogic {
    
    /**
     * Allows a user to claim the tokens from a tile.
     */
    function claimTokensFromTile(uint tileId) external;

    /**
     *  Shows the amount of tokens that are claimable from a tile.
     */
    function claimableTokens(uint tileId) external returns(uint);
    
    function applyImprovementToTile(uint tileId, ImprovementNFT nft, uint nftId) external;
    
    function upgradeTile(uint tileId) external;
    
    function tileUpgradeCost(uint tileId) external view returns(uint);
    
    function colonizeTile(uint tileId, uint neighboringOwnedTileId) external;
    
    function tileColonizeCost(uint tileId) external view returns(uint);

    function killContract() external;
}