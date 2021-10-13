const HEXRGameLogic = artifacts.require('HEXRGameLogicV1');

contract('HEXRGameLogicV1', () => {
    it('Should deploy properly.', async () => {
        const smc = await HEXRGameLogic.deployed();
        assert(smc.address !== '');
    })
})