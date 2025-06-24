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

    function donate() payable public{
    }

    function createProposal(string memory _title, string memory _description, uint _amount, address _recipient) public {
             Proposal memory newProposal = Proposal({
                title: _title,
                description: _description,
                amount: _amount,
                recipient: _recipient,
                voteCount: 0,
                executed: false
             });
        proposals.push(newProposal);
        }

    function vote(uint _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(!hasVoted[_proposalId][msg.sender], "Already Voted");
        hasVoted[_proposalId][msg.sender] = true;
        proposal.voteCount += 1;
    }

    function execute(uint _proposalId) public{
        require(_proposalId < proposals.length, "Must have proposal");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Not executed yet");
        require(proposal.voteCount >=3, "Not have enough vote yet");
        require(address(this).balance >= proposal.amount, "Insufficient contract balance");
        payable(proposal.recipient).transfer(proposal.amount);
        proposal.executed = true;
    }
    }
