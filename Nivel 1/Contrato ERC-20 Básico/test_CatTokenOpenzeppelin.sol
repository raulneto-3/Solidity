// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../contracts/CATopenzeppelin.sol";

contract TestCATopenzeppelin {
    CATopenzeppelin catToken;

    function beforeEach() public {
        catToken = new CATopenzeppelin();
    }

    function testInitialTokenBalance() public {
        uint256 expectedBalance = 1000000 * 10 ** 18;
        Assert.equal(catToken.balanceOf(address(this)), expectedBalance, "Incorrect initial token balance");
    }

    function testTransfer() public {
        address recipient = 0x1234567890abcdef;
        uint256 amount = 1000 * 10 ** 18;

        // Transfer tokens from contract deployer to recipient
        bool success = catToken.transfer(recipient, amount);
        Assert.isTrue(success, "Transfer failed");

        // Check balances after transfer
        uint256 expectedBalance = 1000000 * 10 ** 18 - amount;
        Assert.equal(catToken.balanceOf(address(this)), expectedBalance, "Incorrect token balance after transfer");
        Assert.equal(catToken.balanceOf(recipient), amount, "Incorrect recipient token balance");
    }

    function testApprovalAndTransferFrom() public {
        address spender = 0xabcdef1234567890;
        address recipient = 0x1234567890abcdef;
        uint256 amount = 1000 * 10 ** 18;

        // Approve spender to spend tokens on behalf of contract deployer
        bool approvalSuccess = catToken.approve(spender, amount);
        Assert.isTrue(approvalSuccess, "Approval failed");

        // Transfer tokens from contract deployer to recipient using spender's allowance
        bool transferSuccess = catToken.transferFrom(address(this), recipient, amount);
        Assert.isTrue(transferSuccess, "TransferFrom failed");

        // Check balances after transfer
        uint256 expectedBalance = 1000000 * 10 ** 18 - amount;
        Assert.equal(catToken.balanceOf(address(this)), expectedBalance, "Incorrect token balance after transferFrom");
        Assert.equal(catToken.balanceOf(recipient), amount, "Incorrect recipient token balance after transferFrom");
    }
}