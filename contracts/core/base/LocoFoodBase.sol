// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./LocoFoodStorage.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "../libraries/LocoFoodLib.sol";

contract LocoFoodBase is LocoFoodStorage, Pausable {
    using LocoFoodLib for uint256;

    // Constants
    uint256 public constant MIN_ORDER_AMOUNT = 1e16; // 0.01 ETH
    uint256 public constant PLATFORM_FEE = 200; // 2%
    uint256 public constant DISPUTE_TIMEOUT = 3 days;
    uint256 public constant MIN_REPUTATION_SCORE = 100;

    // Events
    event LogBaseEvent(string message);
    event SystemAddressUpdated(string addressType, address newAddress);

    // Modifiers
    modifier onlyRegisteredRestaurant() {
        require(restaurants[msg.sender].isRegistered, "Not a registered restaurant");
        require(restaurants[msg.sender].isActive, "Restaurant is not active");
        _;
    }

    modifier onlyRegisteredCourier() {
        require(couriers[msg.sender].isRegistered, "Not a registered courier");
        require(couriers[msg.sender].isAvailable, "Courier is not available");
        _;
    }

    modifier onlyOrderParticipant(uint256 orderId) {
        Order storage order = orders[orderId];
        require(
            msg.sender == order.customer ||
            msg.sender == order.restaurant ||
            msg.sender == order.courier,
            "Not order participant"
        );
        _;
    }

    modifier whenInitialized() {
        require(initialized, "Contract not initialized");
        _;
    }

    function _checkOrderState(uint256 orderId, ILocoFood.State expectedState) internal view {
        require(orders[orderId].state == expectedState, "Invalid order state");
    }

    function _updateReputation(
        address user,
        ILocoFood.UserType userType,
        uint256 rating
    ) internal {
        uint256 oldScore;
        uint256 newScore;

        if (userType == ILocoFood.UserType.Restaurant) {
            oldScore = restaurants[user].reputationScore;
            newScore = LocoFoodLib.calculateReputationScore(oldScore, rating);
            restaurants[user].reputationScore = newScore;
        } else if (userType == ILocoFood.UserType.Courier) {
            oldScore = couriers[user].reputationScore;
            newScore = LocoFoodLib.calculateReputationScore(oldScore, rating);
            couriers[user].reputationScore = newScore;
        }

        emit ReputationUpdated(user, userType, oldScore, newScore);
    }
}