// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {

    function run() external returns (FundMe) {
        // Any code before the startBroadcast() won't be a real Tx on chain
        
        // This contract has a variable activeNetworkConfig which is the chainlink price feed address
        HelperConfig helperConfig = new HelperConfig();
        // wrapped in brackets due to the variable being a struct
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }

}