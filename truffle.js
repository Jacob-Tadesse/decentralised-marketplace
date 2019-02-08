var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "actor snap sketch video degree client pause original acquire script wise onion math produce chest";
const path = require("path");

module.exports = {
  compilers: {
    solc: { optimizer: { enabled: true, runs: 200 } }
  },
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "app/src/contracts"),
  networks: {
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/8e206165ecf24d5686cf6012c78249ef")
      },
      network_id: 3,
      gas: 6712390,
    }
  }
};
