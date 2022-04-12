// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract Forsage {

  modifier isRegistred {
    require(parent[msg.sender] != address(0), "You are not registred");
    _;
  }

  struct User {
    bool autoReCycle;
    bool autoUpgrade;
  }

  mapping(address => User) public users;
  mapping(address => address) public parent;
  mapping(address => address[]) public childs;

  mapping(address => mapping(uint => bool)) public activate; // user -> lvl -> active

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



  constructor(address admin) {
      /// Set products
      for (uint i = 0; i < 12; i++) {
          products[i] = ((i + 1) % 3 == 0) ? Product.x4 : Product.x3;
      }

      /// Set products prices
      for (uint j = 0; j < 12; j++) {
          prices.push(firstPrice * 2 ** j);
      }

      /// Set first User
      parent[admin] = admin;
      users[msg.sender] = User(false,false);
      for (uint i = 0; i < 12; i++) {
          activate[admin][i] = true;
      }
  }

  function registration(address ref) external {
      require(msg.sender != ref, "You can`t be referal");

      parent[msg.sender] = ref;
      childs[ref].push(msg.sender);
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

  function updateX3(address _child, uint lvl) public returns (address) {
    address _parent = getActivateParent(_child, lvl);

    // Activate new lvl
    //active[_child]

    // Increment lastChild
    structX3 storage _parentStruct = matrixX3[_parent][lvl];
    uint _lastChild = _parentStruct.lastChild;
    _parentStruct.lastChild++;
    _lastChild = _lastChild % 3;
    console.log("mod lastChild", _lastChild);


    // Last Child
    if (_lastChild == 2) {
      // Check autorecycle
      if (users[_parent].autoReCycle) {
        // transfer token to me
        // transfer token to smart contract
      } else {

        // transfer token to parent
        updateX3(_parent, lvl);
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
        _parentStruct.frozenMoneyX3 += firstPrice * 2 ** lvl;
        // transfer to smart contract firstPrice * 2 ** lvl
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
