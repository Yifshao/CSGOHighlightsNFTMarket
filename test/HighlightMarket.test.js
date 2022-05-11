const { expect } = require("chai");
const { ethers } = require("hardhat");

const toWei = (num) => ethers.utils.parseEther(num.toString())
const fromWei = (num) => ethers.utils.formatEther(num)

describe("market", function(){
    let deployer, addr1, addr2, addr3, Market_deploy, NFT_deploy;
    let feePercent = 1;
    let URI = "Sample URI";
    let URI2 = "another sample url"
    let URI3 = "asdasf"
    beforeEach(async function(){
        const Market = await ethers.getContractFactory("HighlightMarket");
        const NFT_CSGO = await ethers.getContractFactory("NFT_CSGO");
        [deployer, addr1, addr2, addr3] = await ethers.getSigners();
        Market_deploy = await Market.deploy(feePercent);
        NFT_deploy = await NFT_CSGO.deploy();
    });
    describe("Deployment", function(){
        it("should track name and symbol of the nft collection", async function(){
            expect(await NFT_deploy.name()).to.equal("CSGONFT");
            expect(await NFT_deploy.symbol()).to.equal("CSGO");
        })
        it("should track feeAccount and feePercent of the markerplace", async function(){
            expect(await Market_deploy.feeAccount()).to.equal(deployer.address);
            expect(await Market_deploy.feePercent()).to.equal(feePercent);
        })
    })
    describe("Minting NFTs", function(){
        it("should track each mint nft", async function(){
            await NFT_deploy.connect(addr1).mint(URI)
            expect(await NFT_deploy.tokenCount()).to.equal(1);
            expect(await NFT_deploy.balanceOf(addr1.address)).to.equal(1);
            expect(await NFT_deploy.tokenURI(1)).to.equal(URI);

            await NFT_deploy.connect(addr2).mint(URI)
            expect(await NFT_deploy.tokenCount()).to.equal(2);
            expect(await NFT_deploy.balanceOf(addr2.address)).to.equal(1);
            expect(await NFT_deploy.tokenURI(2)).to.equal(URI);
        })
    })
    describe("Making Highlights", function(){
        beforeEach(async function(){
            await NFT_deploy.connect(addr1).mint(URI)
            await NFT_deploy.connect(addr1).setApprovalForAll(Market_deploy.address, true)
        })
        it("should track newly created highlight, transfer NFT from seller to market and emit Highlightcreated event", async function(){
            await expect(Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1), 2, 7, 7, "abc1", 15, 9))
                .to.emit(Market_deploy, "HighlightCreated")
                .withArgs(
                    1,
                    NFT_deploy.address,
                    1,
                    toWei(1),
                    addr1.address,
                    1,
                    "1v5",
                    "Train",
                    "abc1",
                    15,
                    "Counter-strike No.5"
                )
            expect(await NFT_deploy.ownerOf(1)).to.equal(Market_deploy.address);
            expect(await Market_deploy.itemCount()).to.equal(1);
            const highlight = await Market_deploy.items(1);
            expect(highlight.highlight_id).to.equal(1);
            expect(highlight.nft).to.equal(NFT_deploy.address);
            expect(highlight.token_id).to.equal(1);
            expect(highlight.price).to.equal(toWei(1));
            expect(highlight.sold).to.equal(false);
            expect(highlight.most_sold).to.equal(1);
            expect(highlight.class).to.equal(7);
            expect(highlight.csgo_map).to.equal(7);
            expect(highlight.demo_url).to.equal("abc1");
            expect(highlight.round_num).to.equal(15);
            expect(highlight.player_num).to.equal(9);
        });
        it("should succeed reselling function", async function(){
            await Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1),2,1,0,"abc2",15,3)
            totalpriceinwei2 = await Market_deploy.gettotalprice(1);
            expect(Market_deploy.connect(addr3).buyhighlight(1, {value: totalpriceinwei2}))
            await NFT_deploy.connect(addr1).mint(URI2)
            await NFT_deploy.connect(addr1).setApprovalForAll(Market_deploy.address, true)
            await expect(Market_deploy.connect(addr1).resellhighlight(NFT_deploy.address, 2, toWei(1), 1,0,"abc2",15,3))
                    .to.emit(Market_deploy,"HighlightCreated")
                    .withArgs(
                        2,
                        NFT_deploy.address,
                        2,
                        toWei(1),
                        addr1.address,
                        0,
                        "Quadra Kill",
                        "Dust2",
                        "abc2",
                        15,
                        "Terrorist No.4"
                    )
            expect(await NFT_deploy.ownerOf(2)).to.equal(Market_deploy.address);
            expect(await Market_deploy.itemCount()).to.equal(2);
            const highlight = await Market_deploy.items(2);
            expect(highlight.highlight_id).to.equal(2);
            expect(highlight.nft).to.equal(NFT_deploy.address);
            expect(highlight.token_id).to.equal(2);
            expect(highlight.price).to.equal(toWei(1));
            expect(highlight.sold).to.equal(false);
            expect(highlight.most_sold).to.equal(0);
            expect(highlight.class).to.equal(1);
            expect(highlight.csgo_map).to.equal(0);
            expect(highlight.demo_url).to.equal("abc2");
            expect(highlight.round_num).to.equal(15);
            expect(highlight.player_num).to.equal(3);
            const highlight2 = await Market_deploy.items(1);
            expect(highlight2.sold).to.equal(true);
        });
        it("should fail if the highlight cannot be resold", async function(){
            await Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1),1,1,0,"abc2",15,3)
            totalpriceinwei2 = await Market_deploy.gettotalprice(1);
            expect(Market_deploy.connect(addr3).buyhighlight(1, {value: totalpriceinwei2}))
            await NFT_deploy.connect(addr1).mint(URI2)
            await NFT_deploy.connect(addr1).setApprovalForAll(Market_deploy.address, true)
            await expect(
                Market_deploy.connect(addr1).resellhighlight(NFT_deploy.address, 2, toWei(1), 1,0,"abc2",15,3)
            ).to.be.revertedWith("The highlight cannot be resold.")
        });

        it("should fail if not the owner", async function(){
            await Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1),3,1,0,"abc2",15,3)
            totalpriceinwei2 = await Market_deploy.gettotalprice(1);
            expect(Market_deploy.connect(addr3).buyhighlight(1, {value: totalpriceinwei2}))
            await NFT_deploy.connect(addr2).mint(URI2)
            await NFT_deploy.connect(addr2).setApprovalForAll(Market_deploy.address, true)
            await expect(
                Market_deploy.connect(addr2).resellhighlight(NFT_deploy.address, 2, toWei(1), 1,0,"abc2",15,3)
            ).to.be.revertedWith("It is not owned by the sender.")
        });
        it("should fail if the NFT has not been created", async function(){
            await Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1),3,1,0,"abc2",15,3)
            await NFT_deploy.connect(addr1).mint(URI2)
            await NFT_deploy.connect(addr1).setApprovalForAll(Market_deploy.address, true)
            await expect(
                Market_deploy.connect(addr1).resellhighlight(NFT_deploy.address, 2, toWei(1), 1,0,"abc2",14,3)
            ).to.be.revertedWith("The highlight has not been created before.")
        });
        it("should fail it the NFT has not been sold when reselling", async function(){
            await Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1),3,1,0,"abc2",15,3)
            await NFT_deploy.connect(addr1).mint(URI2)
            await NFT_deploy.connect(addr1).setApprovalForAll(Market_deploy.address, true)
            await expect(
                Market_deploy.connect(addr1).resellhighlight(NFT_deploy.address, 1, toWei(1), 1,0,"abc2",15,3)
            ).to.be.revertedWith("The highlight is being sold now.")
        });
        it("should fail if the highlight has been created before", async function(){
            await Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1),2,0,0,"abc2",15,3)
            await NFT_deploy.connect(addr2).mint(URI2)
            await NFT_deploy.connect(addr2).setApprovalForAll(Market_deploy.address, true)
            await expect(
                Market_deploy.connect(addr2).makehighlight(NFT_deploy.address, 2, toWei(2),3,0,0,"abc2",15,3)
            ).to.be.revertedWith("The highlight has been created before.")
        });
        it("should succeed creating two different highlights", async function(){
            await Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1),2,0,0,"abc2",15,3)
            await NFT_deploy.connect(addr2).mint(URI2)
            await NFT_deploy.connect(addr2).setApprovalForAll(Market_deploy.address, true)
            Market_deploy.connect(addr2).makehighlight(NFT_deploy.address, 2, toWei(2),3,0,0,"abc2",14,3)
        })
        it("should fail if price is set to zero", async function(){
            await expect(
                Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, 0, 2, 0, 0, "abc3", 15, 3)
            ).to.be.revertedWith("Price must be greater than 0")
        });
        it("should fail if round number is set to zero", async function(){
            await expect(
                Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1), 2, 0, 0, "abc4", 0, 3)
            ).to.be.revertedWith("Round number must be greater than 0")
        });
        it("should fail if round number is set to zero", async function(){
            await expect(
                Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1), 2, 0, 0, "abc5", 31, 3)
            ).to.be.revertedWith("Round number must be less or equal to 30")
        });
        it("should fail if the most sold number is not greater than zero", async function(){
            await expect(
                Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1), 0, 0, 0, "abc6", 12, 3)
            ).to.be.revertedWith("The highlight should be sold at least once")
        })
        it("should succeed withdrawing", async function (){
            await Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(1), 2, 7, 7, "abc1", 15, 9)
            await Market_deploy.connect(addr1).withdraw(1);
            expect(await Market_deploy.withdrawornot(1)).to.equal(true);
            expect(await NFT_deploy.ownerOf(1)).to.equal(addr1.address);
        })
    });
    describe("Purchasing highlights", function(){
        let price = 2
        let totalpriceinwei
        beforeEach(async function(){
            await NFT_deploy.connect(addr1).mint(URI)
            await NFT_deploy.connect(addr1).setApprovalForAll(Market_deploy.address, true)
            await Market_deploy.connect(addr1).makehighlight(NFT_deploy.address, 1, toWei(2), 2,0,0,"abc7",12,3)
        })
        it("should update sold item", async function(){
            const sellerInitialEthBal = await addr1.getBalance()
            const feeAcountInitialEthBal = await deployer.getBalance()
            totalpriceinwei = await Market_deploy.gettotalprice(1);
            await expect(Market_deploy.connect(addr2).buyhighlight(1, {value: totalpriceinwei}))
                .to.emit(Market_deploy, "Bought")
                .withArgs(
                    1,
                    NFT_deploy.address,
                    1,
                    toWei(price),
                    addr1.address,
                    addr2.address,
                    1
                )
            const sellerFinalEthBal = await addr1.getBalance()
            const feeAcountFinalEthBal = await deployer.getBalance()
            expect(+fromWei(sellerFinalEthBal)).to.equal(+price + + fromWei(sellerInitialEthBal))

            const fee = (feePercent/100)*price
            expect(+fromWei(feeAcountFinalEthBal)).to.equal(+fee + + fromWei(feeAcountInitialEthBal))
            expect(await NFT_deploy.ownerOf(1)).to.equal(addr2.address);
            expect((await Market_deploy.items(1)).sold).to.equal(true)
            expect(await Market_deploy.buyerstorage(1)).to.equal(addr2.address)
        });

        it("should fail for invalid id inputs or sold highlights or not enough money", async function(){
            await expect(
                Market_deploy.connect(addr2).buyhighlight(2, {value: totalpriceinwei})
            ).to.be.revertedWith("The highlight does not exist.");
            await expect(
                Market_deploy.connect(addr2).buyhighlight(0, {value: totalpriceinwei})
            ).to.be.revertedWith("The highlight does not exist.");
            await expect(
                Market_deploy.connect(addr2).buyhighlight(1, {value: toWei(price)})
            ).to.be.revertedWith("The buyer does not have enough money.");
            await Market_deploy.connect(addr2).buyhighlight(1, {value: totalpriceinwei})
            await expect(
                Market_deploy.connect(deployer).buyhighlight(1, {value: totalpriceinwei})
            ).to.be.revertedWith("The highlight has been sold.");
        });
        it("should succeed resell boughts", async function(){
            totalpriceinwei = await Market_deploy.gettotalprice(1);
            await expect(Market_deploy.connect(addr2).buyhighlight(1, {value: totalpriceinwei}))
                .to.emit(Market_deploy, "Bought")
                .withArgs(
                    1,
                    NFT_deploy.address,
                    1,
                    toWei(price),
                    addr1.address,
                    addr2.address,
                    1
                )
            expect(await NFT_deploy.ownerOf(1)).to.equal(addr2.address);
            await NFT_deploy.connect(addr2).setApprovalForAll(Market_deploy.address, true)
            await Market_deploy.connect(addr2).sellboughts(1,toWei(3));
            expect(await Market_deploy.buyersall(2,addr2.address)).to.equal(false);
        })
    })
})