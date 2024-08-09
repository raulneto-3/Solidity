// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CatToken
 * @dev A basic ERC-20 token contract representing Cat Tokens.
 */
contract CatToken {
    string public name = "Cat Token"; // The name of the token
    string public symbol = "CAT"; // The symbol of the token
    uint8 public decimals = 18; // The number of decimal places for the token
    uint256 public totalSupply = 1000000 * 10 ** decimals; // The total supply of tokens (1 million tokens)
    mapping(address => uint256) public balanceOf; // Mapping of token balances for each address
    mapping(address => mapping(address => uint256)) allowance; // Mapping of token allowances for each address

    /**
     * @dev Constructor function that sets the initial token balance for the contract deployer.
     */
    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    /**
     * @dev Returns the token balance of a given address.
     * @param _account The address to query the balance of.
     * @return The token balance of the given address.
     */
    function getBalanceOf(address _account) public view returns (uint) {
        return balanceOf[_account];
    }

    /**
     * @dev Transfers a specified amount of tokens to a given address.
     * @param to The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Saldo Insuficiente");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev Approves a specified address to spend a specified amount of tokens on behalf of the sender.
     * @param spender The address to approve the spending of tokens.
     * @param amount The amount of tokens to approve.
     * @return A boolean indicating whether the approval was successful or not.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Returns the amount of tokens that an address is allowed to spend on behalf of another address.
     * @param owner The address that owns the tokens.
     * @param spender The address that is allowed to spend the tokens.
     * @return The amount of tokens that the spender is allowed to spend.
     */
    function getAllowance(address owner, address spender) public view returns (uint) {
        return allowance[owner][spender];
    }

    /**
     * @dev Transfers tokens from one address to another address.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(balanceOf[from] >= amount, "Saldo Insuficiente");
        require(allowance[from][msg.sender] >= amount, unicode"Permissão Insuficiente");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Emitted when tokens are transferred from one address to another address.
     * @param from The address which tokens are transferred from.
     * @param to The address which tokens are transferred to.
     * @param value The amount of tokens transferred.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a spender for an owner is set or updated.
     * @param owner The address which approves the spending of tokens.
     * @param spender The address which is approved to spend tokens.
     * @param value The new approved amount of tokens.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}