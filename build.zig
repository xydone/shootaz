pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});
    const name = "shootaz";

    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
        .with_sokol_imgui = true,
    });

    const dep_cimgui = b.dependency("cimgui", .{
        .target = target,
        .optimize = optimize,
    });
    // Get the matching Zig module name, C header search path and C library for
    // vanilla imgui vs the imgui docking branch.
    const cimgui_conf = cimgui.getConfig(false);

    // inject the cimgui header search path into the sokol C library compile step
    dep_sokol.artifact("sokol_clib").addIncludePath(dep_cimgui.path(cimgui_conf.include_dir));

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("sokol", dep_sokol.module("sokol"));
    exe_mod.addImport(cimgui_conf.module_name, dep_cimgui.module(cimgui_conf.module_name));

    // extract shdc dependency from sokol dependency
    const dep_shdc = dep_sokol.builder.dependency("shdc", .{});

    // call shdc.createSourceFile() helper function, this returns a `!*Build.Step`:
    const shdc_step = try sokol.shdc.createSourceFile(b, .{
        .shdc_dep = dep_shdc,
        .input = "src/shaders/shaders.glsl",
        .output = "src/shaders/shaders.zig",
        .slang = .{
            .glsl410 = true,
            .glsl300es = true,
            .hlsl4 = true,
            .metal_macos = true,
            .wgsl = true,
        },
    });

    const exe = b.addExecutable(.{
        .name = name,
        .root_module = exe_mod,
    });

    // add the shader compilation step as dependency to the build step
    // which requires the generated Zig source file
    exe.step.dependOn(shdc_step);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    // check step

    const exe_check = b.addExecutable(.{
        .name = name,
        .root_module = exe_mod,
    });

    const check = b.step("check", "Check if it compiles");
    check.dependOn(&exe_check.step);
}

const Build = std.Build;
const std = @import("std");
const sokol = @import("sokol");
const cimgui = @import("cimgui");
