// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract S6 {
  struct structS6 {
    address[] childsLvl1;
    address[] childsLvl2;
    uint slot;
    uint lastChild;
    uint frozenMoneyS3;
  }

  mapping (address => mapping(uint => structS6)) public matrixS6; // user -> lvl -> structS3
}
