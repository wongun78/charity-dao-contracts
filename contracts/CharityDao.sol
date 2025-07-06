// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract CharityDao {
    struct Proposal {
        string title;
        string description;
        uint amount;
        address recipient;
        uint yesVotes;
        uint noVotes;
        bool executed;
        uint deadline;
    }

    address public admin;
    uint public quorum = 3; 
    uint public approvalRate = 60;
    Proposal[] public proposals;
    mapping(uint => mapping(address => bool)) public hasVoted;

    constructor() {
        admin = msg.sender;
    }

    event ProposalCreated(uint indexed proposalId, string title, address indexed creator);
    event Voted(uint indexed proposalId, address indexed voter, bool support);
    event ProposalExecuted(uint indexed proposalId, address indexed recipient, uint amount);
    event TransferFailed(uint indexed proposalId, address indexed recipient, uint amount);

    modifier onlyBeforeDeadline(uint _proposalId) {
        require(block.timestamp < proposals[_proposalId].deadline, "Voting period ended");
        _;
    }

    function donate() external payable {}

    function createProposal(
        string memory _title,
        string memory _description,
        uint _amount,
        address _recipient,
        uint _durationInSeconds
    ) external {
        require(_durationInSeconds > 0, "Duration must be > 0");
        require(_recipient != address(0), "Invalid recipient");

        proposals.push(Proposal({
            title: _title,
            description: _description,
            amount: _amount,
            recipient: _recipient,
            yesVotes: 0,
            noVotes: 0,
            executed: false,
            deadline: block.timestamp + _durationInSeconds
        }));

        emit ProposalCreated(proposals.length - 1, _title, msg.sender);
    }

    function vote(uint _proposalId, bool support) external onlyBeforeDeadline(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        require(!hasVoted[_proposalId][msg.sender], "Already voted");

        hasVoted[_proposalId][msg.sender] = true;

        if (support) {
            proposal.yesVotes += 1;
        } else {
            proposal.noVotes += 1;
        }

        emit Voted(_proposalId, msg.sender, support);
    }

    function execute(uint _proposalId) external {
        require(_proposalId < proposals.length, "Invalid proposal");
        Proposal storage proposal = proposals[_proposalId];

        require(!proposal.executed, "Already executed");
        require(block.timestamp >= proposal.deadline, "Voting still ongoing");

        uint totalVotes = proposal.yesVotes + proposal.noVotes;
        require(totalVotes >= quorum, "Quorum not met");

        uint approval = (proposal.yesVotes * 100) / totalVotes;
        require(approval >= approvalRate, "Approval rate not met");
        require(address(this).balance >= proposal.amount, "Insufficient contract balance");

        proposal.executed = true;

        (bool success, ) = payable(proposal.recipient).call{value: proposal.amount}("");
        if (success) {
            emit ProposalExecuted(_proposalId, proposal.recipient, proposal.amount);
        } else {
            emit TransferFailed(_proposalId, proposal.recipient, proposal.amount);
        }
    }

    function setQuorum(uint _quorum) external {
        require(msg.sender == admin, "Only admin");
        quorum = _quorum;
    }

    function setApprovalRate(uint _rate) external {
        require(msg.sender == admin, "Only admin");
        require(_rate <= 100, "Invalid rate");
        approvalRate = _rate;
    }

    function getProposalCount() external view returns (uint) {
        return proposals.length;
    }
}