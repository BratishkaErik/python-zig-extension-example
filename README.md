<!--
SPDX-FileCopyrightText: 2025 Eric Joldasov

SPDX-License-Identifier: CC0-1.0
-->

# python-zig-extension-example

[![REUSE status](https://api.reuse.software/badge/github.com/BratishkaErik/python-zig-extension-example)](https://api.reuse.software/info/github.com/BratishkaErik/python-zig-extension-example)

Example on how to build and test a Python extension written in Zig.
This example uses `translate-c/@cImport` and [zig-python](https://github.com/BratishkaErik/zig-python)
build plugin to automatically link Python library and generate bindings.

Tested with Zig version `0.14.0`. CI is run for Linux, Windows and macOS.

## Usage

You can simply install Python extension as a regular shared library:
```console
$ zig build
```

However, you won't be able to run `test.py` straight after that.
CPython expects certain filename format which is not the same
as Zig defaults for shared libraries:
* `module.so` on Linux systems (instead of `libmodule.so`)
* same on MacOS (instead of `.dylib`)
* `module.pyd` on Windows (instead of `.dll`)

You can copy them to your current dir or PYTHONPATH in a similar
maner (adjust for your OS) and then run `python test.py`:
```console
$ cp zig-out/lib/libmodule_name.so ./module_name.so
$ python test.py
// Or:
$ cp zig-out/lib/libmodule_name.so zig-out/lib/module_name.so
$ PYTHONPATH="zig-out/lib/" python test.py
```

To simplify this, `build.zig` has test step defined for you:
```console
$ zig build test
```

## Licenses

[![REUSE status](https://api.reuse.software/badge/github.com/BratishkaErik/python-zig-extension-example)](https://api.reuse.software/info/github.com/BratishkaErik/python-zig-extension-example)

This project is [REUSE-compliant](https://github.com/fsfe/reuse-tool),
text of licenses can be found in [LICENSES directory](LICENSES/).
Short overview:
* Code is licensed under 0BSD.
* This README and CI files are licensed under CC0-1.0.

[Comparison of used licenses](https://interoperable-europe.ec.europa.eu/licence/compare/0BSD;CC0-1.0).
