// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

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

  mapping (address => mapping(uint => structS30)) public matrixS30;   // user -> lvl -> structS3
  mapping (address => mapping(uint => address[])) public childsS30;   // user -> lvl -> childs array
  mapping (address => mapping(uint => uint[4])) public lastChildS30;  // user -> lvl -> last child
  mapping (address => mapping(uint => uint)) public slotS30;          // user -> lvl -> slot

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

  function testt() external {
    console.log('tttest');
  }

  function updateS30(address _child, uint lvl) isRegistred public{
    // Get parents info
    address _parent = getActivateParent(_child, lvl);
    structS30 storage _parentStruct = matrixS30[_parent][lvl];

    // Looking for a branch
    uint _branch;
    for (uint i = 0; i < 4; i++) {
      if(lastChildS30[_parent][lvl][i] % (2 ** i) == 0) {
        _branch = i;
        break;
      }
    }

    //
    if(_branch == 0) {
      console.log('Branch', _branch);
    }
  }

  function _cascadeS30(address _child, uint _lvl) internal {
    address[4] memory parents;
    uint _parenLastChild;
    for(uint i = 0; i < 4; i++) {
      parents[i] = getActivateParent(_child, _lvl);
      _parenLastChild = lastChildS30[parents[i]][_lvl][i];

      // First branch
      if (i == 0) {

      }
      /* if (_parenLastChild % (2 ** i) == 0) */
      _child = parents[i];
    }
  }

}
