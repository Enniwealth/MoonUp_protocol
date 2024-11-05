// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "../MoonUpMarket/interfaces/IERC20.sol";

import "../MoonUpMarket/UniswapInteraction.sol";

import "../MoonUpMarket/interfaces/IWETH.sol";

error MoonUpMarket__INVALID_AMOUNT();

error MoonUpMarket__MARKET_CLOSED();

error MoonUpMarket__FAILED_TRANSACTION();

error MoonUpMarket__CANNOT_INITIALIZE_TWICE();

error MoonUpMarket__CANNOT_BUY_MORE_THAN_3_PERCENT();

contract MoonUpMarket is UniswapInteraction {

    IERC20  public token;
    IWETH public weth;
    bool private isMarketOpen;
    uint256 private totalEth;
    uint256 private total_Trade_Volume;
    address private uniswapFactory;
    address private nonfungiblePositionManager;

  
    uint160 TOKEN_LIQUIDITY_VOLUME; //200000000 * 1e18;
    uint160 ETH_LIQUIDITY_VOLUME; //5 ether;
    uint256 TOTAL_TOKEN_SUPPLY; //1_000_000_000 * 1e18;
    uint256 PERCENTAGE_HOLDING_PER_USER; // 30_000_000 * 1e18;
    uint64 initialPrice; //7692307691 wei;

    uint256 private tokensSoldSoFar;

    mapping(address => uint256) private balances;
    bool isInitialized;
    address factory;

    event Buy(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);
    event Sell(address indexed seller, uint256 ethAmount, uint256 tokenAmount);
    event UniswapPoolCreated(address indexed poolAddress);
    event AmountGathered(uint256 indexed amount);
    event TokenWithdrawn(address indexed receiver, uint256 indexed amount, address sender);
    
    function initialize(address _token, IWETH _weth, address _nfpm, address _uFactory, uint256 _total_Trade_Volume, uint160 Token_Liquidity, uint160 Eth_Liquidity, uint256 total_token_supply, uint256 percentage_holding, uint64 initialprice) public {
        if (isInitialized == true){
            revert MoonUpMarket__CANNOT_INITIALIZE_TWICE();
        }

        token = IERC20(_token);
        weth = _weth;
        nonfungiblePositionManager = _nfpm;
        uniswapFactory = _uFactory;
        isMarketOpen = true;
        total_Trade_Volume = _total_Trade_Volume;
        factory = msg.sender;
        TOKEN_LIQUIDITY_VOLUME = Token_Liquidity;
        ETH_LIQUIDITY_VOLUME = Eth_Liquidity;
        TOTAL_TOKEN_SUPPLY = total_token_supply;
        PERCENTAGE_HOLDING_PER_USER = percentage_holding;
        initialPrice = initialprice;
        isInitialized == true;
    }

    modifier marketStatus {
        if(!isMarketOpen){
            revert MoonUpMarket__MARKET_CLOSED();
        }
        _;
    }
    function buy(uint256 minExpected) external marketStatus payable{
        if(msg.value == 0){
            revert MoonUpMarket__INVALID_AMOUNT();
        }
        uint256 fee = (msg.value * 10)/ 1000;
        (bool success,) = factory.call{value: fee}("");
        require(success, "Transfer Failed");
        uint256 buyAmount = msg.value - fee;
        uint256 tokenAmount = getTokenQoute(buyAmount);

        if(total_Trade_Volume - tokensSoldSoFar < tokenAmount){
            tokenAmount = total_Trade_Volume - tokensSoldSoFar;
        }

        if(tokenAmount < minExpected){
            revert MoonUpMarket__FAILED_TRANSACTION();
        }

        totalEth += msg.value;
        tokensSoldSoFar += tokenAmount;
        balances[msg.sender] += tokenAmount;

        if(balances[msg.sender] > PERCENTAGE_HOLDING_PER_USER){
            revert MoonUpMarket__CANNOT_BUY_MORE_THAN_3_PERCENT();
        }
        
        token.transfer(msg.sender, tokenAmount);

        if(msg.value > getEthQoute(tokenAmount)){
            uint256 refund = msg.value - getEthQoute(tokenAmount);
            msg.sender.call{value:refund};
        }

        emit Buy(msg.sender, buyAmount, tokenAmount);

        if(total_Trade_Volume - tokensSoldSoFar == 0){
            isMarketOpen = false;
            emit AmountGathered(address(this).balance);
            addToUniswap();
        }
    }

    function sell(uint256 amount, uint256 minExpected) external marketStatus{
        if(amount == 0){
            revert MoonUpMarket__INVALID_AMOUNT();
        }

        uint256 tokenAmount = amount;
        uint256 ethAmount = getEthQoute(tokenAmount);
        uint256 fee = (ethAmount) * 10 / 1000;
        uint256 ethAmountAfterFee = ethAmount - fee;

        (bool Successful,) = factory.call{value: fee}("");
        require(Successful, "Transfer Failed");
        
        if(ethAmount < minExpected){
            revert MoonUpMarket__FAILED_TRANSACTION();
        }

        token.transferFrom(msg.sender, address(this), tokenAmount);
        totalEth -= ethAmount;
        balances[msg.sender] -= tokenAmount;
        tokensSoldSoFar -= tokenAmount;
        (bool success,) = payable(msg.sender).call{value: ethAmountAfterFee}("");
        require(success, "transfer failed!");
        emit Sell(msg.sender, ethAmount, tokenAmount);
    }

    function addToUniswap() internal {
        require(address(this).balance >= 6 ether, "Insufficient balance to add to Uniswap");

        uint256 platformPercent = 10;
        uint256 platformCut = (address(this).balance * platformPercent) / 100;
        (bool success, ) = address(factory).call{value: platformCut}("");
        require(success, "Transfer Not Successful");

        depositWeth(5 ether);
        address poolAddress = create(uniswapFactory, address(token), address(weth), 500);
        uint160 price = uint160((address(this).balance / (TOKEN_LIQUIDITY_VOLUME)/1e18));
        uint160 sqrtPrice96 = (sqrt(price)*2) **96;
        initialized(poolAddress, sqrtPrice96);
        
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: address(token),
            token1: address(weth),
            fee: 500,
            tickLower: -887272,
            tickUpper: 887272,
            amount0Desired: TOKEN_LIQUIDITY_VOLUME,
            amount1Desired: ETH_LIQUIDITY_VOLUME,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp + 100
        });

        weth.approve(nonfungiblePositionManager, ETH_LIQUIDITY_VOLUME);
        token.approve(nonfungiblePositionManager, TOKEN_LIQUIDITY_VOLUME);

        (uint256 tokenId, , , ) = mint(nonfungiblePositionManager, params);

        INonfungiblePositionManager(nonfungiblePositionManager).transferFrom(address(this), address(0), tokenId);

        emit UniswapPoolCreated(poolAddress);
        }

    function withdrawToken() external {
        require(msg.sender == factory, "Only owner can withdraw fees");
        require(!isMarketOpen, "Market is still open");
        uint256 amount = token.balanceOf(address(this));
        token.transferFrom(address(this), factory, amount);

        emit TokenWithdrawn(factory, amount, address(this));
    }

    
    function depositWeth(uint amount) internal {
        weth.deposit{value: amount}();
    }

    function getPrice() public view returns(uint256){
        if(tokensSoldSoFar > 0) 
        {return initialPrice + (tokensSoldSoFar * initialPrice / total_Trade_Volume);}
        else {return initialPrice;}
    }

    function getAvailableToken() public view returns(uint256){
        return total_Trade_Volume - tokensSoldSoFar;
    }

    /*
    *@dev takes in amount in ether and returns tokens 
    */
    function getTokenQoute (uint256 amount) public view returns(uint256){
        return ((amount) / getPrice())* 1e18; 
    }

    /*
    *@dev returns total amount of ether available tokens left sale will cost 
    */
    function getPriceOfAvailableTokens() external view returns(uint256){
        return getEthQoute(getAvailableToken());
    }

    /*
    *@dev takes amount in tokens and returns cost of tokens in ether
    */
    function getEthQoute (uint256 amount) public view returns(uint256){
        return (amount * getPrice())/1e18; 
    }

    function sqrt(uint160 x) public pure returns (uint160 y) {
        uint160 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

}