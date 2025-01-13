This example project shows how to write [native extensions](https://defold.com/manuals/extensions/) using C++, C# and Zig.

* C++
  * Stable
* [Zig](https://ziglang.org)
  * Experimental support
  * The current state of the Zig toolchain is not stable, and may be updated at any time.
  * Used an experimental [C API for Defold](https://github.com/defold/defold/blob/dev/engine/extension/src/dmsdk/extension/extension.h)
* C#
  * Experimental support
  * Based on DotNet 9 with AOT compilation
  * Generated from an experimental [C API for Defold](https://github.com/defold/defold/blob/dev/engine/extension/src/dmsdk/extension/extension.h)


## Testing locally

The project is also designed to test performance of the different languages.

To build with certain setup, you can use a command line such as:

  LOOPCOUNT=1000000 VARIANT=debug SERVER=http://localhost:9000 ./scripts/build_feature.sh arm64-android cpp

* The `LOOPCOUNT` is used to control how many loops the performance tests should run.
* The `cpp` controls which language to add. Lua is always part of the tests.
  * Possible values are `cpp`, `csharp`, `zig` and `all`

See the [](./scripts/build_feature.sh) and [](./scripts/common.sh) for a full list of environment variables (BOB, SERVER etc)
