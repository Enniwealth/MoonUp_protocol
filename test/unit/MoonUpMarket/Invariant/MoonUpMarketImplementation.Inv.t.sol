// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { MoonUpMarket } from "src/MoonUpMarket/MoonUpMarketImplementation.sol";

import { Test } from "forge-std/Test.sol";

import { MoonUpBeaconFactory } from "src/MoonUpBeaconFactory.sol"; 

import { MockWETH20 } from "test/unit/MoonUpMarket/Mock/WETH.sol";

import { MoonUpProxy } from "src/MoonUpMarket/MoonUpMarketProxy.sol";

import { IWETH } from "src/MoonUpMarket/interfaces/IWETH.sol";
import { IMoonUpMarketImplementation } from "src/MoonUpMarket/interfaces/IMarketImplementation.sol";
import { IERC20} from "src/MoonUpMarket/interfaces/IERC20.sol";
import "./Utils/Cheats.sol";

contract MoonUpMarket_Invariant_Test is Test{
    StdCheats cheats = StdCheats(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    address MoonUpProxyTest;
    address MoonUpErc20;

    uint256 private PERCENTAGE_HOLDING_PER_USER = (1_000_000_000 * 1e18) * 3 / 100;
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
    constructor() {
            moonUpfactory = new MoonUpBeaconFactory(
            owner, 
            CREATION_FEE, 
            IWETH(WETH), 
            nfpm, 
            uniswapFactory,
            TOTAL_TRADE_VOLUME );
            (MoonUpErc20, MoonUpProxyTest) = moonUpfactory.createTokensAndPair{value: CREATION_FEE}("MoonUP", "MUP", "", 0, false);
    }

    // function testDeposit(uint256 amount) public {
    //     vm.assume(amount < 0.003 ether);
    //     uint256 balanceBefore = IERC20(MoonUpErc20).balanceOf(msg.sender);
    //     uint256 MoonUpBalanceBefore = MoonUpProxyTest.balance;
    //     vm.prank(msg.sender);
    //     IMoonUpMarketImplementation(MoonUpProxyTest).buy{value: amount}(1);

    //     vm.assertTrue(IERC20(MoonUpErc20).balanceOf(msg.sender) > balanceBefore);
    //     vm.assertTrue(MoonUpProxyTest.balance > MoonUpBalanceBefore);
    
    // }

}