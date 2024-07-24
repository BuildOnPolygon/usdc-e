## USE [CIRCLE'S OFFICIAL BRIDGE STANDARD USDC REPO](https://github.com/circlefin/stablecoin-evm/)

This repo contains the "unofficial bridge standard" for USDC, implemented before Circle's.

Since Circle now has an official Bridge Standard USDC repo, we are pointing users towards it: https://github.com/circlefin/stablecoin-evm/

The USDC Bridge Standard goes hand in hand with the USDC-LXLY repo, which contains the bridge contracts https://github.com/BuildOnPolygon/usdc-lxly


### For previously deployed CDKs

Note: if you have an existing USDC-e deployment on your CDK chain, and want to update to 2.2, you must deploy all of the contracts in Circle's repo, and then perform the upgrade to your FiatTokenProxy.

Only deploying `FiatTokenV2_2.sol` and upgrading the proxy WILL NOT work.

This is because Circle's USDC 2.2 codebase is different from their previous versions (there were changes made to the parent contracts).
