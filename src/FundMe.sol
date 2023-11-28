// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    //Mapping of funder address to total amount funded
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;
    //List of funder adresses
    address[] private s_funders;

    address private immutable i_owner;
    // $5 USD in wei
    uint256 public constant MINMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        //Allow users to send $
        //Have a minimum $ send

        //Reverts under any actions that have been done, and sends the remainijng gas back
        //msg.value returns a value in terms of wei (or the native crypto of the blockchain)
        require(msg.value.getConversionRate(s_priceFeed) >= MINMUM_USD, "Didn't send enough ETH"); 
        //Update list
        s_funders.push(msg.sender);
        //Update mapping
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256){
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Must be owner!");
        if(msg.sender != i_owner) {revert FundMe__NotOwner(); }
        // _; means after you execute the above code, execute the code in the function the modifier is applied to
        _;
    }

    function cheaperWithdraw() public payable onlyOwner {
        //Read the length of the s_funders array once, rather than each iteration of the loop
        uint256 fundersLength = s_funders.length;
        for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);
        // Withdraw the funds (note the onlyOwner modifier ensures only the owner of this contract can call this functions)
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        // for loop
        // /* start index; end index; step amount */)
        //Iterate through each element in the funders array
        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);
        // withdraw the funds. 3 ways to withdraw native currency:
            
            //transfer
            // msg.sender is of type address
            // payable(msg.sender) is of type payable address
            //payable(msg.sender).transfer(address(this).balance);
            
            //send
            //bool sendSuccess = payable(msg.sender).send(address(this).balance);
            // transfer throws and error if unsuccessful, send returns a bool indicating if it succeeeded or failed.
            //      the require below is necessary to revert upon failure
            //require(sendSuccess, "Send failed!");
            
            //call - generally recommended
            (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
            require(callSuccess, "Call failed");
    }

    // what if someone sends funds to the contract without calling the fund() function
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     *  View / Pure functions (getters)
     *  building these functions to publically retrieve private variables is better practice than just making thes variables public
     */

    function getAddressToAmountfunded(address fundingAddress) external view returns(uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns(address) {
        return s_funders[index];
    }

    function getOwner() external view returns(address) {
        return i_owner;
    }

}