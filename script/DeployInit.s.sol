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

contract DeployInitUSDC is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // setup the addresses for the various roles
        address masterMinter = vm.envAddress("ADDRESS_MASTER_MINTER");
        address pauser = vm.envAddress("ADDRESS_PAUSER");
        address blacklister = vm.envAddress("ADDRESS_BLACKLISTER");
        address owner = vm.envAddress("ADDRESS_OWNER");

        FiatTokenV2_1 usdc = new FiatTokenV2_1();
        usdc.initialize(
            "USD Coin",
            "USDC",
            "USD",
            6,
            masterMinter,
            pauser,
            blacklister,
            owner
        );
        usdc.initializeV2("USD Coin");
        // the lostAndFound address here doesn't matter, because there will not be
        // a nonzero balance on the USDC-e contract (since we just deployed it)
        usdc.initializeV2_1(address(0));

        vm.stopBroadcast();
    }
}
