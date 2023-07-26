pragma solidity 0.6.12;

import "forge-std/Script.sol";
import "../src/usdc-impl/FiatTokenV2_1.sol";

contract AddMinters is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint256 minterAllowedAmount = vm.envUint("MINTER_ALLOWED_AMOUNT");
        FiatTokenV2_1 usdc = FiatTokenV2_1(vm.envAddress("ADDRESS_USDC"));

        usdc.configureMinter(
            vm.envAddress("ADDRESS_ZK_MINTER_BURNER_PROXY"),
            minterAllowedAmount
        );
        usdc.configureMinter(
            vm.envAddress("ADDRESS_NATIVE_CONVER_PROXY"),
            minterAllowedAmount
        );

        vm.stopBroadcast();
    }
}
