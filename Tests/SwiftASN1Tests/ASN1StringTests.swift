//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftASN1 open source project
//
// Copyright (c) 2021 Apple Inc. and the SwiftASN1 project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftASN1 project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import XCTest

@testable import SwiftASN1

final class ASN1StringTests: XCTestCase {
    private func assertRoundTrips<ASN1Object: DERParseable & DERSerializable & Equatable>(_ value: ASN1Object) throws {
        var serializer = DER.Serializer()
        try serializer.serialize(value)
        let parsed = try ASN1Object(derEncoded: serializer.serializedBytes)
        XCTAssertEqual(parsed, value)
    }

    func testUTF8StringEncoding() throws {
        var serializer = DER.Serializer()
        let originalString = ASN1UTF8String(contentBytes: [1, 2, 3, 4])
        try serializer.serialize(originalString)
        XCTAssertEqual(serializer.serializedBytes, [12, 4, 1, 2, 3, 4])
    }

    func testUTF8StringRoundTrips() throws {
        try self.assertRoundTrips(ASN1UTF8String(contentBytes: [1, 2, 3, 4]))
    }

    func testUTF8StringContiguousBytes() throws {
        let string = ASN1UTF8String(contentBytes: [1, 2, 3, 4])
        string.withUnsafeBytes { XCTAssertTrue($0.elementsEqual([1, 2, 3, 4])) }
    }

    func testTeletexStringEncoding() throws {
        var serializer = DER.Serializer()
        let originalString = ASN1TeletexString(contentBytes: [1, 2, 3, 4])
        try serializer.serialize(originalString)
        XCTAssertEqual(serializer.serializedBytes, [20, 4, 1, 2, 3, 4])
    }

    func testTeletexStringRoundTrips() throws {
        try self.assertRoundTrips(ASN1TeletexString(contentBytes: [1, 2, 3, 4]))
    }

    func testTeletexStringContiguousBytes() throws {
        let string = ASN1TeletexString(contentBytes: [1, 2, 3, 4])
        string.withUnsafeBytes { XCTAssertTrue($0.elementsEqual([1, 2, 3, 4])) }
    }

    func testPrintableStringEncoding() throws {
        var serializer = DER.Serializer()
        let originalString = try ASN1PrintableString(contentBytes: [0x54, 0x65, 0x73, 0x74])
        try serializer.serialize(originalString)
        XCTAssertEqual(serializer.serializedBytes, [19, 4, 0x54, 0x65, 0x73, 0x74])
    }

    func testPrintableStringRoundTrips() throws {
        try self.assertRoundTrips(ASN1PrintableString(contentBytes: [0x54, 0x65, 0x73, 0x74]))
    }

    func testPrintableStringContiguousBytes() throws {
        let string = try ASN1PrintableString(contentBytes: [0x54, 0x65, 0x73, 0x74])
        string.withUnsafeBytes { XCTAssertTrue($0.elementsEqual([0x54, 0x65, 0x73, 0x74])) }
    }

    func testUniversalStringEncoding() throws {
        var serializer = DER.Serializer()
        let originalString = ASN1UniversalString(contentBytes: [1, 2, 3, 4])
        try serializer.serialize(originalString)
        XCTAssertEqual(serializer.serializedBytes, [28, 4, 1, 2, 3, 4])
    }

    func testUniversalStringRoundTrips() throws {
        try self.assertRoundTrips(ASN1UniversalString(contentBytes: [1, 2, 3, 4]))
    }

    func testUniversalStringContiguousBytes() throws {
        let string = ASN1UniversalString(contentBytes: [1, 2, 3, 4])
        string.withUnsafeBytes { XCTAssertTrue($0.elementsEqual([1, 2, 3, 4])) }
    }

    func testBMPStringEncoding() throws {
        var serializer = DER.Serializer()
        let originalString = ASN1BMPString(contentBytes: [1, 2, 3, 4])
        try serializer.serialize(originalString)
        XCTAssertEqual(serializer.serializedBytes, [30, 4, 1, 2, 3, 4])
    }

    func testBMPStringRoundTrips() throws {
        try self.assertRoundTrips(ASN1BMPString(contentBytes: [1, 2, 3, 4]))
    }

    func testBMPStringContiguousBytes() throws {
        let string = ASN1BMPString(contentBytes: [1, 2, 3, 4])
        string.withUnsafeBytes { XCTAssertTrue($0.elementsEqual([1, 2, 3, 4])) }
    }

    func testBMPStringStringLiteral() throws {
        typealias TestCase = (literal: String, utf16: [UInt8], asn1: [UInt8])

        let testCases: [TestCase] = [
            TestCase(
                "Test",
                [0, 84, 0, 101, 0, 115, 0, 116],
                [30, 8, 0, 84, 0, 101, 0, 115, 0, 116]
            ),
            TestCase(
                "Tests",
                [0, 84, 0, 101, 0, 115, 0, 116, 0, 115],
                [30, 10, 0, 84, 0, 101, 0, 115, 0, 116, 0, 115]
            ),
            TestCase(
                "中文",
                [78, 45, 101, 135],
                [30, 4, 78, 45, 101, 135]
            ),
        ]

        try testCases.forEach { testCase in
            let string = ASN1BMPString(stringLiteral: testCase.literal)
            XCTAssertEqual(Array(string.bytes), testCase.utf16)

            var serializer = DER.Serializer()
            try serializer.serialize(string)
            XCTAssertEqual(serializer.serializedBytes, testCase.asn1)
        }
    }

    func testUTF8StringCanCreateAString() throws {
        let string = "hello, world!"
        let utf8String = ASN1UTF8String(string)
        let newString = String(utf8String)
        XCTAssertEqual(newString, string)
    }

    func testPrintableStringCanCreateAString() throws {
        let string = "hello, world"
        let utf8String = try ASN1PrintableString(string)
        let newString = String(utf8String)
        XCTAssertEqual(newString, string)
    }

    func testIA5StringCanCreateAString() throws {
        let string = "hello, world"
        let ia5String = try ASN1IA5String(string)
        let newString = String(ia5String)
        XCTAssertEqual(newString, string)
    }

    func testPrintableStringRejectsCharacters() throws {
        let allBytes = (UInt8(0)...UInt8.max)

        let invalidBytes = (UInt8(0)...UInt8(255)).filter {
            switch $0 {
            case UInt8(ascii: "a")...UInt8(ascii: "z"),
                UInt8(ascii: "A")...UInt8(ascii: "Z"),
                UInt8(ascii: "0")...UInt8(ascii: "9"),
                UInt8(ascii: "'"), UInt8(ascii: "("),
                UInt8(ascii: ")"), UInt8(ascii: "+"),
                UInt8(ascii: "-"), UInt8(ascii: "?"),
                UInt8(ascii: ":"), UInt8(ascii: "/"),
                UInt8(ascii: "="), UInt8(ascii: " "),
                UInt8(ascii: ","), UInt8(ascii: "."):
                return false
            default:
                return true
            }
        }

        let validBytes = allBytes.filter { !invalidBytes.contains($0) }

        for byte in invalidBytes {
            XCTAssertThrowsError(try ASN1PrintableString(contentBytes: [byte]))
            XCTAssertThrowsError(try ASN1PrintableString(String(UnicodeScalar(byte))))
            XCTAssertThrowsError(try ASN1PrintableString(derEncoded: [0x13, 1, byte]))
        }

        for byte in validBytes {
            XCTAssertNoThrow(try ASN1PrintableString(contentBytes: [byte]))
            XCTAssertNoThrow(try ASN1PrintableString(String(UnicodeScalar(byte))))
            XCTAssertNoThrow(try ASN1PrintableString(derEncoded: [0x13, 1, byte]))
        }
    }

    func testIA5StringRejectsCharacters() throws {
        let invalidBytes = (UInt8(128)...(UInt8.max))
        let validBytes = (UInt8(0)..<UInt8(128))

        for byte in invalidBytes {
            XCTAssertThrowsError(try ASN1IA5String(contentBytes: [byte]))
            XCTAssertThrowsError(try ASN1IA5String(String(UnicodeScalar(byte))))
            XCTAssertThrowsError(try ASN1IA5String(derEncoded: [0x16, 1, byte]))
        }

        for byte in validBytes {
            XCTAssertNoThrow(try ASN1IA5String(contentBytes: [byte]))
            XCTAssertNoThrow(try ASN1IA5String(String(UnicodeScalar(byte))))
            XCTAssertNoThrow(try ASN1IA5String(derEncoded: [0x16, 1, byte]))
        }
    }
}
