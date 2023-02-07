// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract TimeLock is TimelockController {
  // minDelay - сколько времени нужно ждать перед выполнением
  // proposers - список адресов, которые могут предлагать.
  // executors - это список адресов, которые могут исполнять
  //`admin`: необязательная учетная запись, которой будет предоставлена роль администратора; отключается при нулевом адресе /**
  /**
   * ВАЖНО: Опциональный администратор может помочь с начальной настройкой ролей после развертывания.
   * без задержек, но впоследствии от этой роли следует отказаться в пользу
   * администрирования через предложения с временной блокировкой. Предыдущие версии этого контракта назначали
   * этот администратор назначался развертывающему автоматически, и от него также следует отказаться.
   */
  constructor(
    uint256 minDelay,
    address[] memory proposers,
    address[] memory executors,
    address admin
  ) TimelockController(minDelay, proposers, executors, admin) {}
}
