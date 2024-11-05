// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MoonUpERC20} from "./token/erc20.sol";

import {MoonUpMarket} from "./MoonUpMarket/MoonUpMarketImplementation.sol";

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

import { IMoonUpMarketImplementation } from "src/MoonUpMarket/interfaces/IMarketImplementation.sol";

import { IERC20 } from "src/MoonUpMarket/interfaces/IERC20.sol";

import {UpgradeableBeacon} from "lib/openzeppelin-contracts/contracts/proxy/beacon/UpgradeableBeacon.sol";

import {IWETH} from "./MoonUpMarket/interfaces/IWETH.sol";

import {MoonUpProxy} from "./MoonUpMarket/MoonUpMarketProxy.sol";

contract MoonUpBeaconFactory is UpgradeableBeacon {

    uint256 TOTAL_SUPPLY =  1_000_000_000 * 1e18;

    uint256 public CREATION_FEE;

    address public feeToSetter;

    address[] public allPairs;

    mapping(address => address) private tokenToPair;

    IWETH weth;

    address nonfungiblePositionManager;

    address uniswapV3Factory;
    
    uint256 totalTradeVolume;

    
    uint160 TOKEN_LIQUIDITY_VOLUME = 200000000 * 1e18;
    uint160 ETH_LIQUIDITY_VOLUME = 5 ether;
    uint256 TOTAL_TOKEN_SUPPLY = 1_000_000_000 * 1e18;
    uint256 PERCENTAGE_HOLDING_PER_USER =  30_000_000 * 1e18;
    uint64 initialPrice = 7692307691 wei;
    

    event MoonUpBeaconFactory__TokensCreated(address MoonUpTokenPair, address MoonUpErc20);

    constructor(
        address _feeToSetter, 
        uint256 _creationFee,
        IWETH _weth,
        address _nfpm,
        address _uFactory,
        uint256 _total_Trade_Volume
    ) UpgradeableBeacon(_MoonUpImplementation(), msg.sender) 

    {
        CREATION_FEE = _creationFee;
        feeToSetter = _feeToSetter;
        weth = _weth;
        nonfungiblePositionManager = _nfpm;
        uniswapV3Factory = _uFactory;
        totalTradeVolume = _total_Trade_Volume;

    }

    function _MoonUpImplementation() internal virtual returns (address) {
        return address(new MoonUpMarket());
    }

    function deployPool(address token) internal returns (address moonUpProxy) {
       
        moonUpProxy = address(new MoonUpProxy(address(this), 
            abi.encodeWithSelector(MoonUpMarket.initialize.selector, 
            token, 
            weth, 
            nonfungiblePositionManager, 
            uniswapV3Factory, 
            totalTradeVolume,
            TOKEN_LIQUIDITY_VOLUME,
            ETH_LIQUIDITY_VOLUME,
            TOTAL_TOKEN_SUPPLY,
            PERCENTAGE_HOLDING_PER_USER,
            initialPrice
            )));
    }
    /**
     * @dev This function is responsible for creating tokens and their respective pairs. 
     * It also interacts with buy function in pair contract if amounntMin != 0 to buy tokens
     * @param name The is the name of the token to be created
     * @param symbol Represents the symbol of the token to be created
     * @param minExpected This is the minimum amount of tokens expected if creators want to buy
     */


    function createTokensAndPair(
        string memory name, 
        string memory symbol, 
        string memory _metadataURI, 
        uint256 minExpected,
        bool buy) 
        public payable returns (address moonupErc20, address moonUpProxy){
        
        uint256 buyAmount;
        require(msg.value >= CREATION_FEE, "Not enough eth for creation fee");
        
        moonupErc20 = address(new MoonUpERC20(name, symbol, _metadataURI));
        moonUpProxy = deployPool(address(moonupErc20));
        _mintTokensToMoonUpMarket(moonUpProxy, address(moonupErc20));

         if(buy == true){
            buyAmount = msg.value -  CREATION_FEE;
            
            (bool success,) = moonUpProxy.call{value: buyAmount}
                (abi.encodeWithSignature("buy(uint256)", minExpected));
            require(success);
         }

         tokenToPair[address(moonupErc20)] = moonUpProxy;
         

         allPairs.push(moonUpProxy);
       
        emit MoonUpBeaconFactory__TokensCreated(moonUpProxy, moonupErc20);
        
    }

    /**
     * @param _MoonUpTokenPair address of pairToken contract to mint to 
     * @param _MoonUpErc20 address of token contract
     */

    function _mintTokensToMoonUpMarket(
        address _MoonUpTokenPair,
        address _MoonUpErc20) private {
        MoonUpERC20(_MoonUpErc20).mint(_MoonUpTokenPair, TOTAL_SUPPLY);

    }

    function withdrawFees() public onlyOwner {
    (bool success,) = owner().call{value: address(this).balance}("");
    require(success, "Withdrawal failed");
    }

    function withdrawFromFactory(address moonUpMarket, address moonUpToken, uint256 amount) external onlyOwner { 
        (bool success,) = moonUpMarket.call(abi.encodeWithSignature("withdrawToken()"));
        require(success, "Call Failed!");
        IERC20(moonUpToken).transfer(owner(), amount);

    }

    
    function setCreationFeeTo(uint256 _feeTo) external {
        require(msg.sender == feeToSetter, 'MoonUp: FORBIDDEN');
        CREATION_FEE = _feeTo;
    }

    function setCreationFeeSetter(address _feeToSetter) external {
        require(msg.sender == owner(), 'MoonUP: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }


    function getMoonUpTokenPair(address Token) public view returns (address){
        return tokenToPair[Token];

    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

   
    receive() external payable {}

    // fallback() external {}
    
}
