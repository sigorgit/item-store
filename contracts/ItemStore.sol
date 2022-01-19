pragma solidity ^0.5.6;

import "./klaytn-contracts/ownership/Ownable.sol";
import "./klaytn-contracts/math/SafeMath.sol";
import "./interfaces/IInjeolmi.sol";

contract ItemStore is Ownable {
    using SafeMath for uint256;

    IInjeolmi public ijm;
    address public feeTo;

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
        for (uint256 i = 0; i < ids.length; i = i.add(1)) {
            itemPrices[ids[i]] = prices[i];
        }
    }

    function buyItem(bytes32 hash, uint256 itemId) external {
        require(hash == keccak256(abi.encodePacked(msg.sender, nonces[msg.sender], itemId)));
        nonces[msg.sender] = nonces[msg.sender].add(1);
        uint256 price = itemPrices[itemId];
        ijm.transferFrom(msg.sender, owner(), price.div(10));
        ijm.transferFrom(msg.sender, feeTo, price.mul(9).div(10));
    }

    function buyItems(bytes32[] calldata hashes, uint256[] calldata itemIds) external {
        require(hashes.length == itemIds.length);
        uint256 nonce = nonces[msg.sender];
        uint256 price;
        for (uint256 i = 0; i < hashes.length; i = i.add(1)) {
            require(hashes[i] == keccak256(abi.encodePacked(msg.sender, nonce, itemIds[i])));
            nonce = nonce.add(1);
            price = price.add(itemPrices[itemIds[i]]);
        }
        nonces[msg.sender] = nonce;
        ijm.transferFrom(msg.sender, owner(), price.div(10));
        ijm.transferFrom(msg.sender, feeTo, price.mul(9).div(10));
    }
}
