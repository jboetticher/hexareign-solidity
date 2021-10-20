const HEXRGameLogic = artifacts.require('HEXRGameLogicV1');
const HEXRGameData = artifacts.require('HEXRGameData');

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

    /*
    it('Should have more than 0 HEXR after a bit of time.', async () => {
        const smc = await HEXRGameLogic.deployed();
        await advanceBlockAtTime()
    })*/
})