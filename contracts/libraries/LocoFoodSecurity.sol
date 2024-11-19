// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library LocoFoodSecurity {
    bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    
    function validateAddress(address account) internal pure {
        require(account != address(0), "Invalid address");
    }
    
    function validateAmount(uint256 amount, uint256 minAmount) internal pure {
        require(amount >= minAmount, "Amount too low");
    }
    
    function validateTimestamp(uint256 timestamp) internal view {
        require(timestamp >= block.timestamp, "Invalid timestamp");
    }
    
    function validateStringLength(string memory str, uint256 maxLength) internal pure {
        require(bytes(str).length <= maxLength, "String too long");
    }
}