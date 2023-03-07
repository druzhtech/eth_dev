//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

// importing merkleproof because we use merkle tree
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Airdrop_merkle {
    // for safe transfer purposes
    using SafeERC20 for IERC20;

    // root of the merkle tree
    bytes32 public immutable tree;

    // adress we'll airdrop
    address public immutable token;

    constructor(address t, bytes32 r) {
        token = t;
        tree = r;
    }

    // storing status, default: false
    mapping(address => bool) public claimed;

    event Claim(address indexed claimer);

    // check if adress can claim
    function canClaim(
        address claimer,
        bytes32[] calldata mp
    ) public view returns (bool) {
        // check if user is not yet claimed + check if encoded claimer is leaf of the tree
        return
            !claimed[claimer] &&
            MerkleProof.verify(mp, tree, keccak256(abi.encodePacked(claimer)));
    }

    function claim(bytes32[] calldata mp) external {
        // if user can claim => we claim
        require(canClaim(msg.sender, mp), "claim error");

        // save claim to mapping
        claimed[msg.sender] = true;

        // airdropping
        IERC20(token).safeTransfer(msg.sender, 1 ether);

        emit Claim(msg.sender);
    }
}
