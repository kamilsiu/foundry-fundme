//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 10e18;
    uint256 constant STARTING_BALANCE = 10e18;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testDollarValue() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerisMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function V3Version() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //expects next line to revert and if it doens't test fails otherwise it passes

        fundMe.fund();
    }

    function testFundUpdates() public {
        vm.prank(USER); // NExt tx will be sent by the "USER"
        fundMe.fund{value: SEND_VALUE}();

        uint256 amount = fundMe.getAddressToAmountFunded(USER);
        assertEq(amount, SEND_VALUE);
    }

    function testFunderToArrayofFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);

        vm.expectRevert();

        fundMe.withdraw();
    }

    function testWithdrawAsSingleFunder() public {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); // cheatcode to simulate gas fees
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalnace = address(fundMe).balance;

        assertEq(endingFundMeBalnace, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }
    //hoax cheatcode to use prank and deal function in a same call

    function testWithdrawAsMultipleFunders() public funded {
        //Arrange
        uint160 numberofFunders = 10;
        uint160 startingFundIndex = 1;
        for (uint160 i = startingFundIndex; i < numberofFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        //Act
        uint256 startingFundBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //assert

        assert(address(fundMe).balance == 0);
        assert(startingFundBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithdrawAsMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberofFunders = 10;
        uint160 startingFundIndex = 1;
        for (uint160 i = startingFundIndex; i < numberofFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        //Act
        uint256 startingFundBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //assert

        assert(address(fundMe).balance == 0);
        assert(startingFundBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}

//chisel -> terminal testing solidity
//forge inspect FundMe storageLayout :-> commmand to check the variables using permanant storage
//forge coverage to create a  gas-snapshot file
//immutable and constants and variables in functions dont get stored on storage

//cast storage <contract-address> <slot-index>
//is a low-level Ethereum query that allows you to read raw data stored at a specific storage slot of a smart contract.
