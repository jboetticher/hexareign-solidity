const HEXRToken = artifacts.require("HEXRToken");
const TileNFT = artifacts.require("TileNFT");
const HEXRGameData = artifacts.require("HEXRGameData");
const HEXRGameLogicV1 = artifacts.require("HEXRGameLogicV1");

module.exports = async function (deployer) {
  await deployer.deploy(HEXRToken);
  await deployer.deploy(TileNFT);

  // Import tile data
  let tileNFT = await TileNFT.deployed();
  //await tileNFT.addTiles([206242398208,274945097728,343664574464,206225620992,137522921472,412367273984,343647797248,137506144256,274928320512,281268902313984,281337621790720,281337605013504,281268885536768,281406324490240,281406341267456,281200166060032,67256320,281337588236288,281268868759552,84033536,281406307713024,68786733056,281406358044672,50479104,281200149282816,68769955840,137489432576,68803510272,281131362828288,281062660128768,281062676905984,281131379605504,100679680,68820156416,281337571328000,281131446452224,33570816,281337554550784,281268851851264,281200132374528]);

  //Deploy HEXRGameData
  let hToken = await HEXRToken.deployed();
  await deployer.deploy(HEXRGameData, tileNFT.address, hToken.address);

  // Set HEXRGameData within the tileNFT
  let hexrGameData = await HEXRGameData.deployed();
  tileNFT.setHEXRGameData(hexrGameData.address);

  // Deploy game logic
  await deployer.deploy(HEXRGameLogicV1, hexrGameData.address);

  // Set game logic within the game data
  let gameLogic = await HEXRGameLogicV1.deployed();
  hexrGameData.setGameLogic(gameLogic.address);
};
