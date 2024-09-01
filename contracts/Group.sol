// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Poll.sol";

contract Group {
    struct GroupStruct {
        string name;
        address creator;
        mapping(address => bool) members;
        address[] memberList;
    }

    mapping(uint => GroupStruct) public groups;
    uint public groupCount;
    Poll public pollContract;

    modifier onlyGroupCreator(uint groupId) {
        require(groups[groupId].creator == msg.sender, "Not the group creator");
        _;
    }

    modifier onlyGroupMember(uint groupId) {
        require(groups[groupId].members[msg.sender], "Not a group member");
        _;
    }

    event GroupCreated(uint groupId, string name, address creator);
    event MemberAdded(uint groupId, address member);

    constructor(address pollContractAddress) {
        pollContract = Poll(pollContractAddress);
    }

    function createGroup(string memory name) external {
        groupCount++;
        GroupStruct storage newGroup = groups[groupCount];
        newGroup.name = name;
        newGroup.creator = msg.sender;
        newGroup.members[msg.sender] = true;
        newGroup.memberList.push(msg.sender);

        emit GroupCreated(groupCount, name, msg.sender);
    }

    function addMember(uint groupId, address member)
        external
        onlyGroupCreator(groupId)
    {
        GroupStruct storage group = groups[groupId];
        require(!group.members[member], "Member already added");
        group.members[member] = true;
        group.memberList.push(member);

        emit MemberAdded(groupId, member);
    }

    function createPoll(
        uint groupId,
        string memory question,
        string[] memory options,
        uint duration
    ) external onlyGroupMember(groupId) {
        pollContract.createPoll(groupId, question, options, duration);
    }

    function vote(uint groupId, uint pollId, uint option) external onlyGroupMember(groupId) {
        pollContract.vote(groupId, pollId, option, msg.sender);
    }

    function getMembers(uint groupId) external view returns (address[] memory) {
        return groups[groupId].memberList;
    }

    function getPollResults(uint groupId, uint pollId)
        external
        view
        returns (uint[] memory results)
    {
        return pollContract.getPollResults(groupId, pollId);
    }
}
