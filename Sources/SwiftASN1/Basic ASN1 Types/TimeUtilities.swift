//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftASN1 open source project
//
// Copyright (c) 2022 Apple Inc. and the SwiftASN1 project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftASN1 project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@available(*, unavailable)
extension TimeUtilities: Sendable {}

@usableFromInline
enum TimeUtilities {
    @inlinable
    static func generalizedTimeFromBytes(_ bytes: ArraySlice<UInt8>) throws -> GeneralizedTime {
        var bytes = bytes

        // First, there must always be a calendar date. No separators, 4
        // digits for the year, 2 digits for the month, 2 digits for the day.
        guard let rawYear = bytes._readFourDigitDecimalInteger(),
            let rawMonth = bytes._readTwoDigitDecimalInteger(),
            let rawDay = bytes._readTwoDigitDecimalInteger()
        else {
            throw ASN1Error.invalidASN1Object(reason: "Unable to load year, month, and day for GeneralizedTime")
        }

        // Next there must be a _time_. Per DER rules, this time must always go
        // to at least seconds, there are no separators, there is no time-zone (but there must be a 'Z'),
        // and there may be fractional seconds but they must not have trailing zeros.
        guard let rawHour = bytes._readTwoDigitDecimalInteger(),
            let rawMinutes = bytes._readTwoDigitDecimalInteger(),
            let rawSeconds = bytes._readTwoDigitDecimalInteger()
        else {
            throw ASN1Error.invalidASN1Object(reason: "Unable to load hour, minutes, and seconds for GeneralizedTime")
        }

        // There may be some fractional seconds.
        var rawFractionalSeconds = ArraySlice<UInt8>()
        if bytes.first == UInt8(ascii: ".") {
            bytes.removeFirst()
            rawFractionalSeconds = try bytes._readRawFractionalSeconds()
        }

        // The next character _must_ be Z, or the encoding is invalid.
        guard bytes.popFirst() == UInt8(ascii: "Z") else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid time zone in GeneralizedTime")
        }

        // Great! There better not be anything left.
        guard bytes.count == 0 else {
            throw ASN1Error.invalidASN1Object(reason: "Trailing bytes in GeneralizedTime")
        }

        return try GeneralizedTime(
            year: rawYear,
            month: rawMonth,
            day: rawDay,
            hours: rawHour,
            minutes: rawMinutes,
            seconds: rawSeconds,
            rawFractionalSeconds: rawFractionalSeconds
        )
    }

    @inlinable
    static func utcTimeFromBytes(_ bytes: ArraySlice<UInt8>) throws -> UTCTime {
        var bytes = bytes

        // First, there must always be a calendar date. No separators, 2
        // digits for the year, 2 digits for the month, 2 digits for the day.
        guard let rawYear = bytes._readTwoDigitDecimalInteger(),
            let rawMonth = bytes._readTwoDigitDecimalInteger(),
            let rawDay = bytes._readTwoDigitDecimalInteger()
        else {
            throw ASN1Error.invalidASN1Object(reason: "Unable to load year, month, and day for UTCTime")
        }

        // Next there must be a _time_. Per DER rules, this time must always go
        // to at least seconds, there are no separators, there is no time-zone (but there must be a 'Z').
        guard let rawHour = bytes._readTwoDigitDecimalInteger(),
            let rawMinutes = bytes._readTwoDigitDecimalInteger(),
            let rawSeconds = bytes._readTwoDigitDecimalInteger()
        else {
            throw ASN1Error.invalidASN1Object(reason: "Unable to load hour, minutes, and seconds for UTCTime")
        }

        // The next character _must_ be Z, or the encoding is invalid.
        guard bytes.popFirst() == UInt8(ascii: "Z") else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid time zone in UTCTime")
        }

        // Great! There better not be anything left.
        guard bytes.count == 0 else {
            throw ASN1Error.invalidASN1Object(reason: "Trailing bytes in UTCTime")
        }

        let actualYear = rawYear < 50 ? rawYear &+ 2000 : rawYear &+ 1900

        return try UTCTime(
            year: actualYear,
            month: rawMonth,
            day: rawDay,
            hours: rawHour,
            minutes: rawMinutes,
            seconds: rawSeconds
        )
    }

    @inlinable
    static func daysInMonth(_ month: Int, ofYear year: Int) -> Int? {
        switch month {
        case 1:
            return 31
        case 2:
            // This one has a dependency on the year!
            // A leap year occurs in any year divisible by 4, except when that year is divisible by 100,
            // unless the year is divisible by 400.
            let isLeapYear = (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0))
            return isLeapYear ? 29 : 28
        case 3:
            return 31
        case 4:
            return 30
        case 5:
            return 31
        case 6:
            return 30
        case 7:
            return 31
        case 8:
            return 31
        case 9:
            return 30
        case 10:
            return 31
        case 11:
            return 30
        case 12:
            return 31
        default:
            return nil
        }
    }
}

extension ArraySlice where Element == UInt8 {
    @inlinable
    mutating func _readFourDigitDecimalInteger() -> Int? {
        guard let first = self._readTwoDigitDecimalInteger(),
            let second = self._readTwoDigitDecimalInteger()
        else {
            return nil
        }

        // Unchecked math is still safe here: we're in Int32 space, and this number cannot
        // get any larger than 9999.
        return (first &* 100) &+ second
    }

    @inlinable
    mutating func _readTwoDigitDecimalInteger() -> Int? {
        guard let firstASCII = self.popFirst(),
            let secondASCII = self.popFirst()
        else {
            return nil
        }

        guard let first = Int(fromDecimalASCII: firstASCII),
            let second = Int(fromDecimalASCII: secondASCII)
        else {
            return nil
        }

        // Unchecked math is safe here: we're in Int32 space at the very least, and this number cannot
        // possibly be smaller than zero or larger than 99.
        return (first &* 10) &+ (second)
    }

    @inlinable
    mutating func _readRawFractionalSeconds() throws -> ArraySlice<UInt8> {
        guard let nonDecimalASCIIIndex = self.firstIndex(where: { Int(fromDecimalASCII: $0) == nil }) else {
            throw ASN1Error.invalidASN1Object(
                reason: "Invalid fractional seconds"
            )
        }

        // If `nonDecimalASCIIIndex == self.startIndex`, then it means that there is a decimal point
        // but there are no fractional seconds
        if nonDecimalASCIIIndex == self.startIndex {
            throw ASN1Error.invalidASN1Object(
                reason: "Invalid fractional seconds"
            )
        }

        let rawFractionalSeconds = self[..<nonDecimalASCIIIndex]
        self = self[nonDecimalASCIIIndex...]
        return rawFractionalSeconds
    }

    @inlinable
    mutating func append(fractionalSeconds: Double) throws {
        // Fractional seconds may not be negative and may not be 1 or more.
        guard fractionalSeconds >= 0 && fractionalSeconds < 1 else {
            throw ASN1Error.invalidASN1Object(
                reason: "Invalid fractional seconds: \(fractionalSeconds)"
            )
        }

        if fractionalSeconds != 0 {
            let fractionalSecondsAsString = String(fractionalSeconds)

            assert(fractionalSecondsAsString.starts(with: "0."), "Invalid fractional seconds")
            assert(fractionalSecondsAsString.last != "0", "Trailing zeros in fractional seconds")

            self.append(contentsOf: fractionalSecondsAsString.utf8.dropFirst(2))
        }
    }
}

extension Array where Element == UInt8 {
    @inlinable
    mutating func append(_ generalizedTime: GeneralizedTime) {
        self._appendFourDigitDecimal(generalizedTime.year)
        self._appendTwoDigitDecimal(generalizedTime.month)
        self._appendTwoDigitDecimal(generalizedTime.day)
        self._appendTwoDigitDecimal(generalizedTime.hours)
        self._appendTwoDigitDecimal(generalizedTime.minutes)
        self._appendTwoDigitDecimal(generalizedTime.seconds)

        if generalizedTime.rawFractionalSeconds.count > 0 {
            self.append(UInt8(ascii: "."))
            self.append(contentsOf: generalizedTime.rawFractionalSeconds)
        }

        self.append(UInt8(ascii: "Z"))
    }

    @inlinable
    mutating func append(_ utcTime: UTCTime) {
        precondition((1950..<2050).contains(utcTime.year))
        if utcTime.year >= 2000 {
            self._appendTwoDigitDecimal(utcTime.year &- 2000)
        } else {
            self._appendTwoDigitDecimal(utcTime.year &- 1900)
        }
        self._appendTwoDigitDecimal(utcTime.month)
        self._appendTwoDigitDecimal(utcTime.day)
        self._appendTwoDigitDecimal(utcTime.hours)
        self._appendTwoDigitDecimal(utcTime.minutes)
        self._appendTwoDigitDecimal(utcTime.seconds)
        self.append(UInt8(ascii: "Z"))
    }

    @inlinable
    mutating func _appendFourDigitDecimal(_ number: Int) {
        assert(number >= 0 && number <= 9999)

        // Each digit can be isolated by dividing by the place and then taking the result modulo 10.
        // This is annoyingly division heavy. There may be a better algorithm floating around.
        // Unchecked math is fine, there cannot be an overflow here.
        let asciiZero = UInt8(ascii: "0")
        self.append(UInt8(truncatingIfNeeded: (number / 1000) % 10) &+ asciiZero)
        self.append(UInt8(truncatingIfNeeded: (number / 100) % 10) &+ asciiZero)
        self.append(UInt8(truncatingIfNeeded: (number / 10) % 10) &+ asciiZero)
        self.append(UInt8(truncatingIfNeeded: number % 10) &+ asciiZero)
    }

    @inlinable
    mutating func _appendTwoDigitDecimal(_ number: Int) {
        assert(number >= 0 && number <= 99)

        // Each digit can be isolated by dividing by the place and then taking the result modulo 10.
        // This is annoyingly division heavy. There may be a better algorithm floating around.
        // Unchecked math is fine, there cannot be an overflow here.
        let asciiZero = UInt8(ascii: "0")
        self.append(UInt8(truncatingIfNeeded: (number / 10) % 10) &+ asciiZero)
        self.append(UInt8(truncatingIfNeeded: number % 10) &+ asciiZero)
    }
}

extension Int {
    @inlinable
    init?(fromDecimalASCII ascii: UInt8) {
        let asciiZero = UInt8(ascii: "0")
        let zeroToNine = 0...9

        // These are all coming from UInt8space, the subtraction cannot overflow.
        let converted = Int(ascii) &- Int(asciiZero)

        guard zeroToNine.contains(converted) else {
            return nil
        }

        self = converted
    }
}

extension Double {
    @inlinable
    init(fromRawFractionalSeconds rawFractionalSeconds: ArraySlice<UInt8>) throws {
        if rawFractionalSeconds.count == 0 {
            self = 0
            return
        }

        if rawFractionalSeconds.last == UInt8(ascii: "0") {
            throw ASN1Error.invalidASN1Object(reason: "Trailing zeros in raw fractional seconds")
        }

        let rawFractionalSecondsAsString = String(decoding: rawFractionalSeconds, as: UTF8.self)
        let fractionalSecondsAsString = "0.\(rawFractionalSecondsAsString)"

        guard let fractionalSeconds = Double(fractionalSecondsAsString) else {
            throw ASN1Error.invalidASN1Object(
                reason: "Invalid raw fractional seconds"
            )
        }

        self = fractionalSeconds
    }
}
