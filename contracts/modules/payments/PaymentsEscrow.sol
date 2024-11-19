// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../core/LocoFoodBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LocoFoodEscrow is LocoFoodBase {
    struct EscrowDetails {
        uint256 amount;
        address token;
        uint256 releaseTime;
        bool released;
    }
    
    mapping(bytes32 => EscrowDetails) public escrows;
    
    event EscrowCreated(bytes32 indexed escrowId, uint256 amount, address token);
    event EscrowReleased(bytes32 indexed escrowId, address recipient);
    
    function createEscrow(
        address token,
        uint256 amount,
        uint256 lockPeriod
    ) external payable whenNotPaused nonReentrant returns (bytes32) {
        require(amount > 0, "Invalid amount");
        
        bytes32 escrowId = keccak256(
            abi.encodePacked(
                msg.sender,
                token,
                amount,
                block.timestamp
            )
        );
        
        if (token != address(0)) {
            require(msg.value == 0, "ETH not accepted for token escrows");
            require(
                IERC20(token).transferFrom(msg.sender, address(this), amount),
                "Token transfer failed"
            );
        } else {
            require(msg.value == amount, "Incorrect ETH amount");
        }
        
        escrows[escrowId] = EscrowDetails({
            amount: amount,
            token: token,
            releaseTime: block.timestamp + lockPeriod,
            released: false
        });
        
        emit EscrowCreated(escrowId, amount, token);
        return escrowId;
    }
    
    function releaseEscrow(bytes32 escrowId, address recipient) 
        external 
        whenNotPaused 
        nonReentrant 
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        EscrowDetails storage escrow = escrows[escrowId];
        require(!escrow.released, "Escrow already released");
        require(block.timestamp >= escrow.releaseTime, "Release time not reached");
        
        escrow.released = true;
        
        if (escrow.token == address(0)) {
            payable(recipient).transfer(escrow.amount);
        } else {
            require(
                IERC20(escrow.token).transfer(recipient, escrow.amount),
                "Token transfer failed"
            );
        }
        
        emit EscrowReleased(escrowId, recipient);
    }
}