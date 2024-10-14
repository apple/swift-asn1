// swift-tools-version:5.9
//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftASN1 open source project
//
// Copyright (c) 2019-2023 Apple Inc. and the SwiftASN1 project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftASN1 project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import PackageDescription
import class Foundation.ProcessInfo

let upcomingFeatureSwiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny")
]

let package = Package(
    name: "swift-asn1",
    products: [
        .library(name: "SwiftASN1", targets: ["SwiftASN1"])
    ],
    targets: [
        .target(
            name: "SwiftASN1",
            exclude: ["CMakeLists.txt"],
            swiftSettings: upcomingFeatureSwiftSettings
        ),
        .testTarget(
            name: "SwiftASN1Tests",
            dependencies: ["SwiftASN1"],
            swiftSettings: upcomingFeatureSwiftSettings
        ),
    ]
)
