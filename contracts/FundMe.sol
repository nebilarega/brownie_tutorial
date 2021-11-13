// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract FundMe{
    mapping(address => uint256) public addressToAmount;
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;
    
    constructor(address _priceFeed) public{
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }
    function fund() public payable{
        //uint256 minimumUsd = 50;
        //require(getConversionRate(msg.value) >= minimumUsd);
        addressToAmount[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    function getVersion() public view returns(uint256){
        return priceFeed.version();
    }
    function getPrice() public view returns(uint256){
        (,int256 ansewer,,,) = priceFeed.latestRoundData();
        return uint256(ansewer/10**8);
    }
    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethAmount * ethPrice);
        return ethAmountInUsd;
    }
    modifier onlyOwner{
        require(owner == msg.sender);
        _;
    }
    function withdraw() payable onlyOwner public{
        msg.sender.transfer(address(this).balance);
        for(uint256 funderIndex; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmount[funder] = 0;
        }
        funders = new address[](0);
    }
}