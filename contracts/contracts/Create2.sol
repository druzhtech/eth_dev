//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Factory {
    bytes32 immutable SALT;

    event ContractDeployed(address contract_address);

    constructor(string memory _salt) payable {
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

    function deployCreateTarget() external {
        address t = address(new CreateTarget{salt: SALT, value: 1 ether}()); //  create2
        emit ContractDeployed(t);
    }

    function getBytecode() public pure returns (bytes memory) {
        bytes memory bytecode = type(CreateTarget).creationCode;

        return bytecode;
    }

    receive() external payable {}
}

contract CreateTarget {
    address parent;

    event ContractDeployed(address contract_address);

    constructor() payable {
        parent = msg.sender;
    }

    function deployTarget() external {
        // 0x2675C08861ac5547151198005b364509374f5396
        address t = address(new Target()); // nonce - 0, create
        emit ContractDeployed(t);
    }

    function deployNewTarget() external {
        // 0x2675C08861ac5547151198005b364509374f5396
        address t = address(new NewTarget()); // nonce - 1, create
        emit ContractDeployed(t);
    }

    function destroy() external {
        selfdestruct(payable(parent));
    }

    receive() external payable {}
}

contract Target {
    address parent;
    uint256 public a;

    constructor() payable {
        parent = msg.sender;
    }

    function withdraw() external {
        (bool ok, ) = parent.call{value: address(this).balance}("");
        require(ok, "failed withdraw");
    }

    function setA(uint256 _a) external {
        a = _a;
    }

    function destroy() external {
        selfdestruct(payable(parent));
    }

    receive() external payable {}
}

contract NewTarget {
    address parent;
    uint256 public b;

    constructor() payable {
        parent = msg.sender;
    }

    function withdraw(address to) external {
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "failed withdraw");
    }

    function setB(uint256 _b) external {
        b = _b;
    }

    receive() external payable {}
}
