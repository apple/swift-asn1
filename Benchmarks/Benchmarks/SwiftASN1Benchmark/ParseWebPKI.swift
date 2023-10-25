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

import Benchmark
import SwiftASN1
import Foundation

public func parseWebPKIFromMultiPEMStringToPEMDocument() throws -> () -> Void {
    let caPEMs = try loadWebPKIAsSingleMuliPEMString()
    return {
        blackHole(try! PEMDocument.parseMultiple(pemString: caPEMs))
    }
}

public func parseWebPKIFromPEMStringToPEMDocument() throws -> () -> Void {
    let caPEMs = try loadWebPKIAsPemStrings()
    return {
        blackHole(
            caPEMs.map { pemString in
                try! PEMDocument(pemString: pemString)
            }
        )
    }
}
