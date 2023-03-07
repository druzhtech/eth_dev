//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract Factory {
    bytes32 immutable SALT;

    constructor(string memory _salt) {
        SALT = bytes32(bytes(_salt));
    }

    function callAddr() external view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                SALT,
                keccak256(getBytecode())
            )
        );

        return address(uint160(uint256(hash)));
    }

    function getBytecode() public pure returns (bytes memory) {
        bytes memory bytecode = type(Target).creationCode;

        return bytecode;
    }

    receive() external payable{}
}

contract Target {}
