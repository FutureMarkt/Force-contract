// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../Boost.sol";

contract S301 is Boost {

    uint[10] internal linesBoost;

    mapping(address => mapping(uint => mapping(uint => uint))) lastChildBoost; // user -> lvl -> line -> last child
    mapping(address => mapping(uint => mapping(uint => address[]))) childsBoost; // user -> lvl -> line -> addresses

    mapping(address => mapping(uint => bool)) public activeBoost; // user -> lvl -> is active

    // + Определяем родителя
    // - Узнаем куда в структуре родителя нужно встать.
    // -- Узнаем родителя внутри этой структуры и идем по каскаду на верх.
    // +++ Узнаем свободную линию которая свободна
    // --- Узнаем родителя свободного места
    // ---- Если линия == 0, то действующий родитель и есть свободное место
    // ---- Если ЛС == 0, значит первый родитель последнего слота.
    // ---- Если 0/1 - то получаем 1 руководителя верхнего уровня последнего слота,
    //      если 2/3 - то получаем 2 руководителя
    //      если 4/5 - то получаем 3 руководителя
    //      если 6/7 - то получаем 4 руководителя
    //      Формула нынешний ЛС / 2 взять целое и добавить 1, потом вычесть slot * 2 **(линия + 1)


    constructor(){
        linesBoost[0] = linesBoost[5] = 3;

        // set owner activation
        for (uint i = 0; i < 10; i++) {
            activeBoost[msg.sender][i] = true;
        }

        // set first owner struct S30 - lvl 1
        _setEmptyUsers(msg.sender, 0, linesBoost[0]);

        // set first owner struct S30 - lvl 6
        _setEmptyUsers(msg.sender, 5, linesBoost[0]);
    }

    function buyBoost(uint _lvl) isRegistred public {
        uint _lines = linesBoost[_lvl];
        uint _lastChild = lastChildBoost[msg.sender][_lvl][0];

        require(_lvl < 10, "Level is incorrect");
        // Struct is empty
        if (_lastChild == 0) _setEmptyUsers(owner(), _lvl, _lines);

        // Get Active Parent
        address _parent = _getActiveParent(msg.sender, _lvl);

        // Looking for level, where slot is empty
        uint _branch = _lookingForBranch(msg.sender, _lvl);
        // address _cascadeGenesis = _cascadeGenesis(_parent, _lvl, _branch);

        // Run cascade
        // _cascade(_parent, _lvl);
    }

    // function _cascade(address _parent, uint _lvl) internal {
        
    // }

    /*function _cascadeGenesis(address _parent, uint _lvl, uint _branch) internal returns (address) {
        uint _lastChild = lastChildBoost[msg.sender][_lvl][_branch];
        address _genesis;
        // If last child == 0, then we should get first address on upper line
        if (_lastChild == 0) {
            _genesis = childsBoost[msg.sender][_lvl][_branch - 1][0];
        }

        uint _position = _lastChild / 2 - slot * 2 ** _branch;
        if(_lastChild != 0) _lastChild--;
        _genesis = childsBoost[msg.sender][_lvl][_lastChild];
        return _genesis;
    }*/

    function _lookingForBranch(address _user, uint _lvl) view  internal returns(uint) {
        uint _lastChild;

        for (uint i = 0; i < linesBoost[_lvl]; i++) {
            _lastChild = lastChildBoost[_user][_lvl][i];
            if (_lastChild % 2 ** (i + 1) != 0 || _lastChild == 0) return i;
        }
        return 0; // if all spots are fill  
        
    }

    // function updateS30 (address _child, uint _lvl) internal {

    // }

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