pragma solidity ^0.4.13;

contract Promotion {
    address public boss;

    uint public bonus;

    uint public start;

    uint public end;

    uint public tallies;

    mapping (address => bytes32) votes;
    mapping (address => string) voters;
    mapping (string => address) candidates;
    Standing[] tally;


    struct Standing {
        address candidate;
        uint tally;
    }

    modifier isBoss() {if (msg.sender == boss) {_;}}
    modifier active() {if (now < end) {_;}}
    modifier complete() {if (now > end) {_;}}

    event Won(string name, uint tally);

    function promotion(uint span) public payable {
        boss = msg.sender;
        bonus = msg.value;
        start = now;
        end = start + span;

    }

    function register(string name) 
    active()
    {
        voters[msg.sender] = name;
        candidates[name] = msg.sender;
        tally.push(Standing(msg.sender, 0));
    }

    function vote(bytes32 secret) 
    active()
    {
        votes[msg.sender] = secret; 
    }

    function reveal(string name, string entropy) 
    complete()
    {
        require(candidates[name] != msg.sender);
        for (uint i = 0; i < tally.length; i += 1) {
            if (tally[i].candidate == candidates[name]) {
                tally[i].tally += 1;
                tallies += 1;
                break;
            }
        }
    }

    function count()
    complete()
    isBoss() payable
    {
        address leader;
        uint total = 0;
        for (uint i = 0; i < tally.length; i += 1) {
            if (tally[i].tally >= total) {
                leader = tally[i].candidate;
                total = tally[i].tally;
            }
        }
        Won(voters[leader], total);
        leader.transfer(bonus);
    }








}