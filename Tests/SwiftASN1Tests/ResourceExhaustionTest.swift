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

final class ResourceExhaustionTest: XCTestCase {
    func testNodeLimit() throws {
        // Construct a BER sequence with 100,001 items.
        // Limit should be 100,000.
        // Structure: SEQUENCE (indefinite) { NULL, NULL, ... }
        
        let count = 100_001
        var bytes: [UInt8] = []
        bytes.reserveCapacity(count * 2 + 10)
        
        bytes.append(0x30) // Tag: SEQUENCE
        bytes.append(0x80) // Length: Indefinite
        
        for _ in 0..<count {
            bytes.append(0x05) // NULL
            bytes.append(0x00)
        }
        
        bytes.append(0x00)
        bytes.append(0x00) // End of content
        
        // Write to temp file for verification if needed
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("resource_exhaustion.ber")
        try Data(bytes).write(to: fileURL)
        print("Generated large ASN.1 binary at: \(fileURL.path)")
        
        let data = Data(bytes)
        let arrayData = [UInt8](data)
        
        // Attempt to parse. 
        // Before fix: This might succeed or crash depending on memory.
        // After fix: This MUST throw "Excessive number of ASN.1 nodes".
        
        do {
            _ = try BER.parse(arrayData)
            XCTFail("Parser should have rejected excessive node count")
        } catch let error as ASN1Error {
             print("Caught EXPECTED error: \(error)")
             XCTAssertEqual(error.code, .invalidASN1Object)
             XCTAssertTrue(error.description.contains("Excessive number of ASN.1 nodes"), "Error description was: \(error.description)")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
