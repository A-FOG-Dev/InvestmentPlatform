import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";
import "@nomicfoundation/hardhat-ignition";
import "hardhat-gas-reporter";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  gasReporter: {
    enabled: true,
    currency: "USD",
    coinmarketcap: "your-coinmarketcap-api-key", // Optional, for real-time price
    outputFile: "reports/gas-report.txt", // Optional, save to file
  }
};

export default config;
