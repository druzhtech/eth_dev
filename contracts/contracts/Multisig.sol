// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.19;

contract SimpleMultisig {
    address[] owners; /// 7 from 10

    mapping(address => bool) signed;

    constructor() {
        owners.push(address(0));
        owners.push(msg.sender);
    }

    function Sign() public {
        require(msg.sender == owners[0] || msg.sender == owners[1]);
        require(!signed[msg.sender]);
        signed[msg.sender] = true;
    }

    function Action() public returns (string memory) {
        require(signed[owners[0]] && signed[owners[1]]);
        return "Your action here";
    }
}
