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
import XCTest

@testable import SwiftASN1

final class UTCTimeTests: XCTestCase {
    func testComparisons() throws {
        let original = try UTCTime(year: 2020, month: 03, day: 03, hours: 03, minutes: 03, seconds: 03)

        func modify(_ field: WritableKeyPath<UTCTime, Int>, of time: UTCTime, by modifier: Int) -> UTCTime {
            var copy = time
            copy[keyPath: field] += modifier
            return copy
        }

        let integerTransformable: [WritableKeyPath<UTCTime, Int>] = [
            \.year, \.month, \.day, \.hours, \.minutes, \.seconds
        ]

        var transformationsAndResults: [(UTCTime, lt: Bool, eq: Bool)] = []
        transformationsAndResults.append((original, lt: false, eq: true))

        for transform in integerTransformable {
            transformationsAndResults.append((modify(transform, of: original, by: 1), lt: false, eq: false))
            transformationsAndResults.append((modify(transform, of: original, by: -1), lt: true, eq: false))
        }

        for (newValue, lt, eq) in transformationsAndResults {
            if lt {
                XCTAssertLessThan(newValue, original)
                XCTAssertLessThanOrEqual(newValue, original)
                XCTAssertGreaterThan(original, newValue)
                XCTAssertGreaterThanOrEqual(original, newValue)
            } else if eq {
                XCTAssertGreaterThanOrEqual(newValue, original)
                XCTAssertGreaterThanOrEqual(original, newValue)
                XCTAssertLessThanOrEqual(newValue, original)
                XCTAssertLessThanOrEqual(original, newValue)
            } else {
                XCTAssertGreaterThan(newValue, original)
                XCTAssertGreaterThanOrEqual(newValue, original)
                XCTAssertLessThan(original, newValue)
                XCTAssertLessThanOrEqual(original, newValue)
            }
        }
    }
}
