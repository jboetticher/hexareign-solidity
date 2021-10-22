const HEXRGameLogic = artifacts.require('HEXRGameLogicV1');
const HEXRGameData = artifacts.require('HEXRGameData');
const TileNFT = artifacts.require('TileNFT');

const advanceBlockAtTime = (time) => {
    return new Promise((resolve, reject) => {
      web3.currentProvider.send(
        {
          jsonrpc: "2.0",
          method: "evm_mine",
          params: [time],
          id: new Date().getTime(),
        },
        (err, _) => {
          if (err) {
            return reject(err);
          }
          const newBlockHash = web3.eth.getBlock("latest").hash;
  
          return resolve(newBlockHash);
        },
      );
    });
  };

contract('HEXRGameLogicV1', () => {
    it('Should deploy properly.', async () => {
        const smc = await HEXRGameLogic.deployed();
        assert(smc.address !== '');
    })

    it('Should upgrade properly.', async() => {
        const smc = await HEXRGameLogic.deployed();
        const data = await HEXRGameData.deployed();
        await smc.upgradeTile(3);
        await smc.upgradeTile(3);
        await smc.upgradeTile(3);
        let lvl = (await data.getTileData(3)).tileLevel;
        assert(lvl == 4, "Level was equal to " + lvl);
    })

    it('Should have 0 HEXR available to claim for newly initialized tiles.', async () => {
        const smc = await HEXRGameLogic.deployed();
        const data = await HEXRGameData.deployed();
        await data.initializeTile(5);
        assert((await smc.claimableTokens(5)) == 0);
    })

    it('Should be able to colonize nearby tiles.', async() => {
      // TODO: find one next to 3 and colonize it
      const smc = await HEXRGameLogic.deployed();
      const tiles = await TileNFT.deployed();
      await smc.colonizeTile(1, 3);
      const newOwner = await tiles.ownerOf(1);
      const oldOwner = await tiles.ownerOf(3);

      assert(newOwner == oldOwner);
    })

    it('Should not be able to colonize tiles that are not adjacent to an owned tile.', async() => {
      // TODO: find one that isn't near 3 but is still low and try to colonize it. Check for errors.
      // that would be tile 4
      const smc = await HEXRGameLogic.deployed();
      const tiles = await TileNFT.deployed();
      try {
        await smc.colonizeTile(4, 3);
        assert.fail("No error was detected, it should have failed. New owner: ");
      }
      catch {
        // this is good
        const newOwner = await tiles.ownerOf(4);
        const oldOwner = await tiles.ownerOf(3);
        assert(newOwner != oldOwner, "The new owner is the same as the old owner: " + newOwner);
      }
    })

    /*
    it('Should have more than 0 HEXR after a bit of time.', async () => {
        const smc = await HEXRGameLogic.deployed();
        await advanceBlockAtTime()
    })*/
})