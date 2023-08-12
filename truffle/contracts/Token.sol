// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    struct ExpiryInfo {
        uint256 expiryTimestamp;
        bool isExpired;
    }

    mapping(address => ExpiryInfo) public expiryOf;

    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply * (10 ** uint256(decimals())));
    }

    function mint(address account, uint256 amount, uint256 expiryTimestamp) public onlyOwner {
        require(expiryTimestamp > block.timestamp, "Expiry must be in the future");
        _mint(account, amount);
        expiryOf[account] = ExpiryInfo(expiryTimestamp, false);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
        expiryOf[account].isExpired = true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!expiryOf[msg.sender].isExpired, "Sender's tokens have expired");
        require(!expiryOf[recipient].isExpired, "Recipient's tokens have expired");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!expiryOf[sender].isExpired, "Sender's tokens have expired");
        require(!expiryOf[recipient].isExpired, "Recipient's tokens have expired");
        return super.transferFrom(sender, recipient, amount);
    }
}
