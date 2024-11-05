// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { MoonUpBaseTest } from "test/BaseTest.t.sol";
import { IERC20 } from "src/MoonUpMarket/interfaces/IERC20.sol";
import { MoonUpMarket } from "src/MoonUpMarket/MoonUpMarketImplementation.sol";

contract MoonUpFactoryTest is MoonUpBaseTest{
    uint256 TOTAL_SUPPLY =  1_000_000_000 * 1e18;

    function afterSetup() internal override {}

    function beforeSetup() internal override {}

    address moonUpProxy;

    address moonupErc20;

    uint256 CREATIONFEE_AND_BUY = 0.005 ether;

    modifier prankUser{
      vm.startPrank(alice);
      _;
      vm.stopPrank();
    }

    modifier createTokenPair{
        vm.prank(alice);
       (moonupErc20, moonUpProxy)= moonUpfactory.createTokensAndPair{value: CREATION_FEE}
        ("MoonToken", "MTN", "MoonTokenPump.co.za", 0, false);
      _;
    }

     modifier createTokenPairAndBuy{
        vm.prank(alice);
        (moonupErc20, moonUpProxy)= moonUpfactory.createTokensAndPair{value: CREATIONFEE_AND_BUY}
        ("MoonToken", "MTN", "MoonTokenPump.co.za", 0, true);
      _;
    }
    function _moonUpImplementation() internal virtual returns (address) {
        return address(new MoonUpMarket());
    }
    function test_MintedTotalSupplyToMarket() public createTokenPair {
      uint256 mintedTotalSupply = IERC20(moonupErc20).balanceOf(moonUpProxy);
      assertEq(mintedTotalSupply, TOTAL_SUPPLY );

    }

    function test_MintedTotalSupplyToMarketWhenBuy() public createTokenPairAndBuy {
      uint256 mintedTotalSupply = IERC20(moonupErc20).balanceOf(moonUpProxy);
      vm.expectRevert();
      assertEq(mintedTotalSupply, TOTAL_SUPPLY);

    }

    function test_checkUserBalanceAfterBuy() public createTokenPairAndBuy {
      uint56 userBalanceBefore = 0;
      uint256 userCurrentBalance = IERC20(moonupErc20).balanceOf(moonUpProxy);
      assertGt(userCurrentBalance, userBalanceBefore);

    }
    function test_SendLessEthForCreationFee() public prankUser {
    
      vm.expectRevert();
        (moonupErc20, moonUpProxy)= moonUpfactory.createTokensAndPair{value: 0.0012 ether}
        ("MoonToken", "MTN", "MoonTokenPump.co.za", 0, false);
    }
  
  function test_withdrawFees() public createTokenPair{
    uint256 ownerBalanceBefore = address(owner).balance;
    assertEq(ownerBalanceBefore, 0);
    vm.prank(owner);
    moonUpfactory.withdrawFees();
    assertEq(address(moonUpfactory).balance, 0);
    assertEq(address(owner).balance, CREATION_FEE);

  }


  function test_AnyUserCanSetCreationFee() prankUser public {
    vm.expectRevert();
    moonUpfactory.setCreationFeeTo(0.015 ether);
    
  }

function test_setCreationFeeTo() public {
    uint256 NEW_CREATION_FEE = 0.1 ether;
    address feeToSetter = moonUpfactory.feeToSetter();
    vm.prank(feeToSetter);
    moonUpfactory.setCreationFeeTo(NEW_CREATION_FEE);
   vm.assertTrue(NEW_CREATION_FEE == 0.1 ether);
  }

  function test_setCreationFeeSetter() public {
    address feeToSetter = moonUpfactory.feeToSetter();
    vm.prank(feeToSetter);
    moonUpfactory.setCreationFeeSetter(alice);
    assertEq(moonUpfactory.feeToSetter(), alice);

  }

    function test_UpgradeImplementation() public createTokenPair{
      address newMoonUpImplementationAddress = _moonUpImplementation();
      vm.prank(owner);
      moonUpfactory.upgradeTo(newMoonUpImplementationAddress);
      assertEq(newMoonUpImplementationAddress, moonUpfactory.implementation());

    }

  function test_OnlyOwnerCanUpgrade() public prankUser {
    address newMoonUpImplementationAddress = _moonUpImplementation();
    vm.expectRevert();
    moonUpfactory.upgradeTo(newMoonUpImplementationAddress);
  }

  function test_CannotUpgradeToEOA() public {
      vm.prank(owner);
      vm.expectRevert();
      moonUpfactory.upgradeTo(bob);
  }
    
}