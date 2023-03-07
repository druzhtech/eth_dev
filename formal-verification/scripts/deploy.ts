import { ethers } from "hardhat";

async function main() {
  const Token = await ethers.getContractFactory("Token");
  const lock = await Token.deploy();

  await lock.deployed();

  console.log(`Token deployed to ${lock.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
