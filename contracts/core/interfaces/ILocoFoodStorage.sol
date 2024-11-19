// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../interfaces/ILocoFood.sol";

interface ILocoFoodStorage {
    struct Order {
        uint256 id;
        address customer;
        address restaurant;
        address courier;
        uint256 amount;
        uint256 timestamp;
        ILocoFood.State state;
        bool isStablecoin;
        address paymentToken;
        bytes32 details;
        uint256 disputeId;
    }

    struct Restaurant {
        bool isRegistered;
        uint256 totalOrders;
        uint256 reputationScore;
        bytes32 details;
        bool isActive;
        uint256 lastUpdateTime;
    }

    struct Courier {
        bool isRegistered;
        uint256 totalDeliveries;
        uint256 reputationScore;
        bool isAvailable;
        uint256 lastDeliveryTime;
        uint256 successfulDeliveries; 
    }

    struct Dispute {
        uint256 orderId;
        address initiator;
        string reason;
        bool resolved;
        uint256 creationTime;
    }
}