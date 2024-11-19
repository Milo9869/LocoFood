// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../core/LocoFoodBase.sol";

contract LocoFoodRestaurant is LocoFoodBase {
    uint256 public constant MINIMUM_STAKE = 0.1 ether;
    
    mapping(address => uint256) public restaurantStakes;
    
    event MenuUpdated(address indexed restaurant, bytes32 newMenuHash);
    event StakeDeposited(address indexed restaurant, uint256 amount);
    event StakeWithdrawn(address indexed restaurant, uint256 amount);
    
    function registerRestaurant(bytes32 details) external payable whenNotPaused nonReentrant {
        require(!restaurants[msg.sender].isRegistered, "Already registered");
        require(msg.value >= MINIMUM_STAKE, "Insufficient stake");
        
        restaurants[msg.sender] = Restaurant({
            isRegistered: true,
            totalOrders: 0,
            reputationScore: MIN_REPUTATION_SCORE,
            details: details,
            isActive: true,
            lastUpdateTime: block.timestamp
        });
        
        restaurantStakes[msg.sender] = msg.value;
        
        emit RestaurantRegistered(msg.sender, details, block.timestamp);
        emit StakeDeposited(msg.sender, msg.value);
    }
    
    function updateRestaurantDetails(bytes32 details) 
        external 
        whenNotPaused 
        onlyRegisteredRestaurant 
    {
        restaurants[msg.sender].details = details;
        restaurants[msg.sender].lastUpdateTime = block.timestamp;
        
        emit MenuUpdated(msg.sender, details);
    }
    
    function deactivateRestaurant() 
        external 
        onlyRegisteredRestaurant 
    {
        restaurants[msg.sender].isActive = false;
    }
    
    function reactivateRestaurant() 
        external 
        whenNotPaused 
    {
        require(restaurants[msg.sender].isRegistered, "Not registered");
        require(restaurantStakes[msg.sender] >= MINIMUM_STAKE, "Insufficient stake");
        
        restaurants[msg.sender].isActive = true;
    }
    
    function withdrawStake(uint256 amount) 
        external 
        onlyRegisteredRestaurant 
        nonReentrant 
    {
        require(amount <= restaurantStakes[msg.sender], "Insufficient stake balance");
        require(
            restaurantStakes[msg.sender] - amount >= MINIMUM_STAKE || 
            !restaurants[msg.sender].isActive,
            "Must maintain minimum stake"
        );
        
        restaurantStakes[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        
        emit StakeWithdrawn(msg.sender, amount);
    }
}