const ganache = require('ganache-cli');
const assert = require('assert');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider({ evmVersion: 'paris', vmErrorsOnRPCResponse: true }));
const { abi, bytecode } = require('../compile');
const { clear } = require('console');

let lottery;
let accounts;

beforeEach(async () => {
  try {
    accounts = await web3.eth.getAccounts();
    lottery = await new web3.eth.Contract(JSON.parse(abi))
      .deploy({ data: bytecode })
      .send({ from: accounts[0], gas: '2000000' });
    console.log('Deployed at:', lottery.options.address);
  } catch (error) {
    console.error('Deployment error:', error);
    throw error;
  }
});

describe('Lottery Contract', () => {
  it('deploys a contract', () => {
    assert.ok(lottery.options.address);
  });
  it('allows a single contract',async()=>{
    await lottery.methods.enter().send({
        from:accounts[0],
        value:web3.utils.toWei('0.2','ether')
    });
    const players = await lottery.methods.getPlayers().call();
    assert.equal(players.length,1);
    assert.equal(accounts[0],players[0]);
  });
  it('allows multiple contracts',async()=>{
    await lottery.methods.enter().send({
        from:accounts[0],
        value:web3.utils.toWei('0.2','ether')
    });
    await lottery.methods.enter().send({
        from:accounts[1],
        value:web3.utils.toWei('0.2','ether')
    });
    await lottery.methods.enter().send({
        from:accounts[2],
        value:web3.utils.toWei('0.2','ether')
    });
    const players = await lottery.methods.getPlayers().call();
    assert.equal(players.length,3);
    assert.equal(accounts[0],players[0]);
    assert.equal(accounts[1],players[1]);
    assert.equal(accounts[2],players[2]);
  });
 it('requires a minimum amount of ether',async()=>{
    try{
        await lottery.methods.enter().send({
            from:accounts[0],
            value:web3.utils.toWei('0.02','ether')
        });
    }
    catch(err){
        assert(err);
    }
  });
  it('only manager can pickWinner',async()=>{
    try{
    await lottery.methods.pickWinner().send({
        from:accounts[1]
    });
    assert(false);
}
catch(err){
    assert(err);
} 
  });
  it('sends money to winner and resets array',async()=>{
    await lottery.methods.enter().send({
        from:accounts[0],
        value:web3.utils.toWei('2','ether')
    });
    const initial = await web3.eth.getBalance(accounts[0]);
    await lottery.methods.pickWinner().send({from:accounts[0]});
    const final = await web3.eth.getBalance(accounts[0]);
    const difference = (final - initial);
    const players = await lottery.methods.getPlayers().call();
    assert(difference>web3.utils.toWei('1.8','ether'));
    assert.equal(players.length,0);
});
});
