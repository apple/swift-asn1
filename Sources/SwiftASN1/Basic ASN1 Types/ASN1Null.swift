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
    /// An ASN1 NULL represents nothing.
    public struct ASN1Null: ASN1ImplicitlyTaggable, Hashable, Sendable {
        @inlinable
        public static var defaultIdentifier: ASN1.ASN1Identifier {
            .null
        }

        /// Construct a new ASN.1 null.
        @inlinable
        public init() { }

        @inlinable
        public init(asn1Encoded node: ASN1.ASN1Node, withIdentifier identifier: ASN1.ASN1Identifier) throws {
            guard node.identifier == identifier, case .primitive(let content) = node.content else {
                throw ASN1Error.unexpectedFieldType
            }

            guard content.count == 0 else {
                throw ASN1Error.invalidASN1Object
            }
        }

        @inlinable
        public func serialize(into coder: inout ASN1.Serializer, withIdentifier identifier: ASN1.ASN1Identifier) {
            coder.appendPrimitiveNode(identifier: identifier, { _ in })
        }
    }
}
