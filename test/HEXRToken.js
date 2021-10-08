const Token = artifacts.require('HEXRToken');
const toBN = web3.utils.toBN;

contract('HEXRToken', () => {

    describe("Initial State", () => {
        it('Should deploy properly.', async () => {
            const smc = await Token.deployed();
            assert(smc.address !== '');
        });

        it('Should have a cap of 8.01 billion tokens.', async () => {
            const smc = await Token.deployed();
            const totalSupply = await smc.totalSupply();
            console.log(totalSupply.toNumber())
            assert(totalSupply === toBN(1e18).mult(8010000000));
        });

        it('Should have 0 dapps at the start.', async () => {
            const smc = await Token.deployed();
            const dappCount = await smc.dAppCount();
            console.log(dappCount);
            assert(dappCount.toNumber() === 0);
        });
    });

    describe("Add DApp", () => {

    })
})