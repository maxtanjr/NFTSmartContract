// npx hardhat run scripts/deploy.js --network=rinkeby

const main = async() => {
    const nftContractFactory = await hre.ethers.getContractFactory("MyEpicNFT");
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to this address:", nftContract.address);

    // call the function
    let transaction = await nftContract.mintNFT();
    // wait for the transaction to be mined
    await transaction.wait();

    console.log("Minted NFT #1");

    // transaction = await nftContract.mintNFT();
    // // wait for the transaction to be mined
    // console.log("Minted NFT #2");

}

const runMain = async() => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
}

runMain();