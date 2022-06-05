const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("Case1", function(){
  let acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, acc10, acc11
  let forsage
  let mfs
  beforeEach(async function(){
    [acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, acc10, acc11] = await ethers.getSigners()

    // Deploy token contract
    const MFS = await ethers.getContractFactory("tBUSD", acc1)
    mfs = await MFS.deploy() // send transaction
    await mfs.deployed() // transaction done

    // Deploy system contract
    const Forsage = await ethers.getContractFactory("Forsage", acc1)
    forsage = await Forsage.deploy(mfs.address) // send transaction
    await forsage.deployed() // transaction done

    await mfs.transfer(acc2.address, ethers.utils.parseEther('1000000'))
    await mfs.transfer(acc3.address, ethers.utils.parseEther('1000000'))
    await mfs.transfer(acc4.address, ethers.utils.parseEther('1000000'))
    await mfs.transfer(acc5.address, ethers.utils.parseEther('1000000'))
    await mfs.transfer(acc6.address, ethers.utils.parseEther('1000000'))
    await mfs.transfer(acc7.address, ethers.utils.parseEther('1000000'))
    await mfs.transfer(acc8.address, ethers.utils.parseEther('1000000'))
    await mfs.transfer(acc9.address, ethers.utils.parseEther('1000000'))
    await mfs.transfer(acc10.address, ethers.utils.parseEther('1000000'))

    // Allowance token
    await mfs.connect(acc2).approve(forsage.address, ethers.utils.parseUnits('1000000.0'))
    await mfs.connect(acc3).approve(forsage.address, ethers.utils.parseUnits('1000000.0'))
    await mfs.connect(acc4).approve(forsage.address, ethers.utils.parseUnits('1000000.0'))
    await mfs.connect(acc5).approve(forsage.address, ethers.utils.parseUnits('1000000.0'))
    await mfs.connect(acc6).approve(forsage.address, ethers.utils.parseUnits('1000000.0'))
    await mfs.connect(acc7).approve(forsage.address, ethers.utils.parseUnits('1000000.0'))
    await mfs.connect(acc8).approve(forsage.address, ethers.utils.parseUnits('1000000.0'))
    await mfs.connect(acc9).approve(forsage.address, ethers.utils.parseUnits('1000000.0'))
    await mfs.connect(acc10).approve(forsage.address, ethers.utils.parseUnits('1000000.0'))
  })

  it ("Case", async function(){
    await forsage.connect(acc2).registration(acc1.address)
    for (let i = 0; i < 12; i++) {
        await forsage.connect(acc2).buy(i)
    }

    await forsage.connect(acc3).registration(acc2.address)
    for (let i = 0; i < 12; i++) {
        await forsage.connect(acc3).buy(i)
    }

    await forsage.connect(acc4).registration(acc2.address)
    for (let i = 0; i < 12; i++) {
        await forsage.connect(acc4).buy(i)
    } 

    await forsage.connect(acc5).registration(acc3.address)
    for (let i = 0; i < 12; i++) {
        await forsage.connect(acc5).buy(i)
    } 

    await forsage.connect(acc6).registration(acc3.address)
    for (let i = 0; i < 12; i++) {
        await forsage.connect(acc6).buy(i)
    } 

    await forsage.connect(acc7).registration(acc3.address)
    for (let i = 0; i < 12; i++) {
        await forsage.connect(acc7).buy(i)
    } 

    await forsage.connect(acc8).registration(acc3.address)
    for (let i = 0; i < 12; i++) {
        await forsage.connect(acc8).buy(i)
    } 

    await forsage.connect(acc9).registration(acc4.address)
    for (let i = 0; i < 12; i++) {
        await forsage.connect(acc9).buy(i)
    } 

    await forsage.connect(acc10).registration(acc4.address)
    for (let i = 0; i < 12; i++) {
        await forsage.connect(acc10).buy(i)
    } 
  })

})