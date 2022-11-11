const { expect } = require("chai");
const { ethers, getChainId, deployments } = require("hardhat");
const { config, autoFundCheck } = require("../chainlink.config.js");
import { ethers as Ethers } from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

declare var hre: any

describe("EduChainLinkOracle Tests", () => {
    let EduChainLinkOracle;
    let eduChainLinkOracle: any;
    let VRFCoordinatorMock;
    let vrfCoordinatorMock
    let LinkToken;
    let linkToken: any;
    let chainId = 31337; // TODO
    // let deployer;
    const keyHash = config[chainId].keyHash; // Key Hash - public key against which randomness is generated
    const fee = config[chainId].fee; //     Fee - fee required to fulfill a VRF request

    // const DAY = 3600 * 24;
    let account1: Ethers.Signer;
    let account2: Ethers.Signer;

    before(async function () {
        const [acc1, acc2] = await ethers.getSigners();
        // const chainId = await getChainId();
        // await deployments.fixture(["main"]);

        account1 = acc1;
        account2 = acc2;

        LinkToken = await ethers.getContractFactory("LinkToken");
        linkToken = await LinkToken.deploy();
        await linkToken.deployed();
        console.log(`LinkToken to ${linkToken.address}`);

        VRFCoordinatorMock = await ethers.getContractFactory("VRFCoordinatorMock");
        vrfCoordinatorMock = await VRFCoordinatorMock.deploy(linkToken.address);
        await vrfCoordinatorMock.deployed();
        console.log(`VRFCoordinatorMock deployed to ${vrfCoordinatorMock.address}`);

        let linkTokenAddress = linkToken.address;
        let vrfCoordinatorAddress = vrfCoordinatorMock.address;

        EduChainLinkOracle = await ethers.getContractFactory("EduVRFOracle");
        eduChainLinkOracle = await EduChainLinkOracle.deploy(vrfCoordinatorAddress,
            linkTokenAddress,
            keyHash,
            ethers.utils.parseUnits(fee, 18));
        console.log("eduChainLinkOracle address: ", eduChainLinkOracle.address);
    })

    it("Should Request Random", async () => {
        // const networkName = config[chainId].name;
        // if (
        //     await autoFundCheck(
        //         eduChainLinkOracle.address,
        //         networkName,
        //         linkToken.address            )
        // ) { }
        let fundTx = await hre.run("fund-link", {
            contract: eduChainLinkOracle.address,
            linkaddress: linkToken.address,
        });

        const createStudentTx = await eduChainLinkOracle.createStudent(1, 256);
        await createStudentTx.wait();
        // const receiptCreateStudentTx = await createStudentTx.wait();
        // console.log("txReceipt: ", receiptCreateStudentTx);

        const fee = await eduChainLinkOracle.fee();
        console.log("Fee: ", Number(fee));

        const isLuckyTx = await eduChainLinkOracle.connect(account1).chooseLucky(1);

        // await new Promise((resolve) => setTimeout(resolve, 120000));
        const txReceipt = await isLuckyTx.wait();
        // await new Promise((resolve) => setTimeout(resolve, 180000));

        const requestId = txReceipt.events[2].topics[1];
        expect(requestId).to.be.not.null;
        console.log("txReceipt: ", txReceipt);

        // eslint-disable-next-line no-unused-expressions
        // expect(requestId).to.be.not.null;
    });

    it("Should receive random", async () => {
        // await new Promise((resolve) => setTimeout(resolve, 180000));
        const random = await eduChainLinkOracle.getRandom(1);
        console.log("random number: ", Number(random.data));
    });
});