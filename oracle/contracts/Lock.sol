// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Lock {
    uint public unlockTime;
    address payable public owner;
    uint256 currentPrice;
    uint4 quorum = 5; // 5 from 7

    address[] public oracles;

    mapping(uint8 => uint4) quorums; // timeslot => quorumCount
    mapping(uint8 => uint256[]) pricesBySlot;

    event Withdrawal(uint amount, uint when);
    event PriceUpdate(uint256 price);
    event GetPrice(address token);

    constructor(uint _unlockTime) payable {
        require(
            block.timestamp < _unlockTime,
            "Unlock time should be in the future"
        );

        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    function withdraw() public {
        // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

        require(block.timestamp >= unlockTime, "You can't withdraw yet");
        require(msg.sender == owner, "You aren't the owner");

        emit Withdrawal(address(this).balance, block.timestamp);

        owner.transfer(address(this).balance);
    }

    function updatePrice(uint256 price, uint8 timeSlot) public onlyOracle {
        // math
        // round -
        // quroum - 5 from 7
        // TODO: сделать проверкеу на голосовал оракул или нет
        uint4 currentQuorum = quorums[timeSlot];

        // собираем кворум
        if (currentQuorum >= quorum) {
            // почему курентКворум не может быть больше значения кворума
            currentPrice = price;
        } else {
            quorums[timeSlot] = quorums[timeSlot] + 1; // инкремент к текущему кворуму по таймслоту - вопрос - что здесь может пойти не так?
        }

        pricesBySlot[timeSlot].push(price); // куда определитиь этот блок
        uint256[] prices = pricesBySlot[timeSlot];
        prices.push(price);

        uint256 acc = 0;

        for (uint i = 0; prices.length; i++) {
            uint tmp = prices[i];
            acc = acc + tmp;
        }

        uint256 _price = acc/prices.length // currentPrice = price;
        price = _price;
        emit PriceUpdate(_price);
    }

    function getPrice(address token) public {
        emit GetPrice(token);
    }

    function correctPrice(uint256 corPrice) public {
        currentPrice = corPrice;
    }
}
