const TileAuction = artifacts.require("TileAuction");
const TileSale = artifacts.require("TileSale");
const TileNFT = artifacts.require("TileNFT");
const HEXRGameData = artifacts.require("HEXRGameData");

module.exports = async function (deployer) {
  let tileNFT = await TileNFT.deployed();
  let data = await HEXRGameData.deployed();
  
  // deploy tile auction
  await deployer.deploy(TileAuction, tileNFT.address);

  // deploy tile sale (1 ether)
  await deployer.deploy(TileSale, tileNFT.address, data.address, "1000000000000000000")
}