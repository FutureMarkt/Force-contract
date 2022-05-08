const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("Forsage", function(){
  let acc1, acc2, acc3, acc4, acc5
  let forsage
  let mfs
  beforeEach(async function(){
    [acc1, acc2, acc3, acc4, acc5] = await ethers.getSigners()

    // Deploy token contract
    const MFS = await ethers.getContractFactory("MFS", acc1)
    mfs = await MFS.deploy() // send transaction
    await mfs.deployed() // transaction done

    // Deploy system contract
    const Forsage = await ethers.getContractFactory("Forsage", acc1)
    forsage = await Forsage.deploy(acc1.address, mfs.address) // send transaction
    await forsage.deployed() // transaction done

    await mfs.transfer(acc2.address, ethers.utils.parseEther('100'))
    await mfs.transfer(acc3.address, ethers.utils.parseEther('100'))
    await mfs.transfer(acc4.address, ethers.utils.parseEther('100'))
    await mfs.transfer(acc5.address, ethers.utils.parseEther('100'))

    // set accounts
    await forsage.connect(acc2).registration(acc1.address)
    await forsage.connect(acc3).registration(acc1.address)
    await forsage.connect(acc4).registration(acc2.address)
    await forsage.connect(acc5).registration(acc2.address)
  })

  // it ("should be deployed", async function(){
  //   expect(forsage.address).to.be.properAddress;
  // })

  // it ("first user should be activated", async function(){
  //   let active
  //   for (var i = 0; i < 12; i++) {
  //     expect(await forsage.activate(acc1.address,i)).to.equal(true);
  //   }
  // })

  it ("Get parent", async function(){
    const adminParent = await forsage.getParent()
    const acc2Parent = await forsage.connect(acc2).getParent()
    const acc4Parent = await forsage.connect(acc4).getParent()
    expect(adminParent).to.equal(acc1.address)
    expect(acc2Parent).to.equal(acc1.address)
    expect(acc4Parent).to.equal(acc2.address)
  })

  // it ("Update X3 test", async function(){
  //   await forsage.changeAutoReCycle(true)
  //   const parent = await forsage.connect(acc2).updateX3(acc2.address,0)
  //   await forsage.connect(acc3).updateX3(acc3.address,0)
  //   await forsage.connect(acc4).updateX3(acc4.address,0)
  //   await forsage.connect(acc5).updateX3(acc5.address,0)
  // })
  //
  // it ("Buy test", async function(){
  //   await forsage.connect(acc2).registration(acc1.address)
  //   await forsage.connect(acc2).buy(0)
  // })

  // it ("Change User settings", async function(){
  //   await forsage.changeAutoReCycle(true)
  //   await forsage.changeAutoUpgrade(true)
  // })
  //
  // it ("is token set", async function(){
  //   const token = await forsage.tokenMFS()
  //   expect(token).to.be.properAddress;
  // })
  //
  // it ("balance of sender", async function(){
  //   const balance = await mfs.balanceOf(acc1.address)
  //   expect(balance).to.equal(ethers.utils.parseEther('24600'))
  // })
})
