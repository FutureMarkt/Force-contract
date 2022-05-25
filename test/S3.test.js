const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("S3", function(){
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

    await mfs.transfer(acc2.address, ethers.utils.parseEther('1000'))
    await mfs.transfer(acc3.address, ethers.utils.parseEther('1000'))
    await mfs.transfer(acc4.address, ethers.utils.parseEther('1000'))
    await mfs.transfer(acc5.address, ethers.utils.parseEther('1000'))
    await mfs.transfer(acc6.address, ethers.utils.parseEther('1000'))

    // Allowance token
    await mfs.connect(acc2).approve(forsage.address, ethers.utils.parseUnits('100.0'))
    await mfs.connect(acc3).approve(forsage.address, ethers.utils.parseUnits('100.0'))
    await mfs.connect(acc4).approve(forsage.address, ethers.utils.parseUnits('100.0'))
    await mfs.connect(acc5).approve(forsage.address, ethers.utils.parseUnits('100.0'))
    await mfs.connect(acc6).approve(forsage.address, ethers.utils.parseUnits('1000.0'))

    // set accounts
    await forsage.connect(acc2).registration(acc1.address)
    await forsage.connect(acc3).registration(acc1.address)
    await forsage.connect(acc4).registration(acc1.address)
    await forsage.connect(acc5).registration(acc1.address)
    await forsage.connect(acc6).registration(acc1.address)
  })

  it ("Simple update S3 - first child", async function(){

    
    await forsage.connect(acc2).buy(0)
    expect(await forsage.childsS6Lvl1(acc1.address, 0, 0)).to.equal(acc2.address)

    await forsage.connect(acc2).buy(1)
    expect(await forsage.childsS6Lvl1(acc1.address, 1, 0)).to.equal(acc2.address)

    let start = await mfs.connect(acc2).balanceOf(acc2.address)
    console.log('Start Balance', ethers.utils.formatUnits(start, "ether"))

    await forsage.connect(acc2).buy(2)
    expect(await forsage.childsS3(acc1.address, 2, 0)).to.equal(acc2.address)
    

    // const frozen = await forsage.matrixS3(acc1.address, 0)
    // expect(frozen.frozenMoneyS3).to.equal(await forsage.prices(0))


    const finish = await mfs.connect(acc2).balanceOf(acc2.address)
    console.log(ethers.utils.formatUnits(finish, "ether"))
  })

  /*it ("Update S3 test", async function(){
    await forsage.connect(acc2).buy(0)
    expect(await forsage.childsS3(acc1.address, 0, 0)).to.equal(acc2.address)

    await forsage.connect(acc3).buy(0)
    expect(await forsage.childsS3(acc1.address, 0, 1)).to.equal(acc3.address)

    await forsage.connect(acc4).buy(0)
    expect(await forsage.childsS3(acc1.address, 0, 2)).to.equal(acc4.address)

    await forsage.connect(acc5).buy(0)
    expect(await forsage.childsS3(acc1.address, 0, 3)).to.equal(acc5.address)
  }) */

})
