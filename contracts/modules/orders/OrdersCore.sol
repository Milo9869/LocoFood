// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../core/LocoFoodBase.sol";
import "./LocoFoodDispute.sol";

contract LocoFoodOrders is LocoFoodBase {
    LocoFoodDispute public disputeHandler;
    
    mapping(uint256 => uint256) public orderPreparationTimes;
    mapping(uint256 => uint256) public orderDeliveryTimes;
    
    event DeliveryTimeUpdated(uint256 indexed orderId, uint256 estimatedTime);
    event PreparationTimeUpdated(uint256 indexed orderId, uint256 estimatedTime);
    
    constructor(address _disputeHandler) {
        disputeHandler = LocoFoodDispute(_disputeHandler);
    }
    
    function createOrder(
        address restaurant,
        bytes32 details,
        address paymentToken,
        uint256 amount
    ) external payable whenNotPaused nonReentrant returns (uint256) {
        require(amount >= MIN_ORDER_AMOUNT, "Order amount too low");
        require(restaurants[restaurant].isRegistered, "Restaurant not registered");
        require(restaurants[restaurant].isActive, "Restaurant not active");
        
        uint256 orderId = nextOrderId++;
        
        orders[orderId] = Order({
            id: orderId,
            customer: msg.sender,
            restaurant: restaurant,
            courier: address(0),
            amount: amount,
            timestamp: block.timestamp,
            state: ILocoFood.State.Created,
            isStablecoin: paymentToken != address(0),
            paymentToken: paymentToken,
            details: details,
            disputeId: 0
        });
        
        customerOrders[msg.sender].push(orderId);
        
        // Process payment
        payments.processPayment{value: msg.value}(orderId, paymentToken, amount);
        
        emit OrderCreated(orderId, msg.sender, restaurant, amount, details);
        return orderId;
    }
    
    function updateOrderState(uint256 orderId, ILocoFood.State newState)
        external
        whenNotPaused
        onlyOrderParticipant(orderId)
    {
        Order storage order = orders[orderId];
        ILocoFood.State currentState = order.state;
        
        require(
            LocoFoodLib.isValidStateTransition(currentState, newState),
            "Invalid state transition"
        );
        
        order.state = newState;
        
        if (newState == ILocoFood.State.Delivered) {
            _processDeliveredOrder(orderId);
        }
        
        emit OrderStateChanged(orderId, currentState, newState, msg.sender);
    }
    
    function assignCourier(uint256 orderId, address courier)
        external
        whenNotPaused
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(couriers[courier].isRegistered, "Courier not registered");
        require(couriers[courier].isAvailable, "Courier not available");
        
        Order storage order = orders[orderId];
        require(order.state == ILocoFood.State.ReadyForPickup, "Order not ready for pickup");
        require(order.courier == address(0), "Courier already assigned");
        
        order.courier = courier;
        couriers[courier].isAvailable = false;
    }
    
    function _processDeliveredOrder(uint256 orderId) internal {
        Order storage order = orders[orderId];
        
        // Update metrics
        restaurants[order.restaurant].totalOrders++;
        couriers[order.courier].totalDeliveries++;
        couriers[order.courier].successfulDeliveries++;
        couriers[order.courier].lastDeliveryTime = block.timestamp;
        couriers[order.courier].isAvailable = true;
        
        // Process payments
        payments.releasePayment(orderId);
        
        // Distribute rewards
        rewards.distributeReward(
            order.restaurant,
            ILocoFood.UserType.Restaurant,
            order.amount,
            "ORDER_COMPLETED"
        );
        rewards.distributeReward(
            order.courier,
            ILocoFood.UserType.Courier,
            order.amount,
            "DELIVERY_COMPLETED"
        );
    }
}