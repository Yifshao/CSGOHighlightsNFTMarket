require("@nomiclabs/hardhat-waffle");
require("dotenv").config()



module.exports = {
  solidity: "0.8.4",
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  networks:{
    Huygens_dev :{
      url: process.env.HUYGENS_DEV_URL,
      accounts: [
        process.env.HUYGENS_DEV_PRIVATE_KEY
      ]
    },
    Huygens: {
      url: process.env.HUYGENS_URL,
      accounts: [
        process.env.HUYGENS_PRIVATE_KEY
      ]
    },
  },
};
