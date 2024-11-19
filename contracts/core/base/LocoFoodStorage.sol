// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/ILocoFood.sol";
import "../interfaces/ILocoFoodPayments.sol";
import "../interfaces/ILocoFoodRewards.sol";

contract LocoFoodStorage is AccessControl {
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

    // State variables
    bool internal initialized;
    ILocoFoodPayments internal payments;
    ILocoFoodRewards internal rewards;
    address internal governance;

    mapping(uint256 => Order) internal orders;
    mapping(address => Restaurant) internal restaurants;
    mapping(address => Courier) internal couriers;
    mapping(address => uint256[]) internal customerOrders;
    mapping(uint256 => Dispute) internal disputes;

    uint256 internal nextOrderId = 1;
    uint256 internal nextDisputeId = 1;
}