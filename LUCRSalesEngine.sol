// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILUCRMintEngine {
    function mintTo(address to, uint256 value) external;
}

interface ILUCRPricingEngine {
    function quote(uint256 paymentWei) external view returns (uint256);
}

contract LUCRSalesEngine {
    ILUCRMintEngine public mintEngine;
    ILUCRPricingEngine public pricingEngine;
    address public treasury;

    event LUCRPurchased(address indexed buyer, uint256 payment, uint256 amount);

    constructor(address _mintEngine, address _pricingEngine, address _treasury) {
        mintEngine = ILUCRMintEngine(_mintEngine);
        pricingEngine = ILUCRPricingEngine(_pricingEngine);
        treasury = _treasury;
    }

    function buyLUCR() external payable {
        require(msg.value > 0, "No payment");

        uint256 amount = pricingEngine.quote(msg.value);
        require(amount > 0, "Payment too small");

        (bool sent, ) = treasury.call{value: msg.value}("");
        require(sent, "Treasury transfer failed");

        mintEngine.mintTo(msg.sender, amount);

        emit LUCRPurchased(msg.sender, msg.value, amount);
    }
}
