## THIS REPO IS DEPRECATED - PLEASE USE [CIRCLE'S OFFICIAL USDC REPO](https://github.com/circlefin/stablecoin-evm/)

Circle's official USDC repo: https://github.com/circlefin/stablecoin-evm/

Note: if you have an existing USDC-e deployment on your CDK chain, and want to update to 2.2, you must deploy all of the contracts in Circle's repo, and then perform the upgrade to your FiatTokenProxy.

Only deploying `FiatTokenV2_2.sol` and upgrading the proxy WILL NOT work.

This is because Circle's USDC 2.2 codebase is different from their previous versions (there were changes made to the parent contracts).
