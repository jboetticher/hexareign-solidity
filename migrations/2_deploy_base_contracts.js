const HEXRToken = artifacts.require("HEXRToken");
const TileNFT = artifacts.require("TileNFT");

module.exports = function (deployer) {
  deployer.deploy(HEXRToken);
  deployer.deploy(TileNFT);
};
