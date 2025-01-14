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

/// GeneralizedTime represents a date and time.
///
/// In DER format, this is always in the form of `YYYYMMDDHHMMSSZ`. The type in
/// general is capable of expressing fractional seconds. The time is always in the
/// UTC time zone.
///
/// In BER format, seconds may be omitted, and timezone offsets can be present.
public struct GeneralizedTime: DERImplicitlyTaggable, BERImplicitlyTaggable, Hashable, Sendable {
    @inlinable
    public static var defaultIdentifier: ASN1Identifier {
        .generalizedTime
    }

    /// The numerical year.
    @inlinable
    public var year: Int {
        get {
            return self._year
        }
        set {
            self._year = newValue
            try! self._validate()
        }
    }

    /// The numerical month.
    @inlinable
    public var month: Int {
        get {
            return self._month
        }
        set {
            self._month = newValue
            try! self._validate()
        }
    }

    /// The numerical day.
    @inlinable
    public var day: Int {
        get {
            return self._day
        }
        set {
            self._day = newValue
            try! self._validate()
        }
    }

    /// The numerical hours.
    @inlinable
    public var hours: Int {
        get {
            return self._hours
        }
        set {
            self._hours = newValue
            try! self._validate()
        }
    }

    /// The numerical minutes.
    @inlinable
    public var minutes: Int {
        get {
            return self._minutes
        }
        set {
            self._minutes = newValue
            try! self._validate()
        }
    }

    /// The numerical seconds.
    @inlinable
    public var seconds: Int {
        get {
            return self._seconds
        }
        set {
            self._seconds = newValue
            try! self._validate()
        }
    }

    /// The fractional seconds.
    @inlinable
    public var fractionalSeconds: Double {
        get {
            return self._fractionalSeconds
        }
        set {
            self._fractionalSeconds = newValue
            self._rawFractionalSeconds = ArraySlice<UInt8>()
            try! self._rawFractionalSeconds.append(fractionalSeconds: self._fractionalSeconds)

            try! self._validate()
        }
    }

    /// The ArraySlice of bytes from which the fractional seconds will be computed. (Preserved due to a possible overflow
    /// when computing a Double from this ArraySlice.)
    @inlinable
    public var rawFractionalSeconds: ArraySlice<UInt8> {
        get {
            return self._rawFractionalSeconds
        }
        set {
            self._rawFractionalSeconds = newValue
            self._fractionalSeconds = try! Double(fromRawFractionalSeconds: self._rawFractionalSeconds)

            try! self._validate()
        }
    }

    @usableFromInline var _year: Int
    @usableFromInline var _month: Int
    @usableFromInline var _day: Int
    @usableFromInline var _hours: Int
    @usableFromInline var _minutes: Int
    @usableFromInline var _seconds: Int
    /// `_fractionalSeconds` is a cached value and `_rawFractionalSeconds` is the source of truth for the numerical
    /// fractonal seconds. (No information is lost in the conversion from `_fractionalSeconds` to `_rawFractionalSeconds`.)
    @usableFromInline var _fractionalSeconds: Double
    @usableFromInline var _rawFractionalSeconds: ArraySlice<UInt8>

    /// Construct a new ``GeneralizedTime`` from individual components.
    ///
    /// - parameters:
    ///     - year: The numerical year
    ///     - month: The numerical month
    ///     - day: The numerical day
    ///     - hours: The numerical hours
    ///     - minutes: The numerical minutes
    ///     - seconds: The numerical seconds
    ///     - fractionalSeconds: The numerical fractional seconds.
    @inlinable
    public init(
        year: Int,
        month: Int,
        day: Int,
        hours: Int,
        minutes: Int,
        seconds: Int,
        fractionalSeconds: Double
    ) throws {
        self._year = year
        self._month = month
        self._day = day
        self._hours = hours
        self._minutes = minutes
        self._seconds = seconds
        self._fractionalSeconds = fractionalSeconds
        self._rawFractionalSeconds = ArraySlice<UInt8>()
        try self._rawFractionalSeconds.append(fractionalSeconds: self._fractionalSeconds)

        try self._validate()
    }

    /// Construct a new ``GeneralizedTime`` from individual components.
    ///
    /// - parameters:
    ///     - year: The numerical year
    ///     - month: The numerical month
    ///     - day: The numerical day
    ///     - hours: The numerical hours
    ///     - minutes: The numerical minutes
    ///     - seconds: The numerical seconds
    ///     - rawFractionalSeconds: The ArraySlice of bytes from which the fractional seconds will be computed.
    ///     (Preserved due to a possible overflow when computing a Double from this ArraySlice.)
    @inlinable
    public init(
        year: Int,
        month: Int,
        day: Int,
        hours: Int,
        minutes: Int,
        seconds: Int,
        rawFractionalSeconds: ArraySlice<UInt8>
    ) throws {
        self._year = year
        self._month = month
        self._day = day
        self._hours = hours
        self._minutes = minutes
        self._seconds = seconds
        self._rawFractionalSeconds = rawFractionalSeconds
        self._fractionalSeconds = try Double(fromRawFractionalSeconds: self._rawFractionalSeconds)

        try self._validate()
    }

    @inlinable
    public init(derEncoded node: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        let content = try ASN1OctetString(derEncoded: node, withIdentifier: identifier).bytes
        self = try TimeUtilities.generalizedTimeFromBytes(content)
    }

    @inlinable
    public init(berEncoded node: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        // TODO: BER supports relaxed timestamp parsing, which is not yet supported
        let content = try ASN1OctetString(berEncoded: node, withIdentifier: identifier).bytes
        self = try TimeUtilities.generalizedTimeFromBytes(content)
    }

    @inlinable
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        coder.appendPrimitiveNode(identifier: identifier) { bytes in
            bytes.append(self)
        }
    }

    @inlinable
    func _validate() throws {
        // Validate that the structure is well-formed.
        guard self._year >= 0 && self._year <= 9999 else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid year for GeneralizedTime \(self._year)")
        }

        // This also validates the month.
        guard let daysInMonth = TimeUtilities.daysInMonth(self._month, ofYear: self._year) else {
            throw ASN1Error.invalidASN1Object(
                reason: "Invalid month \(self._month) of year \(self.year) for GeneralizedTime"
            )
        }

        guard self._day >= 1 && self._day <= daysInMonth else {
            throw ASN1Error.invalidASN1Object(
                reason: "Invalid day \(self._day) of month \(self._month) for GeneralizedTime"
            )
        }

        guard self._hours >= 0 && self._hours < 24 else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid hour for GeneralizedTime \(self._hours)")
        }

        guard self._minutes >= 0 && self._minutes < 60 else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid minute for GeneralizedTime \(self._minutes)")
        }

        // We allow leap seconds here, but don't validate it.
        // This exposes us to potential confusion if we naively implement
        // comparison here. We should consider whether this needs to be transformable
        // to `Date` or similar.
        guard self._seconds >= 0 && self._seconds <= 61 else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid seconds for Generalized \(self._seconds)")
        }

        // Fractional seconds may not be negative and may not be 1 or more.
        guard self._fractionalSeconds >= 0 && self._fractionalSeconds < 1 else {
            throw ASN1Error.invalidASN1Object(
                reason: "Invalid fractional seconds for GeneralizedTime \(self._fractionalSeconds)"
            )
        }

        // When `rawFractionalSeconds` is converted to a `Double`, it must be equal to `fractionalSeconds`.
        assert(
            (try? Double(fromRawFractionalSeconds: self._rawFractionalSeconds)) == self._fractionalSeconds
        )
    }
}

extension GeneralizedTime: Comparable {
    @inlinable
    public static func < (lhs: GeneralizedTime, rhs: GeneralizedTime) -> Bool {
        if lhs.year < rhs.year { return true } else if lhs.year > rhs.year { return false }
        if lhs.month < rhs.month { return true } else if lhs.month > rhs.month { return false }
        if lhs.day < rhs.day { return true } else if lhs.day > rhs.day { return false }
        if lhs.hours < rhs.hours { return true } else if lhs.hours > rhs.hours { return false }
        if lhs.minutes < rhs.minutes { return true } else if lhs.minutes > rhs.minutes { return false }
        if lhs.seconds < rhs.seconds { return true } else if lhs.seconds > rhs.seconds { return false }
        if lhs.fractionalSeconds < rhs.fractionalSeconds {
            return true
        } else if lhs.fractionalSeconds > rhs.fractionalSeconds {
            return false
        }

        for (lhsByte, rhsByte) in zip(lhs.rawFractionalSeconds, rhs.rawFractionalSeconds) {
            if lhsByte != rhsByte {
                return lhsByte < rhsByte
            }
        }

        // Since the above `zip` iteration stops at the length of the shorter `Sequence`, finally,
        // compare the length of the two `Sequence`s.
        return lhs.rawFractionalSeconds.count < rhs.rawFractionalSeconds.count
    }
}
