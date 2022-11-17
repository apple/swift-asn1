//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftCrypto open source project
//
// Copyright (c) 2021 Apple Inc. and the SwiftCrypto project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of SwiftCrypto project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension ASN1 {
    /// An ASN1 ANY represents...well, anything.
    ///
    /// In this case we store the ASN.1 ANY as a serialized representation. This is a bit limiting,
    /// but it's the only safe way to manage this data, as we cannot arbitrarily parse it.
    ///
    /// The only things users can do with ASN.1 ANYs is to try to decode them as something else,
    /// to create them from something else, or to serialize them.
    public struct ASN1Any: ASN1Parseable, ASN1Serializable, Hashable, Sendable {
        @usableFromInline
        var _serializedBytes: ArraySlice<UInt8>

        /// Create an ``ASN1/ASN1Any`` from a serializable ASN1 type.
        ///
        /// - parameters:
        ///     erasing: The type to be represented as an ASN1 ANY.
        @inlinable
        public init<ASN1Type: ASN1Serializable>(erasing: ASN1Type) throws {
            var serializer = ASN1.Serializer()
            try erasing.serialize(into: &serializer)
            self._serializedBytes = ArraySlice(serializer._serializedBytes)
        }

        /// Create an ``ASN1/ASN1Any`` from a serializable implicitly taggable ASN1 type.
        ///
        /// - parameters:
        ///     erasing: The type to be represented as an ASN1 ANY.
        ///     identifier: The tag to use with this node.
        @inlinable
        public init<ASN1Type: ASN1ImplicitlyTaggable>(erasing: ASN1Type, withIdentifier identifier: ASN1.ASN1Identifier) throws {
            var serializer = ASN1.Serializer()
            try erasing.serialize(into: &serializer, withIdentifier: identifier)
            self._serializedBytes = ArraySlice(serializer._serializedBytes)
        }

        @inlinable
        public init(asn1Encoded rootNode: ASN1.ASN1Node) {
            // This is a bit sad: we just re-serialize this data. In an ideal world
            // we'd update the parse representation so that all nodes can point at their
            // complete backing storage, but for now this is better.
            var serializer = ASN1.Serializer()
            serializer.serialize(rootNode)
            self._serializedBytes = ArraySlice(serializer._serializedBytes)
        }

        @inlinable
        public func serialize(into coder: inout ASN1.Serializer) throws {
            // Dangerous to just reach in there like this, but it's the right way to serialize this.
            coder._serializedBytes.append(contentsOf: self._serializedBytes)
        }
    }
}

extension ASN1.ASN1Any: CustomStringConvertible {
    @inlinable
    public var description: String {
        "ASN1Any(\(self._serializedBytes))"
    }
}

extension ASN1Parseable {
    /// Construct this node from an ASN.1 ANY object.
    ///
    /// This operation works by asking the type to decode itself from the serialized representation
    /// of this ASN.1 ANY node.
    ///
    /// - parameters:
    ///     asn1Any: The ASN.1 ANY object to reinterpret.
    @inlinable
    public init(asn1Any: ASN1.ASN1Any) throws {
        try self.init(asn1Encoded: asn1Any._serializedBytes)
    }
}

extension ASN1ImplicitlyTaggable {
    /// Construct this node from an ASN.1 ANY object.
    ///
    /// This operation works by asking the type to decode itself from the serialized representation
    /// of this ASN.1 ANY node.
    ///
    /// - parameters:
    ///     asn1Any: The ASN.1 ANY object to reinterpret.
    ///     identifier: The tag to use with this node.
    @inlinable
    public init(asn1Any: ASN1.ASN1Any, withIdentifier identifier: ASN1.ASN1Identifier) throws {
        try self.init(asn1Encoded: asn1Any._serializedBytes, withIdentifier: identifier)
    }
}
