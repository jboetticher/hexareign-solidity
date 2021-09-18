//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;
import './TileNFT.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import './Improvements/ImprovementNFT.sol';
 
// An interface for the logic that is performed on a smart contract.
interface IHEXRGameLogic {
    
    function claimTokensFromTile(uint tileId) external;
    
    function applyImprovementToTile(uint tileId, ImprovementNFT nft, uint nftId) external;
    
    function upgradeTile(uint tileId) external;
    
    function tileUpgradeCost(uint tileId) external view returns(uint);
    
    function colonizeTile(uint tileId, uint neighboringOwnedTileId) external;
    
    function tileColonizeCost(uint tileId) external view returns(uint);
}