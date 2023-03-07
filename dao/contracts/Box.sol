// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
contract Box is Ownable {
  uint256 private value;

  uint256[] taskId; // ДЗ

  mapping (uint256 => uint256) taskPrize; // номер задачи и количество токенов

  // Emitted when the stored value changes
  // event ValueChanged(uint256 newValue);

  // Stores a new value in the contract
  function setPrizeToTask(uint256 taskId, uint256 prizeAmount) public onlyOwner {
    taskPrize[taskId] = prizeAmount;
    // emit ValueChanged(newValue);
  }

  // Reads the last stored value
  function retrieve() public view returns (uint256) {
    return value;
  }
}
