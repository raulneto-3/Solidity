// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CATopenzeppelin is ERC20 {
    constructor() ERC20("CAT", "CAT") {
        _mint(msg.sender, 1000000 * 10**18); // Initial minting of 1 million CAT tokens
    }

    /**
     * @dev Function to mint new tokens.
     * @param to The address to which the new tokens will be minted.
     * @param amount The amount of tokens to be minted.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
