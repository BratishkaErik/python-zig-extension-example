// SPDX-FileCopyrightText: 2025 Eric Joldasov
//
// SPDX-License-Identifier: 0BSD

const std = @import("std");

const c = @cImport({
    @cDefine("PY_SSIZE_T_CLEAN", {});
    @cDefine("Py_LIMITED_API", "0x030A0000");
    @cInclude("Python.h");
});

// Macros that failed translate-c
fn PyObject_HEAD_INIT(@"type": ?*c.PyTypeObject) c.PyObject {
    return switch (c.PY_MINOR_VERSION) {
        0...11 => .{
            .ob_refcnt = 1,
            .ob_type = @"type",
        },
        else => .{
            .unnamed_0 = .{ .ob_refcnt = 1 },
            .ob_type = @"type",
        },
    };
}

const PyModuleDef_HEAD_INIT: c.PyModuleDef_Base = .{
    .ob_base = PyObject_HEAD_INIT(@alignCast(@ptrCast(c._Py_NULL))),
    .m_init = @alignCast(@ptrCast(c._Py_NULL)),
    .m_index = 0,
    .m_copy = @alignCast(@ptrCast(c._Py_NULL)),
};
// End of macros.

/// Bit-reverse a Python's integer (stored and returned as "long long" here.)
fn bitreverse_int(self: [*c]c.PyObject, args: [*c]c.PyObject) callconv(.c) [*c]c.PyObject {
    _ = self;

    var int: c_long = undefined;
    if (c.PyArg_ParseTuple(args, "l", &int) == 0) {
        return null;
    }
    std.log.debug("int (original) = {d}", .{int});

    int = @bitReverse(int);
    std.log.debug("int (reversed) = {d}", .{int});

    return c.PyLong_FromLong(int);
}

var methods: [2]c.PyMethodDef = .{
    .{
        .ml_name = "bitreverse",
        .ml_meth = &bitreverse_int,
        .ml_flags = c.METH_VARARGS,
        .ml_doc = "Bit-reverse an integer.",
    },
    .{},
};

var module: c.PyModuleDef = .{
    .m_base = PyModuleDef_HEAD_INIT,
    .m_name = "module_name",
    .m_doc = "Some documentation for module.",
    .m_size = -1,
    .m_methods = &methods,
};

export fn PyInit_module_name() callconv(.c) [*c]c.PyObject {
    return c.PyModule_Create(&module);
}
