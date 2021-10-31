const TileAuction = artifacts.require("TileAuction");
const TileNFT = artifacts.require("TileNFT");

module.exports = async function (deployer) {
  let tileNFT = await TileNFT.deployed();
  await deployer.deploy(TileAuction, tileNFT.address);
}