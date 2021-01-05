# ``SwiftASN1``

An implementation of ASN.1 types and DER serialization.

## Overview

ASN.1, and the DER encoding scheme, is a commonly used object serialization format. The most common use-cases for ASN.1 in
general computing are in the cryptographic space, but there are a number of use-cases in a wide range of fields. This module
provides an implementation of a number of ASN.1 types, as well as the DER serialization format for ASN.1.

ASN.1 can be used abstractly to describe essentially any kind of object. ASN.1 objects are made up of either primitive or
composite (called "constructed") types. Individual scalar objects can be combined into aggregate types, and composed essentially
arbitrarily to form abstract object formats.

Importantly, the ASN.1 object description does not define a specific encoding for these objects. Instead there are a wide range
of possible ways to serialize or deserialize an ASN.1 object. Some of the most prominent are BER (the Basic Encoding Rules),
CER (the Canonical Encoding Rules), DER (the Distinguished Encoding Rules), and XER (the XML Encoding Rules). For the cryptographic
use-case DER is the standard choice, as a given ASN.1 object can be encoded in only one way under DER. This makes signing and verifying
vastly easier, as it is at least in principle possible to perfectly reconstruct the serialization of a parsed object.

This module provides several moving pieces:

1. A high-level representation of an ASN.1 object, in the form of a tree of object nodes (``ASN1/ASN1Node``).
2. A DER parser that can construct the ASN.1 tree from serialized bytes (``ASN1/parse(_:)-41gug``).
3. A DER serializer that can construct serialized bytes from the ASN.1 tree (``ASN1/Serializer``).
4. A number of built-in ASN.1 types, representing common constructs.

These moving pieces combine to provide support for the DER representation of ASN.1 suitable for a wide range of cryptographic uses.

## Topics

### Articles

- <doc:DecodingASN1>

### Parsing DER

- ``ASN1/parse(_:)-41gug``
- ``ASN1/parse(_:)-8ar01``
- ``ASN1Parseable``
- ``ASN1Serializable``
- ``ASN1ImplicitlyTaggable``
- ``ASN1/sequence(_:identifier:_:)``
- ``ASN1/sequence(of:identifier:rootNode:)``
- ``ASN1/sequence(of:identifier:nodes:)``
- ``ASN1/set(_:identifier:_:)``
- ``ASN1/decodeDefault(_:identifier:defaultValue:_:)``
- ``ASN1/decodeDefaultExplicitlyTagged(_:tagNumber:tagClass:defaultValue:_:)``
- ``ASN1/decodeDefault(_:defaultValue:)``
- ``ASN1/decodeDefault(_:identifier:defaultValue:)``
- ``ASN1/decodeDefaultExplicitlyTagged(_:tagNumber:tagClass:defaultValue:)``
- ``ASN1/optionalExplicitlyTagged(_:tagNumber:tagClass:_:)``
- ``ASN1/optionalImplicitlyTagged(_:tag:)``
- ``ASN1/explicitlyTagged(_:tagNumber:tagClass:_:)-6iqvq``
- ``ASN1/explicitlyTagged(_:tagNumber:tagClass:_:)-4ystp``

### Serializing DER

- ``ASN1/Serializer``
- ``ASN1Serializable``
- ``ASN1ImplicitlyTaggable``

### Representing ASN.1 types

- ``ASN1/ASN1Node``
- ``ASN1/ASN1NodeCollection``
- ``ASN1/ASN1Identifier``

### Built-in ASN.1 types

- ``ASN1IntegerRepresentable``
- ``IntegerBytesCollection``
- ``ASN1/GeneralizedTime``
- ``ASN1/ASN1BitString``
- ``ASN1/UTCTime``
- ``ASN1/ASN1OctetString``
- ``ASN1/ASN1Any``
- ``ASN1/ASN1Null``
- ``ASN1/ASN1ObjectIdentifier``
- ``ASN1/ASN1UTF8String``
- ``ASN1/ASN1PrintableString``
- ``ASN1/ASN1BMPString``
- ``ASN1/ASN1IA5String``
- ``ASN1/ASN1TeletexString``
- ``ASN1/ASN1UniversalString``
