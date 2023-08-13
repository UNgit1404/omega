// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ExpirableToken is ERC20, Ownable {
    struct ExpiryInfo {
        uint256 expiryTimestamp;
        bool isExpired;
    }

    mapping(address => ExpiryInfo) public expiryOf;
    mapping(address => bool) public whitelistedTransfers; // Addresses that can transfer tokens
    address[] public whitelistAddresses;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    }

    modifier onlyTransferAllowed() {
        require(whitelistedTransfers[msg.sender], "Sender is not allowed to transfer");
        _;
    }

    modifier onlyOwnerOrWhitelist() {
        require(msg.sender == owner() || whitelistedTransfers[msg.sender], "Sender is not allowed");
        _;
    }

    function addToTransferWhitelist(address account) public onlyOwner {
        whitelistedTransfers[account] = true;
    }

    function removeFromTransferWhitelist(address account) public onlyOwner {
        whitelistedTransfers[account] = false;
    }

    function addAddressToWhitelist(address account) public onlyOwner {
        require(!whitelistedTransfers[account], "Address is already whitelisted");
        whitelistAddresses.push(account);
        whitelistedTransfers[account] = true;
    }

    function getWhitelistAddresses() public view returns (address[] memory) {
        return whitelistAddresses;
    }

    function mintToWhitelist(uint256 amount, uint256 expiryTimestamp) public onlyOwnerOrWhitelist {
        require(expiryTimestamp > block.timestamp, "Expiry must be in the future");
        require(whitelistAddresses.length > 0, "Whitelist is empty");

        uint256 individualAmount = amount / whitelistAddresses.length;

        for (uint256 i = 0; i < whitelistAddresses.length; i++) {
            address recipient = whitelistAddresses[i];
            _mint(recipient, individualAmount);
            expiryOf[recipient] = ExpiryInfo(expiryTimestamp, false);
        }
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
        expiryOf[account].isExpired = true;
    }

    function transfer(address recipient, uint256 amount) public override onlyTransferAllowed returns (bool) {
        require(!expiryOf[msg.sender].isExpired, "Sender's tokens have expired");
        require(!expiryOf[recipient].isExpired, "Recipient's tokens have expired");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override onlyTransferAllowed returns (bool) {
        require(!expiryOf[sender].isExpired, "Sender's tokens have expired");
        require(!expiryOf[recipient].isExpired, "Recipient's tokens have expired");
        return super.transferFrom(sender, recipient, amount);
    }
}
