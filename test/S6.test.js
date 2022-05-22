const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("S6", function(){
  let acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, acc10
  let forsage
  let mfs
  beforeEach(async function(){
    [acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, acc10] = await ethers.getSigners()

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
    await mfs.transfer(acc7.address, ethers.utils.parseEther('1000'))
    await mfs.transfer(acc8.address, ethers.utils.parseEther('1000'))
    await mfs.transfer(acc9.address, ethers.utils.parseEther('1000'))
    await mfs.transfer(acc10.address, ethers.utils.parseEther('1000'))

    // Allowance token
    await mfs.connect(acc2).approve(forsage.address, ethers.utils.parseUnits('100.0'))
    await mfs.connect(acc3).approve(forsage.address, ethers.utils.parseUnits('100.0'))
    await mfs.connect(acc4).approve(forsage.address, ethers.utils.parseUnits('100.0'))
    await mfs.connect(acc5).approve(forsage.address, ethers.utils.parseUnits('100.0'))
    await mfs.connect(acc6).approve(forsage.address, ethers.utils.parseUnits('1000.0'))
    await mfs.connect(acc7).approve(forsage.address, ethers.utils.parseUnits('1000.0'))
    await mfs.connect(acc8).approve(forsage.address, ethers.utils.parseUnits('1000.0'))
    await mfs.connect(acc9).approve(forsage.address, ethers.utils.parseUnits('1000.0'))
    await mfs.connect(acc10).approve(forsage.address, ethers.utils.parseUnits('1000.0'))

    // set accounts
    await forsage.connect(acc2).registration(acc1.address)
    await forsage.connect(acc3).registration(acc1.address)
    await forsage.connect(acc4).registration(acc1.address)
    await forsage.connect(acc5).registration(acc1.address)
    await forsage.connect(acc6).registration(acc1.address)
    await forsage.connect(acc7).registration(acc1.address)
    await forsage.connect(acc8).registration(acc1.address)
    await forsage.connect(acc9).registration(acc1.address)
    await forsage.connect(acc10).registration(acc1.address)
  })

  it ("Simple update S6 - first child", async function(){
    let start = await mfs.connect(acc2).balanceOf(acc2.address)
    start = +start

    let slot = await forsage.matrixS6(acc1.address, 0)
    console.log('Start slot', slot.slot)

    
    await forsage.connect(acc2).buy(0)
    expect(await forsage.childsS6Lvl1(acc1.address, 0, 0)).to.equal(acc2.address)
    
    await forsage.connect(acc3).buy(0)
    expect(await forsage.childsS6Lvl1(acc1.address, 0, 1)).to.equal(acc3.address)
    
    await forsage.connect(acc4).buy(0)
    expect(await forsage.childsS6Lvl2(acc1.address, 0, 0)).to.equal(acc4.address)
    
    await forsage.connect(acc5).buy(0)
    expect(await forsage.childsS6Lvl2(acc1.address, 0, 1)).to.equal(acc5.address)
    
    await forsage.connect(acc6).buy(0)
    expect(await forsage.childsS6Lvl2(acc1.address, 0, 2)).to.equal(acc6.address)
    
    await forsage.connect(acc7).buy(0)
    expect(await forsage.childsS6Lvl2(acc1.address, 0, 3)).to.equal(acc7.address)
    
    await forsage.connect(acc8).buy(0)
    expect(await forsage.childsS6Lvl1(acc1.address, 0, 2)).to.equal(acc8.address)
    
    await forsage.connect(acc9).buy(0)
    expect(await forsage.childsS6Lvl1(acc1.address, 0, 3)).to.equal(acc9.address)
    
    await forsage.connect(acc10).buy(0)
    expect(await forsage.childsS6Lvl2(acc1.address, 0, 4)).to.equal(acc10.address)

    slot = await forsage.matrixS6(acc1.address, 0)
    console.log('New slot', slot.slot)


    const finish = await mfs.connect(acc2).balanceOf(acc2.address)
    console.log(finish)
  })

  /* it ("Update S6 test", async function(){
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

    await forsage.connect(acc5).updateS6(acc5.address,0)
    console.log('Result3', acc5.address)
    console.log('Result3', await forsage.childsS6Lvl2(acc1.address, 1))

    await forsage.connect(acc6).updateS6(acc6.address,0)
    console.log('Result4', acc6.address)
    console.log('Result4', await forsage.childsS6Lvl2(acc1.address, 2))

    await forsage.connect(acc6).updateS6(acc6.address,0)
    console.log('Result5', acc6.address)
    console.log('Result5', await forsage.childsS6Lvl2(acc1.address, 3))

    await forsage.connect(acc6).updateS6(acc6.address,0)
    console.log('Result6', acc6.address)
    console.log('Result6', await forsage.childsS6Lvl2(acc1.address, 3))

    await forsage.connect(acc6).updateS6(acc6.address,0)
    console.log('Result7', acc6.address)
    console.log('Result7', await forsage.childsS6Lvl2(acc1.address, 3))

    await forsage.connect(acc6).updateS6(acc6.address,0)
    console.log('Result8', acc6.address)
    console.log('Result8', await forsage.childsS6Lvl2(acc1.address, 3))

    await forsage.connect(acc6).updateS6(acc6.address,0)
    console.log('Result9', acc6.address)
    console.log('Result9', await forsage.childsS6Lvl2(acc1.address, 3))
  }) */

})
