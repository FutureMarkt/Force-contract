const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("Forsage", function(){
  let acc1, acc2
  let forsage
  beforeEach(async function(){
    [acc1, acc2, acc3] = await ethers.getSigners()
    const Forsage = await ethers.getContractFactory("Forsage", acc1)
    forsage = await Forsage.deploy(acc1.address) // send transaction
    await forsage.deployed() // transaction done

    // set accounts
    await forsage.connect(acc2).registration(acc1.address)
    await forsage.connect(acc3).registration(acc1.address)
  })

  it ("should be deployed", async function(){
    expect(forsage.address).to.be.properAddress;
  })

  it ("should first user be activated", async function(){
    let active
    for (var i = 0; i < 12; i++) {
      expect(await forsage.activate(acc1.address,i)).to.equal(true);
    }
  })

  it ("Update X3 test", async function(){
    const parent = await forsage.connect(acc2).updateX3(1)
    console.log("First account", acc1.address)
    console.log("Parent is", parent)
  })

  it ("Buy test", async function(){
    await forsage.connect(acc2).registration(acc1.address)
    await forsage.connect(acc2).buy(0)
  })
})
