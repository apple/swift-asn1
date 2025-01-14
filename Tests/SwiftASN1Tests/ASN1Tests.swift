//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftASN1 open source project
//
// Copyright (c) 2019-2020 Apple Inc. and the SwiftASN1 project authors
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

class ASN1Tests: XCTestCase {
    func testSimpleASN1P256SPKI() throws {
        // Given a static SPKI structure, verifies the parse.
        let encodedSPKI =
            "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE2adMrdG7aUfZH57aeKFFM01dPnkxC18ScRb4Z6poMBgJtYlVtd9ly63URv57ZW0Ncs1LiZB7WATb3svu+1c7HQ=="
        let decodedSPKI = Array(Data(base64Encoded: encodedSPKI)!)

        let encodedExpectedKeyBytes =
            "BNmnTK3Ru2lH2R+e2nihRTNNXT55MQtfEnEW+GeqaDAYCbWJVbXfZcut1Eb+e2VtDXLNS4mQe1gE297L7vtXOx0="
        let expectedKeyBytes = Array(Data(base64Encoded: encodedExpectedKeyBytes)!)

        let result = try DER.parse(decodedSPKI)
        let spki = try SubjectPublicKeyInfo(derEncoded: result)

        XCTAssertEqual(spki.algorithmIdentifier, .ecdsaP256)
        spki.key.withUnsafeBytes { XCTAssertEqual(Array($0), expectedKeyBytes) }

        // For SPKI we should be able to round-trip the serialization.
        var serializer = DER.Serializer()
        XCTAssertNoThrow(try serializer.serialize(spki))
        XCTAssertEqual(serializer.serializedBytes, decodedSPKI)

        // The root node should contain all the bytes
        XCTAssertEqual(result.encodedBytes, decodedSPKI[...])
    }

    func testSimpleASN1P384SPKI() throws {
        let encodedSPKI =
            "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEcBr0TNmgagf1ysckEA/3XLGx2amgzeHjDBZREqhCIVBrLhIiIR4zrJ8dqad/Y+zI2Hu8TIUbrzS/diFpFoE0YYKBTfYMCAUtaWuMb1oaBdFzWsLfYSSzF+ON1yeJCtro"
        let decodedSPKI = Array(Data(base64Encoded: encodedSPKI)!)

        let encodedExpectedKeyBytes =
            "BHAa9EzZoGoH9crHJBAP91yxsdmpoM3h4wwWURKoQiFQay4SIiEeM6yfHamnf2PsyNh7vEyFG680v3YhaRaBNGGCgU32DAgFLWlrjG9aGgXRc1rC32EksxfjjdcniQra6A=="
        let expectedKeyBytes = Array(Data(base64Encoded: encodedExpectedKeyBytes)!)

        let result = try DER.parse(decodedSPKI)
        let spki = try SubjectPublicKeyInfo(derEncoded: result)

        XCTAssertEqual(spki.algorithmIdentifier, .ecdsaP384)
        spki.key.withUnsafeBytes { XCTAssertEqual(Array($0), expectedKeyBytes) }

        // For SPKI we should be able to round-trip the serialization.
        var serializer = DER.Serializer()
        XCTAssertNoThrow(try serializer.serialize(spki))
        XCTAssertEqual(serializer.serializedBytes, decodedSPKI)
    }

    func testSimpleASN1P521SPKI() throws {
        let encodedSPKI =
            "MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBTxMJZTRr9NcKmD7iTeX7ofcgz77JPTIDXOHFfS1tZHd9P0uAeK/ARwwDdsQpIKCvmtaO4O52oHqmczdrRwGtrHIBUTqaOw2Fqdiqt0fRQju9wH1Xi4h8u0h80MymUM0sbAQ70jHCeV0S0mGcJS8t3nfP+qLes30h297dPfV3SLsLg8M="
        let decodedSPKI = Array(Data(base64Encoded: encodedSPKI)!)

        let encodedExpectedKeyBytes =
            "BAFPEwllNGv01wqYPuJN5fuh9yDPvsk9MgNc4cV9LW1kd30/S4B4r8BHDAN2xCkgoK+a1o7g7nageqZzN2tHAa2scgFROpo7DYWp2Kq3R9FCO73AfVeLiHy7SHzQzKZQzSxsBDvSMcJ5XRLSYZwlLy3ed8/6ot6zfSHb3t099XdIuwuDww=="
        let expectedKeyBytes = Array(Data(base64Encoded: encodedExpectedKeyBytes)!)

        let result = try DER.parse(decodedSPKI)
        let spki = try SubjectPublicKeyInfo(derEncoded: result)

        XCTAssertEqual(spki.algorithmIdentifier, .ecdsaP521)
        spki.key.withUnsafeBytes { XCTAssertEqual(Array($0), expectedKeyBytes) }

        // For SPKI we should be able to round-trip the serialization.
        var serializer = DER.Serializer()
        XCTAssertNoThrow(try serializer.serialize(spki))
        XCTAssertEqual(serializer.serializedBytes, decodedSPKI)
    }

    func testASN1SEC1PrivateKeyP256() throws {
        let encodedPrivateKey =
            "MHcCAQEEIFAV2+taX2/ht9HEcLQPtfyuRktTkn4S3RaCQwDmDnrloAoGCCqGSM49AwEHoUQDQgAE3Oed98X0hHmzHmmmgtf5rAVEv0jIeH61K61P5UyiCozn+fz+mlmBywvluiVvERiT9WZCd3tkPPWwbIr+a0dnwA=="
        let decodedPrivateKey = Array(Data(base64Encoded: encodedPrivateKey)!)

        let encodedPrivateKeyBytes = "UBXb61pfb+G30cRwtA+1/K5GS1OSfhLdFoJDAOYOeuU="
        let privateKeyBytes = Array(Data(base64Encoded: encodedPrivateKeyBytes)!)

        let encodedPublicKeyBytes =
            "BNznnffF9IR5sx5ppoLX+awFRL9IyHh+tSutT+VMogqM5/n8/ppZgcsL5bolbxEYk/VmQnd7ZDz1sGyK/mtHZ8A="
        let publicKeyBytes = Array(Data(base64Encoded: encodedPublicKeyBytes)!)

        let result = try DER.parse(decodedPrivateKey)
        let pkey = try SEC1PrivateKey(derEncoded: result)

        XCTAssertEqual(pkey.algorithm, .ecdsaP256)
        pkey.privateKey.withUnsafeBytes { XCTAssertEqual(Array($0), privateKeyBytes) }
        pkey.publicKey!.withUnsafeBytes { XCTAssertEqual(Array($0), publicKeyBytes) }

        // For SEC1 we should be able to round-trip the serialization.
        var serializer = DER.Serializer()
        XCTAssertNoThrow(try serializer.serialize(pkey))
        XCTAssertEqual(serializer.serializedBytes, decodedPrivateKey)
    }

    func testASN1SEC1PrivateKeyP384() throws {
        let encodedPrivateKey =
            "MIGkAgEBBDAWv9iH6ZivZKtk5ihjvjlZCYc9JHyykqvmJ7JVQ50ZZWTkCPtIe7RSKzm+l7NJltqgBwYFK4EEACKhZANiAAQz0BBmMxeOj5XwTL1G4fqTYO2UAiYrUMixiRFlFKVY5I6jAgiEWdNbmte8o6dByo0No5YoyDHdG637xvuzGaWd+IT5LoBAVVv3AgL3ao3dA4aVhm6Yz6G6/2o3X7AH99c="
        let decodedPrivateKey = Array(Data(base64Encoded: encodedPrivateKey)!)

        let encodedPrivateKeyBytes = "Fr/Yh+mYr2SrZOYoY745WQmHPSR8spKr5ieyVUOdGWVk5Aj7SHu0Uis5vpezSZba"
        let privateKeyBytes = Array(Data(base64Encoded: encodedPrivateKeyBytes)!)

        let encodedPublicKeyBytes =
            "BDPQEGYzF46PlfBMvUbh+pNg7ZQCJitQyLGJEWUUpVjkjqMCCIRZ01ua17yjp0HKjQ2jlijIMd0brfvG+7MZpZ34hPkugEBVW/cCAvdqjd0DhpWGbpjPobr/ajdfsAf31w=="
        let publicKeyBytes = Array(Data(base64Encoded: encodedPublicKeyBytes)!)

        let result = try DER.parse(decodedPrivateKey)
        let pkey = try SEC1PrivateKey(derEncoded: result)

        XCTAssertEqual(pkey.algorithm, .ecdsaP384)
        pkey.privateKey.withUnsafeBytes { XCTAssertEqual(Array($0), privateKeyBytes) }
        pkey.publicKey!.withUnsafeBytes { XCTAssertEqual(Array($0), publicKeyBytes) }

        // For SEC1 we should be able to round-trip the serialization.
        var serializer = DER.Serializer()
        XCTAssertNoThrow(try serializer.serialize(pkey))
        XCTAssertEqual(serializer.serializedBytes, decodedPrivateKey)
    }

    func testASN1SEC1PrivateKeyP521() throws {
        let encodedPrivateKey =
            "MIHcAgEBBEIBONszidL11f7D8LEbVGKG4A7768X16w35/m6OSPO7MGQcYhWHpgSV4NZ6AFKcksavZSCa59lYdAN+MA3sUjO7R/mgBwYFK4EEACOhgYkDgYYABAAzsbWlHXjMkaSQTBnBKcyPDy/x0nk+VlkYQJXkh+lPJSVEYLbrUZ1LdbfM9mGE7HpgyyELNRHy/BD1JdNnAVPemAC5VQjeGKbezrxz7D5iZNiZiQFVYtMBU3XSsuJrPWVSjBF7xIkOr06k2xg1qlOoXQ66EPHQlwEYJ3xATNKk8K2jlQ=="
        let decodedPrivateKey = Array(Data(base64Encoded: encodedPrivateKey)!)

        let encodedPrivateKeyBytes =
            "ATjbM4nS9dX+w/CxG1RihuAO++vF9esN+f5ujkjzuzBkHGIVh6YEleDWegBSnJLGr2UgmufZWHQDfjAN7FIzu0f5"
        let privateKeyBytes = Array(Data(base64Encoded: encodedPrivateKeyBytes)!)

        let encodedPublicKeyBytes =
            "BAAzsbWlHXjMkaSQTBnBKcyPDy/x0nk+VlkYQJXkh+lPJSVEYLbrUZ1LdbfM9mGE7HpgyyELNRHy/BD1JdNnAVPemAC5VQjeGKbezrxz7D5iZNiZiQFVYtMBU3XSsuJrPWVSjBF7xIkOr06k2xg1qlOoXQ66EPHQlwEYJ3xATNKk8K2jlQ=="
        let publicKeyBytes = Array(Data(base64Encoded: encodedPublicKeyBytes)!)

        let result = try DER.parse(decodedPrivateKey)
        let pkey = try SEC1PrivateKey(derEncoded: result)

        XCTAssertEqual(pkey.algorithm, .ecdsaP521)
        pkey.privateKey.withUnsafeBytes { XCTAssertEqual(Array($0), privateKeyBytes) }
        pkey.publicKey!.withUnsafeBytes { XCTAssertEqual(Array($0), publicKeyBytes) }

        // For SEC1 we should be able to round-trip the serialization.
        var serializer = DER.Serializer()
        XCTAssertNoThrow(try serializer.serialize(pkey))
        XCTAssertEqual(serializer.serializedBytes, decodedPrivateKey)
    }

    func testASN1PKCS8PrivateKeyP256() throws {
        let encodedPrivateKey =
            "MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgCRQo0CoBKfTOhdgQHcQIVv21vIUsxmE3t9L1LqV00bahRANCAATDXEj3jviAtzgx4bnMa/081v+FXbp7O5D1KtKVdje+ckejGVLYuYKE4Lpf5jonefi6wtoCc/sWHlbLiNV5PEB9"
        let decodedPrivateKey = Array(Data(base64Encoded: encodedPrivateKey)!)

        let encodedPrivateKeyBytes = "CRQo0CoBKfTOhdgQHcQIVv21vIUsxmE3t9L1LqV00bY="
        let privateKeyBytes = Array(Data(base64Encoded: encodedPrivateKeyBytes)!)

        let encodedPublicKeyBytes =
            "BMNcSPeO+IC3ODHhucxr/TzW/4Vduns7kPUq0pV2N75yR6MZUti5goTgul/mOid5+LrC2gJz+xYeVsuI1Xk8QH0="
        let publicKeyBytes = Array(Data(base64Encoded: encodedPublicKeyBytes)!)

        let result = try DER.parse(decodedPrivateKey)
        let pkey = try PKCS8PrivateKey(derEncoded: result)

        XCTAssertEqual(pkey.algorithm, .ecdsaP256)
        XCTAssertNil(pkey.privateKey.algorithm)  // OpenSSL nils this out for some reason
        pkey.privateKey.privateKey.withUnsafeBytes { XCTAssertEqual(Array($0), privateKeyBytes) }
        pkey.privateKey.publicKey!.withUnsafeBytes { XCTAssertEqual(Array($0), publicKeyBytes) }

        // For PKCS8 we should be able to round-trip the serialization.
        var serializer = DER.Serializer()
        XCTAssertNoThrow(try serializer.serialize(pkey))
        XCTAssertEqual(serializer.serializedBytes, decodedPrivateKey)
    }

    func testASN1PKCS8PrivateKeyP384() throws {
        let encodedPrivateKey =
            "MIG2AgEAMBAGByqGSM49AgEGBSuBBAAiBIGeMIGbAgEBBDCKfeRAkTtGQG7bGao6Ca5MDDcmxttyr6HNmNoaSkmuYvBtLGLLBWm1+VHT602xOIihZANiAAS56RzXiLO5YvFI0qh/+T9DhOXfkm3K/jJSUAqV/hP0FUlIUR824cFVdMMQA1S100mETsxdT0QDqUGAinMTUBSyk9y+jR33Fw/A068ZQRlqTCa0ThS0vwxKhM/M4vhYeDE="
        let decodedPrivateKey = Array(Data(base64Encoded: encodedPrivateKey)!)

        let encodedPrivateKeyBytes = "in3kQJE7RkBu2xmqOgmuTAw3Jsbbcq+hzZjaGkpJrmLwbSxiywVptflR0+tNsTiI"
        let privateKeyBytes = Array(Data(base64Encoded: encodedPrivateKeyBytes)!)

        let encodedPublicKeyBytes =
            "BLnpHNeIs7li8UjSqH/5P0OE5d+Sbcr+MlJQCpX+E/QVSUhRHzbhwVV0wxADVLXTSYROzF1PRAOpQYCKcxNQFLKT3L6NHfcXD8DTrxlBGWpMJrROFLS/DEqEz8zi+Fh4MQ=="
        let publicKeyBytes = Array(Data(base64Encoded: encodedPublicKeyBytes)!)

        let result = try DER.parse(decodedPrivateKey)
        let pkey = try PKCS8PrivateKey(derEncoded: result)

        XCTAssertEqual(pkey.algorithm, .ecdsaP384)
        XCTAssertNil(pkey.privateKey.algorithm)  // OpenSSL nils this out for some reason
        pkey.privateKey.privateKey.withUnsafeBytes { XCTAssertEqual(Array($0), privateKeyBytes) }
        pkey.privateKey.publicKey!.withUnsafeBytes { XCTAssertEqual(Array($0), publicKeyBytes) }

        // For PKCS8 we should be able to round-trip the serialization.
        var serializer = DER.Serializer()
        XCTAssertNoThrow(try serializer.serialize(pkey))
        XCTAssertEqual(serializer.serializedBytes, decodedPrivateKey)
    }

    func testASN1PKCS8PrivateKeyP521() throws {
        let encodedPrivateKey =
            "MIHuAgEAMBAGByqGSM49AgEGBSuBBAAjBIHWMIHTAgEBBEIB/rwbfr3a+rdHQvKToS6Fw1WxsVFy3Wq2ylWC+EyQv//nGiT5TQYIAV2WDmmud3WnczITapXAAe6eS66jHa+OxyGhgYkDgYYABADrY6IBU4t8BjSIvDWA4VrLILdUOFemM2G8phpJWlGpEO8Qmk28w5pdLD2j3chBvg0xBBi2k9Ked9L43R4E3+gPCAA3CY8v01xlA6npJvdAK0/Md4mY+p65Ehua95jXnSwrpF66+Q/se2ODvZPhXGKBvttxrKyBr9htmkAUv9Sdah+dWQ=="
        let decodedPrivateKey = Array(Data(base64Encoded: encodedPrivateKey)!)

        let encodedPrivateKeyBytes =
            "Af68G3692vq3R0Lyk6EuhcNVsbFRct1qtspVgvhMkL//5xok+U0GCAFdlg5prnd1p3MyE2qVwAHunkuuox2vjsch"
        let privateKeyBytes = Array(Data(base64Encoded: encodedPrivateKeyBytes)!)

        let encodedPublicKeyBytes =
            "BADrY6IBU4t8BjSIvDWA4VrLILdUOFemM2G8phpJWlGpEO8Qmk28w5pdLD2j3chBvg0xBBi2k9Ked9L43R4E3+gPCAA3CY8v01xlA6npJvdAK0/Md4mY+p65Ehua95jXnSwrpF66+Q/se2ODvZPhXGKBvttxrKyBr9htmkAUv9Sdah+dWQ=="
        let publicKeyBytes = Array(Data(base64Encoded: encodedPublicKeyBytes)!)

        let result = try DER.parse(decodedPrivateKey)
        let pkey = try PKCS8PrivateKey(derEncoded: result)

        XCTAssertEqual(pkey.algorithm, .ecdsaP521)
        XCTAssertNil(pkey.privateKey.algorithm)  // OpenSSL nils this out for some reason
        pkey.privateKey.privateKey.withUnsafeBytes { XCTAssertEqual(Array($0), privateKeyBytes) }
        pkey.privateKey.publicKey!.withUnsafeBytes { XCTAssertEqual(Array($0), publicKeyBytes) }

        // For PKCS8 we should be able to round-trip the serialization.
        var serializer = DER.Serializer()
        XCTAssertNoThrow(try serializer.serialize(pkey))
        XCTAssertEqual(serializer.serializedBytes, decodedPrivateKey)
    }

    func testRejectDripFedASN1SPKIP256() throws {
        // This test drip-feeds an ASN.1 P256 SPKI block. It should never parse correctly until we feed the entire block.
        let encodedSPKI =
            "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE2adMrdG7aUfZH57aeKFFM01dPnkxC18ScRb4Z6poMBgJtYlVtd9ly63URv57ZW0Ncs1LiZB7WATb3svu+1c7HQ=="
        let decodedSPKI = Array(Data(base64Encoded: encodedSPKI)!)

        for index in decodedSPKI.indices {
            let expectSuccessfulParse = index == decodedSPKI.endIndex

            do {
                _ = try DER.parse(decodedSPKI[..<index])
                if !expectSuccessfulParse {
                    XCTFail("Unexpected successful parse with: \(decodedSPKI[...])")
                }
            } catch let error as ASN1Error {
                if expectSuccessfulParse {
                    XCTFail("Unexpected failure (error: \(error)) with \(decodedSPKI[...])")
                }
            }
        }
    }

    func testASN1TypesRequireAppropriateTypeIdentifierToDecode() throws {
        // This is an ASN.1 REAL, a type we don't support
        let base64Node = "CQUDMUUtMQ=="
        let decodedReal = Array(Data(base64Encoded: base64Node)!)
        let parsed = try DER.parse(decodedReal)

        XCTAssertThrowsError(try ASN1ObjectIdentifier(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .unexpectedFieldType)
        }
        XCTAssertThrowsError(try DER.sequence(parsed, identifier: .sequence, { _ in })) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .unexpectedFieldType)
        }
        XCTAssertThrowsError(try ASN1OctetString(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .unexpectedFieldType)
        }
        XCTAssertThrowsError(try ASN1BitString(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .unexpectedFieldType)
        }
        XCTAssertThrowsError(try Int(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .unexpectedFieldType)
        }
    }

    func testMultipleRootNodesAreForbidden() throws {
        // This is an ASN.1 REAL, a type we don't support, repeated
        let base64Node = "CQUDMUUtMQkFAzFFLTE="
        let decodedReal = Array(Data(base64Encoded: base64Node)!)
        XCTAssertThrowsError(try DER.parse(decodedReal)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testTrailingBytesAreForbidden() throws {
        // This is an ASN.1 INTEGER with trailing junk bytes
        let base64Node = "AgEBAA=="
        let decodedInteger = Array(Data(base64Encoded: base64Node)!)
        XCTAssertThrowsError(try DER.parse(decodedInteger)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testEmptyStringsDontDecode() throws {
        XCTAssertThrowsError(try DER.parse([])) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .truncatedASN1Field)
        }
    }

    func testSupportMultibyteTags() throws {
        // This is an ASN.1 object with a multibyte explicit tag, with the raw numerical value being 55.
        let base64Node = "vzcDAgEB"
        let decodedInteger = Array(Data(base64Encoded: base64Node)!)
        let result = try DER.parse(decodedInteger)

        XCTAssertEqual(result.identifier, ASN1Identifier(tagWithNumber: 55, tagClass: .contextSpecific))
    }

    func testSupportSmallestValidMultibyteTags() throws {
        // This is an ASN.1 object with a multibyte explicit tag, with the raw numerical value being 31.
        let base64Node = "vx8DAgEB"
        let decodedInteger = Array(Data(base64Encoded: base64Node)!)
        let result = try DER.parse(decodedInteger)

        XCTAssertEqual(result.identifier, ASN1Identifier(tagWithNumber: 31, tagClass: .contextSpecific))
    }

    func testRejectExcessivelySmallMultibyteTags() throws {
        // This is an ASN.1 object with a multibyte explicit tag but whose raw value is 30, which is required to be written in the short form.
        let base64Node = "vx4DAgEB"
        let decodedInteger = Array(Data(base64Encoded: base64Node)!)
        XCTAssertThrowsError(try DER.parse(decodedInteger)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testGracefullyTolerateExcessivelyLargeMultibyteTags() throws {
        // This is an ASN.1 object with a multibyte explicit tag whose raw value is one larger than the max we tolerate, which is (1 << 63).
        let base64Node = "v4GAgICAgICAgAADAgEB"
        let decodedInteger = Array(Data(base64Encoded: base64Node)!)
        XCTAssertThrowsError(try DER.parse(decodedInteger)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testGracefullyTolerateLargeButRepresentableMultibyteTags() throws {
        // This is an ASN.1 object with a multibyte explicit tag whose raw value is (1 << 63) - 1.
        let base64Node = "v///////////fwMCAQE="
        let decodedInteger = Array(Data(base64Encoded: base64Node)!)
        let result = try DER.parse(decodedInteger)

        XCTAssertEqual(result.identifier, ASN1Identifier(tagWithNumber: (1 << 63) - 1, tagClass: .contextSpecific))
    }

    func testRejectMultibyteTagWithLeadingZeroByte() throws {
        // This is an ASN.1 object with a multibyte explicit tag whose raw value is 55 but padded with a leading byte of zeros.
        let base64Node = "v4A3AwIBAQ=="
        let decodedInteger = Array(Data(base64Encoded: base64Node)!)

        XCTAssertThrowsError(try DER.parse(decodedInteger)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testSequenceMustConsumeAllNodes() throws {
        // This is an ASN.1 SEQUENCE with two child nodes, both octet strings. We're going to consume only one.
        let base64Sequence = "MAwEBEFCQ0QEBEVGR0g="
        let decodedSequence = Array(Data(base64Encoded: base64Sequence)!)
        let parsed = try DER.parse(decodedSequence)

        do {
            try DER.sequence(parsed, identifier: .sequence) { nodes in
                // This is fine.
                XCTAssertNoThrow(try ASN1OctetString(derEncoded: &nodes))
            }
        } catch let error as ASN1Error {
            XCTAssertEqual(error.code, .invalidASN1Object)
        }
    }

    func testNodesErrorIfThereIsInsufficientData() throws {
        struct Stub: DERParseable {
            init(derEncoded node: ASN1Node) throws {
                XCTFail("Must not be called")
            }
        }

        // This is an ASN.1 SEQUENCE with two child nodes, both octet strings. We're going to consume both and then try
        // to eat the (nonexistent) next node.
        let base64Sequence = "MAwEBEFCQ0QEBEVGR0g="
        let decodedSequence = Array(Data(base64Encoded: base64Sequence)!)
        let parsed = try DER.parse(decodedSequence)

        do {
            try DER.sequence(parsed, identifier: .sequence) { nodes in
                XCTAssertNoThrow(try ASN1OctetString(derEncoded: &nodes))
                XCTAssertNoThrow(try ASN1OctetString(derEncoded: &nodes))
                _ = try Stub(derEncoded: &nodes)
            }
        } catch let error as ASN1Error {
            XCTAssertEqual(error.code, .invalidASN1Object)
        }
    }

    func testRejectsIndefiniteLengthForm() throws {
        // This the first octets of a constructed object of unknown tag type (private, number 7) whose length
        // is indefinite. We reject this immediately, not even noticing that the rest of the data isn't here.
        XCTAssertThrowsError(try DER.parse([0xe7, 0x80])) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .unsupportedFieldLength)
        }
    }

    func testRejectsUnterminatedASN1OIDSubidentifiers() throws {
        // This data contains the ASN.1 OID 2.6.7, with the last subidentifier having been mangled to set the top bit.
        // This makes it look like we're expecting more data in the OID, and we should flag it as truncated.
        let badBase64 = "BgJWhw=="
        let badNode = Array(Data(base64Encoded: badBase64)!)
        let parsed = try DER.parse(badNode)

        XCTAssertThrowsError(try ASN1ObjectIdentifier(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testRejectsMassiveIntegers() throws {
        // This is an ASN.1 integer containing UInt64.max * 2. This is too big for us to store, and we reject it.
        // This test may need to be rewritten if we either support arbitrary integers or move to platforms where
        // UInt is larger than 64 bits (seems unlikely).
        let badBase64 = "AgkB//////////4="
        let badNode = Array(Data(base64Encoded: badBase64)!)
        let parsed = try DER.parse(badNode)

        XCTAssertThrowsError(try Int(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testStraightforwardPEMDocumentParsing() throws {
        let simplePEM = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            """
        let document = try PEMDocument(pemString: simplePEM)
        XCTAssertEqual(document.discriminator, "EC PRIVATE KEY")
        XCTAssertEqual(document.derBytes.count, 121)

        let documents = try PEMDocument.parseMultiple(pemString: simplePEM)
        XCTAssertEqual(documents, [document])

        let parsed = try DER.parse(document.derBytes)
        let pkey = try SEC1PrivateKey(derEncoded: parsed)

        let reserialized = document.pemString
        XCTAssertEqual(reserialized, simplePEM)

        var serializer = DER.Serializer()
        XCTAssertNoThrow(try serializer.serialize(pkey))
        let reserialized2 = PEMDocument(type: "EC PRIVATE KEY", derBytes: serializer.serializedBytes)
        XCTAssertEqual(reserialized2.pemString, simplePEM)
    }

    func testStraightforwardMultiPEMDocumentParsing() throws {
        let simplePEM = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            """
        let documents = try PEMDocument.parseMultiple(pemString: simplePEM)
        XCTAssertEqual(documents.count, 2)
        for document in documents {
            XCTAssertEqual(document.discriminator, "EC PRIVATE KEY")
            XCTAssertEqual(document.derBytes.count, 121)

            let parsed = try DER.parse(document.derBytes)
            let pkey = try SEC1PrivateKey(derEncoded: parsed)

            let reserialized = document.pemString

            var serializer = DER.Serializer()
            XCTAssertNoThrow(try serializer.serialize(pkey))
            let reserialized2 = PEMDocument(type: "EC PRIVATE KEY", derBytes: serializer.serializedBytes)
            XCTAssertEqual(reserialized2.pemString, reserialized)
        }
    }

    func testMultiPEMDocumentParsing() throws {
        let multiPEM = """
            -----BEGIN CERTIFICATE-----
            MIIDljCCAn6gAwIBAgIQC5McOtY5Z+pnI7/Dr5r0SzANBgkqhkiG9w0BAQsFADBl
            MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
            d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJv
            b3QgRzIwHhcNMTMwODAxMTIwMDAwWhcNMzgwMTE1MTIwMDAwWjBlMQswCQYDVQQG
            EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
            cnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgRzIwggEi
            MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDZ5ygvUj82ckmIkzTz+GoeMVSA
            n61UQbVH35ao1K+ALbkKz3X9iaV9JPrjIgwrvJUXCzO/GU1BBpAAvQxNEP4Htecc
            biJVMWWXvdMX0h5i89vqbFCMP4QMls+3ywPgym2hFEwbid3tALBSfK+RbLE4E9Hp
            EgjAALAcKxHad3A2m67OeYfcgnDmCXRwVWmvo2ifv922ebPynXApVfSr/5Vh88lA
            bx3RvpO704gqu52/clpWcTs/1PPRCv4o76Pu2ZmvA9OPYLfykqGxvYmJHzDNw6Yu
            YjOuFgJ3RFrngQo8p0Quebg/BLxcoIfhG69Rjs3sLPr4/m3wOnyqi+RnlTGNAgMB
            AAGjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMB0GA1UdDgQW
            BBTOw0q5mVXyuNtgv6l+vVa1lzan1jANBgkqhkiG9w0BAQsFAAOCAQEAyqVVjOPI
            QW5pJ6d1Ee88hjZv0p3GeDgdaZaikmkuOGybfQTUiaWxMTeKySHMq2zNixya1r9I
            0jJmwYrA8y8678Dj1JGG0VDjA9tzd29KOVPt3ibHtX2vK0LRdWLjSisCx1BL4Gni
            lmwORGYQRI+tBev4eaymG+g3NJ1TyWGqolKvSnAWhsI6yLETcDbYz+70CjTVW0z9
            B5yiutkBclzzTcHdDrEcDcRjvq30FPuJ7KJBDkzMyFdA0G4Dqs0MjomZmWzwPDCv
            ON9vvKO+KSAnq3T/EyJ43pdSVR6DtVQgA+6uwE9W3jfMw3+qBCe703e4YtsXfJwo
            IhNzbM8m9Yop5w==
            -----END CERTIFICATE-----
            -----BEGIN CERTIFICATE-----
            MIICRjCCAc2gAwIBAgIQC6Fa+h3foLVJRK/NJKBs7DAKBggqhkjOPQQDAzBlMQsw
            CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
            ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
            RzMwHhcNMTMwODAxMTIwMDAwWhcNMzgwMTE1MTIwMDAwWjBlMQswCQYDVQQGEwJV
            UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
            Y29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgRzMwdjAQBgcq
            hkjOPQIBBgUrgQQAIgNiAAQZ57ysRGXtzbg/WPuNsVepRC0FFfLvC/8QdJ+1YlJf
            Zn4f5dwbRXkLzMZTCp2NXQLZqVneAlr2lSoOjThKiknGvMYDOAdfVdp+CW7if17Q
            RSAPWXYQ1qAk8C3eNvJsKTmjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/
            BAQDAgGGMB0GA1UdDgQWBBTL0L2p4ZgFUaFNN6KDec6NHSrkhDAKBggqhkjOPQQD
            AwNnADBkAjAlpIFFAmsSS3V0T8gj43DydXLefInwz5FyYZ5eEJJZVrmDxxDnOOlY
            JjZ91eQ0hjkCMHw2U/Aw5WJjOpnitqM7mzT6HtoQknFekROn3aRukswy1vUhZscv
            6pZjamVFkpUBtA==
            -----END CERTIFICATE-----
            -----BEGIN CERTIFICATE-----
            MIIDrzCCApegAwIBAgIQCDvgVpBCRrGhdWrJWZHHSjANBgkqhkiG9w0BAQUFADBh
            MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
            d3cuZGlnaWNlcnQuY29tMSAwHgYDVQQDExdEaWdpQ2VydCBHbG9iYWwgUm9vdCBD
            QTAeFw0wNjExMTAwMDAwMDBaFw0zMTExMTAwMDAwMDBaMGExCzAJBgNVBAYTAlVT
            MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
            b20xIDAeBgNVBAMTF0RpZ2lDZXJ0IEdsb2JhbCBSb290IENBMIIBIjANBgkqhkiG
            9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4jvhEXLeqKTTo1eqUKKPC3eQyaKl7hLOllsB
            CSDMAZOnTjC3U/dDxGkAV53ijSLdhwZAAIEJzs4bg7/fzTtxRuLWZscFs3YnFo97
            nh6Vfe63SKMI2tavegw5BmV/Sl0fvBf4q77uKNd0f3p4mVmFaG5cIzJLv07A6Fpt
            43C/dxC//AH2hdmoRBBYMql1GNXRor5H4idq9Joz+EkIYIvUX7Q6hL+hqkpMfT7P
            T19sdl6gSzeRntwi5m3OFBqOasv+zbMUZBfHWymeMr/y7vrTC0LUq7dBMtoM1O/4
            gdW7jVg/tRvoSSiicNoxBN33shbyTApOB6jtSj1etX+jkMOvJwIDAQABo2MwYTAO
            BgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUA95QNVbR
            TLtm8KPiGxvDl7I90VUwHwYDVR0jBBgwFoAUA95QNVbRTLtm8KPiGxvDl7I90VUw
            DQYJKoZIhvcNAQEFBQADggEBAMucN6pIExIK+t1EnE9SsPTfrgT1eXkIoyQY/Esr
            hMAtudXH/vTBH1jLuG2cenTnmCmrEbXjcKChzUyImZOMkXDiqw8cvpOp/2PV5Adg
            06O/nVsJ8dWO41P0jmP6P6fbtGbfYmbW0W5BjfIttep3Sp+dWOIrWcBAI+0tKIJF
            PnlUkiaY4IBIqDfv8NZ5YBberOgOzW6sRBc4L0na4UU+Krk2U886UAb3LujEV0ls
            YSEY1QSteDwsOoBrp+uvFRTp2InBuThs4pFsiv9kuXclVzDAGySj4dzp30d8tbQk
            CAUw7C29C79Fv1C5qfPrmAESrciIxpg0X40KPMbp1ZWVbd4=
            -----END CERTIFICATE-----
            """

        let documents = try PEMDocument.parseMultiple(pemString: multiPEM)
        XCTAssertEqual(documents.count, 3)
        for document in documents {
            XCTAssertEqual(document.discriminator, "CERTIFICATE")

            let parsed = try DER.parse(document.derBytes)

            let reserialized = document.pemString

            var serializer = DER.Serializer()
            XCTAssertNoThrow(serializer.serialize(parsed))
            let reserialized2 = PEMDocument(type: "CERTIFICATE", derBytes: serializer.serializedBytes)
            XCTAssertEqual(reserialized2.pemString, reserialized)
        }
    }

    func testStraightforwardPEMParsing() throws {
        let simplePEM = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            """
        let pkey = try SEC1PrivateKey(pemEncoded: simplePEM)

        let reserialized = try pkey.serializeAsPEM().pemString
        XCTAssertEqual(reserialized, simplePEM)

        var serializer = DER.Serializer()
        XCTAssertNoThrow(try serializer.serialize(pkey))
        let reserialized2 = try SEC1PrivateKey(derEncoded: serializer.serializedBytes)
        XCTAssertEqual(try reserialized2.serializeAsPEM().pemString, simplePEM)
    }

    func testStraightforwardPEMLineEndingParsing() throws {
        let simplePEMWithLF = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            """

        let simplePEMWithCRLF = """
            -----BEGIN EC PRIVATE KEY-----\r
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49\r
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG\r
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==\r
            -----END EC PRIVATE KEY-----
            """

        let pemDocumentWithLF = try PEMDocument(pemString: simplePEMWithLF)
        let pemDocumentWithCRLF = try PEMDocument(pemString: simplePEMWithCRLF)

        XCTAssertEqual(pemDocumentWithLF.discriminator, "EC PRIVATE KEY")
        XCTAssertEqual(pemDocumentWithLF.derBytes.count, 121)

        XCTAssertEqual(pemDocumentWithCRLF.discriminator, "EC PRIVATE KEY")
        XCTAssertEqual(pemDocumentWithCRLF.derBytes.count, 121)

        XCTAssertEqual(pemDocumentWithLF.derBytes, pemDocumentWithCRLF.derBytes)
    }

    func testPEMInconsistentLineEndingParsing() throws {
        let simplePEMWithConsistentLFLineEnding = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            """

        // No carriage return \r in line 3.
        let simplePEMWithInconsistentLineEnding = """
            -----BEGIN EC PRIVATE KEY-----\r
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49\r
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==\r
            -----END EC PRIVATE KEY-----
            """

        let consistentPEMDocument = try PEMDocument(pemString: simplePEMWithConsistentLFLineEnding)
        let inconsistentPEMDocument = try PEMDocument(pemString: simplePEMWithInconsistentLineEnding)

        XCTAssertEqual(consistentPEMDocument.discriminator, "EC PRIVATE KEY")
        XCTAssertEqual(consistentPEMDocument.derBytes.count, 121)

        XCTAssertEqual(inconsistentPEMDocument.discriminator, "EC PRIVATE KEY")
        XCTAssertEqual(inconsistentPEMDocument.derBytes.count, 121)

        XCTAssertEqual(consistentPEMDocument.derBytes, inconsistentPEMDocument.derBytes)
    }

    func testStraightforwardPEMAndPrivateKeyLineEndingParsing() throws {
        let simplePEMWithLF = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            """

        let simplePEMWithCRLF = """
            -----BEGIN EC PRIVATE KEY-----\r
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49\r
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG\r
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==\r
            -----END EC PRIVATE KEY-----
            """

        let pemDocumentWithLF = try PEMDocument(pemString: simplePEMWithLF)
        let pemDocumentWithCRLF = try PEMDocument(pemString: simplePEMWithCRLF)

        let privateKeyFromPEMWithLF = try SEC1PrivateKey(pemEncoded: simplePEMWithLF)
        let privateKeyFromPEMWithCRLF = try SEC1PrivateKey(pemEncoded: simplePEMWithCRLF)

        XCTAssertEqual(privateKeyFromPEMWithLF.privateKey, privateKeyFromPEMWithCRLF.privateKey)
        XCTAssertEqual(privateKeyFromPEMWithLF.publicKey, privateKeyFromPEMWithCRLF.publicKey)

        let pemFromPKWithLF = try privateKeyFromPEMWithLF.serializeAsPEM()
        let pemFromPKWithCRLF = try privateKeyFromPEMWithCRLF.serializeAsPEM()

        XCTAssertEqual(pemDocumentWithLF.derBytes, pemFromPKWithLF.derBytes)
        XCTAssertEqual(pemDocumentWithCRLF.derBytes, pemFromPKWithCRLF.derBytes)

        XCTAssertEqual(pemFromPKWithLF.derBytes, pemFromPKWithCRLF.derBytes)
    }

    func testStraightforwardPEMAndPrivateKeyLineEndingSerialization() throws {
        let simplePEMWithLF = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            """

        let simplePEMWithCRLF = """
            -----BEGIN EC PRIVATE KEY-----\r
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49\r
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG\r
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==\r
            -----END EC PRIVATE KEY-----
            """

        let privateKeyFromPEMWithLF = try SEC1PrivateKey(pemEncoded: simplePEMWithLF)
        let privateKeyFromPEMWithCRLF = try SEC1PrivateKey(pemEncoded: simplePEMWithCRLF)

        var lfSerializer = DER.Serializer()
        var crlfSerializer = DER.Serializer()

        XCTAssertNoThrow(try lfSerializer.serialize(privateKeyFromPEMWithLF))
        XCTAssertNoThrow(try crlfSerializer.serialize(privateKeyFromPEMWithCRLF))

        XCTAssertEqual(lfSerializer.serializedBytes, crlfSerializer.serializedBytes)

        let reserializedPKWithLF = try SEC1PrivateKey(derEncoded: lfSerializer.serializedBytes)
        let reserializedPKWithCRLF = try SEC1PrivateKey(derEncoded: crlfSerializer.serializedBytes)

        XCTAssertEqual(reserializedPKWithLF.privateKey, reserializedPKWithCRLF.privateKey)
    }

    func testTruncatedPEMDocumentsAreRejected() throws {
        // We drip feed the PEM one extra character at a time. It never parses successfully.
        let simplePEM = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            """
        for index in simplePEM.indices.dropLast() {
            XCTAssertThrowsError(try PEMDocument(pemString: String(simplePEM[..<index]))) { error in
                XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
            }
            XCTAssertThrowsError(try SEC1PrivateKey(pemEncoded: String(simplePEM[..<index]))) { error in
                XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
            }
        }

        XCTAssertNoThrow(try PEMDocument(pemString: simplePEM))
        XCTAssertNoThrow(try SEC1PrivateKey(pemEncoded: simplePEM))
    }

    func testMismatchedDiscriminatorsAreRejected() throws {
        // Different discriminators is not allowed.
        let simplePEM = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PUBLIC KEY-----
            """
        XCTAssertThrowsError(try PEMDocument(pemString: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }

        XCTAssertThrowsError(try SEC1PrivateKey(pemEncoded: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }
    }

    func testOverlongLinesAreForbidden() throws {
        // This is arguably an excessive restriction, but we should try to be fairly strict here.
        let simplePEM = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzGO
            9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            """
        XCTAssertThrowsError(try PEMDocument(pemString: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }

        XCTAssertThrowsError(try SEC1PrivateKey(pemEncoded: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }
    }

    func testEarlyShortLinesAreForbidden() throws {
        // This is arguably an excessive restriction, but we should try to be fairly strict here.
        let simplePEM = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJz
            GO9zxi7HTvuXyQr7QKSBtdCGmHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            """
        XCTAssertThrowsError(try PEMDocument(pemString: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }

        XCTAssertThrowsError(try SEC1PrivateKey(pemEncoded: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }
    }

    func testEmptyPEMDocument() throws {
        let simplePEM = """
            -----BEGIN EC PRIVATE KEY-----
            -----END EC PRIVATE KEY-----
            """
        XCTAssertThrowsError(try PEMDocument(pemString: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }

        XCTAssertThrowsError(try SEC1PrivateKey(pemEncoded: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }
    }

    func testPEMDocumentWithOnlyLFNewLines() throws {
        let simplePEM = """
            -----BEGIN EC PRIVATE KEY-----


            -----END EC PRIVATE KEY-----
            """
        XCTAssertThrowsError(try PEMDocument(pemString: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }

        XCTAssertThrowsError(try SEC1PrivateKey(pemEncoded: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }
    }

    func testPEMDocumentWithOnlyCRLFNewLines() throws {
        let simplePEM = """
            -----BEGIN EC PRIVATE KEY-----\r
            \r
            \r
            -----END EC PRIVATE KEY-----
            """
        XCTAssertThrowsError(try PEMDocument(pemString: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }

        XCTAssertThrowsError(try SEC1PrivateKey(pemEncoded: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }
    }

    func testInvalidBase64IsForbidden() throws {
        let simplePEM = """
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIBHli4jaj+JwWQlU0yhZUu+TdMPVhZ3wR2PS416Sz/K/oAoGCCqGSM49
            AwEHoUQDQgAEOhvJhbc3zM4SJooCaWdyheY2E6wWkISg7TtxJYgb/S0Zz7WruJzG
            O9zxi7HTvuXyQr7QKSBtdC%mHym+WoPsbA==
            -----END EC PRIVATE KEY-----
            """
        XCTAssertThrowsError(try PEMDocument(pemString: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }

        XCTAssertThrowsError(try SEC1PrivateKey(pemEncoded: simplePEM)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidPEMDocument)
        }
    }

    func testAllowSingleComponentOIDs() throws {
        // This is an encoded OID that has only one subcomponent, 0.
        let singleComponentOID: [UInt8] = [0x06, 0x01, 0x00]
        let parsed = try ASN1ObjectIdentifier(derEncoded: singleComponentOID)
        XCTAssertEqual(parsed, [0, 0])
    }

    func testRejectZeroComponentOIDs() throws {
        // This is an encoded OID that has no subcomponents..
        let zeroComponentOID: [UInt8] = [0x06, 0x00]
        let parsed = try DER.parse(zeroComponentOID)
        XCTAssertThrowsError(try ASN1ObjectIdentifier(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testAllowNonOctetNumberOfBitsInBitstring() throws {
        for i in 1..<8 {
            let lastByte = (UInt8.max << i)
            let weirdBitString = [0x03, 0x02, UInt8(i), lastByte]
            let parsed = try DER.parse(weirdBitString)
            let string = try ASN1BitString(derEncoded: parsed)
            XCTAssertEqual(string.paddingBits, i)
            XCTAssertEqual(string.bytes, [lastByte])
        }
    }

    func testBitstringWithPaddingBitsSetTo1() throws {
        for i in 1..<8 {
            let weirdBitString = [0x03, 0x02, UInt8(i), 0xFF]
            let parsed = try DER.parse(weirdBitString)
            XCTAssertThrowsError(try ASN1BitString(derEncoded: parsed)) { error in
                XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
            }
        }
    }

    func testBitstringWithNoContent() throws {
        // We don't allow bitstrings with no content.
        let weirdBitString: [UInt8] = [0x03, 0x00]
        let parsed = try DER.parse(weirdBitString)
        XCTAssertThrowsError(try ASN1BitString(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testEmptyBitstring() throws {
        // Empty bitstrings must have their leading byte set to 0.
        var bitString: [UInt8] = [0x03, 0x01, 0x00]
        let parsed = try DER.parse(bitString)
        let bs = try ASN1BitString(derEncoded: parsed)
        XCTAssertEqual(bs.bytes, [])

        for i in 1..<8 {
            bitString[2] = UInt8(i)
            let parsed = try DER.parse(bitString)
            XCTAssertThrowsError(try ASN1BitString(derEncoded: parsed)) { error in
                XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
            }
        }
    }

    func testIntegerZeroRequiresAZeroByte() throws {
        // Integer zero requires a leading zero byte.
        let weirdZero: [UInt8] = [0x02, 0x00]
        let parsed = try DER.parse(weirdZero)
        XCTAssertThrowsError(try Int(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1IntegerEncoding)
        }
    }

    func testLeadingZero() throws {
        // We should reject integers that have unnecessary leading zero bytes.
        let overlongOne: [UInt8] = [0x02, 0x02, 0x00, 0x01]
        let parsed = try DER.parse(overlongOne)
        XCTAssertThrowsError(try Int(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1IntegerEncoding)
        }
    }

    func testLeadingOnes() throws {
        // We should reject integers that have unnecessary leading one bytes. This is supposed to be a -127, but we encode it as though it
        // were an Int16.
        let overlongOneTwoSeven: [UInt8] = [0x02, 0x02, 0xFF, 0x81]
        let parsed = try DER.parse(overlongOneTwoSeven)
        XCTAssertThrowsError(try Int(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1IntegerEncoding)
        }
    }

    func testNotConsumingTaggedObject() throws {
        // We should error if there are two nodes inside an explicitly tagged object.
        let weirdASN1: [UInt8] = [
            0x30, 0x08,  // Sequence, containing...
            0xA2, 0x06,  // Context specific tag 2, 3 byte body, containing...
            0x02, 0x01, 0x00,  // Integer 0 and
            0x02, 0x01, 0x01,  // Integer 1

        ]
        let parsed = try DER.parse(weirdASN1)
        try DER.sequence(parsed, identifier: .sequence) { nodes in
            XCTAssertThrowsError(
                try DER.optionalExplicitlyTagged(&nodes, tagNumber: 2, tagClass: .contextSpecific, { _ in })
            ) { error in
                XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
            }
        }
    }

    func testPrimitiveTaggedObject() throws {
        // We should error if primitive encoding is used for an explicitly tagged object.
        let weirdASN1: [UInt8] = [
            0x30, 0x05,  // Sequence, containing...
            0x82, 0x03,  // Context specific tag 2, 3 byte body, containing...
            0x02, 0x01, 0x00,  // Integer 0
        ]
        let parsed = try DER.parse(weirdASN1)
        try DER.sequence(parsed, identifier: .sequence) { nodes in
            XCTAssertThrowsError(
                try DER.optionalExplicitlyTagged(&nodes, tagNumber: 2, tagClass: .contextSpecific, { _ in })
            ) { error in
                XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
            }
        }
    }

    func testSPKIWithUnexpectedKeyTypeOID() throws {
        // This is an SPKI object for RSA instead of EC. This is a 1024-bit RSA key, so hopefully no-one will think to use it.
        let rsaSPKI =
            "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDQEcP8qgwq5JhGgl1mKMeOWbb0WFKkJKj4Tvm4RFWGKDYg/p+Fm8vHwPSICqU9HJ+dHF2Ty0M6WVwVlf6RJdJGsrp1s9cbxfc/74PdQUssIhUjhlBO2RFlQECbgNpw5UleRB9FLnEDp33qMgdr7nwXiYCTjd04QSkdU3mXJYrFfwIDAQAB"
        let decodedSPKI = Array(Data(base64Encoded: rsaSPKI)!)

        var serializer = DER.Serializer()
        serializer.appendPrimitiveNode(identifier: .null) { _ in }
        let null = serializer.serializedBytes

        let parsed = try DER.parse(decodedSPKI)
        let spki = try SubjectPublicKeyInfo(derEncoded: parsed)
        XCTAssertEqual(spki.algorithmIdentifier.algorithm, [1, 2, 840, 113549, 1, 1, 1])  // RSA encryption

        serializer = DER.Serializer()
        try serializer.serialize(spki.algorithmIdentifier.parameters!)
        XCTAssertEqual(serializer.serializedBytes, null)

        let expectedKey: ArraySlice<UInt8> = [
            48, 129, 137, 2, 129, 129, 0, 208, 17, 195, 252, 170, 12, 42, 228, 152,
            70, 130, 93, 102, 40, 199, 142, 89, 182, 244, 88, 82, 164, 36, 168, 248,
            78, 249, 184, 68, 85, 134, 40, 54, 32, 254, 159, 133, 155, 203, 199, 192,
            244, 136, 10, 165, 61, 28, 159, 157, 28, 93, 147, 203, 67, 58, 89, 92,
            21, 149, 254, 145, 37, 210, 70, 178, 186, 117, 179, 215, 27, 197, 247,
            63, 239, 131, 221, 65, 75, 44, 34, 21, 35, 134, 80, 78, 217, 17, 101, 64, 64, 155, 128, 218, 112, 229, 73,
            94, 68, 31, 69, 46, 113, 3, 167, 125,
            234, 50, 7, 107, 238, 124, 23, 137, 128, 147, 141, 221, 56, 65, 41, 29,
            83, 121, 151, 37, 138, 197, 127, 2, 3, 1, 0, 1,
        ]
        XCTAssertEqual(spki.key.bytes, expectedKey)
    }

    func testSPKIWithUnsupportedCurve() throws {
        // This is an EC SPKI object with an unsupported named curve.
        let b64SPKI =
            "MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEzN09Sbb+mhMIlUbOdoIoND8lNcoQPd/yZDjQi1IDyDQEvVvz1yhi5J0FPLAlM3hE2o/a+rASUz2UP4fX5Cpnxw=="
        let decodedSPKI = Array(Data(base64Encoded: b64SPKI)!)

        let parsed = try DER.parse(decodedSPKI)
        let spki = try SubjectPublicKeyInfo(derEncoded: parsed)
        XCTAssertEqual(spki.algorithmIdentifier.algorithm, .AlgorithmIdentifier.idEcPublicKey)
        XCTAssertEqual(try ASN1ObjectIdentifier(asn1Any: spki.algorithmIdentifier.parameters!), [1, 3, 132, 0, 10])

        let expectedKey: ArraySlice<UInt8> = [
            4, 204, 221, 61, 73, 182, 254, 154, 19, 8, 149, 70, 206, 118, 130, 40,
            52, 63, 37, 53, 202, 16, 61, 223, 242, 100, 56, 208, 139, 82, 3, 200,
            52, 4, 189, 91, 243, 215, 40, 98, 228, 157, 5, 60, 176, 37, 51, 120, 68,
            218, 143, 218, 250, 176, 18, 83, 61, 148, 63, 135, 215, 228, 42, 103,
            199,
        ]
        XCTAssertEqual(spki.key.bytes, expectedKey)
    }

    func testSEC1PrivateKeyWithUnknownVersion() throws {
        // This is the beginning of a SEC1 private key with hypothetical version number 5. We should reject it
        let weirdSEC1: [UInt8] = [0x30, 0x03, 0x02, 0x01, 0x05]

        let parsed = try DER.parse(weirdSEC1)
        XCTAssertThrowsError(try SEC1PrivateKey(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testSEC1PrivateKeyUnsupportedKeyType() throws {
        // This is an EC SPKI object with an unsupported named curve.
        let b64SEC1 =
            "MHQCAQEEINIuVmNF7g1wNCJWXDpgL+09jATtaS1n0SxqqQneHi+woAcGBSuBBAAKoUQDQgAEB7v/p7gvuV0aDx02EF6a+pr563p+FzRJXI+COWHdr+XRcjg6vEi4n3Jj7ksmEg4t1x6E1xFyTvF3eV/B/XVXbw=="
        let decodedSEC1 = Array(Data(base64Encoded: b64SEC1)!)

        let parsed = try DER.parse(decodedSEC1)
        XCTAssertThrowsError(try SEC1PrivateKey(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testPKCS8KeyWithNonMatchingKeyOIDS() throws {
        // This is a stubbed PKCS8 key with mismatched OIDs in the inner and outer payload. We have to serialize it out, sadly.
        var serializer = DER.Serializer()
        try serializer.appendConstructedNode(identifier: .sequence) { coder in
            try coder.serialize(0)
            try coder.serialize(RFC5480AlgorithmIdentifier.ecdsaP256)

            var subCoder = DER.Serializer()
            // We won't notice these are empty either, but we will notice the algo mismatch.
            try subCoder.serialize(SEC1PrivateKey(privateKey: [], algorithm: .ecdsaP384, publicKey: []))
            let serializedKey = ASN1OctetString(contentBytes: subCoder.serializedBytes[...])

            try coder.serialize(serializedKey)
        }

        let parsed = try DER.parse(serializer.serializedBytes)
        XCTAssertThrowsError(try PKCS8PrivateKey(derEncoded: parsed)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testNodeSlices() throws {
        // This is an SPKI object for RSA instead of EC. This is a 1024-bit RSA key, so hopefully no-one will think to use it.
        let rsaSPKI =
            "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDQEcP8qgwq5JhGgl1mKMeOWbb0WFKkJKj4Tvm4RFWGKDYg/p+Fm8vHwPSICqU9HJ+dHF2Ty0M6WVwVlf6RJdJGsrp1s9cbxfc/74PdQUssIhUjhlBO2RFlQECbgNpw5UleRB9FLnEDp33qMgdr7nwXiYCTjd04QSkdU3mXJYrFfwIDAQAB"
        let decodedSPKI = Array(Data(base64Encoded: rsaSPKI)!)

        let parsed = try DER.parse(decodedSPKI)
        XCTAssertEqual(parsed.encodedBytes, decodedSPKI[...])

        guard case .constructed(let firstLayerChildren) = parsed.content else {
            XCTFail("Unexpected node")
            return
        }
        var iterator = firstLayerChildren.makeIterator()
        guard let algorithmId = iterator.next(), let key = iterator.next() else {
            XCTFail("Invalid number of children")
            return
        }
        XCTAssertNil(iterator.next())

        // Initial offset of the algorithm ID is 3 (3 bytes of encoding for the parent sequence),
        // the sequence itself is 13 bytes long, and there are 2 bytes of length and tag. End offset
        // is therefore 3 + 13 + 2 == 18.
        XCTAssertEqual(algorithmId.encodedBytes, decodedSPKI[3..<18])

        // Initial offset of the key immediately follows the algorithm ID, so it's 18. It contains the bytes
        // up to the end.
        XCTAssertEqual(key.encodedBytes, decodedSPKI[18...])

        guard case .constructed(let algorithmIDChildren) = algorithmId.content else {
            XCTFail("Invalid content for algorithm ID node")
            return
        }
        iterator = algorithmIDChildren.makeIterator()

        guard let oid = iterator.next(), let null = iterator.next() else {
            XCTFail("Invalid algorithm ID content")
            return
        }

        // The oid begins at offset 5: 3 bytes for the outer sequence tag/length, 2 bytes for the inner sequence tag/length.
        // The oid itself has a 2 byte tag/length combo and a 9 byte length, leaving its end index as 5 + 2 + 9 == 16
        XCTAssertEqual(oid.encodedBytes, decodedSPKI[5..<16])

        // The null is 2 bytes long.
        XCTAssertEqual(null.encodedBytes, decodedSPKI[16..<18])
    }

    func testOptionalImplicitlyTaggedWithCustomTag() throws {
        var serializer = DER.Serializer()
        try serializer.appendConstructedNode(identifier: .sequence) { serializer in
            try serializer.serializeOptionalImplicitlyTagged(
                1,
                withIdentifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific)
            )
        }
        let bytes = serializer.serializedBytes

        XCTAssertEqual(bytes, [0x30, 0x03, 0x81, 0x1, 0x1])

        let parseResult = try DER.parse(bytes)
        let int: Int? = try DER.sequence(parseResult, identifier: .sequence) { nodes in
            try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific))
        }
        XCTAssertEqual(int, 1)
    }

    func testOptionalImplicitlyTaggedWithBuilder() throws {
        var serializer = DER.Serializer()
        try serializer.appendConstructedNode(identifier: .sequence) { serializer in
            try serializer.serializeOptionalImplicitlyTagged(
                1,
                withIdentifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific)
            )
        }
        let bytes = serializer.serializedBytes

        XCTAssertEqual(bytes, [0x30, 0x03, 0x81, 0x1, 0x1])

        let parseResult = try DER.parse(bytes)
        let int = try DER.sequence(parseResult, identifier: .sequence) { nodes in
            try DER.optionalImplicitlyTagged(&nodes, tagNumber: 1, tagClass: .contextSpecific) { node in
                try Int(derEncoded: node, withIdentifier: .init(tagWithNumber: 1, tagClass: .contextSpecific))
            }
        }
        XCTAssertEqual(int, 1)
    }

    func testPrintingOIDs() {
        let oid: ASN1ObjectIdentifier = [1, 2, 865, 11241, 3]
        let s = String(describing: oid)
        XCTAssertEqual(s, "1.2.865.11241.3")
    }

    func testPrintingASN1Any() throws {
        let any = try ASN1Any(erasing: ASN1Null())
        let s = String(describing: any)
        XCTAssertEqual(s, "ASN1Any([5, 0])")
    }

    func testOIDArrayInitializer() {
        let oidArray = try! ASN1ObjectIdentifier(elements: [1, 2, 865, 11241, 3])
        XCTAssertEqual(oidArray.oidComponents, [1, 2, 865, 11241, 3])

        let anotherOidArray = try! ASN1ObjectIdentifier(elements: [1, 2, 865])
        XCTAssertEqual(anotherOidArray.oidComponents, [1, 2, 865])
    }

    func testOIDArrayInitializerInvalid() {
        XCTAssertThrowsError(try ASN1ObjectIdentifier(elements: [1])) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .tooFewOIDComponents)
        }

        XCTAssertThrowsError(try ASN1ObjectIdentifier(elements: [])) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .tooFewOIDComponents)
        }
    }

    func testOIDStringInitializer() {
        let oidFromString: ASN1ObjectIdentifier = "1.2.865.11241.3"
        let oidFromArrayLiteral: ASN1ObjectIdentifier = [1, 2, 865, 11241, 3]

        XCTAssertEqual(oidFromString, oidFromArrayLiteral)
        XCTAssertEqual(oidFromString.oidComponents, [1, 2, 865, 11241, 3])
    }

    func testOIDStringInitializerInvalid() {
        XCTAssertThrowsError(try ASN1ObjectIdentifier(dotRepresentation: "1..2.865.11241.3")) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidStringRepresentation)
        }

        XCTAssertThrowsError(try ASN1ObjectIdentifier(dotRepresentation: "1.2.<invalid>.11241.3")) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidStringRepresentation)
        }

        XCTAssertThrowsError(try ASN1ObjectIdentifier(dotRepresentation: "25")) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .tooFewOIDComponents)
        }
    }

    func testSetOfSingleElement() throws {
        var serializer = DER.Serializer()
        try serializer.serializeSetOf([
            ASN1BitString(bytes: [1])
        ])
        XCTAssertEqual(serializer.serializedBytes, [49, 4, 3, 2, 0, 1])
        let bitStrings = try DER.set(
            of: ASN1BitString.self,
            identifier: .set,
            rootNode: try DER.parse(serializer.serializedBytes)
        )
        XCTAssertEqual(
            bitStrings,
            [
                ASN1BitString(bytes: [1])
            ]
        )
    }

    func testSetOfTwoElementsInOrder() throws {
        var serializer = DER.Serializer()
        try serializer.serializeSetOf([
            ASN1BitString(bytes: [1]),
            ASN1BitString(bytes: [2]),
        ])
        XCTAssertEqual(serializer.serializedBytes, [49, 8, 3, 2, 0, 1, 3, 2, 0, 2])

        let bitStrings = try DER.set(
            of: ASN1BitString.self,
            identifier: .set,
            rootNode: try DER.parse(serializer.serializedBytes)
        )
        XCTAssertEqual(
            bitStrings,
            [
                ASN1BitString(bytes: [1]),
                ASN1BitString(bytes: [2]),
            ]
        )
    }

    func testSetOfTwoElementNotInOrder() throws {
        var serializer = DER.Serializer()
        try serializer.serializeSetOf([
            ASN1BitString(bytes: [2]),
            ASN1BitString(bytes: [1]),
        ])
        XCTAssertEqual(serializer.serializedBytes, [49, 8, 3, 2, 0, 1, 3, 2, 0, 2])

        let bitStrings = try DER.set(
            of: ASN1BitString.self,
            identifier: .set,
            rootNode: try DER.parse(serializer.serializedBytes)
        )
        XCTAssertEqual(
            bitStrings,
            [
                ASN1BitString(bytes: [1]),
                ASN1BitString(bytes: [2]),
            ]
        )
    }
    func testSetOfTwoEqualElements() throws {
        var serializer = DER.Serializer()
        try serializer.serializeSetOf([
            ASN1BitString(bytes: [1]),
            ASN1BitString(bytes: [1]),
        ])
        XCTAssertEqual(serializer.serializedBytes, [49, 8, 3, 2, 0, 1, 3, 2, 0, 1])

        let bitStrings = try DER.set(
            of: ASN1BitString.self,
            identifier: .set,
            rootNode: try DER.parse(serializer.serializedBytes)
        )
        XCTAssertEqual(
            bitStrings,
            [
                ASN1BitString(bytes: [1]),
                ASN1BitString(bytes: [1]),
            ]
        )
    }
    func testSetOfTwoElementsOrderedIncorrectly() throws {
        let rootNode = try DER.parse([49, 8, 3, 2, 0, 2, 3, 2, 0, 1])
        XCTAssertThrowsError(try DER.set(of: ASN1BitString.self, identifier: .set, rootNode: rootNode)) { error in
            XCTAssertEqual((error as? ASN1Error)?.code, .invalidASN1Object)
        }
    }

    func testASN1SetOfOrder() {
        func assertSetOfLessThanOrEqual(
            _ lhs: ArraySlice<UInt8>,
            _ rhs: ArraySlice<UInt8>,
            file: StaticString = #filePath,
            line: UInt = #line
        ) {
            XCTAssert(
                asn1SetElementLessThanOrEqual(lhs, rhs),
                "\(lhs) is not less than or equal to \(rhs)",
                file: file,
                line: line
            )
        }
        assertSetOfLessThanOrEqual([1], [1])
        assertSetOfLessThanOrEqual([1], [2])
        assertSetOfLessThanOrEqual([1, 0], [1])
        assertSetOfLessThanOrEqual([1, 0], [2])
        assertSetOfLessThanOrEqual([1, 0], [1, 0])
        assertSetOfLessThanOrEqual([1, 0], [2, 0])
    }

    func testSerializingRawBytes() {
        var serializer = DER.Serializer()
        serializer.serializeRawBytes([1, 2, 3, 4])

        XCTAssertEqual(serializer.serializedBytes, [1, 2, 3, 4])

        // A more complex example to prove that we can add the raw bytes at arbitrary locations.
        serializer = DER.Serializer()
        serializer.appendConstructedNode(identifier: .sequence) { serializer in
            serializer.serialize(explicitlyTaggedWithTagNumber: 1, tagClass: .contextSpecific) { serializer in
                serializer.serializeRawBytes([1, 2, 3, 4])
            }
            serializer.serialize(explicitlyTaggedWithTagNumber: 2, tagClass: .contextSpecific) { _ in }
        }

        XCTAssertEqual(
            serializer.serializedBytes,
            [0x30, 0x8, 0xA1, 0x04, 0x01, 0x2, 0x03, 0x04, 0xA2, 0x00]
        )
    }

    func testParseBEREncodedCMSContentInfo() throws {
        let encodedCMSContentInfo =
            "MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCCAuQwggLgMIIChqADAgECAhABIEfn+B9M5cVAee4myiEiMAoGCCqGSM49BAMCME0xKTAnBgNVBAMMIEFwcGxlIENvcnBvcmF0ZSBTaWduaW5nIEVDQyBDQSAxMRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUzAeFw0yMzA3MTcyMjM0MDVaFw0yMzA4MDcyMjQ0MDVaMC8xEzARBgNVBAoMCkFwcGxlIEluYy4xGDAWBgNVBAMMD2R6ZWNoQGFwcGxlLmNvbTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABIWQLS6NnPfb8TjlkUU/uRN7FFWIAi7gMRmvA78bUUudor7UGWJ6NB9y1C8TFXpEp5VG+2OSW4D6epwrG6mpaCOjggFkMIIBYDAMBgNVHRMBAf8EAjAAMB8GA1UdIwQYMBaAFEJi3AGoy1MCpVzt8IjG9uFJdhE9MHMGCCsGAQUFBwEBBGcwZTAvBggrBgEFBQcwAoYjaHR0cDovL2NlcnRzLmFwcGxlLmNvbS9hY3NlY2NhMS5kZXIwMgYIKwYBBQUHMAGGJmh0dHA6Ly9vY3NwLmFwcGxlLmNvbS9vY3NwMDMtYWNzZWNjMTA0MBoGA1UdEQQTMBGBD2R6ZWNoQGFwcGxlLmNvbTAUBgNVHSUEDTALBgkqhkiG92NkBBQwMgYDVR0fBCswKTAnoCWgI4YhaHR0cDovL2NybC5hcHBsZS5jb20vYWNzZWNjYTEuY3JsMB0GA1UdDgQWBBTQgwTEnqIhsk9OoQOYYmhj0g7RVTAOBgNVHQ8BAf8EBAMCB4AwJQYDVR0gBB4wHDAMBgoqhkiG92NkBRQBMAwGCiqGSIb3Y2QFFAIwCgYIKoZIzj0EAwIDSAAwRQIhAOd9mU6wS6FLR8TTo8q7qBDbatEevBWXAm5/Ek7nWVU6AiA8oa8GQ6h+OxioJy0Frq2p++UzEdAIw2MLtGN218HuUTGCATgwggE0AgEBMGEwTTEpMCcGA1UEAwwgQXBwbGUgQ29ycG9yYXRlIFNpZ25pbmcgRUNDIENBIDExEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTAhABIEfn+B9M5cVAee4myiEiMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjMwNzIwMjMyMzA5WjAvBgkqhkiG9w0BCQQxIgQgWJG1tSLV3whtD/CxEPvZ0hu0/HFjrzTQgoai6Eb2vgMwCQYHKoZIzj0CAQRHMEUCIQDc9v1VYHfMws7VJpHF0W8wN77QPzYiCtGSfuGKlLiZ3AIgHaPdG8dUuQeiJhO57mhqbJXiKK9tg4dise9HrjBYHPEAAAAAAAA="

        let decodedCMSContentInfo = Array(Data(base64Encoded: encodedCMSContentInfo)!)
        let result = try BER.parse(decodedCMSContentInfo)
        let pkcs7OID = ASN1ObjectIdentifier(arrayLiteral: 1, 2, 840, 113549, 1, 7, 2)

        let cmsContentInfo = try CMSContentInfo(berEncoded: result)
        XCTAssertEqual(cmsContentInfo.contentType, pkcs7OID)

        XCTAssertThrowsError(try DER.parse(decodedCMSContentInfo)) { error in
            XCTAssertEqual((error as! ASN1Error).code, ASN1Error.ErrorCode.unsupportedFieldLength)
        }
    }

    func testParseBEREncodedOctetString() throws {
        let berOctetString: [UInt8] = [
            0x24, 0x80,  // indefinite construcuted Octet String
            0x04, 0x01, 0xfe,  // primitive Octet String: [0xFE]
            0x24, 0x80,  // indefinite constructed Octet String
            0x04, 0x01, 0xed,  // primitive Octet String; [0xED]
            0x00, 0x00,  // indefinite end marker
            0x04, 0x02, 0xfa, 0xce,
            0x00, 0x00,
        ]
        let asn1OctetString = try ASN1OctetString(berEncoded: try BER.parse(berOctetString))
        XCTAssertEqual(asn1OctetString.bytes, [0xFE, 0xED, 0xFA, 0xCE])
        XCTAssertThrowsError(try DER.parse(berOctetString))
    }

    func testConstructedBoolean() throws {
        let weirdASN1: [UInt8] = [0x21, 0x00]
        let node = try DER.parse(weirdASN1)
        XCTAssertThrowsError(try Bool(berEncoded: node))
        XCTAssertThrowsError(try Bool(derEncoded: node))
    }

    func testConstructedInteger() throws {
        let weirdASN1: [UInt8] = [0x22, 0x00]
        let node = try DER.parse(weirdASN1)
        XCTAssertThrowsError(try Int(berEncoded: node))
        XCTAssertThrowsError(try Int(derEncoded: node))
    }

    func testConstructedBitString() throws {
        let weirdASN1: [UInt8] = [0x23, 0x08, 0x03, 0x02, 0x00, 0xAB, 0x03, 0x02, 0x04, 0xC]
        let node = try DER.parse(weirdASN1)
        // Not yet supported
        // XCTAssertEqual(try ASN1BitString(berEncoded: node), ASN1BitString(bytes: [0xAB, 0xC], paddingBits: 4))
        XCTAssertThrowsError(try ASN1BitString(berEncoded: node))
        XCTAssertThrowsError(try ASN1BitString(derEncoded: node))
    }

    func testConstructedOctetString() throws {
        let weirdASN1: [UInt8] = [0x24, 0x06, 0x04, 0x01, 0xAB, 0x04, 0x01, 0xCD]
        let node = try DER.parse(weirdASN1)
        XCTAssertEqual(try ASN1OctetString(berEncoded: node), ASN1OctetString(contentBytes: [0xAB, 0xCD]))
        XCTAssertThrowsError(try ASN1OctetString(derEncoded: node))
    }

    func testConstructedNull() throws {
        let weirdASN1: [UInt8] = [0x25, 0x00]
        let node = try DER.parse(weirdASN1)
        XCTAssertThrowsError(try ASN1Null(berEncoded: node))
        XCTAssertThrowsError(try ASN1Null(derEncoded: node))
    }

    func testConstructedOID() throws {
        let weirdASN1: [UInt8] = [0x26, 0x03, 0x02, 0x01, 0x00]
        let node = try DER.parse(weirdASN1)
        XCTAssertThrowsError(try ASN1ObjectIdentifier(berEncoded: node))
        XCTAssertThrowsError(try ASN1ObjectIdentifier(derEncoded: node))
    }
}
