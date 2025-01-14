//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftASN1 open source project
//
// Copyright (c) 2019-2020 Apple Inc. and the SwiftASN1 project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftASN1 project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// An OCTET STRING is a representation of a string of octets.
public struct ASN1OctetString: DERImplicitlyTaggable, BERImplicitlyTaggable {

    @inlinable
    public static var defaultIdentifier: ASN1Identifier {
        .octetString
    }

    /// The octets that make up this OCTET STRING.
    public var bytes: ArraySlice<UInt8>

    @inlinable
    public init(derEncoded node: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        guard node.identifier == identifier else {
            throw ASN1Error.unexpectedFieldType(node.identifier)
        }

        guard case .primitive(let content) = node.content else {
            throw ASN1Error.invalidASN1Object(reason: "ASN1OctetString encoded with constructed encoding")
        }

        self.bytes = content
    }

    @inlinable
    public init(berEncoded node: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        guard node.identifier == identifier else {
            throw ASN1Error.unexpectedFieldType(node.identifier)
        }

        switch node.content {
        case .constructed(let nodes):
            // BER allows constructed ASN1 BitStrings, that is, you can construct a BitString that is represented by a composition of many individual recursively encoded (primitive or constructed) BitStrings

            // We have to allocate here, since we need to flatten all of the sub octet-strings into a contiguous view
            // Maybe it's possible in the future something like [chain](https://github.com/apple/swift-algorithms/blob/main/Guides/Chain.md)
            // could be used to eliminate allocations, but we need an ArraySlice
            let (count, maxLength) = nodes.reduce((0, 0)) { acc, elem in
                let (countAcc, lenAcc) = acc
                return (countAcc + 1, lenAcc + elem.encodedBytes.count)
            }

            if count == 0 {
                self.bytes = []
                return
            }

            if count == 1 {
                // this recursive call might allocate if the inner string is also constructed, which means the recursive portions have returned a flattened view.
                for node in nodes {
                    let substring = try ASN1OctetString(berEncoded: node)
                    self.bytes = substring.bytes
                    return
                }
            }

            var flattened: [UInt8] = []
            // we are going to reserve capacity a bit over what reality will be, since we are hinting the allocation based on the entire encoded bytes, which includes tags and sizes
            flattened.reserveCapacity(maxLength)
            for node in nodes {
                let substring = try ASN1OctetString(berEncoded: node)
                flattened += substring.bytes
            }

            self.bytes = flattened[...]

        case .primitive(let content):
            self.bytes = content
        }
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
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        coder.appendPrimitiveNode(identifier: identifier) { bytes in
            bytes.append(contentsOf: self.bytes)
        }
    }
}

extension ASN1OctetString: Hashable {}

extension ASN1OctetString: Sendable {}

extension ASN1OctetString {
    @inlinable
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try self.bytes.withUnsafeBytes(body)
    }
}
