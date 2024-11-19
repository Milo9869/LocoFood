// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../core/LocoFoodBase.sol";
import "./LocoFoodToken.sol";

contract LocoFoodStaking is LocoFoodBase {
    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 lastRewardTime;
    }
    
    LocoFoodToken public immutable locoToken;
    
    uint256 public constant MIN_STAKE_DURATION = 30 days;
    uint256 public constant MAX_STAKE_DURATION = 365 days;
    uint256 public constant BASE_APR = 500; // 5%
    uint256 public constant MAX_APR = 2000; // 20%
    
    mapping(address => StakeInfo) public stakes;
    
    constructor(address _locoToken) {
        locoToken = LocoFoodToken(_locoToken);
    }
    
    function stake(uint256 amount, uint256 duration) external whenNotPaused nonReentrant {
        require(amount > 0, "Invalid amount");
        require(
            duration >= MIN_STAKE_DURATION && 
            duration <= MAX_STAKE_DURATION, 
            "Invalid duration"
        );
        
        require(
            locoToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        
        stakes[msg.sender] = StakeInfo({
            amount: amount,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            lastRewardTime: block.timestamp
        });
    }
    
    function unstake() external nonReentrant {
        StakeInfo storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.amount > 0, "No stake found");
        require(block.timestamp >= stakeInfo.endTime, "Stake still locked");
        
        uint256 reward = _calculateReward(msg.sender);
        uint256 total = stakeInfo.amount + reward;
        
        delete stakes[msg.sender];
        
        require(
            locoToken.transfer(msg.sender, total),
            "Transfer failed"
        );
    }
    
    function _calculateReward(address staker) internal view returns (uint256) {
        StakeInfo storage stakeInfo = stakes[staker];
        uint256 duration = stakeInfo.endTime - stakeInfo.startTime;
        
        uint256 apr = BASE_APR + (
            (duration - MIN_STAKE_DURATION) * 
            (MAX_APR - BASE_APR) / 
            (MAX_STAKE_DURATION - MIN_STAKE_DURATION)
        );
        
        uint256 timeElapsed = block.timestamp - stakeInfo.lastRewardTime;
        return (stakeInfo.amount * apr * timeElapsed) / (365 days * 10000);
    }
}