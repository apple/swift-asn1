//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftASN1 open source project
//
// Copyright (c) 2023 Apple Inc. and the SwiftASN1 project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftASN1 project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import SwiftASN1

struct CMSContentInfo: BERImplicitlyTaggable, DERImplicitlyTaggable, Hashable {
    static var defaultIdentifier: ASN1Identifier {
        .sequence
    }

    public var contentType: ASN1ObjectIdentifier

    var content: ASN1Any

    init(contentType: ASN1ObjectIdentifier, content: ASN1Any) {
        self.contentType = contentType
        self.content = content
    }

    init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(rootNode, identifier: Self.defaultIdentifier) { nodes in
            let contentType = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let content = try DER.explicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { node in
                ASN1Any(derEncoded: node)
            }
            return .init(contentType: contentType, content: content)
        }
    }

    init(berEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try BER.sequence(rootNode, identifier: Self.defaultIdentifier) { nodes in
            let contentType = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let content = try BER.explicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { node in
                ASN1Any(berEncoded: node)
            }
            return .init(contentType: contentType, content: content)
        }
    }

    func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.contentType)
            try coder.serialize(self.content)
        }
    }
}
