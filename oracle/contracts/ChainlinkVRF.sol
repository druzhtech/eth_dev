// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract ChainlinkVRF is VRFConsumerBase {
    
    bytes32 keyHash;
    uint256 fee;

    struct Student {
        uint256 studentId;
        uint256 random;
        bool isLucky;
    }

    mapping(bytes32 => uint256) public requests;
    mapping(uint256 => Student) public students;

    constructor(
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _fee
    ) VRFConsumerBase(_vrfCoordinator, _link) {
        keyHash = _keyHash;
        fee = _fee;
    }

    function getLucky(uint256 studentId) public {
        bytes32 requestId = requestRandomness(keyHash, fee);
        requests[requestId] = studentId;
    }

    function fulfillRandomness(bytes32 requestId, uint256 random)
        internal
        override
    {
        uint256 stdId = requests[requestId];
        Student storage stud = students[stdId];
        stud.isLucky = true;
    }
}
