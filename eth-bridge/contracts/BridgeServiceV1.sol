// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "./ValidatorList.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "./library/MessageSet.sol";

contract BridgeServiceV1 is ValidatorList, Pausable, EIP712 {
    using ECDSA for bytes32;

    bytes32 immutable source_chain_id;

    // destination_chain_id => last nonce
    mapping(bytes32 => uint256) destinMsgNonce;

    mapping(bytes32 => MessageSet.Message) public messages;

    event MessageCreated(MessageSet.Message message); // 1
    event MessageConfirmed(bytes32 messageId);

    modifier checkIncomeMessage(MessageSet.Message memory message) {
        //todo: что сообщение уже зарегистировано
        //todo: проверка сетей по белым и чёрным спискам
        //todo: проверка адресов указаных в сообщениях
        //todo: проверка метода и параметров на формат

        require(true, "Is not correct Message");
        _;
    }

    constructor(bytes32 _source_chain_id) EIP712("Web3Bridge", "0.1.0") {
        source_chain_id = _source_chain_id;
        addValidator(msg.sender);
        _pause();
    }

    ///@dev функция создания системного сообытия со значимой для Оракуа информацией
    function initMessage(
        bytes32 _destination_chain_id,
        address _executor_address,
        MessageSet.MessageType _msgType,
        bytes4 _method,
        bytes32 _params
    ) public payable returns (bool) {
        require(_destination_chain_id != source_chain_id, "Current ID");

        // TODO: require(msg.value == 0, 'Not enough Wei for fee');
        // TODO: собрать комиссию

        // TODO: добавить случайность?
        bytes32 _message_id = keccak256(
            abi.encodePacked(
                source_chain_id,
                _destination_chain_id,
                msg.sender,
                _executor_address,
                _msgType,
                _method,
                _params
            )
        );

        uint256 _nonce = destinMsgNonce[_destination_chain_id]; // TODO: nonce для конкретного смарт-контракта

        // TODO: ДЗ - оптимизировать структуру сообщения
        MessageSet.Message memory message = MessageSet.Message({
            nonce: _nonce,
            source_chain_id: source_chain_id,
            destination_chain_id: _destination_chain_id,
            message_id: _message_id,
            sender_address: msg.sender,
            executor_address: _executor_address,
            datatype: _msgType,
            method: _method,
            params: _params,
            confirmations: new address[](0),
            messageStatus: MessageSet.MessageStatus.created
        });

        ++destinMsgNonce[_destination_chain_id];
        messages[_message_id] = message;

        emit MessageCreated(message);
        return true;
    }

    // функция подтверждения сообщения валидатора,
    // после этого сообщение передаётся в другую сеть
    function confirmMessage(bytes32 messageId) public onlyValidator {
        MessageSet.Message storage message = messages[messageId];
        uint256 valNum = _validatorNum();
        uint256 confirmations = message.confirmations.length;

        if (valNum == confirmations + 1) {
            message.confirmations.push(msg.sender);
            message.messageStatus = MessageSet.MessageStatus.confirmed;
            emit MessageConfirmed(messageId);
        } else {
            message.confirmations.push(msg.sender);
        }
    }

    /// @dev функция приёма внешнего сообщения и вызова метода
    function serveInputMessage(MessageSet.Message memory inputMessage)
        public
        checkIncomeMessage(inputMessage)
    {
        // todo: подтверждение валидаторами приход нового сообщения
        // message.executor_address.call(message.method, message.params);
        (bool result, bytes memory data) = inputMessage.executor_address.call(
            abi.encode(inputMessage.method, inputMessage.params)
        );

        bytes4 remoteMethod = bytes4(keccak256("callbackBridge(bytes)"));

        if (inputMessage.datatype == MessageSet.MessageType.read) {
            if (result) {
                initMessage(
                    inputMessage.source_chain_id,
                    inputMessage.sender_address,
                    MessageSet.MessageType.write,
                    remoteMethod,
                    bytesToBytes32Array(data)
                );
            } else {
                //todo: отправить сообщение что что-то пошло не так
            }
        }
    }

     function bytesToBytes32Array(bytes memory data)
    public
    pure
    returns (bytes32 result)
  {
    assembly {
      result := mload(add(data, 32))
    }
  }
}
