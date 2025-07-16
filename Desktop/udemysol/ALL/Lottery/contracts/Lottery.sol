// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
contract Lottery {
    address public manager;
    address[] public players;
    event WinnerPicked(address winner, uint256 amount);
    constructor() {
        manager = msg.sender;
    }
    function enter() public payable {
        require(msg.value >= 0.1 ether, "Minimum 0.1 ether required");
        players.push(msg.sender);
    }
    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players))) % players.length;
    }
    modifier restricted() {
        require(msg.sender == manager, "Only manager can pick a winner");
        _;
    }
    function pickWinner() public restricted {
        require(players.length > 0, "No players in lottery");
        uint256 index = random();
        address winner = players[index];
        uint256 balance = address(this).balance;
        emit WinnerPicked(winner, balance);
        payable(winner).transfer(balance);
        players = new address[](0);
    }
    function getPlayers() public view returns (address[] memory) {
        return players;
    }
}