// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;


import { MoonUpMarket } from "src/MoonUpMarket/MoonUpMarketImplementation.sol";

import { Test } from "forge-std/Test.sol";

import { MoonUpBeaconFactory } from "src/MoonUpBeaconFactory.sol"; 

import { MockWETH20 } from "test/unit/MoonUpMarket/Mock/WETH.sol";

import { MoonUpProxy } from "src/MoonUpMarket/MoonUpMarketProxy.sol";

import { IWETH } from "src/MoonUpMarket/interfaces/IWETH.sol";

contract MoonUpBaseTest is Test {
    
    MoonUpMarket moonUpMarket;

    MoonUpBeaconFactory moonUpfactory;
    
    uint256 TOTAL_TRADE_VOLUME  = 780_000_000 * 1e18;

    uint256 CREATION_FEE = 0.002 ether;

    address uniswapFactory = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c;

    address  nfpm = 0x1238536071E1c677A632429e3655c799b22cDA52;

    address WETH = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;

    address owner = makeAddr("owner");

    address alice = makeAddr("alice");

    address bob = makeAddr("bob");

    bytes32 _nativeCurrencyLabelBytes = keccak256("MoonPump.MoonUp.up");
    
    event MoonUpFactoryDeployed(address moonUpFactoryAddress);
    function beforeSetup() internal virtual { }

    function afterSetup() internal virtual { }

    function setUp() public {
        
        beforeSetup();

        vm.startPrank(owner);
        moonUpfactory = new MoonUpBeaconFactory(
            owner, 
            CREATION_FEE, 
            IWETH(WETH), 
            nfpm, 
            uniswapFactory,
            TOTAL_TRADE_VOLUME );
        vm.stopPrank();
        emit MoonUpFactoryDeployed(address(moonUpfactory));
        vm.deal(alice, 4 ether);
        
        afterSetup();
    }
        
}