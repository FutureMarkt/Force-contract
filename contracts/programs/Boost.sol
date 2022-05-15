// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./S6.sol";

abstract contract Boost is S6 {
  mapping(uint => ProductBoost) public productsBoost;

  enum ProductBoost {
      s30,
      s141,
      s142,
      s31,
      s32,
      s6,
      s2
  }

  uint[10] public pricesBoost;
  uint public firstPriceBoost = 10 * 10 ** 18;

  mapping(address => mapping(uint => bool)) public activateBoost; // user -> lvl -> active

  constructor(){
    /// Set productsBoost
    productsBoost[0] = productsBoost[5] = ProductBoost.s30;
    productsBoost[1] = ProductBoost.s141;
    productsBoost[2] = productsBoost[7] = ProductBoost.s6;
    productsBoost[3] = ProductBoost.s31;
    productsBoost[4] = productsBoost[8] = ProductBoost.s2;
    productsBoost[6] = ProductBoost.s142;

    /// Set productsBoost prices
    pricesBoost[0] = firstPriceBoost;
    pricesBoost[1] = firstPriceBoost * 8;
    pricesBoost[2] = firstPriceBoost * 40;
    pricesBoost[3] = firstPriceBoost * 100;
    pricesBoost[4] = firstPriceBoost * 200;
    pricesBoost[5] = firstPriceBoost * 100;
    pricesBoost[6] = firstPriceBoost * 500;
    pricesBoost[7] = firstPriceBoost * 1500;
    pricesBoost[8] = firstPriceBoost * 3000;
    pricesBoost[9] = firstPriceBoost * 4500;
  }
}
