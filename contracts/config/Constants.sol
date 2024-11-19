// contracts/config/Constants.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title LocoFood System Constants
 * @notice Définition de toutes les constantes utilisées dans le système LocoFood
 */
library Constants {
    // ====== Frais et Montants Minimaux ======
    
    // Frais de la plateforme
    uint256 constant PLATFORM_FEE_PERCENTAGE = 200; // 2.00%
    uint256 constant REFERRAL_FEE_PERCENTAGE = 50;  // 0.50%
    
    // Montants minimaux
    uint256 constant MIN_ORDER_AMOUNT = 1e16;        // 0.01 ETH/SOL
    uint256 constant MIN_RESTAURANT_STAKE = 1e18;    // 1 ETH/SOL
    uint256 constant MIN_COURIER_STAKE = 5e17;       // 0.5 ETH/SOL
    uint256 constant MIN_DISPUTE_STAKE = 1e17;       // 0.1 ETH/SOL

    // Distribution des frais
    uint256 constant RESTAURANT_SHARE = 8000;        // 80% du montant après frais
    uint256 constant COURIER_SHARE = 2000;           // 20% du montant après frais
    
    // ====== Délais et Timeouts ======
    
    // Délais opérationnels
    uint256 constant ORDER_CONFIRMATION_TIMEOUT = 15 minutes;
    uint256 constant ORDER_PREPARATION_MAX_TIME = 2 hours;
    uint256 constant ORDER_PICKUP_TIMEOUT = 30 minutes;
    uint256 constant DELIVERY_MAX_TIME = 1 hours;
    
    // Délais des litiges
    uint256 constant DISPUTE_EVIDENCE_PHASE = 24 hours;
    uint256 constant DISPUTE_VOTING_PHASE = 48 hours;
    uint256 constant DISPUTE_RESOLUTION_TIMEOUT = 72 hours;
    
    // Délais de gouvernance
    uint256 constant PROPOSAL_VOTING_PERIOD = 3 days;
    uint256 constant PROPOSAL_EXECUTION_DELAY = 24 hours;
    uint256 constant GOVERNANCE_TIMELOCK = 48 hours;

    // ====== Réputation et Scores ======
    
    // Scores initiaux
    uint256 constant INITIAL_REPUTATION_SCORE = 100;
    uint256 constant MAX_REPUTATION_SCORE = 1000;
    
    // Ajustements de réputation
    int256 constant SUCCESSFUL_DELIVERY_BONUS = 5;
    int256 constant QUICK_DELIVERY_BONUS = 10;
    int256 constant LATE_DELIVERY_PENALTY = -5;
    int256 constant DISPUTE_LOST_PENALTY = -20;
    
    // Seuils de réputation
    uint256 constant MIN_ACTIVE_REPUTATION = 50;
    uint256 constant TRUSTED_REPUTATION_THRESHOLD = 800;

    // ====== Récompenses et Staking ======
    
    // Récompenses de base (en tokens LOCO)
    uint256 constant BASE_ORDER_REWARD = 10 ether;        // 10 LOCO
    uint256 constant BASE_DELIVERY_REWARD = 5 ether;      // 5 LOCO
    uint256 constant QUICK_DELIVERY_REWARD = 2 ether;     // 2 LOCO
    uint256 constant DISPUTE_RESOLUTION_REWARD = 3 ether; // 3 LOCO
    
    // Multiplicateurs de récompenses
    uint256 constant TIER1_MULTIPLIER = 110; // 1.1x
    uint256 constant TIER2_MULTIPLIER = 125; // 1.25x
    uint256 constant TIER3_MULTIPLIER = 150; // 1.5x
    
    // Staking
    uint256 constant MIN_STAKING_PERIOD = 30 days;
    uint256 constant MAX_STAKING_PERIOD = 365 days;
    uint256 constant BASE_APR = 500;                  // 5.00% APR
    uint256 constant MAX_APR = 2000;                  // 20.00% APR

    // ====== Limites et Contraintes ======
    
    // Limites système
    uint256 constant MAX_ACTIVE_ORDERS_PER_RESTAURANT = 50;
    uint256 constant MAX_ACTIVE_DELIVERIES_PER_COURIER = 3;
    uint256 constant MAX_DAILY_ORDERS_PER_CUSTOMER = 10;
    uint256 constant MAX_DISPUTES_PER_MONTH = 5;
    
    // Contraintes de jury
    uint256 constant MIN_JURY_SIZE = 3;
    uint256 constant MAX_JURY_SIZE = 11;
    uint256 constant MIN_JURY_STAKE = 100 ether;      // 100 LOCO
    uint256 constant MIN_VOTES_FOR_RESOLUTION = 3;

    // ====== Paramètres de Gouvernance ======
    
    // Seuils de gouvernance
    uint256 constant PROPOSAL_THRESHOLD = 100_000 ether;  // 100,000 LOCO
    uint256 constant QUORUM_THRESHOLD = 400;              // 4.00%
    uint256 constant SUPER_MAJORITY = 6000;               // 60.00%
    
    // Délais de governance
    uint256 constant GOVERNANCE_VOTING_DELAY = 1 days;
    uint256 constant GOVERNANCE_VOTING_PERIOD = 1 weeks;
    uint256 constant GOVERNANCE_MIN_TIMELOCK = 2 days;

    // ====== Limites Techniques ======
    
    // Gaz et performance
    uint256 constant MAX_BATCH_SIZE = 50;
    uint256 constant MAX_ARRAY_LENGTH = 100;
    uint256 constant MAX_STRING_LENGTH = 200;
    uint256 constant CHAINLINK_GAS_LIMIT = 200000;

    // Versions et mises à jour
    uint256 constant CURRENT_VERSION = 100;           // v1.0.0
    uint256 constant MIN_SUPPORTED_VERSION = 100;     // v1.0.0
    bytes32 constant CURRENT_DOMAIN_SEPARATOR_VERSION = keccak256("1");
}