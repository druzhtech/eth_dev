// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract MyContract {
    address public owner;

    event CallData(bytes caldata);
    event FallbackCalled(bytes data);

    constructor() {
        owner = msg.sender;
    }

    function add(address proxy, address newOwner) external {
        (bool success, bytes memory data) = proxy.delegatecall(
            abi.encodeWithSignature("add(address)", newOwner)
        );
        require(success == true, "Call to add(address) failed");
        emit CallData(data);
    }

    function returnFunc(address proxy) internal returns (function()) {
        (bool success, bytes memory data) = proxy.call(
            abi.encodeWithSignature("add(address)")
        );
        require(success == true, "Call to add(address) failed");

        function() sign; // = data; // = abi.decode(data, (bytes));

        return sign;
    }

    fallback() external {
        emit FallbackCalled(msg.data);
    }
}

contract ProxyContract {
    address public implAddress;

    event ImplChanged(address impl);
    event FallbackRaised(bytes data);

    // event FallbackRaised(bytes data);

    function setImplAddress(address _impl) public {
        implAddress = _impl;

        emit ImplChanged(_impl);
    }

    fallback() external {
        bytes memory data = msg.data;
        address impl = implAddress;

        emit FallbackRaised(data);

        assembly {
            let result := delegatecall(
                gas(),
                impl,
                add(data, 0x20),
                mload(data),
                0,
                0
            )
            let size := returndatasize()

            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }
}

contract AttackerContract {
    address public attacker;
    event ImplChanged(address impl);

    event AttackerAddress(address attacker);

    function add(address _attacker) external {
        attacker = _attacker;
        emit ImplChanged(_attacker);
        emit AttackerAddress(_attacker);
        // return 5;
    }
}
