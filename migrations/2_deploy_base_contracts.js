const HEXRToken = artifacts.require("HEXRToken");
const TileNFT = artifacts.require("TileNFT");
const HEXRGameData = artifacts.require("HEXRGameData");
const HEXRGameLogicV1 = artifacts.require("HEXRGameLogicV1");

module.exports = async function (deployer) {
  await deployer.deploy(HEXRToken);
  await deployer.deploy(TileNFT);

  // Import tile data
  let tileNFT = await TileNFT.deployed();

  //Deploy HEXRGameData
  let hToken = await HEXRToken.deployed();
  await deployer.deploy(HEXRGameData, tileNFT.address, hToken.address);

  // Set HEXRGameData within the tileNFT
  let hexrGameData = await HEXRGameData.deployed();
  await tileNFT.setHEXRGameData(hexrGameData.address);

  // Deploy game logic
  await deployer.deploy(HEXRGameLogicV1, hexrGameData.address);

  // Set game logic within the game data
  let gameLogic = await HEXRGameLogicV1.deployed();
  hexrGameData.setGameLogic(gameLogic.address);

  // deploy tokens to the game data
  hToken.addApplication(hexrGameData.address);

  // user approve game logic to move game data tokens
  hToken.approve(gameLogic.address, "10000000000000000000000000000000000000000000000000000000000");
};
