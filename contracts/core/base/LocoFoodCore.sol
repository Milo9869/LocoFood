// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../interfaces/ILocoFood.sol";
import "./LocoFoodStorage.sol";
import "./LocoFoodBase.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract LocoFoodCore is LocoFoodBase, ReentrancyGuard {
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function initialize(
        address paymentContract,
        address rewardContract,
        address governanceContract
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!initialized, "Already initialized");
        
        payments = ILocoFoodPayments(paymentContract);
        rewards = ILocoFoodRewards(rewardContract);
        governance = address(governanceContract);
        
        initialized = true;
    }

    function updateSystemAddresses(
        address newPayments,
        address newRewards,
        address newGovernance
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if(newPayments != address(0)) payments = ILocoFoodPayments(newPayments);
        if(newRewards != address(0)) rewards = ILocoFoodRewards(newRewards);
        if(newGovernance != address(0)) governance = newGovernance;
    }

    function getSystemAddresses() external view returns (
        address paymentsAddress,
        address rewardsAddress,
        address governanceAddress
    ) {
        return (address(payments), address(rewards), governance);
    }
}