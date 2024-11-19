// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILocoFood {
    // États possibles d'une commande
    enum OrderState {
        Created,        // Commande créée mais pas encore confirmée par le restaurant
        Confirmed,      // Commande confirmée par le restaurant
        InPreparation, // En cours de préparation
        ReadyForPickup, // Prête pour la collecte par le livreur
        InDelivery,    // En cours de livraison
        Delivered,     // Livrée au client
        Disputed,      // En litige
        Cancelled      // Annulée
    }
    
    // Types d'utilisateurs dans le système
    enum UserType {
        Customer,    // Client
        Restaurant,  // Restaurant
        Courier     // Livreur
    }

    // Types de paiements supportés
    enum PaymentType {
        Native,     // Paiement en ETH/SOL natif
        Stablecoin, // Paiement en stablecoin
        Platform    // Paiement en token de la plateforme
    }

    // États possibles d'un litige
    enum DisputeState {
        Created,    // Litige créé
        Evidence,   // Collection des preuves
        Voting,     // Vote en cours
        Resolved,   // Résolu
        Escalated   // Escaladé vers la gouvernance
    }

    // Types de récompenses
    enum RewardType {
        OrderCompletion,    // Récompense pour complétion de commande
        QuickDelivery,      // Bonus de livraison rapide
        DisputeResolution,  // Récompense pour résolution de litige
        StakingReward,      // Récompense de staking
        ReferralBonus       // Bonus de parrainage
    }
}
