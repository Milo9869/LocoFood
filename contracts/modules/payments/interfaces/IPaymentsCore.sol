// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IPaymentsCore {
    function processPayment(
        uint256 orderId,
        address paymentToken,
        uint256 amount
    ) external payable;

    function releasePayment(uint256 orderId) external;
    
    function refundPayment(uint256 orderId) external;
    
    function withdrawPlatformFees(address token) external;
}