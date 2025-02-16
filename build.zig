// SPDX-FileCopyrightText: 2025 Eric Joldasov
//
// SPDX-License-Identifier: 0BSD

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const python_version = b.option(
        []const u8,
        "python-version",
        "Python version to use (default: 3.11)",
    ) orelse "3.11";

    const extension_lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "module_name",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    @import("zig_python").link_everything(extension_lib.root_module, python_version) catch {
        const fail = b.addFail(b.fmt("Unable to find Python {s}, can't build module", .{python_version}));
        extension_lib.step.dependOn(&fail.step);
    };

    install: {
        b.installArtifact(extension_lib);
        break :install;
    }

    @"test": {
        const test_step = b.step("test", b.fmt("Run test.py with Python {s}", .{python_version}));

        const python_exe = b.findProgram(&.{ b.fmt("python{s}", .{python_version}), "python3" }, &.{}) catch {
            const fail = b.addFail(b.fmt("Unable to find Python {s}, can't run tests", .{python_version}));
            test_step.dependOn(&fail.step);
            break :@"test";
        };

        const install_extension = b.addInstallLibFile(
            extension_lib.getEmittedBin(),
            if (target.result.isDarwin())
                "module_name.so" // instead of usual .dylib
            else if (target.result.os.tag == .windows)
                "module_name.pyd" // instead of usual .lib
            else
                "module_name.so", // instead of usual libmodule_name.so
        );
        const extension_dir = b.getInstallPath(install_extension.dir, ".");

        const run_test_py = b.addSystemCommand(&.{python_exe});
        run_test_py.addFileArg(b.path("test.py"));

        const new_pythonpath = if (run_test_py.getEnvMap().get("PYTHONPATH")) |old_pythonpath|
            b.fmt("{s}{c}{s}", .{ extension_dir, std.fs.path.delimiter, old_pythonpath })
        else
            extension_dir;
        run_test_py.setEnvironmentVariable("PYTHONPATH", new_pythonpath);
        run_test_py.step.dependOn(&install_extension.step);

        test_step.dependOn(&run_test_py.step);
    }
}
