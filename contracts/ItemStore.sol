pragma solidity ^0.5.6;

import "./klaytn-contracts/ownership/Ownable.sol";
import "./klaytn-contracts/math/SafeMath.sol";
import "./interfaces/IInjeolmi.sol";

contract ItemStore is Ownable {
    using SafeMath for uint256;

    IInjeolmi public ijm;
    address public feeTo;
    mapping(bytes32 => bool) public isPurchased;

    constructor(IInjeolmi _ijm, address _feeTo) public {
        ijm = _ijm;
        feeTo = _feeTo;
    }

    function setFeeTo(address _feeTo) onlyOwner external {
        feeTo = _feeTo;
    }

    mapping(address => uint256) public nonces;
    mapping(uint256 => uint256) public itemPrices;

    function setPrices(uint256[] calldata ids, uint256[] calldata prices) onlyOwner external {
        require(ids.length == prices.length);
        for (uint256 i = 0; i < ids.length; i++) {
            itemPrices[ids[i]] = prices[i];
        }
    }

    function buyItems(uint256[] calldata itemIds) external {
        uint256 nonce = nonces[msg.sender];
        uint256 totalPrice;
        for (uint256 i = 0; i < itemIds.length; i++) {
            bytes32 hash = keccak256(abi.encodePacked(msg.sender, nonce++, itemIds[i]));
            isPurchased[hash] = true;

            totalPrice = totalPrice.add(itemPrices[itemIds[i]]);
        }
        nonces[msg.sender] = nonce;

        uint256 priceToOwner = totalPrice.div(10);

        ijm.transferFrom(msg.sender, owner(), priceToOwner);
        ijm.transferFrom(msg.sender, feeTo, totalPrice.sub(priceToOwner));
    }
}
