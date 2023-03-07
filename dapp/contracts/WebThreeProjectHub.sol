//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import 'hardhat/console.sol';

contract WebThreeProjectHub {
  uint256 private version;

  struct Project {
    address owner;
    
    uint256 projectType;
    uint256 blance; // 1000 +100 eth
  }

  mapping(address => Project) projects;

  event VersionChanged(address indexed sender, uint256 version);
  event NewProjectCreated(address indexed sender, Project project);

  constructor(uint256 _version) {
    console.log('Deploying a WebThreeProjectHub with version:', _version);
    version = _version;
  }

  function w3phVersion() public view returns (uint256) {
    return version;
  }

  function setNewVersion(uint256 _version) public {
    console.log(
      "Changing version WebThreeProjectHub from '%s' to '%s'",
      version,
      _version
    );
    version = _version;
    emit VersionChanged(msg.sender, _version);
  }

  function createProject(uint256 _projType) public payable {
    require(msg.value > 1 gwei, 'Not enough fee');
    Project memory proj = Project(msg.sender, _projType);
    projects[msg.sender] = proj;
    emit NewProjectCreated(msg.sender, proj);
  }

  function getProjectByOwner(
    address owner
  ) public view returns (Project memory) {
    return projects[owner];
  }
}
