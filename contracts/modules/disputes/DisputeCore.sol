// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../core/LocoFoodBase.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract LocoFoodDispute is LocoFoodBase, VRFConsumerBaseV2 {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct DisputeVote {
        address voter;
        bool inFavorOfCustomer;
        string reason;
        uint256 weight;           // Poids du vote basé sur la réputation et le staking
    }

    struct Evidence {
        string description;       // Description de la preuve
        bytes32 contentHash;      // Hash du contenu de la preuve
        uint256 timestamp;        // Horodatage de la soumission
        address submitter;        // Adresse du soumissionnaire
    }

    struct Jury {
        EnumerableSet.AddressSet members;
        uint256 selectionTime;
        bool isSelected;
    }

    uint256 public constant VOTING_PERIOD = 3 days;
    uint256 public constant JURY_SIZE = 5;
    uint256 public constant MIN_VOTES_REQUIRED = 3;
    uint256 public constant BASE_VOTE_WEIGHT = 100;
    uint256 public constant MIN_STAKE_AMOUNT = 10 * 10**18; // Montant minimal de staking
    uint256 public constant REWARD_POOL_SHARE = 10; // Pourcentage des frais de litige alloué aux récompenses

    // Chainlink VRF V2 variables
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    bytes32 keyHash;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;

    // Mapping from request ID to dispute ID
    mapping(uint256 => uint256) private vrfRequests;

    mapping(uint256 => DisputeVote[]) public disputeVotes;
    mapping(uint256 => Evidence[]) public disputeEvidence;
    mapping(uint256 => Jury) public disputeJuries;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => uint256) public disputeEndTimes;
    mapping(address => uint256) public voterReputationScore;
    mapping(address => uint256) public stakes; // Montant staké par les votants

    // Suivi des résolutions de force majeure
    mapping(uint256 => bool) public requiresForceMajeureResolution;

    event DisputeCreated(uint256 indexed orderId, address indexed initiator, string reason);
    event DisputeVoteSubmitted(
        uint256 indexed disputeId,
        address indexed voter,
        bool inFavorOfCustomer,
        uint256 weight
    );

    event EvidenceSubmitted(
        uint256 indexed disputeId,
        address indexed submitter,
        bytes32 contentHash,
        string description
    );

    event JurySelected(
        uint256 indexed disputeId,
        address[] jurors
    );

    event DisputeResolved(
        uint256 indexed disputeId,
        bool inFavorOfCustomer,
        uint256 refundAmount
    );

    event ManualResolutionRequired(
        uint256 indexed disputeId,
        string reason
    );

    constructor(
        address _vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _keyHash
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        s_subscriptionId = _subscriptionId;
        keyHash = _keyHash;
    }

    function createDispute(
        uint256 orderId,
        string calldata reason
    ) external payable whenNotPaused onlyOrderParticipant(orderId) {
        require(msg.value >= MIN_STAKE_AMOUNT, "Stake amount insufficient");
        Order storage order = orders[orderId];
        require(
            order.state == ILocoFood.State.InDelivery ||
            order.state == ILocoFood.State.Delivered,
            "Invalid order state for dispute"
        );
        require(order.disputeId == 0, "Dispute already exists");

        uint256 disputeId = nextDisputeId++;
        disputes[disputeId] = Dispute({
            orderId: orderId,
            initiator: msg.sender,
            reason: reason,
            resolved: false,
            creationTime: block.timestamp
        });

        order.disputeId = disputeId;
        order.state = ILocoFood.State.Disputed;
        disputeEndTimes[disputeId] = block.timestamp + VOTING_PERIOD;

        // Les frais de litige sont ajoutés à la pool de récompense
        uint256 rewardPool = (msg.value * REWARD_POOL_SHARE) / 100;

        // Sélection du jury via VRF
        _requestRandomWordsForJury(disputeId);

        emit DisputeCreated(orderId, msg.sender, reason);
    }

    function submitEvidence(
        uint256 disputeId,
        string calldata description,
        bytes32 contentHash
    ) external whenNotPaused {
        require(block.timestamp < disputeEndTimes[disputeId], "Voting period ended");
        require(
            msg.sender == disputes[disputeId].initiator ||
            msg.sender == orders[disputes[disputeId].orderId].courier ||
            msg.sender == orders[disputes[disputeId].orderId].restaurant,
            "Not authorized to submit evidence"
        );

        disputeEvidence[disputeId].push(Evidence({
            description: description,
            contentHash: contentHash,
            timestamp: block.timestamp,
            submitter: msg.sender
        }));

        emit EvidenceSubmitted(disputeId, msg.sender, contentHash, description);
    }

    function stakeAndRegister() external payable whenNotPaused {
        require(msg.value >= MIN_STAKE_AMOUNT, "Insufficient staking amount");
        stakes[msg.sender] += msg.value;
    }

    function submitDisputeVote(
        uint256 disputeId,
        bool inFavorOfCustomer,
        string calldata reason
    ) external whenNotPaused {
        require(block.timestamp < disputeEndTimes[disputeId], "Voting period ended");
        require(!hasVoted[disputeId][msg.sender], "Already voted");
        require(_isJuryMember(disputeId, msg.sender), "Not a jury member");

        uint256 weight = _calculateVoteWeight(msg.sender);

        disputeVotes[disputeId].push(DisputeVote({
            voter: msg.sender,
            inFavorOfCustomer: inFavorOfCustomer,
            reason: reason,
            weight: weight
        }));

        hasVoted[disputeId][msg.sender] = true;

        emit DisputeVoteSubmitted(disputeId, msg.sender, inFavorOfCustomer, weight);

        if (_hasReachedMinimumVotes(disputeId)) {
            _resolveDispute(disputeId);
        }
    }

    function _calculateVoteWeight(address voter) internal view returns (uint256) {
        uint256 weight = BASE_VOTE_WEIGHT;

        // Ajouter le poids basé sur le staking
        weight += stakes[voter] / 1 ether;

        // Ajouter le poids basé sur la réputation
        if (voterReputationScore[voter] > 0) {
            weight += voterReputationScore[voter];
        }

        return weight;
    }

    function _hasReachedMinimumVotes(uint256 disputeId) internal view returns (bool) {
        return disputeVotes[disputeId].length >= MIN_VOTES_REQUIRED;
    }

    function _isJuryMember(uint256 disputeId, address account) internal view returns (bool) {
        return disputeJuries[disputeId].members.contains(account);
    }

    function _requestRandomWordsForJury(uint256 disputeId) internal {
        // Demande de nombres aléatoires à Chainlink VRF V2
        uint32 numWords = uint32(JURY_SIZE);
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        // Stocker la mapping entre requestId et disputeId
        vrfRequests[requestId] = disputeId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 disputeId = vrfRequests[requestId];
        _selectJury(disputeId, randomWords);
    }

    function _selectJury(uint256 disputeId, uint256[] memory randomWords) internal {
        require(!disputeJuries[disputeId].isSelected, "Jury already selected");

        // Obtenir la liste des jurés qualifiés
        address[] memory qualified = _getQualifiedJurors();
        require(qualified.length >= JURY_SIZE, "Not enough qualified jurors");

        uint256 selectedCount = 0;
        uint256 randomIndex = 0;

        while (selectedCount < JURY_SIZE && randomIndex < randomWords.length) {
            uint256 index = randomWords[randomIndex] % qualified.length;
            address juror = qualified[index];

            // Vérifier les conflits d'intérêts
            if (_hasConflictOfInterest(disputeId, juror)) {
                randomIndex++;
                continue; // Passer au suivant si conflit
            }

            if (!disputeJuries[disputeId].members.contains(juror)) {
                disputeJuries[disputeId].members.add(juror);
                selectedCount++;
            }

            randomIndex++;
        }

        require(selectedCount == JURY_SIZE, "Failed to select enough jurors");

        disputeJuries[disputeId].selectionTime = block.timestamp;
        disputeJuries[disputeId].isSelected = true;

        address[] memory selectedJurors = new address[](disputeJuries[disputeId].members.length());
        for (uint256 i = 0; i < disputeJuries[disputeId].members.length(); i++) {
            selectedJurors[i] = disputeJuries[disputeId].members.at(i);
        }

        emit JurySelected(disputeId, selectedJurors);
    }

    function _getQualifiedJurors() internal view returns (address[] memory) {
        // Implémentation pour obtenir les jurés qualifiés
        // Les adresses des jurés sont stockées dans un EnumerableSet
        uint256 count = stakes.length();
        address[] memory tempJurors = new address[](count);

        uint256 jurorCount = 0;
        for (uint256 i = 0; i < count; i++) {
            address juror = stakes.at(i);
            if (stakes[juror] >= MIN_STAKE_AMOUNT) {
                tempJurors[jurorCount] = juror;
                jurorCount++;
            }
        }

        address[] memory jurors = new address[](jurorCount);
        for (uint256 i = 0; i < jurorCount; i++) {
            jurors[i] = tempJurors[i];
        }

        return jurors;
    }

    function _hasConflictOfInterest(uint256 disputeId, address juror) internal view returns (bool) {
        // Vérifier si le juré est impliqué dans le litige ou a un lien direct
        Order storage order = orders[disputes[disputeId].orderId];

        if (juror == disputes[disputeId].initiator ||
            juror == order.courier ||
            juror == order.restaurant) {
            return true;
        }

        // Autres vérifications possibles (par exemple, mêmes régions, collaborations récentes)
        return false;
    }

    function _resolveDispute(uint256 disputeId) internal {
        require(!disputes[disputeId].resolved, "Dispute already resolved");

        DisputeVote[] storage votes = disputeVotes[disputeId];
        uint256 weightedVotesForCustomer = 0;
        uint256 totalWeight = 0;

        for (uint256 i = 0; i < votes.length; i++) {
            totalWeight += votes[i].weight;
            if (votes[i].inFavorOfCustomer) {
                weightedVotesForCustomer += votes[i].weight;
            }
        }

        if (totalWeight == 0 || votes.length < MIN_VOTES_REQUIRED) {
            requiresForceMajeureResolution[disputeId] = true;
            emit ManualResolutionRequired(disputeId, "Insufficient votes");
            _forceMajeureResolution(disputeId);
            return;
        }

        bool inFavorOfCustomer = weightedVotesForCustomer > totalWeight / 2;
        Dispute storage dispute = disputes[disputeId];
        Order storage order = orders[dispute.orderId];

        if (inFavorOfCustomer) {
            payments.refundPayment(dispute.orderId);
        } else {
            payments.releasePayment(dispute.orderId);
        }

        dispute.resolved = true;
        order.state = ILocoFood.State.Delivered;

        // Mettre à jour les scores de réputation des votants
        _updateVoterReputations(disputeId, inFavorOfCustomer);

        // Redistribuer les récompenses à partir de la pool
        _distributeRewards(disputeId);

        emit DisputeResolved(
            disputeId,
            inFavorOfCustomer,
            inFavorOfCustomer ? order.amount : 0
        );
    }

    function _forceMajeureResolution(uint256 disputeId) internal {
        // Étendre le jury ou prendre d'autres mesures P2P pour résoudre le litige
        Jury storage jury = disputeJuries[disputeId];

        if (!jury.isSelected) {
            address[] memory extendedJurors = _getQualifiedJurors();
            for (uint256 i = 0; i < extendedJurors.length; i++) {
                if (!_hasConflictOfInterest(disputeId, extendedJurors[i])) {
                    jury.members.add(extendedJurors[i]);
                }
            }
            jury.isSelected = true;
        }
    }

    function _updateVoterReputations(uint256 disputeId, bool finalOutcome) internal {
        DisputeVote[] storage votes = disputeVotes[disputeId];

        for (uint256 i = 0; i < votes.length; i++) {
            address voter = votes[i].voter;
            if (votes[i].inFavorOfCustomer == finalOutcome) {
                voterReputationScore[voter] += 10;  // Récompenser les votes alignés
            } else {
                if (voterReputationScore[voter] >= 5) {
                    voterReputationScore[voter] -= 5;  // Pénaliser les votes non alignés
                }
            }
        }
    }

    function _distributeRewards(uint256 disputeId) internal {
        // Distribuer les récompenses aux jurés en fonction de leur poids de vote
        uint256 rewardPool = (MIN_STAKE_AMOUNT * REWARD_POOL_SHARE) / 100;
        DisputeVote[] storage votes = disputeVotes[disputeId];
        uint256 totalWeight = 0;

        for (uint256 i = 0; i < votes.length; i++) {
            totalWeight += votes[i].weight;
        }

        for (uint256 i = 0; i < votes.length; i++) {
            uint256 reward = (votes[i].weight * rewardPool) / totalWeight;
            payable(votes[i].voter).transfer(reward);
        }
    }

    // Fonctions de vue pour la transparence
    function getDisputeEvidence(uint256 disputeId) external view returns (Evidence[] memory) {
        return disputeEvidence[disputeId];
    }

    function getJuryMembers(uint256 disputeId) external view returns (address[] memory) {
        require(disputeJuries[disputeId].isSelected, "Jury not selected");
        uint256 size = disputeJuries[disputeId].members.length();
        address[] memory members = new address[](size);
        for (uint256 i = 0; i < size; i++) {
            members[i] = disputeJuries[disputeId].members.at(i);
        }
        return members;
    }

    function getVoterWeight(address voter) external view returns (uint256) {
        return _calculateVoteWeight(voter);
    }
}
