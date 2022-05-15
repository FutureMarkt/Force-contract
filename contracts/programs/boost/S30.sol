// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";
import "../Boost.sol";

abstract contract S30 is Boost {

  struct structS30 {
    uint slot;
    uint lastChild1;
    uint lastChild2;
    uint lastChild3;
    uint lastChild4;
    uint frozenMoneyS30;
  }

  mapping (address => mapping(uint => structS30)) public matrixS30; // user -> lvl -> structS3

  mapping(address => address[]) public childsS30Lvl1;
  mapping(address => address[]) public childsS30Lvl2;
  mapping(address => address[]) public childsS30Lvl3;
  mapping(address => address[]) public childsS30Lvl4;

  function buyBoost1(uint lvl) isRegistred public {
      require(activateBoost[msg.sender][lvl] == false, "This level is already activated");
      // Check if there is enough money

      for (uint i = 0; i < lvl; i++) {
          require(activateBoost[msg.sender][i] == true, "Previous level not activated");
      }

      if (productsBoost[lvl] == ProductBoost.s30) {
          updateS30(msg.sender, lvl);
      }

      // Activate new lvl
      activateBoost[msg.sender][lvl] = true;
  }

  function updateS30(address _child, uint lvl) isRegistred internal{
    // Get parents info
    address _parent = getActivateParent(_child, lvl);
    structS30 storage _parentStruct = matrixS30[_parent][lvl];

    // Looking for a level
    uint _branch = 1;
    if(_parentStruct.lastChild1 % 2 != 0) {
      if (_parentStruct.lastChild2 % 4 == 0) {
        _branch = 2;
      } else {
        if (_parentStruct.lastChild3 % 8 == 0) {
          _branch = 3;
        } else {
          _branch = 4;
        }
      }
    }

    //
    if(_branch == 1) {

    }
  }

}
