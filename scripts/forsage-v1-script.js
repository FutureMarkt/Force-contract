// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Forsage = await ethers.getContractFactory("Forsage")
  forsage = await Forsage.deploy('0x8c58026555C7Fa465C81f16374DAE3d89FD9AEDa', '0x4109918CE2e3fFfDe0EC63a5F8b760a70B960498') // send transaction
  await forsage.deployed();

  console.log("Forsage deployed to:", forsage.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
