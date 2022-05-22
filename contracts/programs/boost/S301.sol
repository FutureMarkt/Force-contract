// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../Boost.sol";

contract S301 is Boost {

    uint public linesS30;
    uint[10] internal linesBoost;

    mapping(address => mapping(uint => mapping(uint => uint))) lastChildBoost; // user -> lvl -> line -> last child
    mapping(address => mapping(uint => mapping(uint => address[]))) childsBoost; // user -> lvl -> line -> addresses

    mapping(address => mapping(uint => bool)) public activeBoost; // user -> lvl -> is active


    constructor(){
        linesS30 = 2;
        linesBoost[0] = linesBoost[5] = 2;

        // set owner activation
        for (uint i = 0; i < 10; i++) {
            activeBoost[msg.sender][i] = true;
        }

        // set first owner struct S30 - lvl 1
        _setEmptyUsers(msg.sender, 0, linesS30);

        // set first owner struct S30 - lvl 6
        _setEmptyUsers(msg.sender, 5, linesS30);
    }

    function buyBoost(uint _lvl) isRegistred public {
        uint _lines = linesBoost[_lvl];
        uint _lastChild = lastChildBoost[msg.sender][_lvl][0];

        require(_lvl < 10, "Level is ");
        // Struct is empty
        if (_lastChild == 0) _setEmptyUsers(owner(), _lvl, _lines);

        // Get Active Parent
        address _parent = _getActiveParent(msg.sender, _lvl);

        // Looking for level, where slot is empty
        uint _branch = _lookingForBranch(msg.sender, _lvl);
    }

    function _lookingForBranch(address _user, uint _lvl) internal returns(uint) {
        uint _lastChild;

        for (uint i = 0; i < linesBoost[_lvl]; i++) {
            _lastChild = lastChildBoost[_user][_lvl][i];
            if (_lastChild % 2 ** (i + 1) == 0 || (i == 0 && _lastChild == 0)) return i;
        }       
    }

    function updateS30 (address _child, uint _lvl) internal {

    }

    function _getActiveParent(address _child, uint _lvl) view internal returns (address _parent) {
        address _parent = parent[_child];
        while(true) {
            if(activeBoost[_parent][_lvl]) {
                return _parent;
            } else {
                _parent = parent[_parent];
            }
        }
    }

    function _setEmptyUsers(address _user, uint _lvl, uint _lines) internal {
        for(uint i = 0; i < _lines; i++){
            for(uint j = 0; j < i * 2 ** (i +1); j++){
                childsBoost[_user][_lvl][i].push(address(0x0));
            }
        }
    }
}