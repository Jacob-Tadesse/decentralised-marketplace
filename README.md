# decentralised-marketplace

Design Patterns:
- Contract-Factory
- Circuit-breaker
- Access restriction (ds-roles ETHPM package imported)

Unfortunately, at the time of writing, I could not yet deploy to Ropsten or Rinkeby, due to insufficient testnet funds. 
I got stuck for a long time on Uport-Drizzle and figuring out how to make Redux play between, eventually finding out that their
web3 instances are fundamentally incompatible. As a result, the frontend hasn't ended up proper, and is not able to fetch the data.
However, deploying the smart contracts in a Remix IDE VM gives satisfactory functinality.
