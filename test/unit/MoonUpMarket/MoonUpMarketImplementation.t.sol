// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import { MoonUpBaseTest } from "test/BaseTest.t.sol";
import { IWETH } from "src/MoonUpMarket/interfaces/IWETH.sol";
import { IMoonUpMarketImplementation } from "src/MoonUpMarket/interfaces/IMarketImplementation.sol";
import { IERC20} from "src/MoonUpMarket/interfaces/IERC20.sol";

error MoonUpMarket__CANNOT_BUY_MORE_THAN_3_PERCENT();
error MoonUpMarket__INVALID_AMOUNT();

contract MoonUpMarketTest is MoonUpBaseTest{
    address MoonUpProxy;
    address MoonUpErc20;
    uint256 private PERCENTAGE_HOLDING_PER_USER = (1_000_000_000 * 1e18) * 3 / 100;

    function afterSetup() internal override {
        vm.prank(alice);
        (MoonUpErc20, MoonUpProxy) = moonUpfactory.createTokensAndPair{value: CREATION_FEE}("MoonUP", "MUP", "", 0, false);
    }

    function beforeSetup() internal override {}

    function test_MoonUpMarket_Initialize() public {
        //test if the contract is initialized
        vm.prank(alice);
        vm.expectRevert();
        IMoonUpMarketImplementation(MoonUpProxy).initialize(MoonUpErc20, IWETH(WETH), nfpm, uniswapFactory, 1000);

        //test if initialized correctly
        vm.assertEq(address(IMoonUpMarketImplementation(MoonUpProxy).token()), MoonUpErc20);
    }

    function test_User_Can_Buy() public {
        //test if user can buy
        vm.prank(alice);
        IMoonUpMarketImplementation(MoonUpProxy).buy{value: 0.003 ether}(1);
        vm.assertTrue(IERC20(MoonUpErc20).balanceOf(alice) > 0);
        vm.assertTrue(MoonUpProxy.balance > 0);
    }

    function test_User_should_not_Buy_More_Than_3_Percent() public {
        //test if user can buy more than 3 percent
        vm.prank(alice);
        bytes memory expectedRevert = abi.encodeWithSelector(MoonUpMarket__CANNOT_BUY_MORE_THAN_3_PERCENT.selector);
        vm.expectRevert(expectedRevert);
        IMoonUpMarketImplementation(MoonUpProxy).buy{value: 0.03 ether}(1);
    }

    function test_Revert_If_User_Sends_Zero_Eth() public {
        //test if user can buy more than 3 percent
        vm.prank(alice);
        bytes memory expectedRevert = abi.encodeWithSelector(MoonUpMarket__INVALID_AMOUNT.selector);
        vm.expectRevert(expectedRevert);
        IMoonUpMarketImplementation(MoonUpProxy).buy{value: 0}(1);
    }

    function test_User_Can_Sell() public {
        //test if user can sell
        vm.prank(alice);
        IMoonUpMarketImplementation(MoonUpProxy).buy{value: 0.003 ether}(1);

        vm.startPrank(alice);
        IERC20(MoonUpErc20).approve(MoonUpProxy, IERC20(MoonUpErc20).balanceOf(alice)); 
        IMoonUpMarketImplementation(MoonUpProxy).sell(IERC20(MoonUpErc20).balanceOf(alice), 1);
        vm.stopPrank();
        vm.assertTrue(IERC20(MoonUpErc20).balanceOf(alice) == 0);

        alice.balance;
    }

    function test_User_Can_Not_Sell_Zero_Amount() public {
        //test if user can sell Zero Amount
        vm.startPrank(alice);
        IMoonUpMarketImplementation(MoonUpProxy).buy{value: 0.003 ether}(1);
        bytes memory expectedRevert = abi.encodeWithSelector(MoonUpMarket__INVALID_AMOUNT.selector);
        IERC20(MoonUpErc20).approve(MoonUpProxy, IERC20(MoonUpErc20).balanceOf(alice)+1); 
        vm.expectRevert(expectedRevert);
        IMoonUpMarketImplementation(MoonUpProxy).sell(0, 1);
        vm.stopPrank();

    }  
    
}
