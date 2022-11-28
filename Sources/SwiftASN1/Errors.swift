//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftCrypto open source project
//
// Copyright (c) 2020 Apple Inc. and the SwiftCrypto project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of SwiftCrypto project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
/// Errors that may be thrown while encoding or decoding ASN.1 objects.
public enum ASN1Error : Error {
    /// The ASN.1 tag for this field is invalid or unsupported.
    case invalidFieldIdentifier

    /// The ASN.1 tag for the parsed field does not match the tag expected for the field.
    case unexpectedFieldType

    /// The format of the parsed ASN.1 object does not match the format required for the data type
    /// being decoded.
    case invalidASN1Object

    /// An ASN.1 integer was decoded that does not use the minimum number of bytes for its encoding.
    case invalidASN1IntegerEncoding

    /// An ASN.1 field was truncated and could not be decoded.
    case truncatedASN1Field

    /// The encoding used for the field length is not supported.
    case unsupportedFieldLength

    /// It was not possible to parse a string as a PEM document.
    case invalidPEMDocument

    /// A string was invalid.
    case invalidStringRepresentation
}