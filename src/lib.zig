const std = @import("std");
const anyascii = @import("anyascii");

/// Convert the provided string to a slugged version of it.
/// With this function, you can set the separator to use.
pub fn slugifySeparator(allocator: std.mem.Allocator, str: []const u8, separator: u8) ![]u8 {
	// Trim the provided string.
	const trimmed = std.mem.trim(u8, str, " \xA0\t\r\n\'\"/\\");
	// Convert UTF-8 string to ASCII.
	const result = try anyascii.utf8ToAscii(allocator, trimmed);

	// Check each char to remove them / replace them by their slugged version if needed.
	var previousIsSeparator = true; // Setting it to true at start forbids the result to start with a separator.
	var shift: usize = 0;
	for (0..result.len, result) |i, char| {
		if (char == ' ' or char == '\xA0' or char == '\t' or char == '\r' or char == '\n' or char == '\'' or char == '"' or char == '/' or char == '\\') {
			// Whitespace-like character: replace it by a dash, or remove it if the previous character is a dash.
			if (!previousIsSeparator) {
				result[i - shift] = separator;
				previousIsSeparator = true;
			} else {
				// To remove the current character, we just shift all future written characters.
				shift += 1;
			}
		} else {
			// In the general case, we keep alphanumeric characters and all the rest is shifted.
			if (std.ascii.isAlphanumeric(char)) {
				// Convert the ASCII character to its lowercased version.
				result[i - shift] = std.ascii.toLower(char);
				previousIsSeparator = false;
			} else {
				shift += 1;
			}
		}
	}

	// If we removed characters, free the remaining unused memory.
	if (shift > 0) {
		_ = allocator.resize(result, result.len - shift);
	}

	// Return the result without the shifted characters.
	return result[0..result.len - shift];
}

/// Convert the provided string to a slugged version of it with the default '-' separator.
pub fn slugify(allocator: std.mem.Allocator, str: []const u8) ![]u8 {
	return slugifySeparator(allocator, str, '-');
}

test slugify {
	try testSlugify("this-is-a-test", "   This is a test.\t\n");
	try testSlugify("something-else", "SôMÈThing   \t    ÉLSÈ");
	try testSlugify("slugify-a-string", "𝒔𝒍𝒖𝒈𝒊𝒇𝒚 𝒂 𝒔𝒕𝒓𝒊𝒏𝒈");

	try testSlugify("blosse-shenzhen", "Blöße 深圳");
	try testSlugify("qiyu-xian", "埼玉 県");
	try testSlugify("samt-redia", "სამტრედია");
	try testSlugify("say-x-ag", "⠠⠎⠁⠽⠀⠭⠀⠁⠛");
	try testSlugify("5-x", "☆ ♯ ♰ ⚄ ⛌");
	try testSlugify("no-m-a-s", "№ ℳ ⅋ ⅍");

	try testSlugify("hearts", "♥");
	try testSlugify("hello-fox", "hello 🦊");
	try testSlugify("deja-vu", "  Déjà Vu!  ");
	try testSlugify("toi-yeu-nhung-chu-ky-lan", "tôi yêu những chú kỳ lân");
}
/// Test slugify function.
pub fn testSlugify(expected: []const u8, toSlugify: []const u8) !void {
	const slug = try slugify(std.testing.allocator, toSlugify);
	defer std.testing.allocator.free(slug);

	try std.testing.expectEqualStrings(expected, slug);
}

test slugifySeparator {
	try testSlugifySeparator("something_else", "SôMÈThing   \t    ÉLSÈ", '_');
}
/// Test slugifySeparator function.
pub fn testSlugifySeparator(expected: []const u8, toSlugify: []const u8, separator: u8) !void {
	const slug = try slugifySeparator(std.testing.allocator, toSlugify, separator);
	defer std.testing.allocator.free(slug);

	try std.testing.expectEqualStrings(expected, slug);
}
