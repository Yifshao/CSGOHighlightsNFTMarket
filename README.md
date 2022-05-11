# CSGO Highlights NFT Market
![License](https://img.shields.io/badge/license-MIT-737CA1?style=flat-square) 
![Node_Badge](https://img.shields.io/badge/node-16.14.2-green?style=flat-square)
![Npm_Badge](https://img.shields.io/badge/npm-8.6.0-yellow?style=flat-square)
![React Badge](https://img.shields.io/badge/React-17.0.2-45b8d8?style=flat-square)
![Solidity_Badge](https://img.shields.io/badge/Solidity-%5E0.8.4-363636?style=flat-square)
![Hardhat](https://img.shields.io/badge/Hardhat-2.8.4-F0E8E0?style=flat-square)
![ethers.js](https://img.shields.io/badge/ethers.js-%5E5.5.4-363636?style=flat-square)

Final Project of ELEN E6883 (2022 Spring).

Author: Yifan Shao<br>
UNI: ys3349

**Introduction**

CSGO Highlights NFT Market is a NFT Market where you can sell your CSGO highlights as well as buy the NFTs of others' highlights. 

The smart contracts codes are in folder "contracts".

The frontend codes are in folder "src".

**Instructions**

PS: The instructions are a little bit long. If you just want to see the demo of my DAPP, you can choose to watch the demo video:

I choose to use Hardhat Testnet + MetaMask instead of Huygens + Ale wallet for the demo of my decentralized application (DAPP). I have emailed Professor Li and he allowed me to do that.

The (main) reason I choose to use Hardhat Testnet + MetaMask is that using Huygens + Ale wallet needs to use mcp.js to call functions in smart contracts. When calling transaction functions, mcp.js requires the user to enter password, which is not safe in a DAPP as blockchain is trustless. There are also some incompatibilities when using mcp.js.

Using ethers.js can solve all the problems of using mcp.js, but only MetaMask supports ethers.js now. Since professor Li told me that Metamask will be supported in the next version of ComputeCoin Network, I choose to use Hardhat Testnet+MetaMask for this demo. When next version of CCN is released, you can choose to use Huygens+MetaMask to use my DAPP. I have also deployed my smart contracts on Huygens successfully (the ABIs and addresses are stored in "/src/Huygens_contractsData"). I will also update my codes when next version of CCN is released.

To experience my DAPP, please follow these steps:

1. Download and install node.js. (Version should larger or equal to 16.14.2 and smaller than 17.0.0). Link: https://nodejs.org/en/
2. Install Hardhat. ```npm install --save-dev hardhat@2.8.4```
3. Download my codes. I recommend you to use Visual Studio Code as IDE. Link: https://code.visualstudio.com/
4. In the terminal (of Visual Studio Code), run ```npm i```
5. run ```npx hardhat node```. Then in the terminal you will see 20 test accounts. Record several private keys of the accounts, which will be used later. Please leave this terminal and do not close it.
6. Install MetaMask. Link: https://metamask.io/ I recommend you to use Chrome explorer.
7. Open your MetaMask. Import several accounts using private keys got in step 5.
<img width="356" alt="image" src="https://user-images.githubusercontent.com/80507783/167769738-d0cf2a83-f533-453d-83f3-c741c9ce17c7.png">
8. Add Hardhat Testnet in your MetaMask network. Here is the information you need.
<img width="361" alt="image" src="https://user-images.githubusercontent.com/80507783/167769992-2d07fbd4-5167-4ee2-8a26-c8ef4a57a242.png">
9. Now open a new terminal in Visual Studio Code. Run ```npm start```.<br>
10. Go to http://localhost:3000/ and enjoy it!

