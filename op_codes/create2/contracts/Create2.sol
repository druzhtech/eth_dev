// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Factory {
    bytes32 immutable SALT;

    event Deployed(address to);

    constructor(string memory salt) {
        SALT = bytes32(bytes(salt));
    }

    function calcAddr() external view returns (address) {
        bytes32 h = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                SALT,
                keccak256(getBytecode())
            )
        );

        return address(uint160(uint256(h)));
    }

    function getBytecode() public pure returns (bytes memory) {
        bytes memory bc = type(TargetOld).creationCode;

        return abi.encodePacked(bc);
    }

    function deploy() external {
        address targetCreator = address(new TargetCreator{salt: SALT}());
        emit Deployed(targetCreator);
    }
}

contract TargetCreator {
    address parent;

    event TargetDeployed(address target);

    constructor() {
        parent = msg.sender;
    }

    function deployTragetOld() external {
        address target = address(new TargetOld());
        emit TargetDeployed(target);
    }

    function deployTragetNew() external {
        address newtarget = address(new TargetNew());
        emit TargetDeployed(newtarget);
    }

      function destroy() external {
        selfdestruct(payable(parent));
    }
}

// Factory --> (create2) TragetCreator --> (create) Target
// create: nonce + deployer_address

contract TargetOld {
    address parent;
    uint public a;

    constructor() {
        parent = msg.sender;
    }

    function withdraw() external {
        (bool ok, ) = parent.call{value: address(this).balance}("");
        require(ok, "failed");
    }

    function setA(uint _a) external {
        a = _a;
    }

    function destroy() external {
        selfdestruct(payable(parent));
    }

    receive() external payable {}
}

contract TargetNew {
    address parent;
    uint public a;

    constructor() {
        parent = msg.sender;
    }

    function withdraw() external {
        (bool ok, ) = _to.call{value: address(this).balance}("");
        require(ok, "failed to withdraw");
    }

    function setA(uint _a) external {
        a = _a;
    }

    function destroy() external {
        selfdestruct(payable(parent));
    }

    receive() external payable {}
}
