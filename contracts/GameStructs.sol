//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;
import "./Improvements/ImprovementNFT.sol";

contract GameStructs {
    struct TileMetadata {
        uint256 lastTokenClaim;
        uint16 tileLevel;
        uint32 tokenGeneration;
        uint16 tokenGenerationPercentageBoost;
        uint256 priceIncrease;
        uint16 priceIncreasePercentageBoost;
        uint256 upgradeIncreasePercentageBoost;
        ImprovementContainer improvements;
    }

    struct ImprovementContainer {
        address slot1;
        address slot2;
        address slot3;
        uint8 improvementPoints;
    }

    uint256 internal ONE_TOKEN = 1000000000000000000;

    function _createNewTile() internal view returns (TileMetadata memory) {
        return TileMetadata(
            block.timestamp,
            1,
            100,
            115,
            0,
            0,
            0,
            ImprovementContainer(address(0), address(0), address(0), 3)
        );
    }
}
