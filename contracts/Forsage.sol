// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract Forsage {

  modifier isRegistred {
    require(parent[msg.sender] != address(0), "You are not registred");
    _;
  }

  mapping(address => address) public parent;
  mapping(address => address[]) public childs;

  mapping(address => mapping(uint => bool)) public activate; // user -> lvl -> active

  uint[] public prices;
  uint public firstPrice = 5 * 10 ** 18;

  enum Product {
      x3,
      x4
  }
  mapping(uint => Product) public products;

  constructor(address admin) {
      /// Set products
      for (uint i = 0; i < 12; i++) {
          products[i] = ((i + 1) % 3 == 0) ? Product.x4 : Product.x3;
      }

      /// Set first User
      parent[admin] = admin;
      for (uint i = 0; i < 12; i++) {
          activate[admin][i] = true;
      }
  }

  function registration(address ref) external {
      require(msg.sender != ref, "You can`t be referal");

      parent[msg.sender] = ref;
      childs[ref].push(msg.sender);
  }

  function buy(uint lvl) isRegistred external view {
      require(activate[msg.sender][lvl] == false, "This level is already activated");

      for (uint i = 0; i < lvl; i++) {
          require(activate[msg.sender][i] == true, "Previous level not activated");
      }

      if (products[lvl] == Product.x3) {
          // updateX3(lvl);
      }
  }

}
