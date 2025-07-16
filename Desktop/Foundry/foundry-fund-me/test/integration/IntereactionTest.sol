//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/Interaction.s.sol";
contract IntereactionTest is Test{
    FundMe fundMe ;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10e18;
    uint256 constant GAS_PRICE = 1;

    function setUp() external{

        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER,STARTING_BALANCE);
    }
    function testUserCanFundInteractoins() public {
    vm.deal(USER, 10 ether);

    // Fund
    vm.prank(USER);
    fundMe.fund{value: 1 ether}();

    // Withdraw
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    // Balance check
    assertEq(address(fundMe).balance, 0);
}

}