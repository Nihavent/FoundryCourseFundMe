// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


// Fund
// Withdraw 

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";


contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    // Funds most recently deployed contract
    function fundFundMe(address mostRecentlyDeployed) public view {
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE};
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    // Calls fundFundMe
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}


contract WithdrawFundMe is Script {
    // Withdraws funds from most recently deployed contract
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    // Calls withdrawFundMe
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }

}