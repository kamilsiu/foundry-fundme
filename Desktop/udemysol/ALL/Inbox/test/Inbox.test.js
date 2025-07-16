const ganache = require('ganache-cli');
const assert = require('assert');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
const { abi, bytecode } = require('../compile');
const { clear } = require('console');

let accounts;
let inbox;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();

    inbox = await new web3.eth.Contract(abi)
        .deploy({ 
            data: bytecode, 
            arguments: ['Hello, Blockchain!'] 
        })
        .send({ 
            from: accounts[0], 
            gas: '1000000' 
        });
});

describe('Inbox.sol', () => {
    it('deploys a contract', () => {

    });

    it('has a default message', async () => {
        const message = await inbox.methods.message().call();
        assert.equal(message, 'Hello, Blockchain!');
    });

    it('can change the message', async () => {
        await inbox.methods.changeValue('New Message').send({ from: accounts[0] });
        const message = await inbox.methods.message().call();
        console.log(message);
    });
});
