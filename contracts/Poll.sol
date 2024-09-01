// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @title Poll Contract
/// @notice This contract allows for the creation and management of polls within different groups.
/// @dev Each group can create multiple polls, and members of the group can vote on them.

contract Poll {
    struct PollStruct {
        string question;
        string[] options;
        mapping(uint => uint) votes; // optionIndex => voteCount
        mapping(address => bool) hasVoted; // userAddress => voted
        uint endTime;
    }

    mapping(uint => mapping(uint => PollStruct)) public polls; // groupID => PollID => Poll
    mapping(uint => uint) public pollCounts; // groupID => pollCount

    // Event emitted when a new poll is created
    event PollCreated(uint groupId, uint pollId, string question);
    // Event emitted when a vote is cast in a poll
    event Voted(uint groupId, uint pollId, address voter, uint option);
    // Event emitted when a poll has ended
    event PollEnded(uint groupId, uint pollId);

    /// @notice Creates a new poll for a given group.
    /// @param groupId The ID of the group creating the poll.
    /// @param question The question being asked in the poll.
    /// @param options The list of options available for voting.
    /// @param duration The duration in seconds for which the poll will be active.
    function createPoll(
        uint groupId,
        string memory question,
        string[] memory options,
        uint duration
    ) external {
        require(options.length > 1, "At least two options required");

        pollCounts[groupId]++;
        PollStruct storage newPoll = polls[groupId][pollCounts[groupId]];
        newPoll.question = question;
        newPoll.options = options;
        newPoll.endTime = block.timestamp + duration;

        emit PollCreated(groupId, pollCounts[groupId], question);
    }

    /// @notice Allows a member of the group to vote on a poll.
    /// @param groupId The ID of the group where the poll is created.
    /// @param pollId The ID of the poll being voted on.
    /// @param option The index of the option the voter chooses.
    /// @param voter The address of the voter.
    function vote(
        uint groupId,
        uint pollId,
        uint option,
        address voter
    ) external {
        PollStruct storage poll = polls[groupId][pollId];
        require(block.timestamp < poll.endTime, 'Poll has ended');
        require(!poll.hasVoted[voter], 'Already voted');
        require(option < poll.options.length, 'Invalid option');

        poll.votes[option]++;
        poll.hasVoted[voter] = true;

        emit Voted(groupId, pollId, voter, option);
    }

    /// @notice Retrieves the results of a poll after it has ended.
    /// @param groupId The ID of the group where the poll was created.
    /// @param pollId The ID of the poll.
    /// @return results An array of vote counts for each option.
    function getPollResults(
        uint groupId,
        uint pollId
    ) external view returns (uint[] memory results) {
        PollStruct storage poll = polls[groupId][pollId];
        require(block.timestamp >= poll.endTime, 'Poll has not ended');

        results = new uint[](poll.options.length);
        for (uint i = 0; i < poll.options.length; i++) {
            results[i] = poll.votes[i];
        }
    }
}
