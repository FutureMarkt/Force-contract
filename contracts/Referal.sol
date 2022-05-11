// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Core.sol";

abstract contract Referal is ForsageCore {

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

  constructor(){

      /// Set first User
      parent[msg.sender] = msg.sender;
      users[msg.sender] = User(false,false);
      for (uint i = 0; i < 12; i++) {
          activate[msg.sender][i] = true;
      }
  }

  function registration(address _parent) external {
      require(msg.sender != _parent, "You can`t be referal");

      parent[msg.sender] = _parent;
      childs[_parent].push(msg.sender);
  }

  function getParent() view external returns(address) {
    return parent[msg.sender];
  }

  function getChilds() view external returns(address[] memory) {
    return childs[msg.sender];
  }

  function _isActive(address _address, uint _lvl) internal view returns(bool) {
      return activate[_address][_lvl];
  }

}
