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

final class PanicSafetyTest: XCTestCase {
    // This test is designed to CRASH with a fatalError.
    // It verifies that the internal invariant violation produces a descriptive message.
    func testInvariantViolation() {
        // manually construct an invalid ParserNode (primitive but no data bytes)
        let identifier = ASN1Identifier(tagWithNumber: 1, tagClass: .universal)
        let invalidNode = ASN1.ParserNode(
            identifier: identifier,
            depth: 1,
            isConstructed: false,
            encodedBytes: [0x02, 0x01, 0x00]
        )
        
        let nodes: ArraySlice<ASN1.ParserNode> = [invalidNode][...]
        var iterator = ASN1NodeCollection.Iterator(nodes: nodes, depth: 0)
        
        print("About to iterate invalid node, expecting fatalError...")
        _ = iterator.next()
    }
}
