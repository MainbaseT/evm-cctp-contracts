/* SPDX-License-Identifier: UNLICENSED
 *
 * Copyright (c) 2022, Circle Internet Financial Trading Company Limited.
 * All rights reserved.
 *
 * Circle Internet Financial Trading Company Limited CONFIDENTIAL
 *
 * This file includes unpublished proprietary source code of Circle Internet
 * Financial Trading Company Limited, Inc. The copyright notice above does not
 * evidence any actual or intended publication of such source code. Disclosure
 * of this source code or any related proprietary information is strictly
 * prohibited without the express written permission of Circle Internet Financial
 * Trading Company Limited.
 */
pragma solidity ^0.7.6;

import "@memview-sol/contracts/TypedMemView.sol";

/**
 * @title Message Library
 * @notice Library for formatted messages used by Relayer and Receiver.
 *
 * @dev The message body is dynamically-sized to support custom message body
 * formats. Other fields must be fixed-size to avoid hash collisions.
 * Each other input value has an explicit type to guarantee fixed-size.
 * Padding: uint32 fields are left-padded, and bytes32 fields are right-padded.
 *
 * Field                 Bytes      Type       Index
 * version               4          uint32     0
 * sourceDomain          4          uint32     4
 * destinationDomain     4          uint32     8
 * nonce                 4          uint32     12
 * recipient             32         bytes32    16
 * messageBody           dynamic    bytes      48
 **/
library Message {
    using TypedMemView for bytes;
    using TypedMemView for bytes29;

    // Indices of each field in message
    uint32 internal constant VERSION_INDEX = 0;
    uint32 internal constant SOURCE_DOMAIN_INDEX = 4;
    uint32 internal constant DESTINATION_DOMAIN_INDEX = 8;
    uint32 internal constant NONCE_INDEX = 12;
    uint32 internal constant RECIPIENT_INDEX = 16;
    uint32 internal constant MESSAGE_BODY_INDEX = 48;

    /**
     * @notice Returns formatted (packed) message with provided fields
     * @param _version the version of the message format
     * @param _sourceDomain Domain of home chain
     * @param _destinationDomain Domain of destination chain
     * @param _nonce Destination-specific nonce
     * @param _recipient Address of recipient on destination chain as bytes32
     * @param _messageBody Raw bytes of message body
     * @return Formatted message
     **/
    function formatMessage(
        uint32 _version,
        uint32 _sourceDomain,
        uint32 _destinationDomain,
        uint32 _nonce,
        bytes32 _recipient,
        bytes memory _messageBody
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                _version,
                _sourceDomain,
                _destinationDomain,
                _nonce,
                _recipient,
                _messageBody
            );
    }

    // @notice Returns message's version field
    function version(bytes29 _message) internal pure returns (uint32) {
        return uint32(_message.indexUint(VERSION_INDEX, 4));
    }

    // @notice Returns message's sourceDomain field
    function sourceDomain(bytes29 _message) internal pure returns (uint32) {
        return uint32(_message.indexUint(SOURCE_DOMAIN_INDEX, 4));
    }

    // @notice Returns message's destinationDomain field
    function destinationDomain(bytes29 _message) internal pure returns (uint32) {
        return uint32(_message.indexUint(DESTINATION_DOMAIN_INDEX, 4));
    }

    // @notice Returns message's nonce field
    function nonce(bytes29 _message) internal pure returns (uint32) {
        return uint32(_message.indexUint(NONCE_INDEX, 4));
    }

    // @notice Returns message's recipient field
    function recipient(bytes29 _message) internal pure returns (bytes32) {
        return _message.index(RECIPIENT_INDEX, 32);
    }

    // @notice Returns message's messageBody field
    function messageBody(bytes29 _message) internal pure returns (bytes29) {
        return _message.slice(MESSAGE_BODY_INDEX, _message.len() - MESSAGE_BODY_INDEX, 0);
    }
}
