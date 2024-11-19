// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Enums.sol";

library DataTypes {
    // Structure pour les paramètres d'une commande
    struct OrderParams {
        address restaurant;      // Adresse du restaurant
        bytes32 menuItemsHash;   // Hash des items commandés
        address paymentToken;    // Token utilisé pour le paiement
        uint256 amount;          // Montant total
        string deliveryAddress;  // Adresse de livraison (encrypted IPFS hash)
        uint256 expectedDeliveryTime; // Temps de livraison estimé
    }
    
    // Structure pour la gestion des litiges
    struct DisputeParams {
        uint256 orderId;          // ID de la commande concernée
        string reason;            // Raison du litige
        bytes32 evidenceHash;     // Hash des preuves (IPFS)
        uint256 compensationAmount; // Montant de compensation demandé
        bool requiresImmediate;    // Si résolution immédiate nécessaire
    }
    
    // Structure pour les récompenses
    struct RewardParams {
        address user;             // Adresse du bénéficiaire
        ILocoFood.UserType userType; // Type d'utilisateur
        uint256 amount;           // Montant de la récompense
        ILocoFood.RewardType rewardType; // Type de récompense
        uint256 multiplier;       // Multiplicateur éventuel
    }

    // Structure pour les restaurants
    struct RestaurantDetails {
        string name;              // Nom du restaurant
        string cuisine;           // Type de cuisine
        bytes32 menuHash;         // Hash du menu (IPFS)
        uint256 preparationTime;  // Temps de préparation moyen
        uint256 minimumOrder;     // Montant minimum de commande
        bool acceptsStablecoin;   // Accepte les stablecoins
        uint256 deliveryRadius;   // Rayon de livraison (en km)
    }

    // Structure pour les coursiers
    struct CourierDetails {
        string name;              // Nom du coursier
        bytes32 documentsHash;    // Hash des documents (IPFS)
        uint256 vehicleType;      // Type de véhicule
        bool availableForExpress; // Disponible pour livraison express
        string[] operatingAreas;  // Zones d'opération
        uint256 maxDistance;      // Distance maximum de livraison
    }

    // Structure pour les métriques de performance
    struct PerformanceMetrics {
        uint256 totalOrders;      // Nombre total de commandes
        uint256 successfulOrders; // Commandes réussies
        uint256 disputedOrders;   // Commandes contestées
        uint256 avgRating;        // Note moyenne
        uint256 responseTime;     // Temps de réponse moyen
        uint256 totalEarnings;    // Gains totaux
    }

    // Structure pour la gouvernance
    struct ProposalParams {
        string description;       // Description de la proposition
        address[] targets;        // Contrats ciblés
        uint256[] values;        // Valeurs à transférer
        bytes[] calldatas;       // Données d'appel
        uint256 startBlock;      // Bloc de début
        uint256 endBlock;        // Bloc de fin
        uint256 threshold;       // Seuil de validation
    }
}