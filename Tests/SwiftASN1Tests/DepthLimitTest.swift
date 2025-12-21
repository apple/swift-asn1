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

final class DepthLimitTest: XCTestCase {
    func testRecursionLimit() throws {
        // Construct a binary file representing nested SEQUENCEs.
        // We will create a nesting depth of 60, which should exceed the default limit of 50.
        // We use indefinite length encoding (0x30 0x80) for simplicity in generation, 
        // as we don't need to back-patch lengths.
        // Structure: SEQUENCE { SEQUENCE { ... } }
        
        let depth = 60
        var bytes: [UInt8] = []
        
        // Open sequences
        for _ in 0..<depth {
            bytes.append(0x30) // Tag: SEQUENCE
            bytes.append(0x80) // Length: Indefinite
        }
        
        // Close sequences (0x00 0x00 is end-of-contents)
        for _ in 0..<depth {
            bytes.append(0x00)
            bytes.append(0x00)
        }
        
        // Write to a temporary file "excessive_depth.ber" for valid proof of file existence
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("excessive_depth.ber")
        try Data(bytes).write(to: fileURL)
        print("Generated recursive ASN.1 binary at: \(fileURL.path)")
        
        // Read back the data to simulate parsing from file
        let fileData = try Data(contentsOf: fileURL)
        let arrayData = [UInt8](fileData)
        
        // Attempt to parse
        XCTAssertThrowsError(try BER.parse(arrayData)) { error in
            print("Parser rejected deep nesting with error: \(error)")
            guard let asn1Error = error as? ASN1Error else {
                XCTFail("Unexpected error type: \(error)")
                return
            }
            
            XCTAssertEqual(asn1Error.code, .invalidASN1Object, "Error code should be invalidASN1Object")
            XCTAssertTrue(asn1Error.description.contains("Excessive stack depth"), "Error description should mention stack depth")
        }
    }
}
