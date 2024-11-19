// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../base/LocoFoodStorage.sol";

interface ILocoFoodCore {
    // System management
    function initialize(
        address paymentContract,
        address rewardContract, 
        address governanceContract
    ) external;
    
    function updateSystemAddresses(
        address newPayments,
        address newRewards,
        address newGovernance
    ) external;
    
    function getSystemAddresses() external view returns (
        address paymentsAddress,
        address rewardsAddress,
        address governanceAddress
    );
}