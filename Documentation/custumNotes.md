# Manual note log

## Errors

### 11/10/2025

- Occurs during mingw32-make all:

warning: link-cplusplus@1.0.12: Compiler family detection failed due to error: ToolNotFound: failed to find tool "arm-none-eabi-g++": program not found (see https://docs.rs/cc/latest/cc/#compile-time-requirements for help)
error: failed to run custom build command for `link-cplusplus v1.0.12`

Caused by:
  process didn't exit successfully: `C:\GithubProjects\CRUST-y\rust\target\release\build\link-cplusplus-5c8a63602497a902\build-script-build` (exit code: 1)

- Verified toolchain is installed with rustup show
- installed toolchain executable at https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads
- still have error