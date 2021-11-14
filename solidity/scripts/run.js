const main = async () => {
    // Hardhat generates a deterministic set of testnet addresses for the local dev chain. Txns default to being sent by first one in this context.
    const [tester1, tester2] = await hre.ethers.getSigners();
    var moderators = [tester1.address];
    var pausers = [tester1.address];
    const baseURI = "testURI/";

    const nftContractFactory = await hre.ethers.getContractFactory('ProjectJ');
    const nftContract = await nftContractFactory.deploy(moderators,pausers,baseURI,tester1.address);
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);

    let mint;
    mint = await nftContract.connect(tester2).mint({value: hre.ethers.utils.parseEther('0.1')});
    console.log("Minted")

    let txn;
    txn = await nftContract.tokenURI(1);
    console.log("Token URI: ",txn);

    // let burn;
    // burn = await nftContract.burn(0);
    // console.log("Burned");
    // balanceOf = await nftContract.balanceOf(tester1.address);
    // console.log("Balance of %s address is: %d",tester1.address,balanceOf);

    // mint = await nftContract.mint(tester2);
    // console.log("Minted")
    // console.log("Balance of %s address is: %d",tester2,balanceOf);
};
  
const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();