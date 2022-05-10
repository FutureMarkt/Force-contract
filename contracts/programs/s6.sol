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


    // Looking for level
    uint _lastChild1 = _parentStruct.lastChild1;
    uint cLvl = 1;

    // Get Lvl, where we will work
    if (_lastChild1 % 2 == 0 && _lastChild1 != 0) {
      cLvl = 2;
    }

    if (cLvl == 1) {
      // set 1 lvl
      // send mfs to parent of my parent
      tokenMFS.transferFrom(msg.sender, _grandpa, _price); // transfer token to grandparent
      _parentStruct.childsLvl1.push(msg.sender); // push new child to parent
      if (_lastChild1 != 0) {
        _changePosition(_grandpaStruct, 3);
      } else {
        _changePosition(_grandpaStruct, 2);
      }

      _parentStruct.lastChild1++;
    } else {
      // set 2 lvl

      uint _position = _parentStruct.lastChild2 % 4;
      _changePosition(_grandpaStruct, _position);
      console.log('Position', _position);

      // Last child
      if (_position == 3) {
        // Check autorecycle
        if (users[_parent].autoReCycle) {
          _sendDevisionMoney(_parent, _price, 40);
        } else {
          tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer token to parent
          updateS6(_parent, lvl); // update parents product
        }
        _parentStruct.slot++;
        // transfer money to parent
      }

      // Last child
      if (_position == 2) {
        // check auto upgrade
        // transfer money to parent
      }

      // Last child
      if (_position == 1) {
        // check auto upgrade
        // transfer money to parent
      }

      // Last child
      if (_position == 0) {
        tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer token to parent
        _parentStruct.childsLvl2.push(msg.sender); // push new child to parent
      }


      _parentStruct.lastChild2++;
    }

    return _parent;
  }

  function _getPositionLvl2(structS6 memory _parent) pure internal returns(uint position) {
    position = _parent.lastChild2 % 4;
  }

  function _changePosition (structS6 storage _parent, uint _position) internal {
    _parent.position[_position] = true;
  }
}
