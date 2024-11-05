// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MoonUpMarket} from "src/MoonUpMarket/MoonUpMarketImplementation.sol";

import {Test} from "forge-std/Test.sol";

import {Vm, VmSafe} from "forge-std/Vm.sol";

import {MoonUpBeaconFactory} from "src/MoonUpBeaconFactory.sol";

import {MockWETH20} from "test/unit/MoonUpMarket/Mock/WETH.sol";

import {MoonUpProxy} from "src/MoonUpMarket/MoonUpMarketProxy.sol";

import {IWETH} from "src/MoonUpMarket/interfaces/IWETH.sol";

import {IMoonUpMarketImplementation} from "src/MoonUpMarket/interfaces/IMarketImplementation.sol";

import {IERC20} from "src/MoonUpMarket/interfaces/IERC20.sol";

contract MoonUpMarketUniswapTest is Test {
    address MoonUpProxyTest;

    address MoonUpErc20;

    MoonUpMarket moonUpMarket;

    MoonUpBeaconFactory moonUpfactory;

    uint256 TOTAL_TRADE_VOLUME = 780_000_000 * 1e18;

    uint256 CREATION_FEE = 0.002 ether;

    address uniswapFactory = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c;

    address nfpm = 0x1238536071E1c677A632429e3655c799b22cDA52;

    address WETH = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;

    address owner;

    address alice = makeAddr("alice");

    address bob = makeAddr("bob");

    bytes32 _nativeCurrencyLabelBytes = keccak256("MoonPump.MoonUp.up");

    address newUser = alice;

    event MoonUpFactoryDeployed(address moonUpFactoryAddress);

    function setUp() public {
        uint256 forkId = vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));

        VmSafe.Wallet memory wallet = vm.createWallet(
            vm.envUint("PRIVATE_KEY")
        );

        owner = wallet.addr;

        vm.startPrank(owner);
        moonUpfactory = new MoonUpBeaconFactory(
            owner,
            CREATION_FEE,
            IWETH(WETH),
            nfpm,
            uniswapFactory,
            TOTAL_TRADE_VOLUME
        );
        vm.stopPrank();
        emit MoonUpFactoryDeployed(address(moonUpfactory));
        vm.deal(alice, 4 ether);

        vm.prank(alice);
        (MoonUpErc20, MoonUpProxyTest) = moonUpfactory.createTokensAndPair{
            value: CREATION_FEE
        }("MoonUP", "MUP", "", 0, false);
    }

    function test_fuzz_deposit() public {
        for (uint256 i; i < 44; i++) {
            address user = generateRandomAddress(newUser); //makeAddr(vm.toString(abi.encodePacked(block.timestamp, block.number + i, i)));
            uint256 balanceBefore = IERC20(MoonUpErc20).balanceOf(user);
            uint256 moonUpBalanceBefore = MoonUpProxyTest.balance;
            vm.deal(user, 1 ether);
            uint256 AvailableToken = IMoonUpMarketImplementation(
                MoonUpProxyTest
            ).getAvailableToken();

            uint256 value = IMoonUpMarketImplementation(MoonUpProxyTest).getEthQoute(AvailableToken);
            if (AvailableToken < (30_000_000 * 1e18)) {
                vm.prank(user);
                IMoonUpMarketImplementation(MoonUpProxyTest).buy{
                    value: value + 0.1 ether
                }(1);
                vm.assertTrue(
                    IERC20(MoonUpErc20).balanceOf(user) > balanceBefore
                );
                vm.assertTrue(MoonUpProxyTest.balance > moonUpBalanceBefore);
            } else {
                vm.prank(user);
              
                IMoonUpMarketImplementation(MoonUpProxyTest).buy{
                    value: 0.2 ether
                }(1);
                vm.assertTrue(
                    IERC20(MoonUpErc20).balanceOf(user) > balanceBefore
                );
                vm.assertTrue(MoonUpProxyTest.balance > moonUpBalanceBefore);
            }

            newUser = user;
        }

    }

    function generateRandomAddress(address user) public view returns (address) {
        // Generate a pseudo-random hash using block data and sender's address
        uint256 randomHash = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao, user))
        );

        // Convert the hash to an address
        address randomAddress = address(uint160(randomHash));
        return randomAddress;
    }

    function test_Prices() public view{
        IMoonUpMarketImplementation(MoonUpProxyTest).getTokenQoute(230769230730000000);
        IMoonUpMarketImplementation(MoonUpProxyTest).getEthQoute(30_000_000 * 1e18);
        IMoonUpMarketImplementation(MoonUpProxyTest).getPriceOfAvailableTokens();
    }

    function testSqrt() public{
    IMoonUpMarketImplementation(MoonUpProxyTest).sqrt(25000000000);
    }

}
