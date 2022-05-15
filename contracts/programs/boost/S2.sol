// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";
import "../Boost.sol";

abstract contract S2 is Boost {

  struct structS2 {
    uint slot;
    uint lastChild;
    uint frozenMoneyS3;
  }

  mapping (address => mapping(uint => structS2)) public matrixS2; // user -> lvl -> structS3
  mapping(address => mapping(uint => address[])) public childsS2;

  function buyBoost(uint lvl) isRegistred virtual public {
      require(activateBoost[msg.sender][lvl] == false, "This level is already activated");
      // Check if there is enough money

      for (uint i = 0; i < lvl; i++) {
          require(activateBoost[msg.sender][i] == true, "Previous level not activated");
      }

      if (productsBoost[lvl] == ProductBoost.s2) {
          updateS2(msg.sender, lvl);
      }

      // Activate new lvl
      activateBoost[msg.sender][lvl] = true;
  }

  function updateS2(address _child, uint lvl) isRegistred internal{
    address _parent = getActivateParent(_child, lvl);

    // Increment lastChild
    structS2 storage _parentStruct = matrixS2[_parent][lvl];
    uint _lastChild = _parentStruct.lastChild;
    _parentStruct.lastChild++;
    _lastChild = _lastChild % 2;

    // Get price
    uint _price = pricesBoost[lvl];

    // First Child
    if (_lastChild == 0) {
      //Check autoUpgrade
      if (users[_parent].autoUpgrade) {
        _sendDevisionMoney(_parent, _price, 25);
      } else {
        if(lvl == 4) {
          tokenMFS.transferFrom(msg.sender, _parent, 1000 * 10 ** 18);
          buyBoost(lvl + 1);
        } else {
          tokenMFS.transferFrom(msg.sender, _parent, _price);
        }
      }
    }

    // Last Child
    if (_lastChild == 1) {
      // Check autorecycle
      if (users[_parent].autoReCycle) {
        _sendDevisionMoney(_parent, _price, 40);
      } else {
        tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer token to parent
        if (_parent != owner()){
          updateS2(msg.sender, lvl); // update parents product
        }
      }
      _parentStruct.slot++;
    }

    // Push new child
    childsS2[_parent][lvl].push(_child);
  }

}
