// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTAuction is Ownable {
    IERC721 public nft;
    uint256 public nftId;
    uint256 public minPrice;
    uint256 public startTime;
    uint256 public endTime;
    address public highestBidder;
    uint256 public highestBid;
    mapping(address => uint256) public bids;
    bool public auctionEnded;

    event AuctionCreated(uint256 nftId, uint256 minPrice, uint256 startTime, uint256 endTime);
    event BidPlaced(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    modifier onlyWhileOpen() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Auction is not open");
        _;
    }

    modifier onlyAfterEnd() {
        require(block.timestamp > endTime, "Auction is still ongoing");
        _;
    }

    function createAuction(
        address _nft,
        uint256 _nftId,
        uint256 _minPrice,
        uint256 _startTime,
        uint256 _endTime
    ) external onlyOwner {
        require(_startTime < _endTime, "Start time must be before end time");
        nft = IERC721(_nft);
        nftId = _nftId;
        minPrice = _minPrice;
        startTime = _startTime;
        endTime = _endTime;
        auctionEnded = false;

        emit AuctionCreated(_nftId, _minPrice, _startTime, _endTime);
    }

    function bid() external payable onlyWhileOpen {
        require(msg.value > highestBid && msg.value >= minPrice, "Bid is too low");

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit BidPlaced(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 amount = bids[msg.sender];
        require(amount > 0, "No funds to withdraw");

        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function endAuction() external onlyAfterEnd {
        require(!auctionEnded, "Auction already ended");

        auctionEnded = true;
        if (highestBidder != address(0)) {
            nft.transferFrom(owner(), highestBidder, nftId);
            payable(owner()).transfer(highestBid);
        }

        emit AuctionEnded(highestBidder, highestBid);
    }

    function getAuctionDetails() external view returns (
        address _nft,
        uint256 _nftId,
        uint256 _minPrice,
        uint256 _startTime,
        uint256 _endTime,
        address _highestBidder,
        uint256 _highestBid,
        bool _auctionEnded
    ) {
        return (address(nft), nftId, minPrice, startTime, endTime, highestBidder, highestBid, auctionEnded);
    }
}