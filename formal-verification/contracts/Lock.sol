// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Lock {
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    uint256 private _decimals = 18;
    uint256 private _hardCap = 200 * (10 ** _decimals);
    uint256 private _rate = 2;

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function buy() public payable {
        require(msg.value != 0);
        require(_hardCap <= _totalSupply + msg.value * _rate);
        _balances[msg.sender] += msg.value * _rate;
        _totalSupply += msg.value * _rate;
    }
}
