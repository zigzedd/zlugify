const std = @import("std");

pub fn build(b: *std.Build) void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	// Add anyascii.zig dependency.
	const anyascii = b.dependency("anyascii.zig", .{
		.target = target,
		.optimize = optimize,
	});

	// Zlugify zig module.
	const zlugify = b.addModule("zlugify", .{
		.root_source_file = b.path("src/lib.zig"),
		.target = target,
		.optimize = optimize,
	});
	zlugify.addImport("anyascii", anyascii.module("anyascii"));

	// Library unit tests.
	const lib_unit_tests = b.addTest(.{
		.root_source_file = b.path("src/lib.zig"),
		.target = target,
		.optimize = optimize,
	});
	lib_unit_tests.root_module.addImport("anyascii", anyascii.module("anyascii"));
	const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

	const test_step = b.step("test", "Run unit tests.");
	test_step.dependOn(&run_lib_unit_tests.step);
}
