const HDWalletProvider = require('@truffle/hdwallet-provider');
const Web3 = require('web3');
const { interface, bytecode } = require('./compile');

const provider = new HDWalletProvider(
    'edit fury picnic degree hour capital energy motion fiction motion column element',
    'https://sepolia.infura.io/v3/2ff4959de1694f42b96a7547de988be1'
);

const web3 = new Web3(provider);

const deploy = async () => {
    try {
        const accounts = await web3.eth.getAccounts();
        console.log("Deploying from account:", accounts[0]);

        const result = await new web3.eth.Contract(JSON.parse(interface))
            .deploy({ data: bytecode, arguments: ['HI there'] })
            .send({ gas: '1000000', from: accounts[0] });

        console.log("Contract deployed successfully!");
        console.log("Contract Address:", result.options.address);
    } catch (error) {
        console.error("Deployment failed:", error);
    } finally {
        provider.engine.stop(); // Correct way to stop provider
    }
};

deploy();

//updated web3 and hdwallet-provider imports added for convenience

// deploy code will go here
//2ff4959de1694f42b96a7547de988be1
//https://sepolia.infura.io/v3/2ff4959de1694f42b96a7547de988be1
// https://rinkeby.infura.io/orDImgKRzwNrVCDrAk50 