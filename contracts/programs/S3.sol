// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";
import "./Programs.sol";

abstract contract S3 is Programs {

  struct structS3 {
    uint slot;
    uint lastChild;
    uint frozenMoneyS3;
  }

  mapping (address => mapping(uint => structS3)) public matrixS3; // user -> lvl -> structS3

  mapping(address => mapping(uint => address[])) public childsS3;

  function buy(uint lvl) isRegistred virtual public {
      require(activate[msg.sender][lvl] == false, "This level is already activated");
      // Check if there is enough money

      for (uint i = 0; i < lvl; i++) {
          require(activate[msg.sender][i] == true, "Previous level not activated");
      }

      if (products[lvl] == Product.s3) {
          updateS3(msg.sender, lvl);
      }

      // Activate new lvl
      activate[msg.sender][lvl] = true;
  }

  function updateS3(address _child, uint lvl) isRegistred public returns (address) {
    address _parent = getActivateParent(_child, lvl);

    // Increment lastChild
    structS3 storage _parentStruct = matrixS3[_parent][lvl];
    uint _lastChild = _parentStruct.lastChild;
    _parentStruct.lastChild++;
    _lastChild = _lastChild % 3;

    // Get price
    uint _price = prices[lvl];

    // First Child
    if (_lastChild == 0) {
      //Check autoUpgrade
      if (users[_parent].autoUpgrade) {
        _sendDevisionMoney(_parent, _price, 25);
      } else {
        _parentStruct.frozenMoneyS3 += _price;
        tokenMFS.transferFrom(msg.sender, address(this), _price);
      }
    }

    // Second Child
    if (_lastChild == 1) {
      //Check autoUpgrade
      if (users[_parent].autoUpgrade) {
        _sendDevisionMoney(_parent, _price, 25);
      } else {
        _parentStruct.frozenMoneyS3 -= _price;

        // THINK
        tokenMFS.transfer(_parent, _price); // transfer frozen money
        tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer money to parent
        // buy((lvl + 1)); // buy next lvl buy[lvl + 1]
      }
    }

    // Last Child
    if (_lastChild == 2) {
      // Check autorecycle
      if (users[_parent].autoReCycle) {
        _sendDevisionMoney(_parent, _price, 40);
      } else {
        tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer token to parent
        if (_parent != owner()){
          updateS3(_parent, lvl); // update parents product
        }
      }
      _parentStruct.slot++;
    }

    // Push new child
    childsS3[_parent][lvl].push(_child);
    // matrixS3[_parent][lvl].childsLvl1.push(_child);

    return _parent;
  }
}
