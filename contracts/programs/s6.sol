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
      _setNull(_parent);
    }

    // Get price
    uint _price = prices[lvl];

    // Looking for level
    uint _lastChild1 = _parentStruct.lastChild1;
    uint cLvl = 1;

    // Get Lvl, where we will work
    if (_lastChild1 % 2 == 0 && _lastChild1 != 0) {
      cLvl = 2;
      // Check slot, if slot * 2 > lc, then level 1
    }

    console.log('Level', cLvl);

    if (cLvl == 1) {
      // set 1 lvl

      // Parent
      childsS6Lvl1[_parent].push(msg.sender); // push new child to parent

      // Set info to parent
      if (_lastChild1 != 0) {
        childsS6Lvl1[_parent][_parentStruct.slot * 2 + 1] = msg.sender;
      } else {
        childsS6Lvl1[_parent][0] = msg.sender;
      }

      _parentStruct.lastChild1++;

      // Set info to grandparent
      uint _grandpaLeg = _grandpaStruct.lastChild1 % 2;
      uint _grandpaPosition;

      // check is admin
      if (_parent != _grandpa){
        if (_lastChild1 != 0) {
          // Leg may be only 1, because if leg == 0, then you should be on level 2
          if (_grandpaLeg == 1) {
            _grandpaPosition = 1;
          } else {
            _grandpaPosition = 3;
          }
          console.log('GrandPa Leg', _grandpaPosition);
          _changePosition(_grandpa, _price, _grandpaStruct, _grandpaPosition, lvl); // GrandParent reward
        } else {
          if (_grandpaLeg == 1) {
            _grandpaPosition = 0;
          } else {
            _grandpaPosition = 2;
          }
          console.log('GrandPa Leg', _grandpaPosition);
          _changePosition(_grandpa, _price, _grandpaStruct, _grandpaPosition, lvl); // GrandParent reward
        }
      }



    } else {
      // set 2 lvl
      uint _position = _findEmptySpot(_parentStruct, _parent);
      _changePosition(_parent, _price, _parentStruct, _position, lvl); // Grandpa

      console.log('POsition on vl 2', _position);

      // Set child info
      // Find child
      address __child;
      if (_position < 2) {
        __child = childsS6Lvl1[_parent][_parentStruct.lastChild1 - 1]; // left leg
      } else {
        __child = childsS6Lvl1[_parent][_parentStruct.lastChild1]; // Right leg
      }

      // Change info
      structS6 storage _childStruct = matrixS6[__child][lvl]; // pa
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


    console.log('Position', (_parentStruct.slot * 4) + _position);
    childsS6Lvl2[_parent][(_parentStruct.slot * 4) + _position] = msg.sender;


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

    // third chid
    if (_spot == 2) {
      //Check autoUpgrade
      if (users[_parent].autoUpgrade) {
        _sendDevisionMoney(_parent, _price, 25);
      } else {

        // THINK
        _parentStruct.frozenMoneyS6 -= _price;
        tokenMFS.transfer(_parent, _price); // transfer frozen money
        tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer money to parent
        buy((lvl + 1)); // buy next lvl buy[lvl + 1]
      }
    }

    // last child in slot
    if (_spot == 3) {
      // Check autorecycle
      if (users[_parent].autoReCycle) {
        _sendDevisionMoney(_parent, _price, 40);
      } else {
        tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer token to parent
        updateS6(_parent, _lvl); // update parents product
      }
      _parentStruct.slot++;
      _setNull(_parent); // update structur to null
    }

    _parentStruct.lastChild2++;
  }

  function _setNull(address _parent) internal {

      for(uint i = 0; i < 2; i++){
        childsS6Lvl1[_parent].push(address(0));
      }

      for(uint i = 0; i < 4; i++){
        childsS6Lvl2[_parent].push(address(0));
      }
  }
}
