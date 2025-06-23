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
    mapping(address => bool) public hasVoted;
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
    }
