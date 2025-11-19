// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {WalletRegistry} from "../src/WalletRegistry.sol";

contract DeployWalletRegistry is Script {
    function run() external {
        vm.startBroadcast();
        new WalletRegistry();
        vm.stopBroadcast();
    }
}
