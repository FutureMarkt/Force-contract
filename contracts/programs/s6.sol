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

  mapping(address => mapping(uint => address[])) public childsS6Lvl1; // user -> lvl -> child
  mapping(address => mapping(uint => address[])) public childsS6Lvl2; // user -> lvl -> child

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

    console.log('LC2',_parentStruct.lastChild2);

    // Get price
    uint _price = prices[lvl];

    // Looking for level
    uint _lastChild1 = _parentStruct.lastChild1;
    uint cLvl = 1;

    // Get Lvl, where we will work
    if (_lastChild1 % 2 == 0 && _lastChild1 != 0 && _parentStruct.slot * 2 != _lastChild1) {
      cLvl = 2;
    }

    // Set null value
    if (_lastChild1 == 0) {
      _setNull(_parent, lvl);
    }

    console.log('Level', cLvl);

    // set 1 lvl
    if (cLvl == 1) {
      // Parent
      // Set info to parent
      console.log('SOME', _parentStruct.slot * 2);
      if (childsS6Lvl1[_parent][lvl][_parentStruct.slot * 2] == address(0)){
        require(childsS6Lvl1[_parent][lvl][_parentStruct.slot * 2] == address(0), 'This position is set');
        childsS6Lvl1[_parent][lvl][_parentStruct.slot * 2] = msg.sender;
      } else {
        require(childsS6Lvl1[_parent][lvl][_parentStruct.slot * 2 + 1] == address(0), 'This position is set');
        childsS6Lvl1[_parent][lvl][_parentStruct.slot * 2 + 1] = msg.sender;
      }

      _parentStruct.lastChild1++;


      // GrandPa
      // Set info to grandparent
      // check is admin
      if (_parent != _grandpa){       
        // Looking for free leg
        uint _grandpaLeg;
        console.log('FIX!', _grandpa);
        console.log('FIX2!', _parentStruct.slot);
        if (childsS6Lvl1[_grandpa][lvl][_parentStruct.slot * 2] == _parent){ // Use parent slot
          _grandpaLeg = 0; // left leg
        } else {
          _grandpaLeg = 1; // right leg
        }

        console.log('LEG',_grandpaLeg);

        uint _grandpaPosition;

        if (_lastChild1 != 0) {
          // Leg may be only 1, because if leg == 0, then you should be on level 2
          if (_grandpaLeg == 0) {
            _grandpaPosition = 1;
          } else {
            _grandpaPosition = 3;
          }
          console.log('THISS');
          _changePosition(_grandpa, _price, _grandpaStruct, _grandpaPosition, lvl,  _parentStruct.slot); // GrandParent reward
        } else {
          // First child in struct
          if (_grandpaLeg == 0) {
            _grandpaPosition = 0;
          } else {
            _grandpaPosition = 2;
          }
          _changePosition(_grandpa, _price, _grandpaStruct, _grandpaPosition, lvl, _parentStruct.slot); // GrandParent reward
        }
      } else {
        tokenMFS.transferFrom(msg.sender, _parent, _price); // send to owner
      }

      
    } else {
      // set 2 lvl
      uint _position = _findEmptySpot(_parentStruct, _parent, lvl);
      _changePosition(_parent, _price, _parentStruct, _position, lvl, _parentStruct.slot); // Grandpa

      // Set child info
      // Find child
      address __child;
      if (_position < 2) {
        // Left leg
        __child = childsS6Lvl1[_parent][lvl][_parentStruct.lastChild1 - 2]; 
      } else {
        // Right leg
        __child = childsS6Lvl1[_parent][lvl][_parentStruct.lastChild1 - 1]; 
      }

      // Change child info
      structS6 storage _childStruct = matrixS6[__child][lvl]; // pa
      uint __childLastChild1 = _childStruct.lastChild1;
      console.log('XXX', _parentStruct.slot);
      if (__childLastChild1 == 0) {
        _setNull(__child, lvl);
      }
      childsS6Lvl1[__child][lvl][_childStruct.lastChild1] = msg.sender;
      _childStruct.lastChild1++;
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

  function _changePosition(address _parent, uint _price, structS6 storage _parentStruct, uint _position, uint _lvl, uint _slot) internal {
    // check which spot
    uint _lastChild = _parentStruct.lastChild2;
    uint _spot;
    if (_lastChild == 0) {
      _spot = 0;
    }
    _spot = _parentStruct.lastChild2 % 4; // THINK BECAUSE DUBLICATE ON SECOND LEVEL
    //lastChild2 - 0 - no child
    
    // THINK ABOUT SLOT!
    // Set address to position
    console.log('FIX', _slot);
    require(childsS6Lvl2[_parent][_lvl][(_slot * 4) + _position] == address(0), 'This position is set');
    childsS6Lvl2[_parent][_lvl][(_slot * 4) + _position] = msg.sender;

    console.log('LC2', _parentStruct.lastChild2);
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
      console.log('XXX!');
      // Check autorecycle
      if (users[_parent].autoReCycle) {
        _sendDevisionMoney(_parent, _price, 40);
      } else {
        tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer token to parent
        if(_parent != owner()) updateS6(_parent, _lvl); // update parents product
      }
      _setNull(_parent, _lvl); // update structur to null
      address _grandParent = getActivateParent(_parent, _lvl);
      console.log('!Slot', _parentStruct.slot);
      _setNull(_grandParent, _lvl); // update structur to null
      _setNull(childsS6Lvl1[_parent][_lvl][_parentStruct.slot * 2], _lvl); // update structur to null
      _setNull(childsS6Lvl1[_parent][_lvl][_parentStruct.slot * 2 + 1], _lvl); // update structur to null
      _parentStruct.slot++;
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
