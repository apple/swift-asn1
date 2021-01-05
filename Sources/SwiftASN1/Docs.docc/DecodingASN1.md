# Encoding and Decoding DER

Serialize and deserialize objects from DER format.

## Overview

When working with your own ASN.1 types, the biggest problem you'll have is writing the code to serialize and deserialize them from DER format.
This module does not provide an ASN.1 compiler which can automatically synthesise this code for you. Instead, you have to write it yourself.
This is some unfortunate boilerplate, but the good news is that it's straightforward enough that you'll get it done in no time.

By way of a worked example, we can build up a few types in increasing complexity.

## ECDSA Signature

Our starting point is the ECDSA signature type, defined like this:

```
ECDSASignature ::= SEQUENCE {
  r INTEGER,
  s INTEGER }
```

This defines `ECDSASignature` as a `SEQUENCE` of two `INTEGER` values.

In ASN.1, `SEQUENCE` is often used to define a record type. This is much like a Swift `struct`: an ordered series of named fields, often
of different types. That makes a `struct` the natural representation for our `ECDSASignature` type:

```swift
struct ECDSASignature {

}
```

### Storing Fields

Our next problem is to work out the fields we want to store in our type. A natural choice might be `Int`, but some more careful reading will
clue us in to the fact that an ASN.1 `INTEGER` type is of arbitrary size. In the case of ECDSA signatures, these can be very large: 32 bytes
large or more! These won't fit into `Int`.

To address this issue, ``SwiftASN1`` defines two helpers. The first is a protocol, ``ASN1IntegerRepresentable``. This allows users that have
access to a preferred arbitrary-precision integer type to decode directly to that type. The second is a conformance of `ArraySlice<UInt8>` to
``ASN1IntegerRepresentable``. This conformance allows us to just store the raw big-endian bytes of the INTEGER fields without needing to
define an arbitrary-precision integer ourselves. As we mostly care about these numbers as arbitrary byte sequences, we'll use this
escape hatch.

```swift
struct ECDSASignature {
    var r: ArraySlice<UInt8>

    var s: ArraySlice<UInt8>

    init(r: ArraySlice<UInt8>, s: ArraySlice<UInt8>) {
        self.r = r
        self.s = s
    }
}
```

### Decoding from DER

To decode from DER, we'll need to implement ``ASN1Parseable``. As this is a `SEQUENCE` type, however, we can safely implement
``ASN1ImplicitlyTaggable``. Most types can do so, especially anything that is a `SEQUENCE` type.

To conform we need to implement the protocol requirement ``ASN1ImplicitlyTaggable/init(asn1Encoded:withIdentifier:)-iudo``. This function
will pass us a pair of arguments. The first is the ``ASN1/ASN1Node`` representing the root of the ASN.1 object tree we've been asked to parse
the `ECDSASignature` from. The second is the ``ASN1/ASN1Identifier`` we expect to have this node to have. In many cases this will be
``ASN1/ASN1Identifier/sequence``, but we will happily use whatever we're told to.

The first trick is to unwrap the `SEQUENCE`. To do that, we can use ``ASN1/sequence(_:identifier:_:)``. This checks whether the ``ASN1/ASN1Node``
we pass to it has the right ``ASN1/ASN1Identifier`` and that it is a constructed node. Assuming all those checks pass, our builder function
will be invoked with an ``ASN1/ASN1NodeCollection/Iterator`` that contains the nodes within the `SEQUENCE`.

This initial scaffolding will look like this:

```swift
extension ECDSASignature: ASN1ImplicitlyTaggable {
    init(asn1Encoded rootNode: ASN1.ASN1Node, withIdentifier identifier: ASN1.ASN1Identifier) throws {
        self = try ASN1.sequence(rootNode, identifier: identifier) { nodes in
            // TODO
        }
    }
}
```

Next, we need to decode the constituent objects. This is where the recursive nature of ASN.1 works in our favour. These sub-objects
(in this case of ASN.1 type `INTEGER`) are themselves described as trees of ASN.1 nodes. For `INTEGER` specifically this tree will
only have a root node, but in general all ASN.1 objects can be parsed from a single root node.

Fortunately for us, this is exactly the interface that ``ASN1Parseable`` provides us. So we can safely recurse into the child objects using
the helper method ``ASN1Parseable/init(asn1Encoded:)-5tkco``. This handy method will even take care of consuming the node from the iterator for us.
The result is a method body that looks like this:

```swift
init(asn1Encoded rootNode: ASN1.ASN1Node, withIdentifier identifier: ASN1.ASN1Identifier) throws {
    self = try ASN1.sequence(rootNode, identifier: identifier) { nodes in
        let r = try ArraySlice<UInt8>(asn1Encoded: &nodes)
        let s = try ArraySlice<UInt8>(asn1Encoded: &nodes)

        return ECDSASignature(r: r, s: s)
    }
}
```

Note that we don't need to confirm the exact length of the ``ASN1/ASN1NodeCollection/Iterator`` `nodes`. The helper method
``ASN1Parseable/init(asn1Encoded:)-5tkco`` will automatically throw an error if there is no node available to decode an object from, and
``ASN1/sequence(_:identifier:_:)`` will confirm that all the nodes were consumed from the child iterator.

This composition approach scales to more complex types. Any ASN.1 composite object can be implemented using ``ASN1/sequence(_:identifier:_:)``
and recursive initialization of ever-smaller ASN.1 objects.

### Encoding to DER

Next we need to implement the inverse method, ``ASN1ImplicitlyTaggable/serialize(into:withIdentifier:)``. This method is implemented in much the
same was as our parsing method, but in reverse.

Importantly, here we don't have a `sequence` helper. Instead we use the more general operation, ``ASN1/Serializer/appendConstructedNode(identifier:_:)``.
This doesn't have any semantic implications: it applies a general purpose ASN.1 constructed node with a given identifier.

```swift
func serialize(into coder: inout ASN1.Serializer, withIdentifier identifier: ASN1.ASN1Identifier) throws {
    try coder.appendConstructedNode(identifier: identifier) { coder in
        try coder.serialize(self.r)
        try coder.serialize(self.s)
    }
}
```

Note that we have shadowed our `coder` in this block. This is important: we're passed our original ``ASN1/Serializer`` `coder` as an `inout`
variable, and ``ASN1/Serializer/appendConstructedNode(identifier:_:)`` is a `mutating` operation. The closure it takes will receive the same
serializer as an `inout` again, allowing us to subsequently serialize new objects.

We can then recurse down the tree. ``ASN1/Serializer/serialize(_:)-3281j`` is a handy wrapper that will ultimately invoke ``ASN1Serializable/serialize(into:)`` on
the node in question.

### Final Result

We're done! Ultimately we've ended up with the following type. Don't worry too much about our use of ``ASN1ImplicitlyTaggable/defaultIdentifier`` here: we'll cover it
in [Implicit Tagging](#Implicit-Tagging).

```swift
struct ECDSASignature: ASN1ImplicitlyTaggable {
    static var defaultIdentifier: ASN1.ASN1Identifier {
        .sequence
    }

    var r: ArraySlice<UInt8>
    var s: ArraySlice<UInt8>

    init(r: ArraySlice<UInt8>, s: ArraySlice<UInt8>) {
        self.r = r
        self.s = s
    }

    init(asn1Encoded rootNode: ASN1.ASN1Node, withIdentifier identifier: ASN1.ASN1Identifier) throws {
        self = try ASN1.sequence(rootNode, identifier: identifier) { nodes in
            let r = try ArraySlice<UInt8>(asn1Encoded: &nodes)
            let s = try ArraySlice<UInt8>(asn1Encoded: &nodes)

            return ECDSASignature(r: r, s: s)
        }
    }

    func serialize(into coder: inout ASN1.Serializer, withIdentifier identifier: ASN1.ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.r)
            try coder.serialize(self.s)
        }
    }
}
```

## Alternative Tagging

ASN.1 supports overriding tags in two ways: implicit and explicit tagging. ``SwiftASN1`` supports both.

It's often difficult to work out from an isolated snippet of ASN.1 definition whether a custom tag is explicit
or implicit. For clarity, this document will attempt to express on each line whether a tag is explicit or
implicit.

### Implicit Tagging

Implicit tagging replaces the usual tag for an object with a new tag. This makes it impossible to know the type
of the object without having the ASN.1 definition. It can also limit some extensibility.

The principal advantage of implicit tagging is that there is no need to add the extra tag that explicit tagging requires.
This will save at least 2 bytes on each object, but may save more.

An object that can be implicitly tagged should conform to ``ASN1ImplicitlyTaggable``. This will make a number of extra
methods available to users of that type, as well as forcing users to implement
``ASN1ImplicitlyTaggable/init(asn1Encoded:withIdentifier:)-iudo`` and ``ASN1ImplicitlyTaggable/serialize(into:withIdentifier:)``.
These two methods allow the caller to tell the type what its implicit tag is. The implementer is required to use that tag
for the top-level object (usually a constructed node).

> Note: A few objects should not conform to ``ASN1ImplicitlyTaggable``. These objects are ones which, if they lost their tag,
> would not be able to correctly decode themselves.
>
> An example of such a type is a CHOICE type. For example:
>
> ```
> CannotBeImplicitlyTagged ::= CHOICE {
>   integerVal    INTEGER
>   boolVal       BOOLEAN
>   stringVal     UTF8String }
> ```
>
> As CHOICE types encode as whatever of the choice values is chosen, the tag is necessary to know which of these cases to decode.
> As a result, we cannot implicitly tag a CHOICE object: it'll be impossible to decode. This is true even if the various CHOICE
> fields are implicitly or explicitly tagged with custom tags: that tag will be obliterated if the CHOICE itself is implicitly
> tagged.

Users can then decode an implicitly tagged object using one of the helper methods. For example, consider
this simple ASN.1 type:

```
ContainsImplicitTag ::= SEQUENCE {
  value    [0]  IMPLICIT INTEGER }
```

We can decode it like so:

```swift
init(asn1Encoded rootNode: ASN1.ASN1Node) throws {
    self = try ASN1.sequence(rootNode, identifier: .sequence) { nodes in
        let value = try Int64(asn1Encoded: &nodes, identifier: .init(tagWithNumber: 0, tagClass: .contextSpecific, constructed: false))

        return ContainsImplicitTag(value: value)
    }
}
```

We can also encode it similarly:

```swift
func serialize(into coder: inout ASN1.Serializer) throws {
    try coder.appendConstructedNode(identifier: .sequence) { coder in
        try self.value.serialize(into: &coder, withIdentifier: .init(tagWithNumber: 0, tagClass: .contextSpecific, constructed: false))
    }
}
```

Note that we need to construct the ``ASN1/ASN1Identifier`` directly in this case. This is common whenever we have an implicit
tag that needs to be passed to an an object that is unconditionally present. It's often a wise idea to store this tag in a `static let`
for ease of access.

There are a few helper functions for circumstances when an object has an implicit tag and is also either `OPTIONAL` or `DEFAULT`. For parsing,
those are:

- ``ASN1/optionalImplicitlyTagged(_:tag:)``
- ``ASN1/decodeDefault(_:identifier:defaultValue:)``
- ``ASN1/decodeDefault(_:identifier:defaultValue:_:)``

For serializing, those are:

- ``ASN1/Serializer/serializeOptionalImplicitlyTagged(_:)``
- ``ASN1/Serializer/serializeOptionalImplicitlyTagged(_:withIdentifier:)``

Note that in a few cases you will see an object that is `OPTIONAL` or `DEFAULT` without a note of a tag. In this case, the implicit tag is
identical to the normal tag for this object.

### Explicit Tagging

Explicit tagging wraps an object in a new constructed object whose tag is equal to the explicit tag defined in the ASN.1 definition. This allows
the explicitly tagged object to still retain its original tag, helping the encoding to remain self-describing. Additionally, unlike with implicit
tagging, all nodes can be explicitly tagged, as the underlying representation of that node is not affected.

As a worked example of explicit tagging, consider the following object:

```
ContainsExplicitTag ::= SEQUENCE {
  value    [0]  EXPLICIT INTEGER }
```

We can decode it like so:

```swift
init(asn1Encoded rootNode: ASN1.ASN1Node) throws {
    self = try ASN1.sequence(rootNode, identifier: .sequence) { nodes in
        let value = try ASN1.explicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) {
            try Int64(asn1Encoded: $0)
        }

        return ContainsExplicitTag(value: value)
    }
}
```

We can also encode it similarly:

```swift
func serialize(into coder: inout ASN1.Serializer) throws {
    try coder.appendConstructedNode(identifier: .sequence) { coder in
        try coder.serialize(self.value, explicitlyTaggedWithTagNumber: 0, tagClass: .contextSpecific)
    }
}
```

As with the implicitly tagged case, most explicit tags are used in cases where the object is also either `OPTIONAL` or `DEFAULT`. We have a number
helper methods for those. For parsing:

- ``ASN1/optionalExplicitlyTagged(_:tagNumber:tagClass:_:)``
- ``ASN1/decodeDefaultExplicitlyTagged(_:tagNumber:tagClass:defaultValue:)``
- ``ASN1/decodeDefaultExplicitlyTagged(_:tagNumber:tagClass:defaultValue:_:)``

For serializing, users are expected to implement the DEFAULT/OPTIONAL logic themselves.
