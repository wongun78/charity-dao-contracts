// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

contract CharityDao {

    struct Proposal {
        string title;
        string description;
        uint amount;
        address recipient;
        uint voteCount;
        bool executed;
    }

    address public admin;
    Proposal[] public proposals;
    mapping(uint => mapping(address => bool)) public hasVoted;

    constructor() {
        admin = msg.sender;
    }

    event ProposalCreated(uint proposalId, string title, address creator);
    event Voted(uint proposalId, address voter);
    event ProposalExecuted(uint proposalId, address recipient, uint amount);
    event TransferFailed(uint proposalId, address recipient, uint amount);

    function donate() public payable {}

    function createProposal(
        string memory _title,
        string memory _description,
        uint _amount,
        address _recipient
    ) public {
        Proposal memory newProposal = Proposal({
            title: _title,
            description: _description,
            amount: _amount,
            recipient: _recipient,
            voteCount: 0,
            executed: false
        });
        proposals.push(newProposal);
        emit ProposalCreated(proposals.length - 1, _title, msg.sender);
    }

    function vote(uint _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(!hasVoted[_proposalId][msg.sender], "Already voted");
        hasVoted[_proposalId][msg.sender] = true;
        proposal.voteCount += 1;
        emit Voted(_proposalId, msg.sender);
    }

    function execute(uint _proposalId) public {
        require(_proposalId < proposals.length, "Proposal does not exist");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.voteCount >= 3, "Not enough votes");
        require(address(this).balance >= proposal.amount, "Insufficient contract balance");

        (bool success, ) = payable(proposal.recipient).call{value: proposal.amount}("");
        if (!success) {
            emit TransferFailed(_proposalId, proposal.recipient, proposal.amount);
            return;
        }

        proposal.executed = true;
        emit ProposalExecuted(_proposalId, proposal.recipient, proposal.amount);
    }
}