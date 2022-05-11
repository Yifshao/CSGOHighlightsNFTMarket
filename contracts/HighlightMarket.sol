//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//Here I import ReentrancyGuard to prevent reentrancy when making transactions.
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract HighlightMarket is ReentrancyGuard{

// Some parameters defined

    enum maps {
        Dust2, 
        Mirage, 
        Inferno, 
        Nuke,
        Overpass, 
        Ancient, 
        Vertigo, 
        Train
    }
    enum classification {
        triple_kill,
        quadra_kill,
        penta_kill,
        one_vs_one,
        one_vs_two,
        one_vs_three,
        one_vs_four,
        one_vs_five
    }

    enum player {
        T_1,
        T_2,
        T_3,
        T_4,
        T_5,
        CT_1,
        CT_2,
        CT_3,
        CT_4,
        CT_5
    }

//Define the structure of Highlight

    struct Highlight{
        uint256 highlight_id;
        IERC721 nft;
        uint256 token_id;
        uint256 price;
        address payable seller;
        bool sold;
        uint256 most_sold;
        classification class;
        maps csgo_map;
        string demo_url;
        uint256 round_num;
        player player_num;
    }

// Define mappings which are used to store some data

    mapping(string => bool) public appear_or_not;

    mapping(string => uint256) public left_sells;

    mapping(string => bool) public sold_or_not;

    mapping(string => address) public owner;

    mapping(string => bool) public appear_or_not_all;

    mapping(uint256 => address) public buyerstorage;
    
    mapping(uint => mapping(address => bool)) public buyersall;

    mapping(uint => mapping(address => bool)) public sellerall;

    mapping(uint256 => Highlight) public items;

    mapping(uint => mapping(address => uint)) public buyerpriceall;

    mapping(uint => mapping(address => uint)) public buyertotalprice;

    mapping(uint => mapping(address => uint)) public sellerpriceall;

    mapping(uint => mapping(address => uint)) public sellertotalprice;

    mapping(uint => uint) public originalmostsold;

    mapping(uint => bool) public withdrawornot;

    mapping(address => uint) public spentmoney;

    mapping(address => uint) public earnmoney;
   
    uint256 new_most_sold;

//feeAccount is the account to receive transaction fee.

    address payable public immutable feeAccount;

    uint256 public immutable feePercent;

    uint256 public itemCount;

    string allconnect;

//Define events

    event HighlightCreated (
        uint256 highlight_id,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller,
        uint256 most_sold_num,
        string class,
        string map,
        string demo_url,
        uint256 round_num,
        string player_num
    );


    event Bought (
        uint256 highlight_id,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller,
        address indexed buyer,
        uint256 left_sold
    );

//The constructor sets the account to receive transaction fee and the percentage of transaction fee.

    constructor(uint256 _feePercent) {
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

//Function getmap transforms enum map to string.

    function getmap(maps _map) internal pure returns (string memory) {
        require(uint256(_map) <= 7, "The map does not exist.");
        if (maps.Dust2 == _map) return "Dust2";
        if (maps.Mirage == _map) return "Mirage";
        if (maps.Inferno == _map) return "Inferno";
        if (maps.Nuke == _map) return "Nuke";
        if (maps.Overpass == _map) return "Overpass";
        if (maps.Ancient == _map) return "Ancient";
        if (maps.Vertigo == _map) return "Vertigo";
        if (maps.Train == _map) return "Train";
        return '';
    }

//Function getclass transforms enum classification to string

    function getclass(classification _class) internal pure returns (string memory){
        require(uint256(_class) <= 7, "The class of highlight does not exist.");
        if (classification.triple_kill == _class) return "Triple Kill";
        if (classification.quadra_kill == _class) return "Quadra Kill";
        if (classification.penta_kill == _class) return "Penta Kill";
        if (classification.one_vs_one == _class) return "1v1";
        if (classification.one_vs_two == _class) return "1v2";
        if (classification.one_vs_three == _class) return "1v3";
        if (classification.one_vs_four == _class) return "1v4";
        if (classification.one_vs_five == _class) return "1v5";
        return "";
    }

//Function getplayer transforms enum player to string

    function getplayer(player _player) internal pure returns (string memory){
        require(uint256(_player) <= 9, "The player number does not exist.");
        if (player.CT_1 == _player) return "Counter-strike No.1";
        if (player.CT_2 == _player) return "Counter-strike No.2";
        if (player.CT_3 == _player) return "Counter-strike No.3";
        if (player.CT_4 == _player) return "Counter-strike No.4";
        if (player.CT_5 == _player) return "Counter-strike No.5";
        if (player.T_1 == _player) return "Terrorist No.1";
        if (player.T_2 == _player) return "Terrorist No.2";
        if (player.T_3 == _player) return "Terrorist No.3";
        if (player.T_4 == _player) return "Terrorist No.4";
        if (player.T_5 == _player) return "Terrorist No.5";
        return "";
    }

//The following two functions work like append in python.

    function append_unique(string memory a, uint256 b, player c, maps d) internal pure returns (string memory) {
        return string(abi.encodePacked(getmap(d), a, Strings.toString(b), getplayer(c)));
    }

    function append(classification a, maps b, string memory c, uint256 d, player e) internal pure returns (string memory) {
        return string(abi.encodePacked(getclass(a), getmap(b), c, Strings.toString(d), getplayer(e)));
    }

//The function makehighlight creates a new NFT for a new highlight.
//Has several requirements before running function (to save gas fee)
//All of the requirement checks are also set at frontend. This is a double insurance.
//1. The price of NFT should be positive.
//2. The round number should be an integer between 1-30
//3. The most sold number should be larger or equal to 1.
//4. The highlight should be a new highlight whose NFT has not been created before.

    function makehighlight(IERC721 _nft, uint256 _tokenId, uint256 _price, uint256 _most_sold_num,
                            classification _class, maps _csgo_map, string memory _demo_url, uint256 _round_num, 
                            player _player_num) external nonReentrant{
        require(_price > 0, "Price must be greater than 0");
        require(_round_num > 0, "Round number must be greater than 0");
        require(_round_num <= 30, "Round number must be less or equal to 30");
        require(_most_sold_num >= 1, "The highlight should be sold at least once");
        require(appear_or_not[append_unique(_demo_url, _round_num, _player_num, _csgo_map)] == false, "The highlight has been created before.");
        //Set this highlight as appeared (which can be resold later).
        appear_or_not[append_unique(_demo_url, _round_num, _player_num, _csgo_map)] = true;
        allconnect = append(_class, _csgo_map, _demo_url, _round_num, _player_num);
        appear_or_not_all[allconnect] = true;
        //Set the owner of highlight.
        owner[allconnect] = msg.sender;
        sold_or_not[allconnect] = false;
        //Set the most_sold number.
        if(_most_sold_num == 1){
            new_most_sold = 0;
            left_sells[allconnect] = new_most_sold;
        }
        else{
            new_most_sold = _most_sold_num - 1;
            left_sells[allconnect] = new_most_sold;
        }
        //Store the NFT in blockchain.
        itemCount = itemCount + 1;
        //The market will own the NFT temporarily
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        //Store the information of NFT(highlight) in blockchain.
        items[itemCount] = Highlight(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false,
            new_most_sold,
            _class,
            _csgo_map,
            _demo_url,
            _round_num,
            _player_num
        );
        originalmostsold[itemCount] = _most_sold_num;
        //Emit event.
        emit HighlightCreated(
            itemCount,
            address(_nft),
            _tokenId,
            _price,
            msg.sender,
            new_most_sold,
            getclass(_class),
            getmap(_csgo_map),
            _demo_url,
            _round_num,
            getplayer(_player_num)
        );
    }

//Function resellhighlight creates NFT for old highlight whose NFT has been sold and the highlight can still be sold.
//Has several requirements before running function (to save gas fee)
//All of the requirement checks are also set at frontend. This is a double insurance.
//1. The price of NFT should be positive.
//2. The round number should be an integer between 1-30
//3. The NFT of this highlight should be created before.
//4. The highlight's owner should be the person who run this function.
//5. The NFT of this highlight should be sold.
//6. The left most_sold number should be larger than 0. (The highlight should be soldable).

    function resellhighlight(IERC721 _nft, uint256 _tokenId, uint256 _price, 
                            classification _class, maps _csgo_map, string memory _demo_url, uint256 _round_num, 
                            player _player_num) external nonReentrant{
        require(_price > 0, "Price must be greater than 0");
        require(_round_num > 0, "Round number must be greater than 0");
        require(_round_num <= 30, "Round number must be less or equal to 30");
        allconnect = append(_class, _csgo_map, _demo_url, _round_num, _player_num);
        require(appear_or_not_all[allconnect] == true, "The highlight has not been created before.");
        require(owner[allconnect] == msg.sender, "It is not owned by the sender.");
        require(sold_or_not[allconnect] == true, "The highlight is being sold now.");
        //Check the new most_sold number
        new_most_sold = left_sells[allconnect];
        require(new_most_sold > 0, "The highlight cannot be resold.");
        //Update most_sold number.
        if(new_most_sold == 1){
            new_most_sold = 0;
            left_sells[allconnect] = new_most_sold;
        }
        else{
            new_most_sold = new_most_sold - 1;
            left_sells[allconnect] = new_most_sold;
        }
        //Store NFT in blockchain
        itemCount = itemCount + 1;
        //The market will own the NFT temporarily
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        sold_or_not[allconnect] = false;
        //Store the information of NFT(highlight) in blockchain.
        items[itemCount] = Highlight(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false,
            new_most_sold,
            _class,
            _csgo_map,
            _demo_url,
            _round_num,
            _player_num
        );
        //Emit event.
        emit HighlightCreated(
            itemCount,
            address(_nft),
            _tokenId,
            _price,
            msg.sender,
            new_most_sold,
            getclass(_class),
            getmap(_csgo_map),
            _demo_url,
            _round_num,
            getplayer(_player_num)
        );
    }

//Function gettotalprice calculated the total price the buyer should pay (price of NFT+fee).

    function gettotalprice(uint256 _highlight_id) view public returns(uint256){
        //The price the buyer should pay is price + feePercent*price
        return(items[_highlight_id].price*(100+feePercent)/100);
    }

//Function buyhighlight let the user able to buy NFT which is on selling.
//Has several requirements before running function (to save gas fee)
//1. The NFT should exist.
//2. The buyer should have enough money to buy the NFT.
//3. The NFT should be on selling.

    function buyhighlight(uint256 _highlight_id) external payable nonReentrant{
        require(_highlight_id > 0, "The highlight does not exist.");
        require(_highlight_id <= itemCount, "The highlight does not exist.");
        //Calculate total price
        uint256 _totalprice = gettotalprice(_highlight_id);
        require(msg.value >= _totalprice, "The buyer does not have enough money.");
        Highlight storage highlight = items[_highlight_id];
        require(!highlight.sold, "The highlight has been sold.");
        //Pay money
        highlight.seller.transfer(highlight.price);
        //Receive transactionfee
        feeAccount.transfer(_totalprice - highlight.price);
        highlight.sold = true;
        //Give NFT to buyer
        highlight.nft.transferFrom(address(this), msg.sender, highlight.token_id);
        sold_or_not[append(highlight.class, highlight.csgo_map, highlight.demo_url, highlight.round_num, highlight.player_num)] = true;
        //Store conditions.
        buyerstorage[_highlight_id] = msg.sender;
        buyersall[_highlight_id][msg.sender] = true;
        sellerall[_highlight_id][highlight.seller] = true;
        buyerpriceall[_highlight_id][msg.sender] = highlight.price;
        sellerpriceall[_highlight_id][highlight.seller] = highlight.price;
        sellertotalprice[_highlight_id][highlight.seller] = _totalprice;
        buyertotalprice[_highlight_id][msg.sender] = _totalprice;
        spentmoney[msg.sender] += _totalprice;
        earnmoney[highlight.seller] += highlight.price;
        //Emit event.
        emit Bought(
            _highlight_id,
            address(highlight.nft),
            highlight.token_id,
            highlight.price,
            highlight.seller,
            msg.sender,
            highlight.most_sold
        );
    }

//Function sellboughts enables buyer to sell the NFT they bought.
//Has several requirements before running function (to save gas fee)
//1. The NFT should exist.
//2. The NFT should be ownered by the person who run this function.
//3. The new price set should be positive.

    function sellboughts(uint256 _highlight_id, uint256 _price) external nonReentrant{
        require(_highlight_id > 0, "The highlight does not exist.");
        require(_highlight_id <= itemCount, "The highlight does not exist.");
        require(buyerstorage[_highlight_id] == msg.sender, "The highlight is not owned by the sender");
        require(_price > 0, "Price must be greater than 0");
        //Get the information of NFT.
        Highlight storage highlight = items[_highlight_id];
        highlight.seller = payable(msg.sender);
        highlight.sold = false;
        highlight.price = _price;
        //After writing the new information of highlight, transfer the NFT to market
        highlight.nft.transferFrom(msg.sender, address(this), highlight.token_id);
        //Store the new NFT
        items[_highlight_id] = highlight;
        sold_or_not[append(highlight.class, highlight.csgo_map, highlight.demo_url, highlight.round_num, highlight.player_num)] = false;
        buyerstorage[_highlight_id] = address(0);
    }

//Function withdraw enables sellers to withdraw their selling NFTs.
//Has several requirements before running function (to save gas fee)
//1. The NFT should exist.
//2. The NFT should be ownered by the person who run this function.

    function withdraw(uint256 _highlight_id) external nonReentrant{
        require(_highlight_id > 0, "The highlight does not exist.");
        require(_highlight_id <= itemCount, "The highlight does not exist.");
        require(items[_highlight_id].seller == msg.sender);
        //Restore the changes caused by this NFT
        Highlight storage highlight = items[_highlight_id];
        allconnect = append_unique(highlight.demo_url, highlight.round_num, highlight.player_num, highlight.csgo_map);
        if(highlight.most_sold + 1 == originalmostsold[_highlight_id]){
            appear_or_not[allconnect] = false;
            appear_or_not_all[allconnect] = false;
            owner[allconnect] = address(0);
            left_sells[allconnect] = 0;
        }
        else{
            left_sells[allconnect] ++;
            sold_or_not[allconnect] = true;
        }
        highlight.nft.transferFrom(address(this), msg.sender, highlight.token_id);
        withdrawornot[_highlight_id] = true;
    }

}