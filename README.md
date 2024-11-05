
# MoonUp Protocol Smart Contracts

# Summary

Contracts in scope: All files in
   1.  MoonUp/src
   2.  MoonUp/scripts


# Details


## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [src/Interfaces/IPumpFactory.sol](/src/Interfaces/IPumpFactory.sol) | Solidity | 8 | 1 | 6 | 15 |
| [src/MoonUpBeaconFactory.sol](/src/MoonUpBeaconFactory.sol) | Solidity | 104 | 13 | 52 | 169 |
| [src/MoonUpMarket/MoonUpMarketImplementation.sol](/src/MoonUpMarket/MoonUpMarketImplementation.sol) | Solidity | 175 | 10 | 50 | 235 |
| [src/MoonUpMarket/MoonUpMarketProxy.sol](/src/MoonUpMarket/MoonUpMarketProxy.sol) | Solidity | 17 | 21 | 9 | 47 |
| [src/MoonUpMarket/Proxy.sol](/src/MoonUpMarket/Proxy.sol) | Solidity | 24 | 27 | 11 | 62 |
| [src/MoonUpMarket/UniswapInteraction.sol](/src/MoonUpMarket/UniswapInteraction.sol) | Solidity | 19 | 1 | 4 | 24 |
| [src/MoonUpMarket/interfaces/IBeacon.sol](/src/MoonUpMarket/interfaces/IBeacon.sol) | Solidity | 4 | 9 | 2 | 15 |
| [src/MoonUpMarket/interfaces/IERC20.sol](/src/MoonUpMarket/interfaces/IERC20.sol) | Solidity | 11 | 58 | 9 | 78 |
| [src/MoonUpMarket/interfaces/IMarketImplementation.sol](/src/MoonUpMarket/interfaces/IMarketImplementation.sol) | Solidity | 19 | 1 | 2 | 22 |
| [src/MoonUpMarket/interfaces/INonfungiblePositionManager.sol](/src/MoonUpMarket/interfaces/INonfungiblePositionManager.sol) | Solidity | 30 | 16 | 3 | 49 |
| [src/MoonUpMarket/interfaces/IUniswapFactory.sol](/src/MoonUpMarket/interfaces/IUniswapFactory.sol) | Solidity | 13 | 17 | 3 | 33 |
| [src/MoonUpMarket/interfaces/IUniswapV3Pool.sol](/src/MoonUpMarket/interfaces/IUniswapV3Pool.sol) | Solidity | 19 | 1 | 5 | 25 |
| [src/MoonUpMarket/interfaces/IWETH.sol](/src/MoonUpMarket/interfaces/IWETH.sol) | Solidity | 10 | 1 | 1 | 12 |
| [src/token/erc20.sol](/src/token/erc20.sol) | Solidity | 17 | 1 | 11 | 29 |

# Languages
| language | files | code | comment | blank | total |
| :--- | ---: | ---: | ---: | ---: | ---: |
| Solidity | 14 | 470 | 177 | 168 | 815 |

## Directories
| path | files | code | comment | blank | total |
| :--- | ---: | ---: | ---: | ---: | ---: |
| . | 14 | 470 | 177 | 168 | 815 |
| . (Files) | 1 | 104 | 13 | 52 | 169 |
| Interfaces | 1 | 8 | 1 | 6 | 15 |
| MoonUpMarket | 11 | 341 | 162 | 99 | 602 |
| MoonUpMarket (Files) | 4 | 235 | 59 | 74 | 368 |
| MoonUpMarket/interfaces | 7 | 106 | 103 | 25 | 234 |
| token | 1 | 17 | 1 | 11 | 29 |


## Technical Documentation
Link: https://moonupmemes-organization.gitbook.io/moonup.meme


   ```
   forge build
   ```
   To run test, you will need to insert private key and your SEPOLIA_RPC_URL to the .env file.

   ```
   forge test -vvvvv
   ```

## Additional Information For Audit

The requirements for this audit are as follows:

1. Gas Optimization: The Guild Audit security team is requested to conduct a comprehensive analysis focused on gas optimization. This involves identifying sections of the system where excessive gas consumption occurs and providing detailed recommendations for improvement. Recommendations should include both a written proof of concept and corrective code, demonstrating the specific changes needed.

2. Vulnerability Assessment: The Guild Audit security team is expected to identify vulnerabilities across all severity levels, including high, medium, low, and informational issues within the protocol. For each high and medium severity finding, the report should include both a proof of concept and an accompanying proof of code, along with the necessary corrective code to resolve each issue.

3. Security Review: Following the implementation of changes recommended in the initial audit, a follow-up review by the Guild Audit security team is requested to ensure that all updates have been accurately applied and that the protocol meets security standards.

4. Focus and emphasis should also be on the market contracts. This is to ensure buy and sell runs smoothly throughout the protocol and ensure no discrepancies in fees gotten from user interaction on the protocol.

## Known Issues
- SqrtX96 causing overflow
- Invariant test case not fully implemented