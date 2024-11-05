

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract MoonUpERC20 is ERC20, Ownable(msg.sender) {

    string public metadataURI;
    constructor(string memory name, string memory symbol, string memory _metadataURI)
        
        ERC20(name, symbol)
    {
        metadataURI = _metadataURI;

    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
    
}