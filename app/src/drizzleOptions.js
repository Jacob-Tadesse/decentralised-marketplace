import Admin from "./contracts/Admin.json";

const options = {
  web3: {
    block: false,
    fallback: {
      type: "ws",
      url: "ws://127.0.0.1:9545",
    },
  },
  contracts: [Admin],
  events: {
    Admin: ["StoreFrontDeployed"],
  },
  polls: {
    // accounts: 1500,
  },
};

export default options;
