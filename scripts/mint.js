const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
    //const nftContract = await nftContractFactory.deploy();
    //await nftContract.deployed();
    //console.log("Contract deployed to:", nftContract.address);
  
    //const nftContract = await nftContractFactory.attach("0xfcc697ebb913c435c5a48d6cd13c1c829ddad74a");
    const nftContract = await nftContractFactory.attach("0x6adc1f9608f157236C55dF287d3Ad2c59E2bb593");
    console.log("Attached contract:", nftContract.address);

    // Call the function.
    let txn = await nftContract.makeAnEpicNFT({ gasLimit: 2000000 })
    // Wait for it to be mined.
    await txn.wait()
    console.log("Minted Another NFT!")
  
    // txn = await nftContract.makeAnEpicNFT()
    // // Wait for it to be mined.
    // await txn.wait()
    // console.log("Minted NFT #2")
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