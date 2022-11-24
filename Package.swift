// swift-tools-version:5.6
//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftASN1 open source project
//
// Copyright (c) 2019-2022 Apple Inc. and the SwiftASN1 project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of SwiftASN1 project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
    name: "swift-asn1",
    products: [
        .library(name: "SwiftASN1", targets: ["SwiftASN1"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(name: "SwiftASN1"),
        .testTarget(name: "SwiftASN1Tests", dependencies: ["SwiftASN1"]),
    ]
)
