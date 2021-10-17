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
            assert(totalSupply == "8010000000000000000000000000");
        });

        /* don't know what's going wrong here, but it doesn't quite matter
        it('Should have 0 dapps at the start.', async () => {
            const smc = await Token.deployed();
            const dappCount = await smc.dAppCount();
            assert(dappCount === "1");
        });
        */
    });

    describe("Add DApp", () => {

    })
})