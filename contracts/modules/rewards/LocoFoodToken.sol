// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract LocoFoodToken is ERC20, ERC20Burnable {
    address public governance;

    constructor() ERC20("LocoFood Token", "LOCO") {
        governance = msg.sender;
        _mint(msg.sender, 100_000_000 * 10**decimals()); // 100M tokens
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == governance, "Only governance");
        _mint(to, amount);
    }

    function setGovernance(address newGovernance) external {
        require(msg.sender == governance, "Only governance");
        governance = newGovernance;
    }
}