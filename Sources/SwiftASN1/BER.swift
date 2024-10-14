//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftASN1 open source project
//
// Copyright (c) 2019-2023 Apple Inc. and the SwiftASN1 project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftASN1 project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// ``BER`` defines a namespace that is used to store a number of helper methods and types
/// for BER encoding and decoding.
public enum BER {}

@available(*, unavailable)
extension BER: Sendable {}

// MARK: - Parser Node
extension BER {
    @usableFromInline
    typealias ParserNode = ASN1.ParserNode
    typealias ParseResult = ASN1.ParseResult
}

// MARK: - Parsing

extension BER {
    @inlinable
    public static func parse(_ data: [UInt8]) throws -> ASN1Node {
        return try parse(data[...])
    }

    @inlinable
    public static func parse(_ data: ArraySlice<UInt8>) throws -> ASN1Node {
        var result = try ASN1.ParseResult.parse(data, encoding: .basic)

        // There will always be at least one node if the above didn't throw, so we can safely just removeFirst here.
        let firstNode = result.nodes.removeFirst()

        let rootNode: ASN1Node
        if firstNode.isConstructed {
            // We need to feed it the next set of nodes.
            let nodeCollection = result.nodes.prefix { $0.depth > firstNode.depth }
            result.nodes = result.nodes.dropFirst(nodeCollection.count)
            rootNode = ASN1Node(
                identifier: firstNode.identifier,
                content: .constructed(.init(nodes: nodeCollection, depth: firstNode.depth)),
                encodedBytes: firstNode.encodedBytes
            )
        } else {
            rootNode = ASN1Node(
                identifier: firstNode.identifier,
                content: .primitive(firstNode.dataBytes!),
                encodedBytes: firstNode.encodedBytes
            )
        }

        precondition(result.nodes.count == 0, "ASN1ParseResult unexpectedly allowed multiple root nodes")

        return rootNode
    }
}

// MARK: - Sequence, SequenceOf, Set and SetOf
extension BER {
    /// Parse the node as an ASN.1 SEQUENCE.
    ///
    /// The "child" elements in the sequence will be exposed as an iterator to `builder`.
    ///
    /// - parameters:
    ///     - node: The ``ASN1Node`` to parse
    ///     - identifier: The ``ASN1Identifier`` that the SEQUENCE is expected to have.
    ///     - builder: A closure that will be called with the collection of nodes within the sequence.
    @inlinable
    public static func sequence<T>(
        _ node: ASN1Node,
        identifier: ASN1Identifier,
        _ builder: (inout ASN1NodeCollection.Iterator) throws -> T
    ) throws -> T {
        return try DER.sequence(node, identifier: identifier, builder)
    }

    /// Parse the node as an ASN.1 SEQUENCE OF.
    ///
    /// Constructs an array of `T` elements parsed from the sequence.
    ///
    /// - parameters:
    ///     - of: An optional parameter to express the type to decode.
    ///     - identifier: The ``ASN1Identifier`` that the SEQUENCE OF is expected to have.
    ///     - rootNode: The ``ASN1Node`` to parse
    /// - returns: An array of elements representing the elements in the sequence.
    @inlinable
    public static func sequence<T: BERParseable>(
        of: T.Type = T.self,
        identifier: ASN1Identifier,
        rootNode: ASN1Node
    ) throws -> [T] {
        guard rootNode.identifier == identifier, case .constructed(let nodes) = rootNode.content else {
            throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }

        return try nodes.map { try T(berEncoded: $0) }
    }

    /// Parse the node as an ASN.1 SEQUENCE OF.
    ///
    /// Constructs an array of `T` elements parsed from the sequence.
    ///
    /// - parameters:
    ///     - of: An optional parameter to express the type to decode.
    ///     - identifier: The ``ASN1Identifier`` that the SEQUENCE OF is expected to have.
    ///     - nodes: An ``ASN1NodeCollection/Iterator`` of nodes to parse.
    /// - returns: An array of elements representing the elements in the sequence.
    @inlinable
    public static func sequence<T: BERParseable>(
        of: T.Type = T.self,
        identifier: ASN1Identifier,
        nodes: inout ASN1NodeCollection.Iterator
    ) throws -> [T] {
        guard let node = nodes.next() else {
            // Not present, throw.
            throw ASN1Error.invalidASN1Object(
                reason: "No sequence node available for \(T.self) and identifier \(identifier)"
            )
        }

        return try sequence(of: T.self, identifier: identifier, rootNode: node)
    }

    /// Parse the node as an ASN.1 SET.
    ///
    /// The "child" elements in the sequence will be exposed as an iterator to `builder`.
    ///
    /// - parameters:
    ///     - node: The ``ASN1Node`` to parse
    ///     - identifier: The ``ASN1Identifier`` that the SET is expected to have.
    ///     - builder: A closure that will be called with the collection of nodes within the set.
    @inlinable
    public static func set<T>(
        _ node: ASN1Node,
        identifier: ASN1Identifier,
        _ builder: (inout ASN1NodeCollection.Iterator) throws -> T
    ) throws -> T {
        // Shhhh these two are secretly the same with identifier.
        return try sequence(node, identifier: identifier, builder)
    }

    /// Parse the node as an ASN.1 SET OF.
    ///
    /// Constructs an array of `T` elements parsed from the set.
    ///
    /// - parameters:
    ///     - of: An optional parameter to express the type to decode.
    ///     - identifier: The ``ASN1Identifier`` that the SET OF is expected to have.
    ///     - nodes: An ``ASN1NodeCollection/Iterator`` of nodes to parse.
    /// - returns: An array of elements representing the elements in the set.
    @inlinable
    public static func set<T: BERParseable>(
        of: T.Type = T.self,
        identifier: ASN1Identifier,
        nodes: inout ASN1NodeCollection.Iterator
    ) throws -> [T] {
        guard let node = nodes.next() else {
            // Not present, throw.
            throw ASN1Error.invalidASN1Object(
                reason: "No set node available for \(T.self) and identifier \(identifier)"
            )
        }

        return try Self.set(of: T.self, identifier: identifier, rootNode: node)
    }

    /// Parse the node as an ASN.1 SET OF.
    ///
    /// Constructs an array of `T` elements parsed from the set.
    ///
    /// - parameters:
    ///     - type: An optional parameter to express the type to decode.
    ///     - identifier: The ``ASN1Identifier`` that the SET OF is expected to have.
    ///     - rootNode: The ``ASN1Node`` to parse
    /// - returns: An array of elements representing the elements in the sequence.
    @inlinable
    public static func set<T: BERParseable>(
        of type: T.Type = T.self,
        identifier: ASN1Identifier,
        rootNode: ASN1Node
    ) throws -> [T] {
        try self.lazySet(of: type, identifier: identifier, rootNode: rootNode).map { try $0.get() }
    }

    /// Parse the node as an ASN.1 SET OF lazily.
    ///
    /// Constructs a Sequence of `T` elements that will be lazily parsed from the set.
    ///
    /// - parameters:
    ///     - of: An optional parameter to express the type to decode.
    ///     - identifier: The ``ASN1Identifier`` that the SET OF is expected to have.
    ///     - rootNode: The ``ASN1Node`` to parse
    /// - returns: A `Sequence` of elements representing the `Result` of parsing the elements in the sequence.
    @inlinable
    public static func lazySet<T: BERParseable>(
        of: T.Type = T.self,
        identifier: ASN1Identifier,
        rootNode: ASN1Node
    ) throws -> BER.LazySetOfSequence<T> {
        guard rootNode.identifier == identifier, case .constructed(let nodes) = rootNode.content else {
            throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }

        // BER allows unsorted SET OF

        return .init(nodes.lazy.map { node in Result { try T(berEncoded: node) } })
    }
}

// MARK: - LazySetOfSequence
extension BER {
    public typealias LazySetOfSequence = ASN1.LazySetOfSequence
}

// MARK: - Optional explicitly tagged
extension BER {
    /// Parses an optional explicitly tagged element.
    ///
    /// - parameters:
    ///     - nodes: The ``ASN1NodeCollection/Iterator`` to parse this element out of.
    ///     - tagNumber: The number of the explicit tag.
    ///     - tagClass: The class of the explicit tag.
    ///     - builder: A closure that will be called with the node for the element, if the element is present.
    ///
    /// - returns: The result of `builder` if the element was present, or `nil` if it was not.
    @inlinable
    public static func optionalExplicitlyTagged<T>(
        _ nodes: inout ASN1NodeCollection.Iterator,
        tagNumber: UInt,
        tagClass: ASN1Identifier.TagClass,
        _ builder: (ASN1Node) throws -> T
    ) throws -> T? {
        return try DER.optionalExplicitlyTagged(&nodes, tagNumber: tagNumber, tagClass: tagClass, builder)
    }
}

// MARK: - Optional implicitly tagged
extension BER {
    /// Parses an optional implicitly tagged element.
    ///
    /// - parameters:
    ///     - nodes: The ``ASN1NodeCollection/Iterator`` to parse this element out of.
    ///     - tag: The implicit tag. Defaults to the default tag for the element.
    ///
    /// - returns: The parsed element, if it was present, or `nil` if it was not.
    @inlinable
    public static func optionalImplicitlyTagged<T: DERImplicitlyTaggable>(
        _ nodes: inout ASN1NodeCollection.Iterator,
        tag: ASN1Identifier = T.defaultIdentifier
    ) throws -> T? {
        var localNodesCopy = nodes
        guard let node = localNodesCopy.next() else {
            // Node not present, return nil.
            return nil
        }

        guard node.identifier == tag else {
            // Node is a mismatch, with the wrong tag. Our optional isn't present.
            return nil
        }

        // We're good: pass the node on.
        return try T(derEncoded: &nodes, withIdentifier: tag)
    }

    /// Parses an optional implicitly tagged element.
    ///
    /// - parameters:
    ///     - nodes: The ``ASN1NodeCollection/Iterator`` to parse this element out of.
    ///     - tagNumber: The number of the explicit tag.
    ///     - tagClass: The class of the explicit tag.
    ///     - builder: A closure that will be called with the node for the element, if the element is present.
    ///
    /// - returns: The result of `builder` if the element was present, or `nil` if it was not.
    @inlinable
    public static func optionalImplicitlyTagged<Result>(
        _ nodes: inout ASN1NodeCollection.Iterator,
        tagNumber: UInt,
        tagClass: ASN1Identifier.TagClass,
        _ builder: (ASN1Node) throws -> Result
    ) rethrows -> Result? {
        return try DER.optionalImplicitlyTagged(&nodes, tagNumber: tagNumber, tagClass: tagClass, builder)
    }
}

// MARK: - DEFAULT
extension BER {
    /// Parses a value that is encoded with a DEFAULT.
    ///
    /// Such a value is optional, and if absent will be replaced with its default.
    ///
    /// - parameters:
    ///     - nodes: The ``ASN1NodeCollection/Iterator`` to parse this element out of.
    ///     - identifier: The implicit tag. Defaults to the default tag for the element.
    ///     - defaultValue: The default value to use if there was no encoded value.
    ///     - builder: A closure that will be called with the node for the element, if the element is present.
    ///
    /// - returns: The parsed element, if it was present, or the default if it was not.
    @inlinable
    public static func decodeDefault<T: BERParseable & Equatable>(
        _ nodes: inout ASN1NodeCollection.Iterator,
        identifier: ASN1Identifier,
        defaultValue: T,
        _ builder: (ASN1Node) throws -> T
    ) throws -> T {
        // A weird trick here: we only want to consume the next node _if_ it has the right tag. To achieve that,
        // we work on a copy.
        var localNodesCopy = nodes
        guard let node = localNodesCopy.next() else {
            // Whoops, nothing here.
            return defaultValue
        }

        guard node.identifier == identifier else {
            // Node is a mismatch, with the wrong identifier. Our optional isn't present.
            return defaultValue
        }

        // We have the right optional, so let's consume it.
        nodes = localNodesCopy
        let parsed = try builder(node)

        // DER forbids encoding DEFAULT values at their default state, but BER allows it

        return parsed
    }

    /// Parses a value that is encoded with a DEFAULT.
    ///
    /// Such a value is optional, and if absent will be replaced with its default. This function is
    /// a helper wrapper for ``decodeDefault(_:identifier:defaultValue:_:)`` that automatically invokes
    /// ``DERParseable/init(derEncoded:)-7tumk`` on `T`.
    ///
    /// - parameters:
    ///     - nodes: The ``ASN1NodeCollection/Iterator`` to parse this element out of.
    ///     - identifier: The implicit tag. Defaults to the default tag for the element.
    ///     - defaultValue: The default value to use if there was no encoded value.
    ///
    /// - returns: The parsed element, if it was present, or the default if it was not.
    @inlinable
    public static func decodeDefault<T: BERParseable & Equatable>(
        _ nodes: inout ASN1NodeCollection.Iterator,
        identifier: ASN1Identifier,
        defaultValue: T
    ) throws -> T {
        return try Self.decodeDefault(&nodes, identifier: identifier, defaultValue: defaultValue) {
            try T(berEncoded: $0)
        }
    }

    /// Parses a value that is encoded with a DEFAULT.
    ///
    /// Such a value is optional, and if absent will be replaced with its default. This function is
    /// a helper wrapper for ``decodeDefault(_:identifier:defaultValue:_:)`` that automatically invokes
    /// ``DERImplicitlyTaggable/init(derEncoded:withIdentifier:)-7e88k`` on `T` using ``DERImplicitlyTaggable/defaultIdentifier``.
    ///
    /// - parameters:
    ///     - nodes: The ``ASN1NodeCollection/Iterator`` to parse this element out of.
    ///     - defaultValue: The default value to use if there was no encoded value.
    ///
    /// - returns: The parsed element, if it was present, or the default if it was not.
    @inlinable
    public static func decodeDefault<T: BERImplicitlyTaggable & Equatable>(
        _ nodes: inout ASN1NodeCollection.Iterator,
        defaultValue: T
    ) throws -> T {
        return try Self.decodeDefault(&nodes, identifier: T.defaultIdentifier, defaultValue: defaultValue)
    }

    /// Parses a value that is encoded with a DEFAULT and an explicit tag.
    ///
    /// Such a value is optional, and if absent will be replaced with its default.
    ///
    /// - parameters:
    ///     - nodes: The ``ASN1NodeCollection/Iterator`` to parse this element out of.
    ///     - tagNumber: The number of the explicit tag.
    ///     - tagClass: The class of the explicit tag.
    ///     - defaultValue: The default value to use if there was no encoded value.
    ///     - builder: A closure that will be called with the node for the element, if the element is present.
    ///
    /// - returns: The parsed element, if it was present, or the default if it was not.
    @inlinable
    public static func decodeDefaultExplicitlyTagged<T: BERParseable & Equatable>(
        _ nodes: inout ASN1NodeCollection.Iterator,
        tagNumber: UInt,
        tagClass: ASN1Identifier.TagClass,
        defaultValue: T,
        _ builder: (ASN1Node) throws -> T
    ) throws -> T {
        guard let result = try optionalExplicitlyTagged(&nodes, tagNumber: tagNumber, tagClass: tagClass, builder)
        else {
            return defaultValue
        }
        // BER allows explcitly default encoded
        return result
    }

    /// Parses a value that is encoded with a DEFAULT and an explicit tag.
    ///
    /// Such a value is optional, and if absent will be replaced with its default. This function is
    /// a helper wrapper for ``decodeDefaultExplicitlyTagged(_:tagNumber:tagClass:defaultValue:_:)`` that automatically invokes
    /// ``DERParseable/init(derEncoded:)-7tumk`` on `T`.
    ///
    /// - parameters:
    ///     - nodes: The ``ASN1NodeCollection/Iterator`` to parse this element out of.
    ///     - tagNumber: The number of the explicit tag.
    ///     - tagClass: The class of the explicit tag.
    ///     - defaultValue: The default value to use if there was no encoded value.
    ///
    /// - returns: The parsed element, if it was present, or the default if it was not.
    @inlinable
    public static func decodeDefaultExplicitlyTagged<T: BERParseable & Equatable>(
        _ nodes: inout ASN1NodeCollection.Iterator,
        tagNumber: UInt,
        tagClass: ASN1Identifier.TagClass,
        defaultValue: T
    ) throws -> T {
        return try Self.decodeDefaultExplicitlyTagged(
            &nodes,
            tagNumber: tagNumber,
            tagClass: tagClass,
            defaultValue: defaultValue
        ) {
            try T(berEncoded: $0)
        }
    }
}

// MARK: - Ordinary, explicit tagging
extension BER {
    /// Parses an explicitly tagged element.
    ///
    /// - parameters:
    ///     - nodes: The ``ASN1NodeCollection/Iterator`` to parse this element out of.
    ///     - tagNumber: The number of the explicit tag.
    ///     - tagClass: The class of the explicit tag.
    ///     - builder: A closure that will be called with the node for the element.
    ///
    /// - returns: The result of `builder`.
    @inlinable
    public static func explicitlyTagged<T>(
        _ nodes: inout ASN1NodeCollection.Iterator,
        tagNumber: UInt,
        tagClass: ASN1Identifier.TagClass,
        _ builder: (ASN1Node) throws -> T
    ) throws -> T {
        return try DER.explicitlyTagged(&nodes, tagNumber: tagNumber, tagClass: tagClass, builder)
    }

    /// Parses an explicitly tagged element.
    ///
    /// - parameters:
    ///     - node: The ``ASN1Node`` to parse this element out of.
    ///     - tagNumber: The number of the explicit tag.
    ///     - tagClass: The class of the explicit tag.
    ///     - builder: A closure that will be called with the node for the element.
    ///
    /// - returns: The result of `builder`.
    @inlinable
    public static func explicitlyTagged<T>(
        _ node: ASN1Node,
        tagNumber: UInt,
        tagClass: ASN1Identifier.TagClass,
        _ builder: (ASN1Node) throws -> T
    ) throws -> T {
        let expectedNodeID = ASN1Identifier(tagWithNumber: tagNumber, tagClass: tagClass)
        guard node.identifier == expectedNodeID else {
            // Node is a mismatch, with the wrong tag.
            throw ASN1Error.unexpectedFieldType(node.identifier)
        }

        // We expect a single child.
        guard case .constructed(let nodes) = node.content else {
            throw ASN1Error.invalidASN1Object(reason: "Explicit tag \(expectedNodeID) for \(T.self) is primitive")
        }

        var nodeIterator = nodes.makeIterator()
        guard let child = nodeIterator.next(), nodeIterator.next() == nil else {
            throw ASN1Error.invalidASN1Object(
                reason: "Invalid number of child nodes for explicit tag \(expectedNodeID) for \(T.self)"
            )
        }

        return try builder(child)
    }
}

// MARK: - Helpers

/// Defines a type that can be parsed from a BER-encoded form, which is a superset of DER.
///
/// Inherits the DERParseable protocol.
///
/// Users implementing this type are expected to write the ASN.1 decoding code themselves. This approach is discussed in
/// depth in <doc:DecodingASN1>. When working with a type that may be implicitly tagged (which is most ASN.1 types),
/// users are recommended to implement ``BERImplicitlyTaggable`` instead.
public protocol BERParseable: DERParseable {
    /// Initialize this object from a serialized BER representation.
    ///
    /// This function is invoked by the parser with the root node for the ASN.1 object. Implementers are
    /// expected to initialize themselves if possible, or to throw if they cannot.
    ///
    /// - parameters:
    ///     - node: The ASN.1 node representing this object.
    init(berEncoded node: ASN1Node) throws
}

extension BERParseable {

    /// By default, uses the underlying DERParseable initializer.
    @inlinable
    public init(berEncoded node: ASN1Node) throws {
        self = try .init(derEncoded: node)
    }

    @inlinable
    public init(berEncoded sequenceNodeIterator: inout ASN1NodeCollection.Iterator) throws {
        guard let node = sequenceNodeIterator.next() else {
            throw ASN1Error.invalidASN1Object(reason: "Unable to decode \(Self.self), no ASN.1 nodes to decode")
        }

        self = try .init(berEncoded: node)
    }

    /// Initialize this object from a serialized BER representation.
    ///
    /// - parameters:
    ///     - berEncoded: The BER-encoded bytes representing this object.
    @inlinable
    public init(berEncoded: [UInt8]) throws {
        self = try .init(berEncoded: BER.parse(berEncoded))
    }

    /// Initialize this object from a serialized BER representation.
    ///
    /// - parameters:
    ///     - berEncoded: The BER-encoded bytes representing this object.
    @inlinable
    public init(berEncoded: ArraySlice<UInt8>) throws {
        self = try .init(berEncoded: BER.parse(berEncoded))
    }
}

/// Defines a type that can be serialized in BER-encoded form.
///
/// Inherits from DERSerializable.
///
/// Since DER is a subset of BER, all DER-encoded objects are valid BER-encodings. In almost all cases DER is the preferred
/// form of serialization, and no BER-only constructs for serialization are supported.
///
/// Users implementing this type are expected to write the ASN.1 serialization code themselves. This approach is discussed in
/// depth in <doc:DecodingASN1>. When working with a type that may be implicitly tagged (which is most ASN.1 types),
/// users are recommended to implement ``BERImplicitlyTaggable`` instead.
public protocol BERSerializable: DERSerializable {
}

public protocol BERImplicitlyTaggable: BERParseable, BERSerializable, DERImplicitlyTaggable {
    /// The tag that the first node will use "by default" if the grammar omits
    /// any more specific tag definition.
    static var defaultIdentifier: ASN1Identifier { get }

    /// Initialize this object from a serialized BER representation.
    ///
    /// This function is invoked by the parser with the root node for the ASN.1 object. Implementers are
    /// expected to initialize themselves if possible, or to throw if they cannot. The object is expected
    /// to use the identifier `identifier`.
    ///
    /// - parameters:
    ///     - berEncoded: The ASN.1 node representing this object.
    ///     - identifier: The ASN.1 identifier that `berEncoded` is expected to have.
    init(berEncoded: ASN1Node, withIdentifier identifier: ASN1Identifier) throws
}

extension BERImplicitlyTaggable {
    /// Initialize this object as one element of a constructed ASN.1 object.
    ///
    /// This is a helper function for parsing constructed ASN.1 objects. It delegates all its functionality
    /// to ``BERImplicitlyTaggable/init(berEncoded:withIdentifier:)``.
    ///
    /// - parameters:
    ///     - sequenceNodeIterator: The sequence of nodes that make up this object's parent. The first node in this collection
    ///         will be used to construct this object.
    ///     - identifier: The ASN.1 identifier that `berEncoded` is expected to have.
    @inlinable
    public init(
        berEncoded sequenceNodeIterator: inout ASN1NodeCollection.Iterator,
        withIdentifier identifier: ASN1Identifier = Self.defaultIdentifier
    ) throws {
        guard let node = sequenceNodeIterator.next() else {
            throw ASN1Error.invalidASN1Object(reason: "Unable to decode \(Self.self), no ASN.1 nodes to decode")
        }

        self = try .init(berEncoded: node, withIdentifier: identifier)
    }

    /// Initialize this object from a serialized BER representation.
    ///
    /// - parameters:
    ///     - berEncoded: The BER-encoded bytes representing this object.
    ///     - identifier: The ASN.1 identifier that `berEncoded` is expected to have.
    @inlinable
    public init(berEncoded: [UInt8], withIdentifier identifier: ASN1Identifier = Self.defaultIdentifier) throws {
        self = try .init(berEncoded: BER.parse(berEncoded), withIdentifier: identifier)
    }

    /// Initialize this object from a serialized BER representation.
    ///
    /// - parameters:
    ///     - berEncoded: The DER-encoded bytes representing this object.
    ///     - identifier: The ASN.1 identifier that `berEncoded` is expected to have.
    @inlinable
    public init(
        berEncoded: ArraySlice<UInt8>,
        withIdentifier identifier: ASN1Identifier = Self.defaultIdentifier
    ) throws {
        self = try .init(berEncoded: BER.parse(berEncoded), withIdentifier: identifier)
    }

    /// Initialize this object from a serialized BER representation.
    ///
    /// - parameters:
    ///     - berEncoded: The BER-encoded bytes representing this object.
    @inlinable
    public init(berEncoded: ASN1Node) throws {
        try self.init(berEncoded: berEncoded, withIdentifier: Self.defaultIdentifier)
    }
}
