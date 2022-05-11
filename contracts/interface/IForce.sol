// SPDX-License-Identifier:  MIT
pragma solidity >=0.7.0 <0.9.0;

interface IForce {

  /************
   * Referals *
   ************/

  /**
   * @dev New User Registration
   */
  function registration(address _parent) external;

  /**
   * @dev Return your parent
   *
   * Returns address your parent
   */
  function getParent() view external returns(address);

  /**
   * @dev Return your childes
   *
   * Returns an array of addresses
   */
  function getChilds() view external returns(address[] memory);

  /******
   * S6 *
   ******/

   /**
    * @dev Buy Classic product. This function itself define product S3 or S6.
    */
   function buy(uint lvl) external;

   /******
    * Main *
    ******/

    /**
     * @dev Change autorecycle flag
     */
    function changeAutoReCycle(bool flag) external;

    /**
     * @dev Change autoupgrade flag
     */
    function changeAutoUpgrade(bool flag) external;
}
