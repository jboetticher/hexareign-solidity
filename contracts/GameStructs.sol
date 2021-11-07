//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;

contract GameStructs {
    struct TileMetadata {
        uint256 lastTokenClaim;
        uint16 tileLevel;

        // Percentage boosts are default 0. All calculations add 100 to them.
        // So (100 + percentage boost) / 100.
        // Increases are multiplied by e16.
        // So total = calculation + increase * 10e16
        // Token generation is instead e12, but has a similar format to the increase.
        uint24 tokenGeneration;
        uint24 tokenGenerationPercentageBoost;
        uint24 priceIncrease;
        uint24 priceIncreasePercentageBoost;
        uint24 upgradeIncreasePercentageBoost;

        ImprovementContainer improvements;
    }

    struct ImprovementContainer {
        address slot1;
        address slot2;
        address slot3;
        uint8 improvementPoints;
    }

    function _createNewTile() internal view returns (TileMetadata memory) {
        return TileMetadata(
            block.timestamp, // last token claim
            1, // tile level
            100, // token generation
            0, // token generation percentage boost
            0, // price increase
            0, // price increase percentage boost
            0, // upgrade icnrease percentage boost
            ImprovementContainer(address(0), address(0), address(0), 3)
        );
    }
}
