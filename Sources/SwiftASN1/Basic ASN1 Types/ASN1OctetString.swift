//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftCrypto open source project
//
// Copyright (c) 2019-2020 Apple Inc. and the SwiftCrypto project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of SwiftCrypto project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension ASN1 {
    /// An OCTET STRING is a representation of a string of octets.
    public struct ASN1OctetString: ASN1ImplicitlyTaggable {
        @inlinable
        public static var defaultIdentifier: ASN1.ASN1Identifier {
            .primitiveOctetString
        }

        /// The octets that make up this OCTET STRING.
        public var bytes: ArraySlice<UInt8>

        @inlinable
        public init(asn1Encoded node: ASN1.ASN1Node, withIdentifier identifier: ASN1.ASN1Identifier) throws {
            guard node.identifier == identifier else {
                throw ASN1Error.unexpectedFieldType
            }

            guard case .primitive(let content) = node.content else {
                preconditionFailure("ASN.1 parser generated primitive node with constructed content")
            }

            self.bytes = content
        }

        /// Construct an OCTET STRING from a sequence of bytes.
        ///
        /// - parameters:
        ///     - contentBytes: The bytes that make up this OCTET STRING.
        @inlinable
        public init(contentBytes: ArraySlice<UInt8>) {
            self.bytes = contentBytes
        }

        @inlinable
        public func serialize(into coder: inout ASN1.Serializer, withIdentifier identifier: ASN1.ASN1Identifier) throws {
            coder.appendPrimitiveNode(identifier: identifier) { bytes in
                bytes.append(contentsOf: self.bytes)
            }
        }
    }
}

extension ASN1.ASN1OctetString: Hashable { }

extension ASN1.ASN1OctetString: Sendable { }

extension ASN1.ASN1OctetString {
    @inlinable
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try self.bytes.withUnsafeBytes(body)
    }
}
