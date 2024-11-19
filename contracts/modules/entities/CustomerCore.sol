// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../core/LocoFoodBase.sol";

contract LocoFoodCustomer is LocoFoodBase {
    struct CustomerProfile {
        uint256 totalOrders;
        uint256 cancelledOrders;
        uint256 disputedOrders;
        uint256 lastOrderTimestamp;
        bool isBlacklisted;
    }
    
    mapping(address => CustomerProfile) public customerProfiles;
    
    event CustomerBlacklisted(address indexed customer, bool status);
    event CustomerProfileUpdated(address indexed customer);
    
    modifier notBlacklisted() {
        require(!customerProfiles[msg.sender].isBlacklisted, "Customer is blacklisted");
        _;
    }
    
    function createCustomerProfile() external {
        require(customerProfiles[msg.sender].totalOrders == 0, "Profile already exists");
        
        customerProfiles[msg.sender] = CustomerProfile({
            totalOrders: 0,
            cancelledOrders: 0,
            disputedOrders: 0,
            lastOrderTimestamp: 0,
            isBlacklisted: false
        });
        
        emit CustomerProfileUpdated(msg.sender);
    }
    
    function updateCustomerMetrics(
        address customer,
        bool isDispute,
        bool isCancellation
    ) 
        external 
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        CustomerProfile storage profile = customerProfiles[customer];
        
        profile.totalOrders++;
        if (isDispute) profile.disputedOrders++;
        if (isCancellation) profile.cancelledOrders++;
        profile.lastOrderTimestamp = block.timestamp;
        
        // Auto-blacklist logic
        if (
            (profile.disputedOrders * 100) / profile.totalOrders > 20 || // >20% disputed orders
            (profile.cancelledOrders * 100) / profile.totalOrders > 30    // >30% cancelled orders
        ) {
            profile.isBlacklisted = true;
            emit CustomerBlacklisted(customer, true);
        }
        
        emit CustomerProfileUpdated(customer);
    }
    
    function setBlacklistStatus(address customer, bool status) 
        external 
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        customerProfiles[customer].isBlacklisted = status;
        emit CustomerBlacklisted(customer, status);
    }
    
    function getCustomerProfile(address customer) 
        external 
        view 
        returns (CustomerProfile memory) 
    {
        return customerProfiles[customer];
    }
}