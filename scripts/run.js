// for testing on local blockchain

const main = async() => {
    const nftContractFactory = await hre.ethers.getContractFactory("MyEpicNFT");

    const [owner] = await ethers.getSigners();

    console.log("Deploying contracts with the account: ", owner.address);

    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to this address:", nftContract.address);

    // call the function
    let transaction = await nftContract.mintNFT();
    // wait for the transaction to be mined
    await transaction.wait();

    // mint another time
    transaction = await nftContract.mintNFT();
    // wait for the transaction to be mined
    await transaction.wait();

    // to check if we can access the number of NFTs minted by the owner so far
    let numMinted = await nftContract.numNFTsOwnedMap(owner.address);

    console.log("Number of NFTs owned so far: ", numMinted);

    // show IDs of minted tokens so far
    let tokenIdArr = await nftContract.getTokenIdsByAddress(owner.address);
    for (let i = 0; i < tokenIdArr.length; i++) {

        // use the ethers library to convert from bignumber to a number
        let id = ethers.BigNumber.from(tokenIdArr[i]).toNumber();

        console.log("Token ID: ", id);
    }
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