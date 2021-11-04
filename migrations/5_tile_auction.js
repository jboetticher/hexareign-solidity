const TileAuction = artifacts.require("TileAuction");
const TileSale = artifacts.require("TileSale");
const TileNFT = artifacts.require("TileNFT");
const HEXRGameData = artifacts.require("HEXRGameData");

module.exports = async function (deployer) {
  let tileNFT = await TileNFT.deployed();
  let data = await HEXRGameData.deployed();
  
  // deploy tile auction
  await deployer.deploy(TileAuction, tileNFT.address);

  // deploy tile sale (0.1 ether)
  // YOU SHOULD CHANGE THIS WHEN DEPLOYING ONTO YOUR DESIRED NETWORK
  await deployer.deploy(TileSale, tileNFT.address, data.address, "100000000000000000")
  let tileSale = await TileSale.deployed();
  let tiles = await TileNFT.deployed();

  // automatically puts 2 into the market
  let accounts = await web3.eth.getAccounts()
  tiles.transferFrom(accounts[0], tiles.address, 23);
  tiles.transferFrom(accounts[0], tiles.address, 43);
}
