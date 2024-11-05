// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IWETH.sol";
import "./IERC20.sol";

interface IMoonUpMarketImplementation {
    function token() external view returns (IERC20);
    function sqrt(uint160) external view returns(uint160);
    function withdrawToken() external;
    function calculateToken(uint256 amount) external view returns(uint256 tokenAmount);
    function initialize(address _token, IWETH _weth, address _nfpm, address _uFactory, uint256 _total_Trade_Volume) external; 
    function buy(uint256 minExpected) external payable;
    function sell(uint256 tokenAmount, uint256 minExpected) external;
    function withdrawFees() external;
    function getPrice() external view returns (uint256);
    function getAvailableToken() external view returns (uint256);
    function getTokenQoute(uint256 tokenAmount) external view returns (uint256);
    function getPriceOfAvailableTokens() external view returns (uint256);
    function getEthQoute(uint256 ethAmount) external view returns (uint256);
    function wethInContract() external view returns(uint256);
}