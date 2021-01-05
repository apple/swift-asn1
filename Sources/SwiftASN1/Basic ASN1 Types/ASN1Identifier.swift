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
    /// An ``ASN1/ASN1Identifier`` is a representation of the abstract notion of an ASN.1 identifier.
    public struct ASN1Identifier {
        /// The base tag.
        public var tagNumber: UInt

        /// The class of the tag.
        public var tagClass: TagClass

        /// Whether this tag represents a primitive object.
        public var primitive: Bool

        /// Whether this tag represents a constructed object.
        @inlinable
        public var constructed: Bool {
            get {
                return !self.primitive
            }
            set {
                self.primitive = !newValue
            }
        }

        @inlinable
        var _shortForm: UInt8? {
            // An ASN.1 identifier can be encoded in short form iff the tag number is strictly
            // less than 0x1f.
            guard self.tagNumber < 0x1f else { return nil }

            var baseNumber = UInt8(truncatingIfNeeded: self.tagNumber)
            if self.constructed {
                baseNumber |= 0x20
            }
            baseNumber |= self.tagClass._topByteFlags
            return baseNumber
        }

        /// The class of an ASN.1 tag.
        public enum TagClass: Hashable, Sendable {
            case universal
            case application
            case contextSpecific
            case `private`

            @inlinable
            init(topByteInWireFormat topByte: UInt8) {
                switch topByte >> 6 {
                case 0x00:
                    self = .universal
                case 0x01:
                    self = .application
                case 0x02:
                    self = .contextSpecific
                case 0x03:
                    self = .private
                default:
                    fatalError("Unreachable")
                }
            }

            @inlinable
            var _topByteFlags: UInt8 {
                switch self {
                case .universal:
                    return 0x00
                case .application:
                    return 0x01 << 6
                case .contextSpecific:
                    return 0x02 << 6
                case .private:
                    return 0x03 << 6
                }
            }
        }

        @inlinable
        init(shortIdentifier: UInt8) {
            precondition(shortIdentifier & 0x1F != 0x1F)
            self.tagClass = TagClass(topByteInWireFormat: shortIdentifier)
            self.primitive = (shortIdentifier & 0x20 == 0)
            self.tagNumber = UInt(shortIdentifier & 0x1f)
        }

        /// Produces a tag suitable for use as an explicit tag from components.
        ///
        /// This is equivalent to ``init(tagWithNumber:tagClass:constructed:)``, but sets
        /// `constructed` to `true` in all cases.
        ///
        /// - parameters:
        ///     - number: The tag number.
        ///     - tagClass: The class of the ASN.1 tag.
        @inlinable
        public init(explicitTagWithNumber number: UInt, tagClass: TagClass) {
            self.tagClass = tagClass
            self.tagNumber = number

            // Explicit tags are always constructed
            self.primitive = false
        }

        /// Produces a tag from components.
        ///
        /// This is equivalent to ``init(tagWithNumber:tagClass:constructed:)``, but sets
        /// `constructed` to `true` in all cases.
        ///
        /// - parameters:
        ///     - number: The tag number.
        ///     - tagClass: The class of the ASN.1 tag.
        ///     - constructed: Whether this is a constructed tag.
        @inlinable
        public init(tagWithNumber number: UInt, tagClass: TagClass, constructed: Bool) {
            self.tagNumber = number
            self.tagClass = tagClass
            self.primitive = !constructed
        }
    }
}

extension ASN1.ASN1Identifier {
    /// This tag represents an OBJECT IDENTIFIER.
    public static let objectIdentifier = ASN1.ASN1Identifier(shortIdentifier: 0x06)

    /// This tag represents a BITSTRING.
    public static let primitiveBitString = ASN1.ASN1Identifier(shortIdentifier: 0x03)

    /// This tag represents an OCTET STRING.
    public static let primitiveOctetString = ASN1.ASN1Identifier(shortIdentifier: 0x04)

    /// This tag represents an INTEGER.
    public static let integer = ASN1.ASN1Identifier(shortIdentifier: 0x02)

    /// This tag represents a SEQUENCE or SEQUENCE OF.
    public static let sequence = ASN1.ASN1Identifier(shortIdentifier: 0x30)

    /// This tag represents a SET or SET OF.
    public static let set = ASN1.ASN1Identifier(shortIdentifier: 0x31)

    /// This tag represents an ASN.1 NULL.
    public static let null = ASN1.ASN1Identifier(shortIdentifier: 0x05)

    /// This tag represents a BOOLEAN.
    public static let boolean = ASN1.ASN1Identifier(shortIdentifier: 0x01)

    /// This tag represents an ENUMERATED.
    public static let enumerated = ASN1.ASN1Identifier(shortIdentifier: 0x0a)

    /// This tag represents a UTF8STRING.
    public static let primitiveUTF8String = ASN1.ASN1Identifier(shortIdentifier: 0x0c)

    /// This tag represents a NUMERICSTRING.
    public static let primitiveNumericString = ASN1.ASN1Identifier(shortIdentifier: 0x12)

    /// This tag represents a PRINTABLESTRING.
    public static let primitivePrintableString = ASN1.ASN1Identifier(shortIdentifier: 0x13)

    /// This tag represents a TELETEXSTRING.
    public static let primitiveTeletexString = ASN1.ASN1Identifier(shortIdentifier: 0x14)

    /// This tag represents a VIDEOTEXSTRING.
    public static let primitiveVideotexString = ASN1.ASN1Identifier(shortIdentifier: 0x15)

    /// This tag represents an IA5STRING.
    public static let primitiveIA5String = ASN1.ASN1Identifier(shortIdentifier: 0x16)

    /// This tag represents a GRAPHICSTRING.
    public static let primitiveGraphicString = ASN1.ASN1Identifier(shortIdentifier: 0x19)

    /// This tag represents a VISIBLESTRING.
    public static let primitiveVisibleString = ASN1.ASN1Identifier(shortIdentifier: 0x1a)

    /// This tag represents a GENERALSTRING.
    public static let primitiveGeneralString = ASN1.ASN1Identifier(shortIdentifier: 0x1b)

    /// This tag represents a UNIVERSALSTRING.
    public static let primitiveUniversalString = ASN1.ASN1Identifier(shortIdentifier: 0x1c)

    /// This tag represents a BMPSTRING.
    public static let primitiveBMPString = ASN1.ASN1Identifier(shortIdentifier: 0x1e)

    /// This tag represents a GENERALIZEDTIME.
    public static let generalizedTime = ASN1.ASN1Identifier(shortIdentifier: 0x18)

    /// This tag represents a UTCTIME.
    public static let utcTime = ASN1.ASN1Identifier(shortIdentifier: 0x17)
}

extension ASN1.ASN1Identifier: Hashable { }

extension ASN1.ASN1Identifier: Sendable { }

extension ASN1.ASN1Identifier: CustomStringConvertible {
    @inlinable
    public var description: String {
        return "ASN1Identifier(tagNumber: \(self.tagNumber), tagClass: \(self.tagClass), primitive: \(self.primitive))"
    }
}

extension Array where Element == UInt8 {
    @inlinable
    mutating func writeIdentifier(_ identifier: ASN1.ASN1Identifier) {
        if let shortForm = identifier._shortForm {
            self.append(shortForm)
        } else {
            // Long-form encoded. The top byte is 0x1f plus the various flags.
            var topByte = UInt8(0x1f)
            if identifier.constructed {
                topByte |= 0x20
            }
            topByte |= identifier.tagClass._topByteFlags
            self.append(topByte)

            // Then we encode this in base128, just like an OID subidentifier.
            // TODO: Adjust the ASN1Identifier to use UInt for its storage.
            self.writeUsing7BitBytesASN1Discipline(unsignedInteger: UInt(identifier.tagNumber))
        }
    }
}
