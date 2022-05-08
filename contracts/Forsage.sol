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
    uint frozenMoneyS3;
  }

  IERC20 public tokenMFS;

  constructor(address admin, IERC20 _token) Referal(admin) {
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

  function buy(uint lvl) isRegistred external {
      require(activate[msg.sender][lvl] == false, "This level is already activated");
      // Check if there is enough money

      for (uint i = 0; i < lvl; i++) {
          require(activate[msg.sender][i] == true, "Previous level not activated");
      }

      if (products[lvl] == Product.x3) {
          updateX3(msg.sender, lvl);
      } else {
        // updateX4(lvl);
      }

      // Activate new lvl
      activate[msg.sender][lvl] = true;
  }

  function updateX3(address _child, uint lvl) isRegistred public returns (address) {
    address _parent = getActivateParent(_child, lvl);

    // Increment lastChild
    structX3 storage _parentStruct = matrixX3[_parent][lvl];
    uint _lastChild = _parentStruct.lastChild;
    _parentStruct.lastChild++;
    _lastChild = _lastChild % 3;
    console.log("Last Child", _lastChild);

    // Get price
    uint _price = prices[lvl];
    console.log('Price', _price);


    // Last Child
    if (_lastChild == 2) {
      // Check autorecycle
      if (users[_parent].autoReCycle) {
        _sendDevisionMoney(_parent, _price, 40);
      } else {
        tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer token to parent
        updateX3(_parent, lvl); // update parents product
      }
      _parentStruct.slot++;
    }

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
        tokenMFS.transfer(_parent, _price); // transfer frozen money
        tokenMFS.transferFrom(msg.sender, _parent, _price); // transfer money to parent
        buy((lvl + 1)); // bue next lvl buy[lvl + 1]
      }
    }

    // Push new child
    matrixX3[_parent][lvl].childsLvl1.push(_child);

    return _parent;
  }

  function _sendDevisionMoney(address _parent, uint _price, uint _percent) internal {
    uint amoutSC = _price * _percent / 100;
    tokenMFS.transferFrom(msg.sender, _parent, (_price - amoutSC)); // transfer token to me
    tokenMFS.transferFrom(msg.sender, address(this), amoutSC); // transfer token to smart contract
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
    // check frozen money. If froaen not empty - 25 to sc / 75 to msg.sender
    User storage cUser = users[msg.sender];
    cUser.autoUpgrade = flag;
    console.log('Changed auto upgrade', users[msg.sender].autoUpgrade);
  }

}
