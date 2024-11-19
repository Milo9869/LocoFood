// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../core/LocoFoodBase.sol";
import "./LocoFoodToken.sol";

contract LocoFoodRewards is LocoFoodBase {
    LocoFoodToken public immutable locoToken;
    
    struct RewardTier {
        uint256 minOrders;
        uint256 multiplier;
        uint256 maxReward;
    }
    
    mapping(ILocoFood.UserType => RewardTier[]) public rewardTiers;
    mapping(address => uint256) public lastRewardTime;
    
    uint256 public constant BASE_ORDER_REWARD = 10 * 10**18;    // 10 tokens
    uint256 public constant BASE_DELIVERY_REWARD = 5 * 10**18;  // 5 tokens
    uint256 public constant QUICK_DELIVERY_BONUS = 2 * 10**18;  // 2 tokens
    
    constructor(address _locoToken) {
        locoToken = LocoFoodToken(_locoToken);
        _initializeRewardTiers();
    }
    
    function _initializeRewardTiers() internal {
        // Customer tiers
        rewardTiers[ILocoFood.UserType.Customer].push(RewardTier(10, 110, 15 * 10**18));
        rewardTiers[ILocoFood.UserType.Customer].push(RewardTier(50, 125, 20 * 10**18));
        rewardTiers[ILocoFood.UserType.Customer].push(RewardTier(100, 150, 25 * 10**18));
        
        // Restaurant tiers
        rewardTiers[ILocoFood.UserType.Restaurant].push(RewardTier(100, 110, 20 * 10**18));
        rewardTiers[ILocoFood.UserType.Restaurant].push(RewardTier(500, 125, 30 * 10**18));
        rewardTiers[ILocoFood.UserType.Restaurant].push(RewardTier(1000, 150, 40 * 10**18));
        
        // Courier tiers
        rewardTiers[ILocoFood.UserType.Courier].push(RewardTier(100, 110, 10 * 10**18));
        rewardTiers[ILocoFood.UserType.Courier].push(RewardTier(500, 125, 15 * 10**18));
        rewardTiers[ILocoFood.UserType.Courier].push(RewardTier(1000, 150, 20 * 10**18));
    }
    
    function calculateReward(
        address user,
        ILocoFood.UserType userType,
        uint256 amount,
        bool isQuickDelivery
    ) public view returns (uint256) {
        uint256 baseReward = userType == ILocoFood.UserType.Courier ? 
            BASE_DELIVERY_REWARD : BASE_ORDER_REWARD;
            
        uint256 orderCount = _getOrderCount(user, userType);
        RewardTier[] storage tiers = rewardTiers[userType];
        
        for (uint256 i = tiers.length; i > 0; i--) {
            if (orderCount >= tiers[i-1].minOrders) {
                baseReward = (baseReward * tiers[i-1].multiplier) / 100;
                if (baseReward > tiers[i-1].maxReward) {
                    baseReward = tiers[i-1].maxReward;
                }
                break;
            }
        }
        
        if (isQuickDelivery && userType == ILocoFood.UserType.Courier) {
            baseReward += QUICK_DELIVERY_BONUS;
        }
        
        return baseReward;
    }
    
    function distributeReward(
        address user,
        ILocoFood.UserType userType,
        uint256 amount,
        string calldata rewardType
    ) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        bool isQuickDelivery = keccak256(bytes(rewardType)) == keccak256(bytes("QUICK_DELIVERY"));
        uint256 reward = calculateReward(user, userType, amount, isQuickDelivery);
        
        lastRewardTime[user] = block.timestamp;
        locoToken.mint(user, reward);
        
        emit RewardDistributed(user, userType, reward, rewardType);
    }
    
    function _getOrderCount(address user, ILocoFood.UserType userType) internal view returns (uint256) {
        if (userType == ILocoFood.UserType.Restaurant) {
            return restaurants[user].totalOrders;
        } else if (userType == ILocoFood.UserType.Courier) {
            return couriers[user].totalDeliveries;
        } else {
            return customerOrders[user].length;
        }
    }
}