// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import { MoonUpBeaconFactory } from "src/MoonUpBeaconFactory.sol";
import { Script } from "forge-std/Script.sol";
import { HelperConfig } from "./HelperConfig.s.sol";

contract DeployMoonUpFactory is Script {
    function run() external returns (address moonUpBeaconFactory) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getNetworkConfig();

        vm.startBroadcast();
        moonUpBeaconFactory = address(new MoonUpBeaconFactory(
            msg.sender,
            0.002 ether, 
            config.weth,
            config.NonfungiblePositionManager,
            config.UniswapV3Factory,
            config.totalTradeVolume
            ));
            
        vm.stopBroadcast();
        
    }
}