<h1 align="center">
	zlugify
</h1>

<p align="center">
	Generate ASCII slugs from unicode strings
</p>

zlugify is part of [_zedd_](https://code.zeptotech.net/zedd), a collection of useful libraries for zig.

## zlugify

_zlugify_ is a library to generate slugs from all types of UTF-8 encoded strings. It uses [anyascii.zig](https://code.zeptotech.net/zedd/anyascii.zig) to convert UTF-8 encoded strings into ASCII-only strings.

## Versions

zlugify 1.1.0 is made and tested with zig 0.14.0.

## How to use

### Install

In your project directory:

```shell
$ zig fetch --save https://code.zeptotech.net/zedd/zlugify/archive/v1.1.0.tar.gz
```

In `build.zig`:

```zig
// Add zlugify dependency.
const zlugify = b.dependency("zlugify", .{
	.target = target,
	.optimize = optimize,
});
exe.root_module.addImport("zlugify", zlugify.module("zlugify"));
```

### Examples

These examples are highly inspired from the test cases that you can find at the end of [`lib.zig`](https://code.zeptotech.net/zedd/zlugify/src/branch/main/src/lib.zig).

#### trim and normalize

```zig
const slugify = @import("zlugify").slugify;

const slug = try slugify(allocator, "   This is a test.\t\n");
defer allocator.free(slug);
try std.testing.expectEqualStrings("this-is-a-test", slug);
```

#### remove diacritics and unnecessary spaces

```zig
const slugify = @import("zlugify").slugify;

const slug = try slugify(allocator, "SôMÈThing   \t    ÉLSÈ");
defer allocator.free(slug);
try std.testing.expectEqualStrings("something-else", slug);
```

#### convert non-latin characters

```zig
const slugify = @import("zlugify").slugify;

const slug = try slugify(allocator, "埼玉 県");
defer allocator.free(slug);
try std.testing.expectEqualStrings("qiyu-xian", slug);
```

#### convert ascii-like characters

```zig
const slugify = @import("zlugify").slugify;

const slug = try slugify(allocator, "𝒔𝒍𝒖𝒈𝒊𝒇𝒚 𝒂 𝒔𝒕𝒓𝒊𝒏𝒈");
defer allocator.free(slug);
try std.testing.expectEqualStrings("slugify-a-string", slug);
```

#### convert emojis

```zig
const slugify = @import("zlugify").slugify;

const slug = try slugify(allocator, "hello 🦊");
defer allocator.free(slug);
try std.testing.expectEqualStrings("hello-fox", slug);
```

#### customized separator

```zig
const slugifySeparator = @import("zlugify").slugify;

const slug = try slugifySeparator(allocator, "tôi yêu những chú kỳ lân", '_');
defer allocator.free(slug);
try std.testing.expectEqualStrings("toi_yeu_nhung_chu_ky_lan", slug);
```
