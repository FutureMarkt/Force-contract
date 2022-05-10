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
    uint frozenMoneyS6;
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
    // _parentStruct.lastChild1 = 2;


    // Looking for level
    uint _lastChild1 = _parentStruct.lastChild1;
    uint cLvl = 1;

    // Get Lvl, where we will work
    if (_lastChild1 % 2 == 0 && _lastChild1 != 0) {
      cLvl = 2;
    }

    if (cLvl == 1) {
      // set 1 lvl

      // Parent
      _parentStruct.childsLvl1.push(msg.sender); // push new child to parent
      _parentStruct.lastChild1++;

      // GrandParent
      if (_lastChild1 != 0) {
        _changePosition(_grandpa, _price, _grandpaStruct, 3, lvl);
      } else {
        _changePosition(_grandpa, _price, _grandpaStruct, 2, lvl);
      }

    } else {
      // set 2 lvl

      uint _position = _parentStruct.lastChild2 % 4;
        _changePosition(_grandpa, _price, _grandpaStruct, _position, lvl);
      console.log('Position', _position);

      // Last child
      if (_position == 3) {

      }

      // Last child
      if (_position == 2) {
      }

      // Last child
      if (_position == 1) {
        // check auto upgrade
        // transfer money to parent
        // update child 1
      }

      // Last child
      if (_position == 0) {

      }
    }

    return _parent;
  }

  function _getPositionLvl2(structS6 memory _parent) pure internal returns(uint position) {
    position = _parent.lastChild2 % 4;
  }

  function _changePosition(address _parent, uint _price, structS6 storage _parentStruct, uint _position, uint _lvl) internal {
    // check which spot
    uint _spot = _parentStruct.lastChild2 % 4;


    // first child in slot
    if (_spot == 0) {
      tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer token to parent
    }

    // second child in slot
    if (_spot == 1) {
      //Check autoUpgrade
      if (users[_parent].autoUpgrade) {
        _sendDevisionMoney(_parent, _price, 25);
      } else {
        _parentStruct.frozenMoneyS6 += _price;
        tokenMFS.transferFrom(msg.sender, address(this), _price);
      }
    }

    if (_spot == 3) {
      // Check autorecycle
      if (users[_parent].autoReCycle) {
        _sendDevisionMoney(_parent, _price, 40);
      } else {
        tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer token to parent
        updateS6(_parent, _lvl); // update parents product
      }
      _parentStruct.slot++;
      // update structur
      // update child 2
    }

    if (_spot == 2) {
      //Check autoUpgrade
      if (users[_parent].autoUpgrade) {
        _sendDevisionMoney(_parent, _price, 25);
      } else {
        _parentStruct.frozenMoneyS3 += _price;
        tokenMFS.transferFrom(msg.sender, address(this), _price);
      }
    }

    _parentStruct.lastChild2++;
    _parentStruct.childsLvl2[(_parentStruct.slot * 4) + _position] = msg.sender;
  }
}
