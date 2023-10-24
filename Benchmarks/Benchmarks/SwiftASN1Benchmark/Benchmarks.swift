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
import Foundation

let benchmarks = {
    Benchmark.defaultConfiguration = .init(
        metrics: [
            .mallocCountTotal,
            .syscalls,
            .readSyscalls,
            .writeSyscalls,
            .memoryLeaked,
            .retainCount,
            .releaseCount,
        ]
    )

    Benchmark("Parse WebPKI Roots from multi PEM to PEMDocument ") { benchmark, run in
        for _ in benchmark.scaledIterations {
            run()
        }
    } setup: {
        try! parseWebPKIFromMultiPEMStringToPEMDocument()
    }

    Benchmark("Parse WebPKI Roots from PEM to PEMDocument") { benchmark, run in
        for _ in benchmark.scaledIterations {
            run()
        }
    } setup: {
        try! parseWebPKIFromPEMStringToPEMDocument()
    }
}
