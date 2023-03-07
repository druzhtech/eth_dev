import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploy() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    console.log("owner: ", owner.address)
    console.log("otherAccount: ", otherAccount.address)


    const MyContract = await ethers.getContractFactory("MyContract");
    const myContract = await MyContract.deploy();
    // console.log("myContract: ", myContract);

    const ProxyContract = await ethers.getContractFactory("ProxyContract");
    const proxyContract = await ProxyContract.deploy();
    // console.log("proxyContract: ", proxyContract);

    const AttackerContract = await ethers.getContractFactory("AttackerContract");
    const attackerContract = await AttackerContract.deploy();
    // console.log("attackerContract: ", attackerContract);

    return { myContract, proxyContract, attackerContract, owner, otherAccount };
  }

  describe("Set attacker address in Proxy", function () {
    it("1", async function () {
      const { myContract, proxyContract, attackerContract, owner, otherAccount } = await loadFixture(deploy);

      console.log("1/ attackerContract.address: ", attackerContract.address)
      const attckerAddr1 = await attackerContract.attacker();
      console.log("1/ attackerContract.attacker: ", attckerAddr1)
      console.log("1/ proxyContract.address: ", proxyContract.address)
      const implAddr1 = await proxyContract.implAddress();
      console.log("1/ proxyContract.implAddress: ", implAddr1)
      const myOwner1 = await myContract.owner();
      console.log("1/ myContract.owner(): ", myOwner1)
      console.log("3/ myContract.address: ", myContract.address)

      console.log("\n")

      const tx1 = await proxyContract.setImplAddress(attackerContract.address);
      console.log("tx1: ", tx1)
      console.log("\n")

      let receipt1 = await tx1.wait();
      console.log(receipt1.events?.filter((x) => { return x.event == "ImplChanged" }));

      expect(await proxyContract.implAddress()).to.equal(attackerContract.address);

      console.log("2/ attackerContract.address: ", attackerContract.address)
      const attckerAddr2 = await attackerContract.attacker();
      console.log("2/ attackerContract.attacker: ", attckerAddr2)
      console.log("2/ proxyContract.address: ", proxyContract.address)
      const implAddr2 = await proxyContract.implAddress();
      console.log("2/ proxyContract.implAddress: ", implAddr2)
      const myOwner2 = await myContract.owner();
      console.log("2/ myContract.address: ", myContract.address)
      console.log("2/ myContract.owner(): ", myOwner2)

      console.log("\n")

      const tx2 = await myContract.add(proxyContract.address, otherAccount.address);
      let receipt2 = await tx2.wait();
      console.log(receipt2.events?.filter((x) => { return x.event == "AttackerAddress" }));
      console.log(receipt2.events?.filter((x) => { return x.event == "FallbackRaised" }));
      console.log(receipt2.events?.filter((x) => { return x.event == "ImplChanged" }));
      console.log(receipt2.events?.filter((x) => { return x.event == "CallData" }));
      console.log(receipt2.events?.filter((x) => { return x.event == "FallbackCalled" }));

      console.log("\n");

      console.log("tx2: ", tx2)
      console.log("\n")

      expect(await myContract.owner()).to.equal(owner.address);
      expect(await proxyContract.implAddress()).to.equal(attackerContract.address);

      console.log("3/ attackerContract.address: ", attackerContract.address)
      const attckerAddr3 = await attackerContract.attacker();
      console.log("3/ attackerContract.attacker: ", attckerAddr3)
      console.log("3/ proxyContract.address: ", proxyContract.address)
      const implAddr3 = await proxyContract.implAddress();
      console.log("3/ proxyContract.implAddress: ", implAddr3)
      const myOwner3 = await myContract.owner();
      console.log("3/ myContract.owner(): ", myOwner3)
      console.log("3/ myContract.address: ", myContract.address)

      console.log("3/ otherAccount.address: ", otherAccount.address)
    });

    // it("2", async function () {
    //   const { myContract, proxyContract, attackerContract, owner } = await loadFixture(deploy);

    //   // We can increase the time in Hardhat Network

    //   expect(await proxyContract.implAddress()).to.equal(attackerContract.address);
    // });

    // it("Should receive and store the funds to lock", async function () {
    //   const { lock } = await loadFixture(
    //     deploy
    //   );
    // });

    // it("Should fail if the unlockTime is not in the future", async function () {
    //   // We don't use the fixture here because we want a different deployment
    //   const latestTime = await time.latest();
    //   const Lock = await ethers.getContractFactory("Lock");
    //   await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
    //     "Unlock time should be in the future"
    //   );
    // });
  });

  // describe("Withdrawals", function () {
  //   describe("Validations", function () {
  //     it("Should revert with the right error if called too soon", async function () {
  //       const { lock } = await loadFixture(deploy);

  //       await expect(lock.withdraw()).to.be.revertedWith(
  //         "You can't withdraw yet"
  //       );
  //     });

  //     it("Should revert with the right error if called from another account", async function () {
  //       const { lock, otherAccount } = await loadFixture(
  //         deploy
  //       );

  //       // // We can increase the time in Hardhat Network
  //       // await time.increaseTo(unlockTime);

  //       // // We use lock.connect() to send a transaction from another account
  //       // await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
  //       //   "You aren't the owner"
  //       // );
  //     });

  //     it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
  //       const { lock } = await loadFixture(
  //         deploy
  //       );

  //       // Transactions are sent using the first signer by default
  //       // await time.increaseTo(unlockTime);

  //       // await expect(lock.withdraw()).not.to.be.reverted;
  //     });
  //   });

  //   describe("Events", function () {
  //     it("Should emit an event on withdrawals", async function () {
  //       const { lock } = await loadFixture(
  //         deploy
  //       );

  //       // await time.increaseTo(unlockTime);

  //       // await expect(lock.withdraw())
  //       //   .to.emit(lock, "Withdrawal")
  //       //   .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
  //     });
  //   });

  //   describe("Transfers", function () {
  //     it("Should transfer the funds to the owner", async function () {
  //       const { lock, owner } = await loadFixture(
  //         deploy
  //       );

  //       // await time.increaseTo(unlockTime);

  //       // await expect(lock.withdraw()).to.changeEtherBalances(
  //       //   [owner, lock],
  //       //   [lockedAmount, -lockedAmount]
  //       // );
  //     });
  //   });
  // });
});
