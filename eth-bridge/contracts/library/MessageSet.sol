// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library MessageSet {
  
  enum MessageStatus {
    created,
    confirmed,
    canceled
  }

  enum MessageType {
    read,
    write
  }

  struct Message {
    uint256 nonce;
    bytes32 source_chain_id;
    bytes32 destination_chain_id;
    bytes32 message_id;
    address sender_address;
    address executor_address;
    MessageType datatype;
    bytes4 method;
    bytes32 params;
    address[] confirmations;
    MessageStatus messageStatus;
  }
}
