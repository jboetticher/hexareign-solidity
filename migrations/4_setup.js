const HEXRToken = artifacts.require("HEXRToken");
const TileNFT = artifacts.require("TileNFT");
const HEXRGameData = artifacts.require("HEXRGameData");
const HEXRGameLogicV1 = artifacts.require("HEXRGameLogicV1");

module.exports = async function (deployer) {

    let hToken = await HEXRToken.deployed();
    let data = await HEXRGameData.deployed();
    let logic = await HEXRGameLogicV1.deployed();

    // Send tokens to the game data
    hToken.addApplication(data.address);

    // user approve game logic to move game data tokens
    await hToken.approve(
        logic.address, 
        "115792089237316195423570985008687907853269984665640564039457584007913129639935");

    // initialize tile 3 for testing
    await data.initializeTile(3);
};
