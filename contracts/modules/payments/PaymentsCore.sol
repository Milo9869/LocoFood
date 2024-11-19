// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../core/LocoFoodBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LocoFoodPayments is LocoFoodBase {
    struct PaymentEscrow {
        uint256 amount;
        address paymentToken;
        bool released;
    }
    
    mapping(uint256 => PaymentEscrow) public escrows;
    mapping(address => uint256) public platformFeeBalance;
    
    function processPayment(
        uint256 orderId,
        address paymentToken,
        uint256 amount
    ) external payable whenNotPaused nonReentrant {
        require(amount > 0, "Invalid amount");
        
        if (paymentToken != address(0)) {
            require(msg.value == 0, "ETH not accepted for token payments");
            require(
                IERC20(paymentToken).transferFrom(msg.sender, address(this), amount),
                "Token transfer failed"
            );
        } else {
            require(msg.value == amount, "Incorrect ETH amount");
        }
        
        escrows[orderId] = PaymentEscrow({
            amount: amount,
            paymentToken: paymentToken,
            released: false
        });
        
        emit PaymentProcessed(orderId, msg.sender, paymentToken, amount);
    }
    
    function releasePayment(uint256 orderId) external whenNotPaused nonReentrant {
        PaymentEscrow storage escrow = escrows[orderId];
        Order storage order = orders[orderId];
        
        require(!escrow.released, "Payment already released");
        require(order.state == ILocoFood.State.Delivered, "Order not delivered");
        
        uint256 platformFee = LocoFoodLib.calculateFee(escrow.amount, PLATFORM_FEE);
        (uint256 restaurantShare, uint256 courierShare) = LocoFoodLib.calculatePaymentShares(
            escrow.amount, 
            platformFee
        );
        
        platformFeeBalance[escrow.paymentToken] += platformFee;
        
        if (escrow.paymentToken == address(0)) {
            payable(order.restaurant).transfer(restaurantShare);
            payable(order.courier).transfer(courierShare);
        } else {
            IERC20 token = IERC20(escrow.paymentToken);
            require(
                token.transfer(order.restaurant, restaurantShare) &&
                token.transfer(order.courier, courierShare),
                "Token transfer failed"
            );
        }
        
        escrow.released = true;
        
        emit PaymentReleased(
            orderId,
            order.restaurant,
            order.courier,
            restaurantShare,
            courierShare,
            platformFee
        );
    }
    
    function refundPayment(uint256 orderId) external whenNotPaused nonReentrant {
        PaymentEscrow storage escrow = escrows[orderId];
        Order storage order = orders[orderId];
        
        require(!escrow.released, "Payment already released");
        require(
            order.state == ILocoFood.State.Cancelled ||
            order.state == ILocoFood.State.Disputed,
            "Invalid order state for refund"
        );
        
        escrow.released = true;
        
        if (escrow.paymentToken == address(0)) {
            payable(order.customer).transfer(escrow.amount);
        } else {
            require(
                IERC20(escrow.paymentToken).transfer(order.customer, escrow.amount),
                "Token transfer failed"
            );
        }
        
        emit PaymentRefunded(orderId, order.customer, escrow.amount);
    }
    
    function withdrawPlatformFees(address token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 amount = platformFeeBalance[token];
        require(amount > 0, "No fees to withdraw");
        
        platformFeeBalance[token] = 0;
        
        if (token == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            require(
                IERC20(token).transfer(msg.sender, amount),
                "Token transfer failed"
            );
        }
    }
}