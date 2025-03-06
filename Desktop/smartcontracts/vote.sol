// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Voting{
    struct Voters{
        bool hasVoted;
        uint256 candidateId;
        uint256 timestamp;
    } 
    struct Candidate{
        string name;
        uint256 voteCount;
    }
    event VoteCast(address indexed voter,uint256 _candidateId);
    mapping(address=>Voters) private voters;
    Candidate[]public candidates;
    constructor(){
        candidates.push(Candidate("Kamil",0));
        candidates.push(Candidate("Mahroosh",0));
    }
    function vote(uint256 _candidateId)public {
        require(!voters[msg.sender].hasVoted,"Already Voted");
        require(_candidateId < candidates.length,"Invalid Candidate");
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].candidateId = _candidateId;
        voters[msg.sender].timestamp = block.timestamp;
        candidates[_candidateId].voteCount +=1;
        emit VoteCast(msg.sender,_candidateId);
    }
    function getCandidate(uint256 _candidateId)public view returns(Candidate memory){
        require(_candidateId<candidates.length,"Invalid Candidate");
        return candidates[_candidateId];
    }
    function getVote()public view returns(Voters memory){
        return voters[msg.sender];
    }
    function getCandidateCount() public view returns(uint256){
        // returns the number of candidates participating in the election
        return candidates.length;
    }
    function getTotalVotes()public view returns(uint256){
        uint256 total = 0;
        for(uint256 i = 0;i<candidates.length;i++){
            total+=candidates[i].voteCount;
        }
        return total;
    }
}