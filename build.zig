const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("engine", "src/engine.zig");
    lib.setBuildMode(mode);
    lib.install();

    var tests = b.addTest("src/engine.zig");
    tests.setBuildMode(mode);
    tests.addPackagePath("zlm", "vendor/zlm/zlm.zig");
    tests.linkLibC();
    tests.linkSystemLibrary("csfml-graphics");
    tests.linkSystemLibrary("csfml-window");
    tests.linkSystemLibrary("csfml-system");

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&tests.step);
}
