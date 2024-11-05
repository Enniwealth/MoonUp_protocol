// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { IWETH } from "src/MoonUpMarket/interfaces/IWETH.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
       
        uint256 totalTradeVolume;
        IWETH weth;
        address UniswapV3Factory;
        address NonfungiblePositionManager;
    }

    NetworkConfig private networkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            networkConfig = getSepoliaConfig();
        }
        else if(block.chainid == 1){
            networkConfig = getEthereumConfig();
        }
    }

    function getSepoliaConfig() internal pure returns (NetworkConfig memory) {
        return NetworkConfig ({
            
            totalTradeVolume: 780_000_000,
            weth: IWETH(0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14),
            UniswapV3Factory: 0x0227628f3F023bb0B980b67D528571c95c6DaC1c,
            NonfungiblePositionManager: 0x1238536071E1c677A632429e3655c799b22cDA52
        });
    }
     function getEthereumConfig() internal pure returns (NetworkConfig memory) {
        return NetworkConfig ({
            
            totalTradeVolume: 780_000_000,
            weth: IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2),
            UniswapV3Factory: 0x1F98431c8aD98523631AE4a59f267346ea31F984,
            NonfungiblePositionManager: 0xC36442b4a4522E871399CD717aBDD847Ab11FE88
        });
    }

    function getNetworkConfig() external view returns (NetworkConfig memory) {
        return networkConfig;
    }
}