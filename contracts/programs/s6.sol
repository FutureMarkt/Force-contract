// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./S3.sol";

abstract contract S6 is S3 {
  struct structS6 {
    address[] childsLvl1;
    address[] childsLvl2;
    uint slot;
    uint lastChild1;
    uint lastChild2;
    bool[4] position;
    uint frozenMoneyS3;
  }

  mapping (address => mapping(uint => structS6)) public matrixS6; // user -> lvl -> structS6

  function updateS6(address _child, uint lvl) isRegistred public returns (address) {
    address _parent = getActivateParent(_child, lvl);
    address _grandpa = getActivateParent(_parent, lvl);

    // Increment lastChild
    structS6 storage _parentStruct = matrixS6[_parent][lvl];
    structS6 storage _grandpaStruct = matrixS6[_grandpa][lvl];

    // Get price
    uint _price = prices[lvl];

    console.log('last',_parentStruct.lastChild1);
    _parentStruct.lastChild1 = 2;
    _parentStruct.lastChild2 = 3;


    // Looking for level
    uint _lastChild1 = _parentStruct.lastChild1;
    uint cLvl = 1;

    // Get Lvl, where we will work
    if (_lastChild1 % 2 == 0 && _lastChild1 != 0) {
      cLvl = 2;
    }

    if (cLvl == 1) {
      // set 1 lvl
      _parentStruct.lastChild1++;

      // send mfs to parent of my parent
      tokenMFS.transferFrom(msg.sender, _grandpa, _price); // transfer token to parent
      if (_lastChild1 != 0) {
        _changePosition3(_grandpaStruct);
      } else {
        _changePosition2(_grandpaStruct);
      }
    } else {
      // set 2 lvl
      uint position = _parentStruct.lastChild2 % 4;
      console.log('Position', position);
    }

    return _parent;
  }

  function _getPositionLvl2(structS6 memory _parent) pure internal returns(uint position) {
    position = _parent.lastChild2 % 4;
  }

  function _changePosition3 (structS6 storage _parent) internal {
    _parent.position[3] = true;
  }

  function _changePosition2 (structS6 storage _parent) internal {
    _parent.position[2] = true;
  }
}
