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

/// An ECDSA signature is laid out as follows:
///
/// ECDSASignature ::= SEQUENCE {
///   r INTEGER,
///   s INTEGER
/// }
///
/// This type is generic because our different backends want to use different bignum representations.
struct ECDSASignature<IntegerType: ASN1IntegerRepresentable>: DERImplicitlyTaggable {
    static var defaultIdentifier: ASN1Identifier {
        .sequence
    }

    var r: IntegerType
    var s: IntegerType

    init(r: IntegerType, s: IntegerType) {
        self.r = r
        self.s = s
    }

    init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(rootNode, identifier: identifier) { nodes in
            let r = try IntegerType(derEncoded: &nodes)
            let s = try IntegerType(derEncoded: &nodes)

            return ECDSASignature(r: r, s: s)
        }
    }

    func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.r)
            try coder.serialize(self.s)
        }
    }
}
