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
        enum ExpectedComparisonResult {
            case lessThan
            case equal
            case greaterThan
        }

        let original = try UTCTime(year: 2020, month: 03, day: 03, hours: 03, minutes: 03, seconds: 03)

        func modify(_ field: WritableKeyPath<UTCTime, Int>, of time: UTCTime, by modifier: Int) -> UTCTime {
            var copy = time
            copy[keyPath: field] += modifier
            return copy
        }

        let integerTransformable: [WritableKeyPath<UTCTime, Int>] = [
            \.year, \.month, \.day, \.hours, \.minutes, \.seconds,
        ]

        var transformationsAndResults: [(UTCTime, ExpectedComparisonResult)] = []
        transformationsAndResults.append((original, .equal))

        for transform in integerTransformable {
            transformationsAndResults.append((modify(transform, of: original, by: 1), .greaterThan))
            transformationsAndResults.append((modify(transform, of: original, by: -1), .lessThan))
        }

        transformationsAndResults.append(
            (
                try UTCTime(year: 2019, month: 08, day: 08, hours: 08, minutes: 08, seconds: 08),
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
