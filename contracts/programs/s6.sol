// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./S3.sol";

abstract contract S6 is S3 {
  struct structS6 {
    uint slot;
    uint lastChild1;
    uint lastChild2;
    uint frozenMoneyS6;
  }

  mapping (address => mapping(uint => structS6)) public matrixS6; // user -> lvl -> structS6

  mapping(address => address[]) public childsS6Lvl1;
  mapping(address => address[]) public childsS6Lvl2;

  function updateS6(address _child, uint lvl) isRegistred public returns (address) {
    address _parent = getActivateParent(_child, lvl);
    address _grandpa = getActivateParent(_parent, lvl);

    // Increment lastChild
    structS6 storage _parentStruct = matrixS6[_parent][lvl];
    structS6 storage _grandpaStruct = matrixS6[_grandpa][lvl];

    // Set null value
    if (_parentStruct.lastChild1 == 0) {
      for(uint i = 0; i < 2; i++){
        childsS6Lvl1[_parent].push(address(0));
      }

      for(uint i = 0; i < 4; i++){
        childsS6Lvl2[_parent].push(address(0));
      }
    }

    // Get price
    uint _price = prices[lvl];

    // Looking for level
    uint _lastChild1 = _parentStruct.lastChild1;
    uint cLvl = 1;

    // Get Lvl, where we will work
    if (_lastChild1 % 2 == 0 && _lastChild1 != 0) {
      cLvl = 2;
    }

    console.log('Level', cLvl);

    if (cLvl == 1) {
      // set 1 lvl

      // Parent
      childsS6Lvl1[_parent].push(msg.sender); // push new child to parent

      uint _grandpaLeg = _grandpaStruct.lastChild1 % 2;
      uint _grandpaPosition;



      if (_lastChild1 != 0) {
        // Leg may be only 1, because if leg == 0, then you should be on level 2
        if (_grandpaLeg == 0) {
          _grandpaPosition = 1;
        } else {
          _grandpaPosition = 3;
        }
        console.log('GrandPa Leg', _grandpaPosition);
        _changePosition(_grandpa, _price, _grandpaStruct, _grandpaPosition, lvl); // GrandParent reward
        childsS6Lvl1[_parent][_parentStruct.slot * 2 + 1] = msg.sender;
      } else {
        if (_grandpaLeg == 0) {
          _grandpaPosition = 0;
        } else {
          _grandpaPosition = 2;
        }
        console.log('GrandPa Leg', _grandpaPosition);
        _changePosition(_grandpa, _price, _grandpaStruct, _grandpaPosition, lvl); // GrandParent reward
        childsS6Lvl1[_parent][0] = msg.sender;
      }

      _parentStruct.lastChild1++;

    } else {
      // set 2 lvl
      uint _position = _findEmptySpot(_parentStruct, _parent);
      _changePosition(_parent, _price, _parentStruct, _position, lvl);

      console.log('Check2', _position);

      // Set child info
      // Find child
      address __child;
      if (_position < 2) {
        __child = childsS6Lvl1[_parent][_parentStruct.lastChild1 - 1];
      } else {
        __child = childsS6Lvl1[_parent][_parentStruct.lastChild1];
      }

      // Change info
      structS6 storage _childStruct = matrixS6[__child][lvl];
      _childStruct.lastChild1++;
      childsS6Lvl1[__child].push(msg.sender);
    }

    return _parent;
  }

  function  _findEmptySpot(structS6 memory _parentStruct, address _parent) view internal returns(uint _position) {
    uint _index;
    for(uint i = 0; i < 4; i++) {
      _index = _parentStruct.slot * 4 + i;
      if (childsS6Lvl2[_parent][_index] == address(0)) return _index;
    }
  }

  function _getPositionLvl2(structS6 memory _parent) pure internal returns(uint position) {
    position = _parent.lastChild2 % 4;
  }

  function _changePosition(address _parent, uint _price, structS6 storage _parentStruct, uint _position, uint _lvl) internal {
    // check which spot
    uint _spot = _parentStruct.lastChild2 % 4; // THINK BECAUSE DUBLICATE ON SECOND LEVEL

    console.log('Spot', _spot);


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
        _parentStruct.frozenMoneyS6 += _price;
        tokenMFS.transferFrom(msg.sender, address(this), _price);
      }
    }

    _parentStruct.lastChild2++;
    childsS6Lvl2[_parent][(_parentStruct.slot * 4) + _position] = msg.sender;
    console.log('Position', (_parentStruct.slot * 4) + _position);
  }
}
