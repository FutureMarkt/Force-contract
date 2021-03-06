const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("Contract", function(){
  let acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8
  let forsage
  let mfs
  beforeEach(async function(){
    [acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8] = await ethers.getSigners()

    // Deploy token contract
    const MFS = await ethers.getContractFactory("MFS", acc1)
    mfs = await MFS.deploy() // send transaction
    await mfs.deployed() // transaction done

    // Deploy system contract
    const Forsage = await ethers.getContractFactory("Forsage", acc1)
    forsage = await Forsage.deploy(mfs.address) // send transaction
    await forsage.deployed() // transaction done

    await mfs.transfer(acc2.address, ethers.utils.parseEther('100'))
    await mfs.transfer(acc3.address, ethers.utils.parseEther('100'))
    await mfs.transfer(acc4.address, ethers.utils.parseEther('100'))
    await mfs.transfer(acc5.address, ethers.utils.parseEther('100'))

    // Allowance token
    await mfs.connect(acc2).approve(forsage.address, ethers.utils.parseUnits('100.0'))
    await mfs.connect(acc3).approve(forsage.address, ethers.utils.parseUnits('100.0'))
    await mfs.connect(acc4).approve(forsage.address, ethers.utils.parseUnits('100.0'))
    await mfs.connect(acc5).approve(forsage.address, ethers.utils.parseUnits('100.0'))

    // set accounts
    await forsage.connect(acc2).registration(acc1.address)
    await forsage.connect(acc3).registration(acc1.address)
    await forsage.connect(acc4).registration(acc2.address)
    await forsage.connect(acc5).registration(acc2.address)
  })

  it ("should be deployed", async function(){
    expect(forsage.address).to.be.properAddress;
  })

  it ("first user should be activated", async function(){
    let active
    for (var i = 0; i < 12; i++) {
      expect(await forsage.activate(acc1.address,i)).to.equal(true);
    }
  })
  
  it ("Get parent", async function(){
    expect(await forsage.getParent()).to.equal(acc1.address)
    expect(await forsage.connect(acc2).getParent()).to.equal(acc1.address)
    expect(await forsage.connect(acc4).getParent()).to.equal(acc2.address)
  })

  it ("Get childs", async function(){
    await forsage.connect(acc5).registration(acc1.address)
    await forsage.connect(acc6).registration(acc1.address)
    await forsage.connect(acc7).registration(acc1.address)
    await forsage.connect(acc8).registration(acc1.address)
    const adminChilds = await forsage.getChilds()
    expect(adminChilds[4]).to.equal(acc7.address)
    expect(adminChilds[5]).to.equal(acc8.address)
  })

  it ("Buy test", async function(){
    await forsage.connect(acc2).buy(0)
  })

  // it ("Change User settings", async function(){
  //   let user = await forsage.users(acc1.address)
  //   expect(user.autoReCycle).to.equal(false)
  //   expect(user.autoUpgrade).to.equal(false)
  //
  //   await forsage.changeAutoReCycle(true)
  //   await forsage.changeAutoUpgrade(true)
  //
  //   user = await forsage.users(acc1.address)
  //   expect(user.autoReCycle).to.equal(true)
  //   expect(user.autoUpgrade).to.equal(true)
  // })

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
