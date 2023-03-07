import '@nomiclabs/hardhat-waffle';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

task('deploy', 'Deploy W3PH contract').setAction(
  async (_, hre: HardhatRuntimeEnvironment): Promise<void> => {
    const W3PH = await hre.ethers.getContractFactory('WebThreeProjectHub');
    const w3ph = await W3PH.deploy('Hello, Hardhat!');

    await w3ph.deployed();

    console.log('W3PH deployed to:', w3ph.address);
  }
);
