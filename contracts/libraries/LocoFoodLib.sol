// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "../interfaces/ILocoFood.sol";

library LocoFoodLib {
    uint256 constant REPUTATION_MULTIPLIER = 100;
    uint256 constant MAX_RATING = 5;
    uint256 constant MIN_RATING = 1;
    
    function calculateFee(uint256 amount, uint256 feePercentage) internal pure returns (uint256) {
        return Math.mulDiv(amount, feePercentage, 10000);
    }
    
    function calculatePaymentShares(uint256 amount, uint256 platformFee)
        internal
        pure
        returns (uint256 restaurantShare, uint256 courierShare)
    {
        uint256 remaining = amount - platformFee;
        restaurantShare = Math.mulDiv(remaining, 80, 100); // 80% restaurant
        courierShare = remaining - restaurantShare; // 20% courier
    }
    
    function calculateReputationScore(uint256 currentScore, uint256 newRating)
        internal
        pure
        returns (uint256)
    {
        require(newRating >= MIN_RATING && newRating <= MAX_RATING, "Invalid rating");
        if (currentScore == 0) return newRating * REPUTATION_MULTIPLIER;
        return (currentScore + (newRating * REPUTATION_MULTIPLIER)) / 2;
    }

    function isValidStateTransition(ILocoFood.State current, ILocoFood.State next) 
        internal 
        pure 
        returns (bool) 
    {
        if (current == ILocoFood.State.Created) {
            return next == ILocoFood.State.Confirmed || next == ILocoFood.State.Cancelled;
        }
        if (current == ILocoFood.State.Confirmed) {
            return next == ILocoFood.State.InPreparation || next == ILocoFood.State.Cancelled;
        }
        if (current == ILocoFood.State.InPreparation) {
            return next == ILocoFood.State.ReadyForPickup;
        }
        if (current == ILocoFood.State.ReadyForPickup) {
            return next == ILocoFood.State.InDelivery;
        }
        if (current == ILocoFood.State.InDelivery) {
            return next == ILocoFood.State.Delivered || next == ILocoFood.State.Disputed;
        }
        return false;
    }
}