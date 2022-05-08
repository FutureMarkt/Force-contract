// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Referal.sol";

contract Forsage is Referal {  

  uint[] public prices;
  uint public firstPrice = 5 * 10 ** 18;

  enum Product {
      x3,
      x4
  }
  mapping(uint => Product) public products;

  mapping (address => mapping(uint => structX3)) public matrixX3; // user -> lvl -> structX3

  struct structX3 {
    address[] childsLvl1;
    uint slot;
    uint lastChild;
    uint frozenMoneyX3;
  }

  IERC20 public tokenMFS;

  constructor(IERC20 _token, address admin) Referal(admin) {
      /// Set products
      for (uint i = 0; i < 12; i++) {
          products[i] = ((i + 1) % 3 == 0) ? Product.x4 : Product.x3;
      }

      /// Set products prices
      for (uint j = 0; j < 12; j++) {
          prices.push(firstPrice * 2 ** j);
      }

      /// Set token
      tokenMFS = _token;
  }

  function buy(uint lvl) isRegistred external view {
      require(activate[msg.sender][lvl] == false, "This level is already activated");
      // Check if there is enough money

      for (uint i = 0; i < lvl; i++) {
          require(activate[msg.sender][i] == true, "Previous level not activated");
      }

      if (products[lvl] == Product.x3) {
          // updateX3(lvl);
      } else {
        // updateX4(lvl);
      }
  }

  function updateX3(address _child, uint lvl) isRegistred public returns (address) {
    address _parent = getActivateParent(_child, lvl);

    // Activate new lvl
    activate[msg.sender][lvl] = true;

    // Increment lastChild
    structX3 storage _parentStruct = matrixX3[_parent][lvl];
    uint _lastChild = _parentStruct.lastChild;
    _parentStruct.lastChild++;
    _lastChild = _lastChild % 3;
    console.log("Last Child", _lastChild);


    // Last Child
    if (_lastChild == 2) {
      // Check autorecycle
      if (users[_parent].autoReCycle) {
        // transfer token to me
        // transfer token to smart contract
      } else {

        // transfer token to parent
        updateX3(_parent, lvl); // update parents product
      }
      _parentStruct.slot++;
    }

    // First Child
    if (_lastChild == 0) {
      //Check autoUpgrade
      if (users[_parent].autoUpgrade) {
        // transfer token to me
        // transfer token to smart contract
      } else {
        uint _frozen = firstPrice * 2 ** lvl;
        _parentStruct.frozenMoneyX3 += _frozen;
        tokenMFS.transferFrom(msg.sender, address(this), _frozen);
      }
    }

    // Second Child
    if (_lastChild == 1) {
      //Check autoUpgrade
      if (users[_parent].autoUpgrade) {
        // transfer token to me
        // transfer token to smart contract
      } else {
        _parentStruct.frozenMoneyX3 -= firstPrice * 2 ** lvl;
        // transfer money back
        // bue next lvl buy[lvl + 1]
      }
    }

    // Push new child
    matrixX3[_parent][lvl].childsLvl1.push(_child);

    return _parent;
  }

  function getActivateParent(address _child, uint _lvl) internal view returns (address response) {
      address __parent = parent[_child];
      while(true) {
          if (_isActive(__parent, _lvl)) {
              return __parent;
          } else {
              __parent =parent[__parent];
          }
      }
  }

  function _isActive(address _address, uint _lvl) internal view returns(bool) {
      return activate[_address][_lvl];
  }

  function changeAutoReCycle(bool flag) external {
    User storage cUser = users[msg.sender];
    cUser.autoReCycle = flag;
    console.log('Changed auto recycle', users[msg.sender].autoReCycle);
  }

  function changeAutoUpgrade(bool flag) external {
    // check frozen money
    User storage cUser = users[msg.sender];
    cUser.autoUpgrade = flag;
    console.log('Changed auto upgrade', users[msg.sender].autoUpgrade);
  }

}
