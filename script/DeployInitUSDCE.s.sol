/**
 * Copyright (c) 2018-2023 CENTRE SECZ
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS OR DEPLOYERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

pragma solidity 0.6.12;

import "forge-std/Script.sol";
import "../src/usdc-impl/FiatTokenV2_1.sol";

/// @notice This script deploys and initializes the USDC-e token. It also
/// configures the zkMinterBurnerProxy and the nativeConverterProxy from the usdc-lxly repo
/// as minters. Control of the various USDC-e roles is relinquished to the deployer-provided
/// addresses
contract DeployInitUSDCE is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        uint256 minterAllowedAmount = vm.envUint("MINTER_ALLOWED_AMOUNT");

        address masterMinter = vm.envAddress("ADDRESS_MASTER_MINTER");
        address pauser = vm.envAddress("ADDRESS_PAUSER");
        address blacklister = vm.envAddress("ADDRESS_BLACKLISTER");
        address owner = vm.envAddress("ADDRESS_OWNER");

        FiatTokenV2_1 usdce = deployUSDCE();
        initializeAndConfigureMinters(
            usdce,
            deployerAddress,
            minterAllowedAmount
        );
        relinquishPower(
            usdce,
            deployerAddress,
            masterMinter,
            pauser,
            blacklister,
            owner
        );

        vm.stopBroadcast();
    }

    function deployUSDCE() internal returns (FiatTokenV2_1) {
        FiatTokenV2_1 usdce = new FiatTokenV2_1();
        console.log("Deployed USDCE at address: %s", address(usdce));
        return usdce;
    }

    /// @notice Put the USDC-e token in a state where it is ready to be used
    /// by the zkMinterBurnerProxy and the nativeConverterProxy, but is not
    /// secure because all of its security-sensitive roles are controlled by
    /// the deployer hot wallet
    /// @dev The token still needs to have all of its roles transferred to
    // the appropriate controller
    function initializeAndConfigureMinters(
        FiatTokenV2_1 usdce,
        address deployerAddress,
        uint256 minterAllowedAmount
    ) internal {
        // we first initialize the token with the deployer as the controller
        // so we can configure the minters. Later on we will relinquish this
        // power to the appropriate controllers
        usdce.initialize(
            "USD Coin",
            "USDC",
            "USD",
            6,
            deployerAddress, // master minter
            deployerAddress, // pauser
            deployerAddress, // blacklister
            deployerAddress // owner
        );
        usdce.initializeV2("USD Coin");
        // we pass the 0 address here because `initializeV2_1`'s `lostAndFound`
        // parameter will not be used, since this is a newly deployed token and
        // thus we can assume it will have a balance of 0
        usdce.initializeV2_1(address(0));

        usdce.configureMinter(
            vm.envAddress("ADDRESS_ZK_MINTER_BURNER_PROXY"),
            minterAllowedAmount
        );
        console.log(
            "Configured zkMinterBurnerProxy with address %s as minter with allowance: %s",
            vm.envAddress("ADDRESS_ZK_MINTER_BURNER_PROXY"),
            minterAllowedAmount
        );
        usdce.configureMinter(
            vm.envAddress("ADDRESS_NATIVE_CONVERTER_PROXY"),
            minterAllowedAmount
        );
        console.log(
            "Configured nativeConverter with address %s as minter with allowance: %s",
            vm.envAddress("ADDRESS_NATIVE_CONVERTER_PROXY"),
            minterAllowedAmount
        );
    }

    /// @notice Relinquish all of the security-sensitive roles of the USDC-e token
    /// to the appropriate controllers
    function relinquishPower(
        FiatTokenV2_1 usdce,
        address deployerAddress,
        address masterMinter,
        address pauser,
        address blacklister,
        address owner
    ) public {
        usdce.updatePauser(pauser);
        console.log("Updated pauser to address: %s", pauser);
        usdce.updateBlacklister(blacklister);
        console.log("Updated blacklister to address: %s", blacklister);
        usdce.updateMasterMinter(masterMinter);
        console.log("Updated master minter to address: %s", masterMinter);
        usdce.transferOwnership(owner);
        console.log("Transferred ownership to address: %s", owner);

        require(
            usdce.pauser() != deployerAddress,
            "DeployInitUSDCE: pauser role was not relinquished"
        );
        require(
            usdce.blacklister() != deployerAddress,
            "DeployInitUSDCE: blacklister role was not relinquished"
        );
        require(
            usdce.masterMinter() != deployerAddress,
            "DeployInitUSDCE: master minter role was not relinquished"
        );
        require(
            usdce.owner() != deployerAddress,
            "DeployInitUSDCE: owner role was not relinquished"
        );
    }
}
