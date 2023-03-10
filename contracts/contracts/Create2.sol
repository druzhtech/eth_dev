//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Main {
    bytes32 immutable salt;

    event ContractDeployed(address contract_address);

    constructor(string memory _salt) payable {
        salt = bytes32(bytes(_salt));
    }

    function callAddrAsCreate2() external view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(getBytecode())
            )
        );

        return address(uint160(uint256(hash)));
    }

    function deploy() external {
        address addr = address(
            new ContractFactory{salt: salt, value: 1 ether}()
        ); //  create2
        emit ContractDeployed(addr);
    }

    function getBytecode() public pure returns (bytes memory) {
        bytes memory bytecode = type(ContractFactory).creationCode;
        return bytecode;
    }

    receive() external payable {}
}

contract ContractFactory {
    address creator;

    event ContractDeployed(address contract_address);

    constructor() payable {
        creator = msg.sender;
    }

    function deployContract1() external {
        address addr = address(new ContractV1()); // create
        emit ContractDeployed(addr);
    }

    function deployContract2() external {
        address addr = address(new ContractV2()); // create
        emit ContractDeployed(addr);
    }

    function destroy() external {
        selfdestruct(payable(creator));
    }

    receive() external payable {}
}

contract ContractV1 {
    address creator;
    uint256 public a;

    constructor() payable {
        creator = msg.sender;
    }

    function withdraw() external {
        (bool res, ) = creator.call{value: address(this).balance}("");
        require(res, "failed");
    }

    function setA(uint256 _a) external {
        a = _a;
    }

    function destroy() external {
        selfdestruct(payable(creator));
    }

    receive() external payable {}
}

contract ContractV2 {
    address creator;
    uint256 public a;

    constructor() payable {
        creator = msg.sender;
    }

    function withdraw() external {
        (bool res, ) = address(0xaB854be0A4d499B6FD8D0bB5F796Ab5b33cE825b).call{
            value: address(this).balance
        }("");
        require(res, "failed");
    }

    function setA(uint256 _a) external {
        a = _a;
    }

    receive() external payable {}
}
