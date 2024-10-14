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

@available(*, unavailable)
extension ASN1: Sendable {}

public enum ASN1 {}

// MARK: - EncodingRules
extension ASN1 {
    @usableFromInline
    enum EncodingRules: Sendable {
        case basic

        case distinguished
    }
}

extension ASN1.EncodingRules {
    @inlinable
    var indefiniteLengthAllowed: Bool { self == .basic }

    @inlinable
    var nonMinimalEncodedLengthsAllowed: Bool { self == .basic }

    @inlinable
    var constructedBitStringAllowed: Bool { self == .basic }

    @inlinable
    var relaxedTimestampsAllowed: Bool { self == .basic }

    @inlinable
    var defaultEncodableSequenceAllowed: Bool { self == .basic }

    @inlinable
    var defaultEncodableSETAllowed: Bool { self == .basic }

    @inlinable
    var unsortedSETAllowed: Bool { self == .basic }

    @inlinable
    var unsortedSETOFAllowed: Bool { self == .basic }
}

// MARK: - Parser Node
extension ASN1 {
    /// A ``ParserNode`` is a representation of a parsed ASN.1 TLV section.
    ///
    /// A ``ParserNode`` may be primitive, or may be composed of other ``ParserNode``s.
    /// In our representation, we keep track of this by storing a node "depth", which allows rapid forward and backward scans to hop over sections
    /// we're uninterested in.
    ///
    /// This type is not exposed to users of the API: it is only used internally for implementation of the user-level API.
    @usableFromInline
    struct ParserNode {
        /// The identifier.
        @usableFromInline
        var identifier: ASN1Identifier

        /// The depth of this node.
        @usableFromInline
        var depth: Int

        /// Whether this node is constructed
        @usableFromInline
        var isConstructed: Bool

        /// The encoded bytes for this complete ASN.1 object.
        @usableFromInline
        var encodedBytes: ArraySlice<UInt8>

        /// The data bytes for this node, if it is primitive.
        @usableFromInline
        var dataBytes: ArraySlice<UInt8>?

        @inlinable
        init(
            identifier: ASN1Identifier,
            depth: Int,
            isConstructed: Bool,
            encodedBytes: ArraySlice<UInt8>,
            dataBytes: ArraySlice<UInt8>? = nil
        ) {
            self.identifier = identifier
            self.depth = depth
            self.isConstructed = isConstructed
            self.encodedBytes = encodedBytes
            self.dataBytes = dataBytes
        }
    }
}

extension ASN1.ParserNode: Hashable {}

extension ASN1.ParserNode: Sendable {}

extension ASN1.ParserNode: CustomStringConvertible {
    @inlinable
    var description: String {
        return
            "ASN1.ParserNode(identifier: \(self.identifier), depth: \(self.depth), dataBytes: \(self.dataBytes?.count ?? 0))"
    }
}

extension ASN1.ParserNode {
    @inlinable
    var isEndMarker: Bool {
        self.identifier.tagClass == .universal
            && self.identifier.tagNumber == 0
            && self.isConstructed == false
            && self.encodedBytes.elementsEqual([0x00, 0x00])
    }
}

// MARK: - Parsing

extension ASN1 {
    @usableFromInline
    struct ParseResult: Sendable {
        @inlinable
        static var _maximumNodeDepth: Int { 50 }

        @usableFromInline
        var nodes: ArraySlice<ParserNode>

        @inlinable
        init(_ nodes: ArraySlice<ParserNode>) {
            self.nodes = nodes
        }

        @inlinable
        static func parse(_ data: ArraySlice<UInt8>, encoding rules: EncodingRules) throws -> ParseResult {
            var data = data
            var nodes = [ParserNode]()
            nodes.reserveCapacity(16)
            try _parseNode(from: &data, encoding: rules, depth: 1, into: &nodes)
            guard data.count == 0 else {
                throw ASN1Error.invalidASN1Object(reason: "Trailing unparsed data is present")
            }
            return ParseResult(nodes[...])
        }

        @inlinable
        static func _parseNode(
            from data: inout ArraySlice<UInt8>,
            encoding rules: EncodingRules,
            depth: Int,
            into nodes: inout [ParserNode]
        ) throws {
            guard depth <= ParseResult._maximumNodeDepth else {
                throw ASN1Error.invalidASN1Object(reason: "Excessive stack depth was reached")
            }

            let originalData = data

            guard let rawIdentifier = data.popFirst() else {
                throw ASN1Error.truncatedASN1Field()
            }

            // Check whether the bottom 5 bits are set: if they are, this uses long-form encoding.
            let constructed = (rawIdentifier & 0x20) != 0
            let identifier: ASN1Identifier
            if (rawIdentifier & 0x1f) == 0x1f {
                let tagClass = ASN1Identifier.TagClass(topByteInWireFormat: rawIdentifier)

                // Now we need to read a UInt from the array.
                let tagNumber = try data.readUIntUsing8BitBytesASN1Discipline()

                // We need a check here: this number needs to be greater than or equal to 0x1f, or it should have been encoded as short form.
                guard tagNumber >= 0x1f else {
                    throw ASN1Error.invalidASN1Object(
                        reason: "ASN.1 tag incorrectly encoded in long form: \(tagNumber)"
                    )
                }
                identifier = ASN1Identifier(tagWithNumber: tagNumber, tagClass: tagClass)
            } else {
                identifier = ASN1Identifier(shortIdentifier: rawIdentifier)
            }

            guard let wideLength = try data._readASN1Length(!rules.nonMinimalEncodedLengthsAllowed) else {
                throw ASN1Error.truncatedASN1Field()
            }

            switch wideLength {
            case let .definite(wideLength):
                guard let length = Int(exactly: wideLength) else {
                    throw ASN1Error.invalidASN1Object(reason: "Excessively large field: \(wideLength)")
                }

                // we know the length of the data, so we can cut the entire buffer now
                var subData = data.prefix(length)
                data = data.dropFirst(length)

                guard subData.count == length else {
                    throw ASN1Error.truncatedASN1Field()
                }

                let encodedBytes = originalData[..<subData.endIndex]

                if constructed {
                    nodes.append(
                        ParserNode(
                            identifier: identifier,
                            depth: depth,
                            isConstructed: true,
                            encodedBytes: encodedBytes
                        )
                    )
                    while subData.count > 0 {
                        try _parseNode(from: &subData, encoding: rules, depth: depth + 1, into: &nodes)
                    }
                } else {
                    nodes.append(
                        ParserNode(
                            identifier: identifier,
                            depth: depth,
                            isConstructed: false,
                            encodedBytes: encodedBytes,
                            dataBytes: subData
                        )
                    )
                }

            case .indefinite:
                guard rules.indefiniteLengthAllowed == true else {
                    // Indefinite form. Unsupported in DER
                    throw ASN1Error.unsupportedFieldLength(
                        reason: "Indefinite form of field length not supported in DER."
                    )
                }

                guard constructed == true else {
                    throw ASN1Error.unsupportedFieldLength(
                        reason: "Indefinite-length field must have constructed identifier"
                    )
                }

                nodes.append(
                    ParserNode(
                        identifier: identifier,
                        depth: depth,
                        isConstructed: true,
                        encodedBytes: []
                    )
                )
                let lastIndex = nodes.endIndex - 1
                repeat {
                    try _parseNode(from: &data, encoding: rules, depth: depth + 1, into: &nodes)
                } while data.count > 0 && nodes.last!.isEndMarker == false
                let endMarker = nodes.popLast()!
                let encodedBytes = originalData[..<endMarker.encodedBytes.endIndex]
                nodes[lastIndex].encodedBytes = encodedBytes
            }
        }
    }
}

extension ASN1.ParseResult: Hashable {}

// MARK: - LazySetOfSequence
extension ASN1 {
    public struct LazySetOfSequence<T>: Sequence {
        public typealias Element = Result<T, any Error>

        @usableFromInline
        typealias WrappedSequence = LazyMapSequence<LazySequence<(ASN1NodeCollection)>.Elements, Result<T, any Error>>

        public struct Iterator: IteratorProtocol {
            @usableFromInline
            var wrapped: WrappedSequence.Iterator

            @inlinable
            mutating public func next() -> Element? {
                wrapped.next()
            }

            @inlinable
            init(_ wrapped: WrappedSequence.Iterator) {
                self.wrapped = wrapped
            }
        }

        @usableFromInline
        var wrapped: WrappedSequence

        @inlinable
        init(_ wrapped: WrappedSequence) {
            self.wrapped = wrapped
        }

        @inlinable
        public func makeIterator() -> Iterator {
            .init(wrapped.makeIterator())
        }
    }
}

@available(*, unavailable)
extension ASN1.LazySetOfSequence: Sendable {}

@available(*, unavailable)
extension ASN1.LazySetOfSequence.Iterator: Sendable {}

// MARK: - NodeCollection
/// Represents a collection of ASN.1 nodes contained in a constructed ASN.1 node.
///
/// Constructed ASN.1 nodes are made up of multiple child nodes. This object represents the collection of those child nodes.
/// It allows us to lazily construct the child nodes, potentially skipping over them when we don't care about them.
///
/// This type cannot be constructed directly, and is instead provided by helper functions such as ``DER/sequence(of:identifier:rootNode:)``.
public struct ASN1NodeCollection {
    @usableFromInline var _nodes: ArraySlice<ASN1.ParserNode>

    @usableFromInline var _depth: Int

    @inlinable
    init(nodes: ArraySlice<ASN1.ParserNode>, depth: Int) {
        self._nodes = nodes
        self._depth = depth

        precondition(self._nodes.allSatisfy({ $0.depth > depth }))
        if let firstDepth = self._nodes.first?.depth {
            precondition(firstDepth == depth + 1)
        }
    }
}

extension ASN1NodeCollection: Hashable {}

extension ASN1NodeCollection: Sendable {}

extension ASN1NodeCollection: Sequence {
    /// An iterator of ASN.1 nodes that are children of a specific constructed node.
    public struct Iterator: IteratorProtocol, Sendable {
        @usableFromInline
        var _nodes: ArraySlice<ASN1.ParserNode>

        @usableFromInline
        var _depth: Int

        @inlinable
        init(nodes: ArraySlice<ASN1.ParserNode>, depth: Int) {
            self._nodes = nodes
            self._depth = depth
        }

        @inlinable
        public mutating func next() -> ASN1Node? {
            guard let nextNode = self._nodes.popFirst() else {
                return nil
            }

            assert(nextNode.depth == self._depth + 1)
            guard nextNode.isConstructed else {
                // There must be data bytes here, even if they're empty.
                return ASN1Node(
                    identifier: nextNode.identifier,
                    content: .primitive(nextNode.dataBytes!),
                    encodedBytes: nextNode.encodedBytes
                )
            }
            // We need to feed it the next set of nodes.
            let nodeCollection = self._nodes.prefix { $0.depth > nextNode.depth }
            self._nodes = self._nodes.dropFirst(nodeCollection.count)
            return ASN1Node(
                identifier: nextNode.identifier,
                content: .constructed(.init(nodes: nodeCollection, depth: nextNode.depth)),
                encodedBytes: nextNode.encodedBytes
            )
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        return Iterator(nodes: self._nodes, depth: self._depth)
    }
}

// MARK: - ASN1Node
/// An ``ASN1Node`` is a single entry in the ASN.1 representation of a data structure.
///
/// Conceptually, an ASN.1 data structure is rooted in a single node, which may itself contain zero or more
/// other nodes. ASN.1 nodes are either "constructed", meaning they contain other nodes, or "primitive", meaning they
/// store a base data type of some kind.
///
/// In this way, ASN.1 objects tend to form a "tree", where each object is represented by a single top-level constructed
/// node that contains other objects and primitives, eventually reaching the bottom which is made up of primitive objects.
public struct ASN1Node: Hashable, Sendable {
    /// The tag for this ASN.1 node.
    public var identifier: ASN1Identifier

    /// The content of this ASN.1 node.
    public var content: Content

    /// The encoded bytes for this node.
    ///
    /// This is principally intended for diagnostic purposes.
    public var encodedBytes: ArraySlice<UInt8>

    @inlinable
    internal init(
        identifier: ASN1Identifier,
        content: ASN1Node.Content,
        encodedBytes: ArraySlice<UInt8>
    ) {
        self.identifier = identifier
        self.content = content
        self.encodedBytes = encodedBytes
    }
}

// MARK: - ASN1Node.Content
extension ASN1Node {
    /// The content of a single ``ASN1Node``.
    public enum Content: Hashable, Sendable {
        /// This ``ASN1Node`` is constructed, and has a number of child nodes.
        case constructed(ASN1NodeCollection)

        /// This ``ASN1Node`` is primitive, and is made up only of a collection of bytes.
        case primitive(ArraySlice<UInt8>)
    }
}

// MARK: - Primitive Extensions

extension ArraySlice where Element == UInt8 {
    @usableFromInline
    enum ASN1Length: Sendable {
        case indefinite
        case definite(_: UInt)
    }

    @inlinable
    mutating func _readASN1Length(_ minimalEncoding: Bool) throws -> ASN1Length? {
        guard let firstByte = self.popFirst() else {
            return nil
        }

        switch firstByte {
        case 0x80:
            return .indefinite
        case let val where val & 0x80 == 0x80:
            // Top bit is set, this is the long form. The remaining 7 bits of this octet
            // determine how long the length field is.
            let fieldLength = Int(val & 0x7F)
            guard self.count >= fieldLength else {
                return nil
            }

            // We need to read the length bytes
            let lengthBytes = self.prefix(fieldLength)
            self = self.dropFirst(fieldLength)
            let length = try UInt(bigEndianBytes: lengthBytes)

            if minimalEncoding {
                // DER requires that we enforce that the length field was encoded in the minimum number of octets necessary.
                let requiredBits = UInt.bitWidth - length.leadingZeroBitCount
                switch requiredBits {
                case 0...7:
                    // For 0 to 7 bits, the long form is unacceptable and we require the short.
                    throw ASN1Error.unsupportedFieldLength(
                        reason:
                            "Field length encoded in long form, but DER requires \(length) to be encoded in short form"
                    )
                case 8...:
                    // For 8 or more bits, fieldLength should be the minimum required.
                    let requiredBytes = (requiredBits + 7) / 8
                    if fieldLength > requiredBytes {
                        throw ASN1Error.unsupportedFieldLength(
                            reason: "Field length encoded in excessive number of bytes"
                        )
                    }
                default:
                    // This is not reachable, but we'll error anyway.
                    throw ASN1Error.unsupportedFieldLength(
                        reason: "Correctness error: computed required bits as \(requiredBits)"
                    )
                }
            }

            return .definite(length)
        case let val:
            // Short form, the length is only one 7-bit integer.
            return .definite(UInt(val))
        }
    }
}

extension FixedWidthInteger {
    @inlinable
    internal init<Bytes: Collection>(bigEndianBytes bytes: Bytes) throws where Bytes.Element == UInt8 {
        guard bytes.count <= (Self.bitWidth / 8) else {
            throw ASN1Error.invalidASN1Object(reason: "Unable to treat \(bytes.count) bytes as a \(Self.self)")
        }

        self = 0

        // Unchecked subtraction because bytes.count must be positive, so we can safely subtract 8 after the
        // multiply. The same logic applies to the math in the loop. Finally, the multiply can be unchecked because
        // we know that bytes.count is less than or equal to bitWidth / 8, so multiplying by 8 cannot possibly overflow.
        var shift = (bytes.count &* 8) &- 8

        var index = bytes.startIndex
        while shift >= 0 {
            self |= Self(truncatingIfNeeded: bytes[index]) << shift
            bytes.formIndex(after: &index)
            shift &-= 8
        }
    }
}

extension Array where Element == UInt8 {
    @inlinable
    mutating func _moveRange(offset: Int, range: Range<Index>) {
        // We only bothered to implement this for positive offsets for now, the algorithm
        // generalises.
        precondition(offset > 0)

        let distanceFromEndOfRangeToEndOfSelf = self.distance(from: range.endIndex, to: self.endIndex)
        if distanceFromEndOfRangeToEndOfSelf < offset {
            // We begin by writing some zeroes out to the size we need.
            for _ in 0..<(offset - distanceFromEndOfRangeToEndOfSelf) {
                self.append(0)
            }
        }

        // Now we walk the range backwards, moving the elements.
        for index in range.reversed() {
            self[index + offset] = self[index]
        }
    }
}

extension Int {
    @inlinable
    var _bytesNeededToEncode: Int {
        // ASN.1 lengths are in two forms. If we can store the length in 7 bits, we should:
        // that requires only one byte. Otherwise, we need multiple bytes: work out how many,
        // plus one for the length of the length bytes.
        guard self <= 0x7F else {
            // We need to work out how many bytes we need. There are many fancy bit-twiddling
            // ways of doing this, but honestly we don't do this enough to need them, so we'll
            // do it the easy way. This math is done on UInt because it makes the shift semantics clean.
            // We save a branch here because we can never overflow this addition.
            return UInt(self).neededBytes &+ 1
        }
        return 1
    }
}

extension FixedWidthInteger {
    // Bytes needed to store a given integer.
    @inlinable
    internal var neededBytes: Int {
        let neededBits = self.bitWidth - self.leadingZeroBitCount
        return (neededBits + 7) / 8
    }
}

extension ASN1NodeCollection {
    @inlinable
    func isOrderedAccordingToSetOfSemantics() -> Bool {
        var iterator = self.makeIterator()
        guard let first = iterator.next() else {
            return true
        }

        var previousElement = first
        while let nextElement = iterator.next() {
            guard asn1SetElementLessThanOrEqual(previousElement.encodedBytes, nextElement.encodedBytes) else {
                return false
            }
            previousElement = nextElement
        }

        return true
    }
}

@inlinable
func asn1SetElementLessThan(_ lhs: ArraySlice<UInt8>, _ rhs: ArraySlice<UInt8>) -> Bool {
    for (leftByte, rightByte) in zip(lhs, rhs) {
        if leftByte < rightByte {
            // true means left comes before right
            return true
        } else if rightByte < leftByte {
            // Right comes after left
            return false
        }
    }

    // We got to the end of the shorter element, so all current elements are equal.
    // If lhs is shorter, it comes earlier, _unless_ all of rhs's trailing elements are zero.
    let trailing = rhs.dropFirst(lhs.count)
    if trailing.allSatisfy({ $0 == 0 }) {
        // Must return false when the two elements are equal.
        return false
    }
    return true
}

@inlinable
func asn1SetElementLessThanOrEqual(_ lhs: ArraySlice<UInt8>, _ rhs: ArraySlice<UInt8>) -> Bool {
    // https://github.com/apple/swift/blob/43c5824be892967993f4d0111206764eceeffb67/stdlib/public/core/Comparable.swift#L202
    !asn1SetElementLessThan(rhs, lhs)
}
