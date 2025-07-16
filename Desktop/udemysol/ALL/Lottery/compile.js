const path = require('path');
const fs = require('fs');
const solc = require('solc');

const inboxPath = path.resolve(__dirname, 'contracts', 'Lottery.sol');
const source = fs.readFileSync(inboxPath, 'utf8');

const input = {
  language: 'Solidity',
  sources: {
    'Lottery.sol': {
      content: source,
    },
  },
  settings: {
    evmVersion: 'paris', // Add this
    outputSelection: {
      '*': {
        '*': ['abi', 'evm.bytecode'],
      },
    },
  },
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));
if (output.errors) {
  console.error('Compilation errors:', output.errors);
  process.exit(1);
}
const contract = output.contracts['Lottery.sol']['Lottery'];
const abi = JSON.stringify(contract.abi);
const bytecode = contract.evm.bytecode.object;


module.exports = {
  abi: abi,
  bytecode: bytecode,
};