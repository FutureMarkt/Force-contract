// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./programs/S6.sol";

contract Forsage is S6 {

  constructor(address _token) Ownable() {
    /// Set token
    tokenMFS = IERC20(_token);
  }

  function changeAutoReCycle(bool flag) external {
    User storage cUser = users[msg.sender];
    cUser.autoReCycle = flag;
    console.log('Changed auto recycle', users[msg.sender].autoReCycle);
  }

  function changeAutoUpgrade(bool flag) external {
    // check frozen money. If froaen not empty - 25 to sc / 75 to msg.sender
    uint _price;
    for (uint i =0; i < 12; i++){
      structS3 storage _structure = matrixS3[msg.sender][i];
      if (_structure.frozenMoneyS3 != 0) {
        _price = prices[i];
        _structure.frozenMoneyS3 = 0;
        _sendDevisionMoney(msg.sender, _price, 25);
      }
    }

    User storage cUser = users[msg.sender];
    cUser.autoUpgrade = flag;
    console.log('Changed auto upgrade', users[msg.sender].autoUpgrade);
  }

}
