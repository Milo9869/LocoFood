// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../core/LocoFoodBase.sol";

contract LocoFoodCourier is LocoFoodBase {
    struct CourierMetrics {
        uint256 totalDistance;
        uint256 averageDeliveryTime;
        uint256 totalEarnings;
    }
    
    mapping(address => CourierMetrics) public courierMetrics;
    
    event CourierStatusChanged(address indexed courier, bool isAvailable);
    event DeliveryMetricsUpdated(
        address indexed courier, 
        uint256 distance,
        uint256 deliveryTime
    );
    
    function registerCourier() external whenNotPaused {
        require(!couriers[msg.sender].isRegistered, "Already registered");
        
        couriers[msg.sender] = Courier({
            isRegistered: true,
            totalDeliveries: 0,
            reputationScore: MIN_REPUTATION_SCORE,
            isAvailable: true,
            lastDeliveryTime: 0,
            successfulDeliveries: 0
        });
        
        emit CourierRegistered(msg.sender, block.timestamp);
    }
    
    function setAvailability(bool _isAvailable) 
        external 
        whenNotPaused 
        onlyRegisteredCourier 
    {
        couriers[msg.sender].isAvailable = _isAvailable;
        emit CourierStatusChanged(msg.sender, _isAvailable);
    }
    
    function updateDeliveryMetrics(
        uint256 orderId,
        uint256 distance,
        uint256 deliveryTime
    ) 
        external 
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        Order storage order = orders[orderId];
        require(order.courier != address(0), "No courier assigned");
        
        CourierMetrics storage metrics = courierMetrics[order.courier];
        
        metrics.totalDistance += distance;
        metrics.averageDeliveryTime = (
            (metrics.averageDeliveryTime * couriers[order.courier].successfulDeliveries) + 
            deliveryTime
        ) / (couriers[order.courier].successfulDeliveries + 1);
        
        emit DeliveryMetricsUpdated(order.courier, distance, deliveryTime);
    }
    
    function getCourierMetrics(address courier) 
        external 
        view 
        returns (
            uint256 totalDeliveries,
            uint256 reputationScore,
            uint256 totalDistance,
            uint256 averageDeliveryTime,
            uint256 totalEarnings
        ) 
    {
        Courier storage courierData = couriers[courier];
        CourierMetrics storage metrics = courierMetrics[courier];
        
        return (
            courierData.totalDeliveries,
            courierData.reputationScore,
            metrics.totalDistance,
            metrics.averageDeliveryTime,
            metrics.totalEarnings
        );
    }
}