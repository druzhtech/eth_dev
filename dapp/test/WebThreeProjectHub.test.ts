import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('Web Three Project Hub', function (): void {
  it("Should return the new version once it's changed", async function (): Promise<void> {
    const WebThreeProjectHub = await ethers.getContractFactory(
      'WebThreeProjectHub'
    );
    const w3ph = await WebThreeProjectHub.deploy(1);
    await w3ph.deployed();

    expect(await w3ph.w3phVersion()).to.equal(1);

    const setNewVersionTx = await w3ph.setNewVersion(2);

    // wait until the transaction is mined
    await setNewVersionTx.wait();

    expect(await w3ph.w3phVersion()).to.equal(2);
  });
});
