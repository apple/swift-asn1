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

#if canImport(Foundation)
import Foundation

/// Defines a type that can be serialized in PEM-encoded form.
///
/// Users implementing this type are expected to just provide the ``defaultPEMDiscriminator``
///
/// A PEM `String` can be serialized by constructing a ``PEMDocument`` by calling ``PEMSerializable/serializeAsPEM()`` and then accessing the ``PEMDocument/pemString`` preropty.
public protocol PEMSerializable: DERSerializable {
    /// The PEM discriminator identifying this object type.
    ///
    /// The PEM discriminator is in the first line of a PEM string after `BEGIN` and at the end of the string after `END` e.g.
    /// ```
    /// -----BEGIN defaultPEMDiscriminator-----
    /// <base 64 DER representation of this object>
    /// -----END defaultPEMDiscriminator-----
    /// ```
    static var defaultPEMDiscriminator: String { get }

    func serializeAsPEM(discriminator: String) throws -> PEMDocument
}

/// Defines a type that can be parsed from a PEM-encoded form.
///
/// Users implementing this type are expected to just provide the ``defaultPEMDiscriminator``.
///
/// Objects that are ``PEMParseable`` can be construct from a PEM `String` through ``PEMParseable/init(pemEncoded:)``.
public protocol PEMParseable: DERParseable {
    /// The PEM discriminator identifying this object type.
    ///
    /// The PEM discriminator is in the first line of a PEM string after `BEGIN` and at the end of the string after `END` e.g.
    /// ```
    /// -----BEGIN defaultPEMDiscriminator-----
    /// <base 64 DER representation of this object>
    /// -----END defaultPEMDiscriminator-----
    /// ```
    static var defaultPEMDiscriminator: String { get }

    init(pemDocument: PEMDocument) throws
}

/// Defines a type that can be serialized in and parsed from PEM-encoded form.
///
/// Users implementing this type are expected to just provide the ``PEMParseable/defaultPEMDiscriminator``.
///
/// Objects that are ``PEMRepresentable`` can be construct from a PEM `String` through ``PEMParseable/init(pemEncoded:)``.
///
/// A PEM `String` can be serialized by constructing a ``PEMDocument`` by calling ``PEMSerializable/serializeAsPEM()`` and then accessing the ``PEMDocument/pemString`` preropty.
public typealias PEMRepresentable = PEMSerializable & PEMParseable

extension PEMParseable {

    /// Initialize this object from a serialized PEM representation.
    ///
    /// This will check that the discriminator matches ``PEMParseable/defaultPEMDiscriminator``, decode the base64 encoded string and
    /// then decode the DER encoded bytes using ``DERParseable/init(derEncoded:)-i2rf``.
    ///
    /// - parameters:
    ///     - pemEncoded: The PEM-encoded string representing this object.
    @inlinable
    public init(pemEncoded pemString: String) throws {
        try self.init(pemDocument: try PEMDocument(pemString: pemString))
    }

    /// Initialize this object from a serialized PEM representation.
    /// This will check that the ``PEMParseable/pemDiscriminator`` matches and
    /// forward the DER encoded bytes to ``DERParseable/init(derEncoded:)-i2rf``.
    ///
    /// - parameters:
    ///     - pemDocument: DER-encoded PEM document
    @inlinable
    public init(pemDocument: PEMDocument) throws {
        guard pemDocument.discriminator == Self.defaultPEMDiscriminator else {
            throw ASN1Error.invalidPEMDocument(
                reason:
                    "PEMDocument has incorrect discriminator \(pemDocument.discriminator). Expected \(Self.defaultPEMDiscriminator) instead"
            )
        }

        try self.init(derEncoded: pemDocument.derBytes)
    }
}

extension PEMSerializable {
    /// Serializes `self` as a PEM document with given `discriminator`.
    /// - Parameter discriminator: PEM discriminator used in for the BEGIN and END encapsulation boundaries.
    /// - Returns: DER encoded PEM document
    @inlinable
    public func serializeAsPEM(discriminator: String) throws -> PEMDocument {
        var serializer = DER.Serializer()
        try serializer.serialize(self)

        return PEMDocument(type: discriminator, derBytes: serializer.serializedBytes)
    }

    /// Serializes `self` as a PEM document with the ``defaultPEMDiscriminator``.
    @inlinable
    public func serializeAsPEM() throws -> PEMDocument {
        try self.serializeAsPEM(discriminator: Self.defaultPEMDiscriminator)
    }
}

/// A PEM document is some data, and a discriminator type that is used to advertise the content.
public struct PEMDocument: Hashable, Sendable {
    fileprivate static let lineLength = 64

    /// The PEM discriminator is in the first line of a PEM string after `BEGIN` and at the end of the string after `END` e.g.
    /// ```
    /// -----BEGIN discriminator-----
    /// <base 64 encoded derBytes>
    /// -----END discriminator-----
    /// ```
    public var discriminator: String

    public var derBytes: [UInt8]
    
    public init(pemString: String) throws {
        let documents = try PEMDocument.multiple(pemString: pemString)
        if documents.count == 0 {
            throw ASN1Error.invalidPEMDocument(reason: "could not find PEM start marker")
        } else if documents.count == 1 {
            self = documents.first!
        } else {
            throw ASN1Error.invalidPEMDocument(reason: "Multiple PEMDocuments found")
        }
    }

    public init(type: String, derBytes: [UInt8]) {
        self.discriminator = type
        self.derBytes = derBytes
    }

    /// PEM string is a base 64 encoded string of ``derBytes`` enclosed in BEGIN and END encapsulation boundaries with the specified ``discriminator`` type.
    ///
    /// Example PEM string:
    /// ```
    /// -----BEGIN discriminator-----
    /// <base 64 encoded derBytes>
    /// -----END discriminator-----
    /// ```
    public var pemString: String {
        var encoded = Data(self.derBytes).base64EncodedString()[...]
        let pemLineCount = (encoded.utf8.count + Self.lineLength) / Self.lineLength
        var pemLines = [Substring]()
        pemLines.reserveCapacity(pemLineCount + 2)

        pemLines.append("-----BEGIN \(self.discriminator)-----")

        while encoded.count > 0 {
            let prefixIndex =
                encoded.index(encoded.startIndex, offsetBy: Self.lineLength, limitedBy: encoded.endIndex)
                ?? encoded.endIndex
            pemLines.append(encoded[..<prefixIndex])
            encoded = encoded[prefixIndex...]
        }

        pemLines.append("-----END \(self.discriminator)-----")

        return pemLines.joined(separator: "\n")
    }
}

extension PEMDocument {
    public static func multiple(pemString: String) throws -> [PEMDocument] {
        var pemString = pemString.utf8[...]
        var pemDocuments = [PEMDocument]()
        while true {
            guard let (discriminator, base64EncodedDER) = try pemString.readNextPEMDocument() else {
                // we reached the end
                return pemDocuments
            }
            guard let base64EncodedDERString = String(base64EncodedDER) else {
                return pemDocuments
            }
            
            guard let data = Data(base64Encoded: base64EncodedDERString, options: .ignoreUnknownCharacters) else {
                throw ASN1Error.invalidPEMDocument(reason: "PEMDocument not correctly base64 encoded")
            }
            guard let type = String(discriminator) else {
                return pemDocuments
            }
            let derBytes = Array(data)
            pemDocuments.append(PEMDocument(type: type, derBytes: derBytes))
        }
    }
}

extension Substring.UTF8View {
    /// A PEM document looks like this:
    /// ```
    /// -----BEGIN <SOME DISCRIMINATOR>-----
    /// <base64 encoded bytes, 64 characters per line>
    /// -----END <SOME DISCRIMINATOR>-----
    /// ```
    /// This function attempts find the BEGIN and END marker.
    /// It then tries to extract the discriminator and the base64 encoded.
    /// - Returns: `discriminator` found after BEGIN and END markers and `base64EncodedDerBytes`.
    /// The `base64EncodedDerBytes` is as found in the original string and will still contain new lines if present in the original.
    mutating func readNextPEMDocument() throws -> (discriminator: Self, base64EncodedDerBytes: Self)? {
        /// First find the BEGIN marker: `-----BEGIN <SOME DISCRIMINATOR>-----
        guard
            let beginDiscriminatorPrefix = self.firstRange(of: "-----BEGIN ".utf8[...]),
            let beginDiscriminatorSuffix = self[beginDiscriminatorPrefix.upperBound...].firstRange(of: "-----\n".utf8[...])
        else {
            return nil
        }
        let beginDiscriminator = self[beginDiscriminatorPrefix.upperBound..<beginDiscriminatorSuffix.lowerBound]
        
        /// and then find the END marker: `-----END <SOME DISCRIMINATOR>-----
        guard
            let endDiscriminatorPrefix = self[beginDiscriminatorSuffix.upperBound...].firstRange(of: "-----END ".utf8[...]),
            let endDiscriminatorSuffix = self[endDiscriminatorPrefix.upperBound...].firstRange(of: "-----".utf8[...])
        else {
            let pemBegin = self[beginDiscriminatorPrefix.lowerBound..<beginDiscriminatorSuffix.upperBound]
            let pemEnd = "-----END \(beginDiscriminator)-----"
            throw ASN1Error.invalidPEMDocument(
                reason: "PEMDocument has \(String(reflecting: String(pemBegin))) but not \(String(reflecting: pemEnd))"
            )
        }
        let endDiscriminator = self[endDiscriminatorPrefix.upperBound..<endDiscriminatorSuffix.lowerBound]
        
        /// discriminator found in the BEGIN and END markers need to match
        guard beginDiscriminator.elementsEqual(endDiscriminator) else {
            throw ASN1Error.invalidPEMDocument(
                reason: "PEMDocument begin and end discriminator don't match. BEGIN: \(String(reflecting: String(beginDiscriminator))). END: \(String(reflecting: String(endDiscriminator)))"
            )
        }
        
        /// everything between the BEGIN and END markers is considered the base64 encoded bytes
        let base64EncodedDerBytes = self[beginDiscriminatorSuffix.upperBound..<endDiscriminatorPrefix.lowerBound]
        
        /// move `self` to the end of the END marker
        self = self[endDiscriminatorPrefix.upperBound...]
        
        return (
            discriminator: beginDiscriminator,
            base64EncodedDerBytes: base64EncodedDerBytes
        )
    }
}

extension Substring.UTF8View {
    func firstRange(of other: Self) -> Range<Index>? {
        guard other.count >= 1 else {
            return self.startIndex..<self.startIndex
        }
        let otherWithoutFirst = other.dropFirst()
        
        var currentSearchRange = self
        while currentSearchRange.count >= other.count {
            // find the first occurrence of first element in other
            guard let firstIndexOfOther = currentSearchRange.firstIndex(of: other.first!) else {
                return nil
            }
            // this is now the start of a potential match.
            // we have already checked the first element so we can skip that and 
            // continue our search from the second element
            let secondIndexOfOther = currentSearchRange.index(after: firstIndexOfOther)
            guard let searchEndIndex = currentSearchRange.index(firstIndexOfOther, offsetBy: other.count, limitedBy: currentSearchRange.endIndex) else {
                // not enough elements remaining
                return nil
            }
            // check that all elements are equal
            if currentSearchRange[secondIndexOfOther..<searchEndIndex].elementsEqual(otherWithoutFirst) {
                // we found a match
                return firstIndexOfOther..<searchEndIndex
            } else {
                // we continue our search one after the current match
                currentSearchRange = self[secondIndexOfOther...]
            }
        }
        return nil
    }
}

#endif
