// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./interfaces/INonfungiblePositionManager.sol";
import "./interfaces/IUniswapFactory.sol";
import "./interfaces/IUniswapV3Pool.sol";
contract UniswapInteraction{
    function create(address _uniswapFactory, address token, address weth, uint24 fee) internal returns(address) {
        return IUniswapV3Factory(_uniswapFactory).createPool(token, weth, fee);
    }

    function initialized(address poolAddress, uint160 sqrtPrice64) internal {
        IUniswapV3Pool(poolAddress).initialize(sqrtPrice64);
    }

    function call0(address poolAddress) view internal returns(uint160){
        (uint160 sqrtPriceX96,,,,,,)= IUniswapV3Pool(poolAddress).slot0();
        return sqrtPriceX96;
    }

    function mint(address _nonfungiblePositionManager, INonfungiblePositionManager.MintParams memory params) internal returns(uint256, uint128, uint256, uint256) {
        return INonfungiblePositionManager(_nonfungiblePositionManager).mint(params);
    }
}