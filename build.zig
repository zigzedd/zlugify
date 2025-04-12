const std = @import("std");

pub fn build(b: *std.Build) void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	// Add anyascii dependency.
	const anyascii = b.dependency("anyascii", .{
		.target = target,
		.optimize = optimize,
	});

	// Zlugify zig module.
	const zlugify = b.addModule("zlugify", .{
		.root_source_file = b.path("src/lib.zig"),
		.target = target,
		.optimize = optimize,
	});
	// Add anyascii dependency.
	zlugify.addImport("anyascii", anyascii.module("anyascii"));

	// Library unit tests.
	const lib_unit_tests = b.addTest(.{
		.root_module = zlugify,
		.target = target,
		.optimize = optimize,
	});
	const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

	const test_step = b.step("test", "Run unit tests.");
	test_step.dependOn(&run_lib_unit_tests.step);
}
