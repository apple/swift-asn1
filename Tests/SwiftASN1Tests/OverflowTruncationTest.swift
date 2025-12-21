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

final class OverflowTruncationTest: XCTestCase {
    
    // Test rejection of Tag Number > UInt64.max
    func testTagOverflow() {
        // Construct a tag in long form that is excessively large.
        // Format: [Tag Class | 0x1F] [0x8X] ... [0x0Y]
        // We will send 10 bytes of 0x81 (all with MSB set) followed by 0x01.
        // This is 70 bits + 1 bit, definitely > 64 bits.
        
        var bytes: [UInt8] = []
        bytes.append(0x1F) // Universal, Long form
        for _ in 0..<10 {
            bytes.append(0x81)
        }
        bytes.append(0x01)
        
        // Append 0 length and no content to complete the "node" if the tag were valid
        bytes.append(0x00)
        
        do {
            _ = try BER.parse(bytes)
            XCTFail("Should have rejected oversized tag")
        } catch let error as ASN1Error {
            // "Unable to store OID subidentifier" or similar invalid object error
             XCTAssertEqual(error.code, .invalidASN1Object)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // Test rejection of OID Component > UInt64.max
    func testOIDComponentOverflow() {
        // Tag: OBJECT IDENTIFIER (0x06)
        // Length: enough for our bytes
        // Value: 0x2A (1.2) first byte, then massive VLQ
        
        var oidValue: [UInt8] = [0x2A] // 1.2
        // Append massive VLQ: 10 bytes of 0x81, then 0x01
        for _ in 0..<10 {
            oidValue.append(0x81)
        }
        oidValue.append(0x01)
        
        var bytes: [UInt8] = []
        bytes.append(0x06) // OID Tag
        bytes.append(UInt8(oidValue.count)) // Length (short form is fine for < 127)
        bytes.append(contentsOf: oidValue)
        
        // Parsing the outer structure succeeds, but decoding OID should fail.
        do {
            let result = try BER.parse(bytes)
            _ = try ASN1ObjectIdentifier(berEncoded: result, withIdentifier: .objectIdentifier)
             XCTFail("Should have rejected oversized OID component")
        } catch let error as ASN1Error {
            XCTAssertEqual(error.code, .invalidASN1Object)
             // Expected reason: "Unable to store OID subidentifier"
        } catch {
             XCTFail("Unexpected error: \(error)")
        }
    }
    
    // Test OID Truncation (incomplete VLQ)
    func testOIDTruncation() {
        // Tag: OID
        // Length: 2
        // Value: 0x2A, 0x81 (Second component starts but never finishes)
        
        let bytes: [UInt8] = [0x06, 0x02, 0x2A, 0x81]
        
        do {
            let result = try BER.parse(bytes)
            _ = try ASN1ObjectIdentifier(berEncoded: result, withIdentifier: .objectIdentifier)
             XCTFail("Should have rejected truncated OID")
        } catch let error as ASN1Error {
             XCTAssertEqual(error.code, .invalidASN1Object)
             // Expected reason: "Invalid encoding for OID subidentifier" (no end index found)
        } catch {
             XCTFail("Unexpected error: \(error)")
        }
    }
}
