//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;
import "../GameStructs.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../HEXRGameData.sol";

abstract contract ImprovementNFT is GameStructs, ERC721Enumerable {

    HEXRGameData gameData;

    constructor(HEXRGameData _gameData, string memory _name, string memory _tag) ERC721(_name, _tag)  {
        gameData = _gameData;
    } 

    // When implementing ImprovementNFT, be sure to cancel all transactions if isApplied is true
    modifier cancelIfApplied(uint improvementId) {
        require(!isApplied(improvementId), "Cannot be done when the nft has been applied.");
        _;
    }

    modifier onlyGameLogic() {
        require(_msgSender() == address(gameData.gameLogic()), "Can only be done by game logic.");
        _;
    }

    function applyNFTToTile(TileMetadata memory meta) virtual public;

    function isApplied(uint improvementId) public virtual returns(bool);
}