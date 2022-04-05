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

  struct structX3 {
    address[] childsLvl1;
    uint slot;
    uint lastChild;
  }

  mapping (address => mapping(uint => structX3)) matrixX3; // user -> lvl -> structX3

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

  function updateX3(uint lvl) external view returns (address) {
    address _parent = getActivateParent(msg.sender, lvl);
    console.log('Update');
    return _parent;
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

    function _isActive(address _address, uint _lvl) internal view returns(bool) {
        return activate[_address][_lvl];
    }

}
