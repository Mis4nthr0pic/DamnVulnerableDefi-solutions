// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Address} from "openzeppelin-contracts/utils/Address.sol";
import "forge-std/console.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    using Address for address payable;

    mapping(address => uint256) private balances;
    mapping(address => bool) public activeLoans;

    error NotEnoughETHInPool();
    error FlashLoanHasNotBeenPaidBack();

    function deposit() external payable {
        require(msg.sender != address(this));
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        if (balanceBefore < amount) revert NotEnoughETHInPool();
        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();
        if (address(this).balance < balanceBefore) {
            revert FlashLoanHasNotBeenPaidBack();
        }
    }
}
