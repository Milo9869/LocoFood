async function main() {
    const LocoFood = await ethers.getContractFactory("LocoFood");
    const locoFood = await LocoFood.deploy();
    await locoFood.deployed();
    console.log("LocoFood deployed to:", locoFood.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
