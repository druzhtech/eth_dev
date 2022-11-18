// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;
import "./BridgeServiceV1.sol";
import "./library/MessageSet.sol";


contract BridgeClient {

    function sendMessage(address bridge) public {
        BridgeServiceV1 br = BridgeServiceV1(bridge);
        // br.initMessage();
    }

    function callbackBridge(bytes memory data) external {

    }
  
}
