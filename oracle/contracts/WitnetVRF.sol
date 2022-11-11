// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "witnet-solidity-bridge/contracts/interfaces/IWitnetRandomness.sol";
import "witnet-solidity-bridge/contracts/UsingWitnet.sol";
import "witnet-solidity-bridge/contracts/requests/WitnetRequest.sol";

contract WitnetVRF {
    uint32 public randomness;
    uint256 public latestRandomizingBlock;
    IWitnetRandomness public immutable witnet;

    /// @param _witnetRandomness Address of the WitnetRandomness contract.
    constructor(IWitnetRandomness _witnetRandomness) {
        assert(address(_witnetRandomness) != address(0));
        witnet = _witnetRandomness;
    }

    // [0, 4294967296)
    function requestRandomNumber() external payable {

        latestRandomizingBlock = block.number;

        uint _usedFunds = witnet.randomize{value: msg.value}();

        if (_usedFunds < msg.value) {
            payable(msg.sender).transfer(msg.value - _usedFunds);
        }
    }

    function fetchRandomNumber() external {
        assert(latestRandomizingBlock > 0);
        randomness = witnet.random(type(uint32).max, 0, latestRandomizingBlock);
        // randomness = witnet.getRandomnessAfter(latestRandomizingBlock); bytes32
    }
}
