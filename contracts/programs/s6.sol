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

  mapping(address => mapping(uint => address[])) public childsS6Lvl1;
  mapping(address => mapping(uint => address[])) public childsS6Lvl2;

  function buy(uint lvl) isRegistred override public {
      require(activate[msg.sender][lvl] == false, "This level is already activated");
      require(lvl < 12, "Wrong level");
      // Check if there is enough money

      for (uint i = 0; i < lvl; i++) {
        require(activate[msg.sender][i] == true, "Previous level not activated");
      }

      if (products[lvl] == Product.s3) {
        updateS3(msg.sender, lvl);
      } else {
        updateS6(msg.sender, lvl);
      }

      // Activate new lvl
      activate[msg.sender][lvl] = true;
  }

  function updateS6(address _child, uint lvl) isRegistred internal returns (address) {
    address _parent = getActivateParent(_child, lvl);
    address _grandpa = getActivateParent(_parent, lvl);

    // Increment lastChild
    structS6 storage _parentStruct = matrixS6[_parent][lvl];
    structS6 storage _grandpaStruct = matrixS6[_grandpa][lvl];

    // Set null value
    if (_parentStruct.lastChild1 == 0) {
      _setNull(_parent, lvl);
    }

    // Get price
    uint _price = prices[lvl];

    // Looking for level
    uint _lastChild1 = _parentStruct.lastChild1;
    uint cLvl = 1;

    // Get Lvl, where we will work
    if (_lastChild1 % 2 == 0 && _lastChild1 != 0 && _parentStruct.slot * 2 != _lastChild1) {
      cLvl = 2;
    }

    // set 1 lvl
    if (cLvl == 1) {
      // Parent
      // Set info to parent
      if (childsS6Lvl1[_parent][lvl][_parentStruct.slot * 2] == address(0)){
        childsS6Lvl1[_parent][lvl][_parentStruct.slot * 2] = msg.sender;
      } else {
        childsS6Lvl1[_parent][lvl][_parentStruct.slot * 2 + 1] = msg.sender;
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
          _changePosition(_grandpa, _price, _grandpaStruct, _grandpaPosition, lvl); // GrandParent reward
        } else {
          if (_grandpaLeg == 1) {
            _grandpaPosition = 0;
          } else {
            _grandpaPosition = 2;
          }
          _changePosition(_grandpa, _price, _grandpaStruct, _grandpaPosition, lvl); // GrandParent reward
        }
      } else {
        tokenMFS.transferFrom(msg.sender, _parent, _price); // send to owner
      }
    } else {
      // set 2 lvl
      uint _position = _findEmptySpot(_parentStruct, _parent, lvl);
      _changePosition(_parent, _price, _parentStruct, _position, lvl); // Grandpa

      // Set child info
      // Find child
      address __child;
      if (_position < 2) {
        __child = childsS6Lvl1[_parent][lvl][_parentStruct.lastChild1 - 2]; // left leg
      } else {
        __child = childsS6Lvl1[_parent][lvl][_parentStruct.lastChild1 - 1]; // Right leg
      }

      // Change info
      structS6 storage _childStruct = matrixS6[__child][lvl]; // pa
      _childStruct.lastChild1++;
      childsS6Lvl1[__child][lvl].push(msg.sender);
    }

    return _parent;
  }

  function  _findEmptySpot(structS6 memory _parentStruct, address _parent, uint _lvl) view internal returns(uint _position) {
    uint _index;
    for(uint i = 0; i < 4; i++) {
      _index = _parentStruct.slot * 4 + i;
      if (childsS6Lvl2[_parent][_lvl][_index] == address(0)) return i;
    }
  }

  function _getPositionLvl2(structS6 memory _parent) pure internal returns(uint position) {
    position = _parent.lastChild2 % 4;
  }

  function _changePosition(address _parent, uint _price, structS6 storage _parentStruct, uint _position, uint _lvl) internal {
    // check which spot
    uint _spot = _parentStruct.lastChild2 % 4; // THINK BECAUSE DUBLICATE ON SECOND LEVEL
    childsS6Lvl2[_parent][_lvl][(_parentStruct.slot * 4) + _position] = msg.sender;


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
        //buy((_lvl + 1)); // buy next lvl buy[lvl + 1]
      }
    }

    // last child in slot
    if (_spot == 3) {
      // Check autorecycle
      if (users[_parent].autoReCycle) {
        _sendDevisionMoney(_parent, _price, 40);
      } else {
        tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer token to parent
        if(_parent != owner()) updateS6(_parent, _lvl); // update parents product
      }
      _parentStruct.slot++;
      _setNull(_parent, _lvl); // update structur to null
    }

    _parentStruct.lastChild2++;
  }

  function _setNull(address _parent, uint lvl) internal {

      for(uint i = 0; i < 2; i++){
        childsS6Lvl1[_parent][lvl].push(address(0));
      }

      for(uint i = 0; i < 4; i++){
        childsS6Lvl2[_parent][lvl].push(address(0));
      }
  }
}
