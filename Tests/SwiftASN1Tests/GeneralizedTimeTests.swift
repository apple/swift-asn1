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

final class GeneralizedTimeTests: XCTestCase {
    private func assertRoundTrips<ASN1Object: DERParseable & DERSerializable & Equatable>(_ value: ASN1Object) throws {
        var serializer = DER.Serializer()
        try serializer.serialize(value)
        let parsed = try ASN1Object(derEncoded: serializer.serializedBytes)
        XCTAssertEqual(parsed, value)
    }

    func testSimpleGeneralizedTimeTestVectors() throws {
        // This is a small set of generalized time test vectors derived from the ASN.1 docs.
        // We store the byte payload here as a string.
        let vectors: [(String, GeneralizedTime?)] = [
            // Valid representations
            (
                "19920521000000Z",
                try .init(year: 1992, month: 5, day: 21, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "19920521000000Z",
                try .init(
                    year: 1992,
                    month: 5,
                    day: 21,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),
            (
                "19920622123421Z",
                try .init(year: 1992, month: 6, day: 22, hours: 12, minutes: 34, seconds: 21, fractionalSeconds: 0)
            ),
            (
                "19920622123421Z",
                try .init(
                    year: 1992,
                    month: 6,
                    day: 22,
                    hours: 12,
                    minutes: 34,
                    seconds: 21,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),
            (
                "19920722132100.3Z",
                try .init(year: 1992, month: 7, day: 22, hours: 13, minutes: 21, seconds: 0, fractionalSeconds: 0.3)
            ),
            (
                "19920722132100.3Z",
                try .init(
                    year: 1992,
                    month: 7,
                    day: 22,
                    hours: 13,
                    minutes: 21,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>([51])
                )
            ),
            (
                "19851106210627.3Z",
                try .init(year: 1985, month: 11, day: 6, hours: 21, minutes: 6, seconds: 27, fractionalSeconds: 0.3)
            ),
            (
                "19851106210627.3Z",
                try .init(
                    year: 1985,
                    month: 11,
                    day: 6,
                    hours: 21,
                    minutes: 6,
                    seconds: 27,
                    rawFractionalSeconds: ArraySlice<UInt8>([51])
                )
            ),
            (
                "19851106210627.14159Z",
                try .init(year: 1985, month: 11, day: 6, hours: 21, minutes: 6, seconds: 27, fractionalSeconds: 0.14159)
            ),
            (
                "19851106210627.14159Z",
                try .init(
                    year: 1985,
                    month: 11,
                    day: 6,
                    hours: 21,
                    minutes: 6,
                    seconds: 27,
                    rawFractionalSeconds: ArraySlice<UInt8>([49, 52, 49, 53, 57])
                )
            ),
            (
                "20210131000000Z",
                try .init(year: 2021, month: 1, day: 31, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20210131000000Z",
                try .init(
                    year: 2021,
                    month: 1,
                    day: 31,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 31 days in January
            (
                "20210228000000Z",
                try .init(year: 2021, month: 2, day: 28, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20210228000000Z",
                try .init(
                    year: 2021,
                    month: 2,
                    day: 28,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 28 days in February 2021
            (
                "20200229000000Z",
                try .init(year: 2020, month: 2, day: 29, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20200229000000Z",
                try .init(
                    year: 2020,
                    month: 2,
                    day: 29,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 29 days in February 2020
            (
                "21000228000000Z",
                try .init(year: 2100, month: 2, day: 28, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "21000228000000Z",
                try .init(
                    year: 2100,
                    month: 2,
                    day: 28,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 28 days in February 2100
            (
                "20000229000000Z",
                try .init(year: 2000, month: 2, day: 29, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20000229000000Z",
                try .init(
                    year: 2000,
                    month: 2,
                    day: 29,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 29 days in February 2000
            (
                "20210331000000Z",
                try .init(year: 2021, month: 3, day: 31, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20210331000000Z",
                try .init(
                    year: 2021,
                    month: 3,
                    day: 31,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 31 days in March
            (
                "20210430000000Z",
                try .init(year: 2021, month: 4, day: 30, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20210430000000Z",
                try .init(
                    year: 2021,
                    month: 4,
                    day: 30,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 30 days in April
            (
                "20210531000000Z",
                try .init(year: 2021, month: 5, day: 31, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20210531000000Z",
                try .init(
                    year: 2021,
                    month: 5,
                    day: 31,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 31 days in May
            (
                "20210630000000Z",
                try .init(year: 2021, month: 6, day: 30, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20210630000000Z",
                try .init(
                    year: 2021,
                    month: 6,
                    day: 30,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 30 days in June
            (
                "20210731000000Z",
                try .init(year: 2021, month: 7, day: 31, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20210731000000Z",
                try .init(
                    year: 2021,
                    month: 7,
                    day: 31,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 31 days in July
            (
                "20210831000000Z",
                try .init(year: 2021, month: 8, day: 31, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20210831000000Z",
                try .init(
                    year: 2021,
                    month: 8,
                    day: 31,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 31 days in August
            (
                "20210930000000Z",
                try .init(year: 2021, month: 9, day: 30, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20210930000000Z",
                try .init(
                    year: 2021,
                    month: 9,
                    day: 30,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 30 days in September
            (
                "20211031000000Z",
                try .init(year: 2021, month: 10, day: 31, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20211031000000Z",
                try .init(
                    year: 2021,
                    month: 10,
                    day: 31,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 31 days in October
            (
                "20211130000000Z",
                try .init(year: 2021, month: 11, day: 30, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20211130000000Z",
                try .init(
                    year: 2021,
                    month: 11,
                    day: 30,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 30 days in November
            (
                "20211231000000Z",
                try .init(year: 2021, month: 12, day: 31, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 0)
            ),
            (
                "20211231000000Z",
                try .init(
                    year: 2021,
                    month: 12,
                    day: 31,
                    hours: 0,
                    minutes: 0,
                    seconds: 0,
                    rawFractionalSeconds: ArraySlice<UInt8>()
                )
            ),  // only 31 days in December
            (
                "19851106210627.10000000000000001Z",
                try .init(
                    year: 1985,
                    month: 11,
                    day: 6,
                    hours: 21,
                    minutes: 6,
                    seconds: 27,
                    rawFractionalSeconds: ArraySlice<UInt8>([
                        49, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 49,
                    ])
                )
            ),  // `fractionalSeconds` loses precision and becomes 0.1 (as opposed to 0.10000000000000001).
            // But `GeneralizedTime` round-trips when serialized and deserialized, as `rawFractionalSeconds` is preserved.

            // Invalid representations
            ("19920520240000Z", nil),  // midnight may not be 2400000
            ("19920622123421.0Z", nil),  // spurious trailing zeros
            ("19920722132100.30Z", nil),  // spurious trailing zeros
            ("19851106210627,3Z", nil),  // comma as decimal separator
            ("1985110621.14159Z", nil),  // missing minutes and seconds
            ("198511062106.14159Z", nil),  // missing seconds
            ("19851106210627.3", nil),  // missing trailing Z
            ("19851106210627.3-0500", nil),  // explicit time zone
            ("20211300000000Z", nil),  // there is no 13th month
            ("20210000000000Z", nil),  // there is no zeroth month
            ("20210100000000Z", nil),  // there is no zeroth day
            ("20210101000062Z", nil),  // 62nd second is not allowed
            ("20210101236000Z", nil),  // 60th minute is not allowed
            ("20210132000000Z", nil),  // only 31 days in January
            ("20210229000000Z", nil),  // only 28 days in February 2021
            ("20200230000000Z", nil),  // only 29 days in February 2020
            ("21000229000000Z", nil),  // only 28 days in February 2100
            ("20000230000000Z", nil),  // only 29 days in February 2000
            ("20210332000000Z", nil),  // only 31 days in March
            ("20210431000000Z", nil),  // only 30 days in April
            ("20210532000000Z", nil),  // only 31 days in May
            ("20210631000000Z", nil),  // only 30 days in June
            ("20210732000000Z", nil),  // only 31 days in July
            ("20210832000000Z", nil),  // only 31 days in August
            ("20210931000000Z", nil),  // only 30 days in September
            ("20211032000000Z", nil),  // only 31 days in October
            ("20211131000000Z", nil),  // only 30 days in November
            ("19920521000000.", nil),  // invalid fractional seconds and missing trailing Z
            ("19920521000000.Z", nil),  // invalid fractional seconds

        ]

        for (stringRepresentation, expectedResult) in vectors {
            var serialized = [UInt8]()
            serialized.writeIdentifier(ASN1Identifier.generalizedTime, constructed: false)
            serialized.append(UInt8(stringRepresentation.utf8.count))
            serialized.append(contentsOf: stringRepresentation.utf8)

            let result = try? GeneralizedTime(derEncoded: serialized)
            XCTAssertEqual(result, expectedResult)

            if let expected = expectedResult {
                try self.assertRoundTrips(expected)
            }
        }
    }

    func testCreatingOutOfBoundsValuesViaInitFails() throws {
        func mustFail(_ code: @autoclosure () throws -> GeneralizedTime) {
            XCTAssertThrowsError(try code())
        }

        // Invalid year, negative
        mustFail(try .init(year: -1, month: 1, day: 1, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: -1,
                month: 1,
                day: 1,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid month, zero.
        mustFail(try .init(year: 2000, month: 0, day: 1, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 0,
                day: 1,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid month, negative.
        mustFail(try .init(year: 2000, month: -1, day: 1, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: -1,
                day: 1,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid month, too large.
        mustFail(try .init(year: 2000, month: 13, day: 1, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 13,
                day: 1,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid day, zero.
        mustFail(try .init(year: 2000, month: 1, day: 0, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 1,
                day: 0,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid day, negative.
        mustFail(try .init(year: 2000, month: 1, day: -1, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 1,
                day: -1,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 31 days in January
        mustFail(try .init(year: 2000, month: 1, day: 32, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 1,
                day: 32,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 28 days in February 2021
        mustFail(try .init(year: 2021, month: 2, day: 29, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2021,
                month: 2,
                day: 29,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 29 days in February 2020
        mustFail(try .init(year: 2020, month: 2, day: 30, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2020,
                month: 2,
                day: 30,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 28 days in February 2100
        mustFail(try .init(year: 2100, month: 2, day: 29, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2100,
                month: 2,
                day: 29,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 29 days in February 2000
        mustFail(try .init(year: 2000, month: 2, day: 30, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 2,
                day: 30,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 31 days in March
        mustFail(try .init(year: 2000, month: 3, day: 32, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 3,
                day: 32,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 30 days in April
        mustFail(try .init(year: 2000, month: 4, day: 31, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 4,
                day: 31,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 31 days in May
        mustFail(try .init(year: 2000, month: 5, day: 32, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 5,
                day: 32,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 30 days in June
        mustFail(try .init(year: 2000, month: 6, day: 31, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 6,
                day: 31,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 31 days in July
        mustFail(try .init(year: 2000, month: 7, day: 32, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 7,
                day: 32,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 31 days in August
        mustFail(try .init(year: 2000, month: 8, day: 32, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 8,
                day: 32,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 30 days in September
        mustFail(try .init(year: 2000, month: 9, day: 31, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 9,
                day: 31,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 31 days in October
        mustFail(try .init(year: 2000, month: 10, day: 32, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 10,
                day: 32,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 30 days in November
        mustFail(try .init(year: 2000, month: 11, day: 31, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 11,
                day: 31,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // only 31 days in December
        mustFail(try .init(year: 2000, month: 11, day: 32, hours: 1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 11,
                day: 32,
                hours: 1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid hour, negative
        mustFail(try .init(year: 2000, month: 1, day: 1, hours: -1, minutes: 1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 1,
                day: 1,
                hours: -1,
                minutes: 1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid hour, 24
        mustFail(try .init(year: 2000, month: 1, day: 1, hours: 24, minutes: 0, seconds: 0, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 1,
                day: 1,
                hours: 24,
                minutes: 0,
                seconds: 0,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid minute, negative
        mustFail(try .init(year: 2000, month: 1, day: 1, hours: 0, minutes: -1, seconds: 1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 1,
                day: 1,
                hours: 0,
                minutes: -1,
                seconds: 1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid minute, 60
        mustFail(try .init(year: 2000, month: 1, day: 1, hours: 0, minutes: 60, seconds: 0, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 1,
                day: 1,
                hours: 0,
                minutes: 60,
                seconds: 0,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid second, negative
        mustFail(try .init(year: 2000, month: 1, day: 1, hours: 0, minutes: 0, seconds: -1, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 1,
                day: 1,
                hours: 0,
                minutes: 0,
                seconds: -1,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid second, 62 (we allow some leap seconds)
        mustFail(try .init(year: 2000, month: 1, day: 1, hours: 0, minutes: 0, seconds: 62, fractionalSeconds: 0))
        mustFail(
            try .init(
                year: 2000,
                month: 1,
                day: 1,
                hours: 0,
                minutes: 0,
                seconds: 62,
                rawFractionalSeconds: ArraySlice<UInt8>()
            )
        )
        // Invalid fractional seconds, negative
        mustFail(try .init(year: 2000, month: 1, day: 1, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: -0.5))
        // Invalid fractional seconds, greater than one
        mustFail(try .init(year: 2000, month: 1, day: 1, hours: 0, minutes: 0, seconds: 0, fractionalSeconds: 1.1))
    }

    func testTruncatedRepresentationsRejected() throws {
        func mustNotDeserialize(_ stringRepresentation: Substring) {
            var serialized = [UInt8]()
            serialized.writeIdentifier(ASN1Identifier.generalizedTime, constructed: false)
            serialized.append(UInt8(stringRepresentation.utf8.count))
            serialized.append(contentsOf: stringRepresentation.utf8)

            XCTAssertThrowsError(try GeneralizedTime(derEncoded: serialized))
        }

        func deserializes(_ stringRepresentation: Substring) {
            var serialized = [UInt8]()
            serialized.writeIdentifier(ASN1Identifier.generalizedTime, constructed: false)
            serialized.append(UInt8(stringRepresentation.utf8.count))
            serialized.append(contentsOf: stringRepresentation.utf8)

            XCTAssertNoThrow(try GeneralizedTime(derEncoded: serialized))
        }

        // Anything that doesn't end up in a Z must fail to deserialize.
        let string = Substring("19851106210627.14159Z")
        for distance in 0..<string.count {
            let sliced = string.prefix(distance)
            mustNotDeserialize(sliced)
        }

        deserializes(string)

        // Adding some excess data should fail too.
        for junkByteCount in 1...string.count {
            let junked = string + string.prefix(junkByteCount)
            mustNotDeserialize(junked)
        }
    }

    func testRequiresAppropriateTag() throws {
        let rawValue = "19920521000000Z".utf8
        var invalidBytes = [UInt8]()
        invalidBytes.writeIdentifier(ASN1Identifier.integer, constructed: false)  // generalizedTime isn't an integer
        invalidBytes.append(UInt8(rawValue.count))
        invalidBytes.append(contentsOf: rawValue)

        XCTAssertThrowsError(try GeneralizedTime(derEncoded: invalidBytes))
    }

    func testComparisons() throws {
        enum ExpectedComparisonResult {
            case lessThan
            case equal
            case greaterThan
        }

        let original = try GeneralizedTime(
            year: 2020,
            month: 03,
            day: 03,
            hours: 03,
            minutes: 03,
            seconds: 03,
            fractionalSeconds: 0.105
        )

        func modify<Modifiable: AdditiveArithmetic>(
            _ field: WritableKeyPath<GeneralizedTime, Modifiable>,
            of time: GeneralizedTime,
            by modifier: Modifiable
        ) -> GeneralizedTime {
            var copy = time
            copy[keyPath: field] += modifier
            return copy
        }

        let integerTransformable: [WritableKeyPath<GeneralizedTime, Int>] = [
            \.year, \.month, \.day, \.hours, \.minutes, \.seconds,
        ]

        var transformationsAndResults: [(GeneralizedTime, ExpectedComparisonResult)] = []
        transformationsAndResults.append((original, .equal))

        for transform in integerTransformable {
            transformationsAndResults.append((modify(transform, of: original, by: 1), .greaterThan))
            transformationsAndResults.append((modify(transform, of: original, by: -1), .lessThan))
        }

        transformationsAndResults.append((modify(\.fractionalSeconds, of: original, by: 0.1), .greaterThan))
        transformationsAndResults.append((modify(\.fractionalSeconds, of: original, by: -0.1), .lessThan))

        transformationsAndResults.append(
            (
                try GeneralizedTime(
                    year: 2019,
                    month: 08,
                    day: 08,
                    hours: 08,
                    minutes: 08,
                    seconds: 08,
                    fractionalSeconds: 0.205
                ),
                .lessThan
            )
        )

        for (newValue, expectedResult) in transformationsAndResults {
            switch expectedResult {
            case .lessThan:
                XCTAssertLessThan(newValue, original)
                XCTAssertLessThanOrEqual(newValue, original)
                XCTAssertGreaterThan(original, newValue)
                XCTAssertGreaterThanOrEqual(original, newValue)
            case .equal:
                XCTAssertGreaterThanOrEqual(newValue, original)
                XCTAssertGreaterThanOrEqual(original, newValue)
                XCTAssertLessThanOrEqual(newValue, original)
                XCTAssertLessThanOrEqual(original, newValue)
            case .greaterThan:
                XCTAssertGreaterThan(newValue, original)
                XCTAssertGreaterThanOrEqual(newValue, original)
                XCTAssertLessThan(original, newValue)
                XCTAssertLessThanOrEqual(original, newValue)
            }
        }
    }
}
