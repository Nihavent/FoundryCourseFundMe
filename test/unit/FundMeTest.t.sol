// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployfundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address TestUser = makeAddr("TestUser");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(TestUser, STARTING_BALANCE);
    }

    function testMinumumDollarIsFive() public {
        assertEq(fundMe.MINMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public {
        //console.log(fundMe.i_owner());
        //console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceConversionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // The next line should revert, (ignoring vm.x lines) (or else test fails)
        fundMe.fund(); // send 0 value
    }
    
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(TestUser); // The next TX will be sent by TestUser

        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountfunded(TestUser);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFundertoArrayOfFunders() public {
        vm.prank(TestUser); // The next TX will be sent by TestUser
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, TestUser); 
    }

    modifier funded() {
        vm.prank(TestUser);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerAndWithdraw() public funded {
        vm.expectRevert();
        vm.prank(TestUser); //TestUser is not the owner so we expect this to revert if our error handling is working correctly
        fundMe.withdraw();
    }
        
    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        
        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance); // test that the owner balance updated to the withdrawal amount
        assertEq(endingFundMeBalance, 0); // test we withdrew all funds
    }

    function testWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOffunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOffunders; i++) {
            // hoax combines vm.prank and vm.deal, ie the next transaction comes from this address, and vm.deal funds the address
            hoax(address(i), SEND_VALUE);
            //fund the fundMe contract
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        //uint256 gasStart = gasleft(); // e.g. 1000 gas
        //vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw(); // e.g. cost: 200 gas
        vm.stopPrank();

        //uint256 gasEnd = gasleft(); // e.g. 800 gas
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance); // test that the owner balance updated to the withdrawal amount
        assertEq(endingFundMeBalance, 0); // test we withdrew all funds
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberOffunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOffunders; i++) {
            // hoax combines vm.prank and vm.deal, ie the next transaction comes from this address, and vm.deal funds the address
            hoax(address(i), SEND_VALUE);
            //fund the fundMe contract
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        //uint256 gasStart = gasleft(); // e.g. 1000 gas
        //vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw(); // e.g. cost: 200 gas
        vm.stopPrank();

        //uint256 gasEnd = gasleft(); // e.g. 800 gas
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance); // test that the owner balance updated to the withdrawal amount
        assertEq(endingFundMeBalance, 0); // test we withdrew all funds
    }

}