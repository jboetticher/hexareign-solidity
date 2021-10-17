const HEXRGameLogic = artifacts.require('HEXRGameLogicV1');
const HEXRGameData = artifacts.require('HEXRGameData');

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
        assert((await data.getTileData(3)).tileLevel == 3);
    })
})