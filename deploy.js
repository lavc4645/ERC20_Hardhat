const ethers = require("ethers");
const fs = require("fs-extra");
require("dotenv").config();

async function main() {
  /**
   * Providing the RPC endpoint
   * Ganache Endpoint
   */
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);

  /**
   * Creating the wallet
   * Ganache Account 2
   */
  const wallet = new ethers.Wallet(
    process.env.PRIVATE_KEY,                // Adding the privatekey using .env file 
    provider
  );

  /**
   * Reading the ABI file using the 'fs module'
   * and Binary file
   */
  const abi = fs.readFileSync("./SourceToken_sol_SourceToken.abi", "utf8");
  const binary = fs.readFileSync("./SourceToken_sol_SourceToken.bin", "utf8");

  /**
   * Contract Interaction
   *    1. "Contract"
   *    2. "ContractFactory"
   */
  const contractFactory = new ethers.ContractFactory(abi, binary, wallet);
  console.log("Deploying, please wait...");

  /**
   * Deploying Contract
   *    Constructor have 3 arguments
   *    1. intialSupply of token
   *    2. name of token
   *    3. symbol of token
   */
  const contract = await contractFactory.deploy(
    initialSupply=30,
    name_="SourceSoft",
    symbol_= "SRC"
    );              
  // STOP here! Wait for contract to deploy

//   console.log("THis is Contract Object", contract);

  /**
   * Interacting with Contract using its functions
   */
  const nameOfToken = await contract.name();
  console.log(`Name : ${nameOfToken}`);

  const symbolOfToken = await contract.symbol();
  console.log(`Symbol : ${symbolOfToken}`);

  const totalSupplyOfToken = await contract.totalSupply();
  console.log(`Total Supply : ${totalSupplyOfToken}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
