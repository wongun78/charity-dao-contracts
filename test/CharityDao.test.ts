import hre from "hardhat";
const { ethers } = hre;
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("CharityDao", function () {
  async function deployCharityDaoFixture() {
    const [owner, donor] = await ethers.getSigners();
    const CharityDao = await ethers.getContractFactory("CharityDao");
    const charityDao = await CharityDao.deploy();
    await charityDao.waitForDeployment();
    return { charityDao, owner, donor };
  }

  it("should accept donations", async function () {
    const { charityDao, donor } = await loadFixture(deployCharityDaoFixture);

    const tx = await charityDao.connect(donor).donate({
      value: ethers.parseEther("1"),
    });
    await tx.wait();

    const balance = await ethers.provider.getBalance(charityDao.target);
    expect(balance).to.equal(ethers.parseEther("1"));
  });
});
