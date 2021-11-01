//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TileNFT.sol";

// Using this contract:
// First the auctioneer must approve this contract. Preferrably for all tokens.
// Then the auctioneer must activate the openAuction for each NFT they intend to auction.

contract TileAuction is Ownable {
    struct Auction {
        uint256 highestBid;
        uint256 closingTime;
        address highestBidder;
        address originalOwner;
        bool isActive;
    }

    // NFT id => Auction data
    mapping(uint256 => Auction) public auctions;

    // NFT contract interface
    TileNFT private sNft_;

    // ETH balance
    uint256 public balances;
    uint256 public taxPrice;
    mapping(address => uint256) claimableBids;

    /**
     * @dev New Auction Opened Event
     * @param nftId Auction NFT Id
     * @param startingBid NFT starting bid price
     * @param closingTime Auction close time
     * @param originalOwner Auction creator address
     */
    event NewAuctionOpened(
        uint256 nftId,
        uint256 startingBid,
        uint256 closingTime,
        address originalOwner
    );

    /**
     * @dev Auction Closed Event
     * @param nftId Auction NFT id
     * @param highestBid Auction highest bid
     * @param highestBidder Auction highest bidder
     */
    event AuctionClosed(
        uint256 nftId,
        uint256 highestBid,
        address highestBidder
    );

    /**
     * @dev Bid Placed Event
     * @param nftId Auction NFT id
     * @param bidPrice Bid price
     * @param bidder Bidder address
     */
    event BidPlaced(uint256 nftId, uint256 bidPrice, address bidder);

    /**
     * @dev Receive ETH. msg.data is empty
     */
    receive() external payable {
        balances += msg.value;
    }

    /**
     * @dev Receive ETH. msg.data is not empty
     */
    fallback() external payable {
        balances += msg.value;
    }

    constructor(TileNFT _sNft) {
        require(address(_sNft) != address(0), "Invalid address");
        sNft_ = _sNft;
        balances = 0;
    }

    /**
     * @dev Open Auction
     * @param _nftId NFT id
     * @param _sBid Starting bid price
     * @param _duration Auction opening duration time
     */
    function openAuction(
        uint256 _nftId,
        uint256 _sBid,
        uint256 _duration
    ) external {
        require(auctions[_nftId].isActive == false, "Ongoing auction detected");
        require(_duration > 0 && _sBid > 0, "Invalid input");
        require(sNft_.ownerOf(_nftId) == msg.sender, "Not NFT owner");
        require(sNft_.isCoreTile(_nftId), "Must be a core tile!");

        // NFT Transfer to contract
        sNft_.transferFrom(msg.sender, address(this), _nftId);

        // Opening new auction
        auctions[_nftId].highestBid = _sBid;
        auctions[_nftId].closingTime = block.timestamp + _duration;
        auctions[_nftId].highestBidder = msg.sender;
        auctions[_nftId].originalOwner = msg.sender;
        auctions[_nftId].isActive = true;

        emit NewAuctionOpened(
            _nftId,
            auctions[_nftId].highestBid,
            auctions[_nftId].closingTime,
            auctions[_nftId].highestBidder
        );
    }

    /**
     * @dev Place Bid
     * @param _nftId NFT id
     */
    function placeBid(uint256 _nftId) external payable {
        require(auctions[_nftId].isActive == true, "Not active auction");
        require(
            auctions[_nftId].closingTime > block.timestamp,
            "Auction is closed"
        );
        require(msg.value > auctions[_nftId].highestBid, "Bid is too low");

        // Add previously highest bid to claimable bids so that they can claim later
        claimableBids[auctions[_nftId].highestBidder] += auctions[_nftId].highestBid;

        // set the new highest bidder
        auctions[_nftId].highestBid = msg.value;
        auctions[_nftId].highestBidder = msg.sender;

        emit BidPlaced(
            _nftId,
            auctions[_nftId].highestBid,
            auctions[_nftId].highestBidder
        );
    }

    /**
     * @dev Close Auction
     * @param _nftId NFT id
     */
    function closeAuction(uint256 _nftId) external {
        require(auctions[_nftId].isActive == true, "Not active auction");
        require(
            auctions[_nftId].closingTime <= block.timestamp,
            "Auction is not closed"
        );

        // Transfer ETH to NFT Owner for them to claim later
        uint256 tax = claimableBids[auctions[_nftId].originalOwner] * 3 / 100;
        uint256 bidPrice = claimableBids[auctions[_nftId].originalOwner] * 97 / 100;
        claimableBids[auctions[_nftId].originalOwner] += bidPrice;
        claimableBids[owner()] += tax;

        // Transfer NFT to Highest Bidder
        sNft_.transferFrom(address(this), auctions[_nftId].highestBidder, _nftId);

        // Close Auction
        auctions[_nftId].isActive = false;

        emit AuctionClosed(
            _nftId,
            auctions[_nftId].highestBid,
            auctions[_nftId].highestBidder
        );
    }

    /**
     * @dev Withdraw ETH
     */
    function withdraw() external {
        require(claimableBids[msg.sender] > 0);
        uint256 pay = claimableBids[msg.sender];
        claimableBids[msg.sender] = 0;
        payable(msg.sender).transfer(pay);
    }
}