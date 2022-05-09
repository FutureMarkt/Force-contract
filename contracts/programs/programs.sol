// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";
import "../Referal.sol";

abstract contract Programs is Referal {
  mapping(uint => Product) public products;

  enum Product {
      s3,
      s6
  }

  uint[] public prices;
  uint public firstPrice = 5 * 10 ** 18;

  constructor(){
    /// Set products
    for (uint i = 0; i < 12; i++) {
        products[i] = ((i + 1) % 3 == 0) ? Product.s6 : Product.s3;
    }

    /// Set products prices
    for (uint j = 0; j < 12; j++) {
        prices.push(firstPrice * 2 ** j);
    }
  }

  function _sendDevisionMoney(address _parent, uint _price, uint _percent) internal {
    uint amoutSC = _price * _percent / 100;
    tokenMFS.transferFrom(msg.sender, _parent, (_price - amoutSC)); // transfer token to me
    tokenMFS.transferFrom(msg.sender, address(this), amoutSC); // transfer token to smart contract
  }

  function getActivateParent(address _child, uint _lvl) internal view returns (address response) {
      address __parent = parent[_child];
      while(true) {
          if (_isActive(__parent, _lvl)) {
              return __parent;
          } else {
              __parent =parent[__parent];
          }
      }
  }
}
