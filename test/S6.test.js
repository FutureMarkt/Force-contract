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
    await forsage.connect(acc4).registration(acc1.address)
    await forsage.connect(acc5).registration(acc1.address)
  })

  it ("Update S6 test", async function(){
    await forsage.changeAutoReCycle(true)

    await forsage.connect(acc2).updateS6(acc2.address,0)
    console.log('Result0', await forsage.childsS6Lvl1(acc1.address, 0))
    console.log('Result0', await forsage.childsS6Lvl2(acc1.address, 0))

    await forsage.connect(acc3).updateS6(acc3.address,0)
    console.log('Result1', await forsage.childsS6Lvl1(acc1.address, 1))
    console.log('Result1', await forsage.childsS6Lvl2(acc1.address, 3))

    await forsage.connect(acc4).updateS6(acc4.address,0)
    console.log('Result2', await forsage.childsS6Lvl2(acc1.address, 0))
    console.log('Result2', await forsage.childsS6Lvl2(acc1.address, 0))

    // await forsage.connect(acc5).updateS6(acc5.address,0)
    // console.log('Result3', acc5.address)
    // console.log('Result3', await forsage.childsS6Lvl2(acc1.address, 2))
  })

})
