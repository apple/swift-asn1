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

/// Defines a type that can be serialized in PEM-encoded form.
///
/// Users implementing this type are expected to just provide the ``pemDiscriminator``
///
/// Objects that are ``PEMSerializable`` can be serialized to a PEM `String` by constructing a ``PEMSerializer`` and calling ``PEMSerializer/serialize(_:)``.
public protocol PEMSerializable: DERSerializable {
    /// The PEM discriminator identifying this object type.
    ///
    /// The PEM discriminator is in the first line of a PEM string after `BEGIN` and at the end of the string after `END` i.e.
    /// ```
    /// -----BEGIN pemDiscrimiator-----
    /// <base 64 DER representation of this object>
    /// -----END pemDiscrimiator-----
    /// ```
    static var pemDiscriminator: String { get }
}

/// Defines a type that can be parsed from a PEM-encoded form.
///
/// Users implementing this type are expected to just provide the ``pemDiscriminator``.
///
/// Objects that are ``PEMParseable`` can be construct from a PEM `String` through ``PEMParseable/init(pemEncoded:)``.
public protocol PEMParseable: DERParseable {
    /// The PEM discriminator identifying this object type.
    ///
    /// The PEM discriminator is in the first line of a PEM string after `BEGIN` and at the end of the string after `END` i.e.
    /// ```
    /// -----BEGIN pemDiscrimiator-----
    /// <base 64 DER representation of this object>
    /// -----END pemDiscrimiator-----
    /// ```
    static var pemDiscriminator: String { get }
}

/// Defines a type that can be serialized in and parsed from PEM-encoded form.
///
/// Users implementing this type are expected to just provide the ``pemDiscriminator``.
///
/// Objects that are ``PEMRepresentable`` can be construct from a PEM `String` through ``PEMParseable/init(pemEncoded:)``.
///
/// A PEM `String` can serialized by constructing a ``PEMSerializer`` and calling ``PEMSerializer/serialize(_:)``.
public typealias PEMRepresentable = PEMSerializable & PEMParseable

#if canImport(Foundation)
import Foundation

extension PEMParseable {
    /// Initialize this object from a serialized PEM representation.
    ///
    /// - parameters:
    ///     - pemEncoded: The PEM-encoded string representing this object.
    public init(pemEncoded pemString: String) throws {
        // A PEM document looks like this:
        //
        // -----BEGIN <SOME DISCRIMINATOR>-----
        // <base64 encoded bytes, 64 characters per line>
        // -----END <SOME DISCRIMINATOR>-----
        //
        // This function attempts to parse this string as a PEM document, and returns the discriminator type
        // and the base64 decoded bytes.
        var lines = pemString.split { $0.isNewline }[...]
        guard let first = lines.first, let last = lines.last else {
            throw ASN1Error.invalidPEMDocument(reason: "Leading or trailing line missing.")
        }

        guard let discriminator = first.pemStartDiscriminator, discriminator == last.pemEndDiscriminator else {
            throw ASN1Error.invalidPEMDocument(reason: "Leading or trailing line missing PEM discriminator")
        }

        // All but the last line must be 64 bytes. The force unwrap is safe because we require the lines to be
        // greater than zero.
        lines = lines.dropFirst().dropLast()
        guard lines.count > 0,
            lines.dropLast().allSatisfy({ $0.utf8.count == PEMDocument.lineLength }),
            lines.last!.utf8.count <= PEMDocument.lineLength else {
            throw ASN1Error.invalidPEMDocument(reason: "PEMDocument has incorrect line lengths")
        }

        guard discriminator == Self.pemDiscriminator else {
            throw ASN1Error.invalidPEMDocument(reason: "PEMDocument has incorrect discriminator \(discriminator). Expected \(Self.pemDiscriminator) instead")
        }
        
        guard let derBytes = Data(base64Encoded: lines.joined()) else {
            throw ASN1Error.invalidPEMDocument(reason: "PEMDocument not correctly base64 encoded")
        }
        
        try self.init(derEncoded: Array(derBytes))
    }
}


/// An object that can serialize PEM strings through ``PEMSerializer/serialize(_:)``.
public struct PEMSerializer: Sendable {
    
    public init() {}
    
    /// Serializes a node as a PEM string.
    /// - parameters:
    ///     node: The node to be serialized.
    public func serialize<Node: PEMSerializable>(_ node: Node) throws -> String {
        var serializer = DER.Serializer()
        try serializer.serialize(node)
        var encoded = Data(serializer.serializedBytes).base64EncodedString()[...]
        let pemLineCount = (encoded.utf8.count + PEMDocument.lineLength) / PEMDocument.lineLength
        var pemLines = [Substring]()
        pemLines.reserveCapacity(pemLineCount + 2)
        
        pemLines.append("-----BEGIN \(Node.pemDiscriminator)-----")
        
        while encoded.count > 0 {
            let prefixIndex = encoded.index(encoded.startIndex, offsetBy: PEMDocument.lineLength, limitedBy: encoded.endIndex) ?? encoded.endIndex
            pemLines.append(encoded[..<prefixIndex])
            encoded = encoded[prefixIndex...]
        }
        
        pemLines.append("-----END \(Node.pemDiscriminator)-----")
        
        return pemLines.joined(separator: "\n")
    }
}

extension PEMSerializable {
    /// Serializes `self` as a PEM string.
    public var pemString: String {
        get throws {
            var serializer = DER.Serializer()
            try serializer.serialize(self)
            var encoded = Data(serializer.serializedBytes).base64EncodedString()[...]
            let pemLineCount = (encoded.utf8.count + PEMDocument.lineLength) / PEMDocument.lineLength
            var pemLines = [Substring]()
            pemLines.reserveCapacity(pemLineCount + 2)
            
            pemLines.append("-----BEGIN \(Self.pemDiscriminator)-----")
            
            while encoded.count > 0 {
                let prefixIndex = encoded.index(encoded.startIndex, offsetBy: PEMDocument.lineLength, limitedBy: encoded.endIndex) ?? encoded.endIndex
                pemLines.append(encoded[..<prefixIndex])
                encoded = encoded[prefixIndex...]
            }
            
            pemLines.append("-----END \(Self.pemDiscriminator)-----")
            
            return pemLines.joined(separator: "\n")
        }
    }
}

/// A PEM document is some data, and a discriminator type that is used to advertise the content.
public struct PEMDocument {
    fileprivate static let lineLength = 64

    public var type: String

    public var derBytes: Data

    public init(pemString: String) throws {
        // A PEM document looks like this:
        //
        // -----BEGIN <SOME DISCRIMINATOR>-----
        // <base64 encoded bytes, 64 characters per line>
        // -----END <SOME DISCRIMINATOR>-----
        //
        // This function attempts to parse this string as a PEM document, and returns the discriminator type
        // and the base64 decoded bytes.
        var lines = pemString.split { $0.isNewline }[...]
        guard let first = lines.first, let last = lines.last else {
            throw ASN1Error.invalidPEMDocument(reason: "Leading or trailing line missing.")
        }

        guard let discriminator = first.pemStartDiscriminator, discriminator == last.pemEndDiscriminator else {
            throw ASN1Error.invalidPEMDocument(reason: "Leading or trailing line missing PEM discriminator")
        }

        // All but the last line must be 64 bytes. The force unwrap is safe because we require the lines to be
        // greater than zero.
        lines = lines.dropFirst().dropLast()
        guard lines.count > 0,
            lines.dropLast().allSatisfy({ $0.utf8.count == PEMDocument.lineLength }),
            lines.last!.utf8.count <= PEMDocument.lineLength else {
            throw ASN1Error.invalidPEMDocument(reason: "PEMDocument has incorrect line lengths")
        }

        guard let derBytes = Data(base64Encoded: lines.joined()) else {
            throw ASN1Error.invalidPEMDocument(reason: "PEMDocument not correctly base64 encoded")
        }

        self.type = discriminator
        self.derBytes = derBytes
    }

    public init(type: String, derBytes: Data) {
        self.type = type
        self.derBytes = derBytes
    }

    public var pemString: String {
        var encoded = self.derBytes.base64EncodedString()[...]
        let pemLineCount = (encoded.utf8.count + PEMDocument.lineLength) / PEMDocument.lineLength
        var pemLines = [Substring]()
        pemLines.reserveCapacity(pemLineCount + 2)

        pemLines.append("-----BEGIN \(self.type)-----")

        while encoded.count > 0 {
            let prefixIndex = encoded.index(encoded.startIndex, offsetBy: PEMDocument.lineLength, limitedBy: encoded.endIndex) ?? encoded.endIndex
            pemLines.append(encoded[..<prefixIndex])
            encoded = encoded[prefixIndex...]
        }

        pemLines.append("-----END \(self.type)-----")

        return pemLines.joined(separator: "\n")
    }
}

extension Substring {
    fileprivate var pemStartDiscriminator: String? {
        return self.pemDiscriminator(expectedPrefix: "-----BEGIN ", expectedSuffix: "-----")
    }

    fileprivate var pemEndDiscriminator: String? {
        return self.pemDiscriminator(expectedPrefix: "-----END ", expectedSuffix: "-----")
    }

    private func pemDiscriminator(expectedPrefix: String, expectedSuffix: String) -> String? {
        var utf8Bytes = self.utf8[...]

        // We want to split this sequence into three parts: the prefix, the middle, and the end
        let prefixSize = expectedPrefix.utf8.count
        let suffixSize = expectedSuffix.utf8.count

        let prefix = utf8Bytes.prefix(prefixSize)
        utf8Bytes = utf8Bytes.dropFirst(prefixSize)
        let suffix = utf8Bytes.suffix(suffixSize)
        utf8Bytes = utf8Bytes.dropLast(suffixSize)

        guard prefix.elementsEqual(expectedPrefix.utf8), suffix.elementsEqual(expectedSuffix.utf8) else {
            return nil
        }

        return String(utf8Bytes)
    }
}

#endif
