// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract MFS is ERC20, ERC20Detailed {

  constructor(uint256 initialSupply) ERC20Detailed("Gold", "GLD", 18) public {
        _mint(msg.sender, initialSupply);
    }

}
