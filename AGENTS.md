# AGENTS.md

This application uses ISO C23 (ISO/IEC 9899:2024) on 64-bit GNU/Linux and is compiled with GCC's `gcc`. It uses glibc for the C standard library and GNU/Linux APIs, with `_GNU_SOURCE=1` enabled. CMake builds the application, CTest runs automated tests, and CPack creates binary packages.

The documented GNU/Linux amd64 environment with Linux 7.x, its toolchain and libraries, and the selected instruction-set variant define the target; portability to other platforms or compatibility with older environments is not a goal. Make full use of the facilities available in ISO C23, glibc, GNU APIs exposed by `_GNU_SOURCE=1`, and Linux-specific APIs. Prefer modern, supported APIs and technologies over legacy, deprecated, or superseded alternatives. When an older API and a newer supported alternative both provide the required behavior on this target, choose the newer alternative rather than retaining the older one for familiarity or broader compatibility. Do not add portability wrappers, compatibility layers, or fallback implementations for environments outside this target unless explicitly required.

## Target platform

- Operating system: GNU/Linux
- Kernel: Linux 7.x
- Target triple: x86_64-pc-linux-gnu
- Architecture: x86_64 (amd64)
- Data layout: 64-bit, LP64, little-endian
- Instruction sets: x86-64-v1, x86-64-v2, x86-64-v3
- C standard library: glibc 2.43
- Interfaces: GNU extensions, Linux-specific interfaces, Linux UAPI, POSIX.1-2024, XSI

## Build tools

- Compiler: GCC
- Build system: CMake
- Automated tests: CTest
- Packaging: CPack

## Language and warnings

- Language: ISO/IEC 9899:2024 C (C23)
- Standard: `-std=c23`
- Warnings: `-Wall -Wextra -Wpedantic -pedantic-errors`

## glibc API

The build defines [`_GNU_SOURCE=1`](https://www.sourceware.org/glibc/manual/2.43/html_node/Feature-Test-Macros.html) for all project targets, enabling these feature-test macros in glibc 2.43:

```c
#define _ISOC95_SOURCE 1
#define _ISOC99_SOURCE 1
#define _ISOC11_SOURCE 1
#define _ISOC23_SOURCE 1
#define _ISOC2Y_SOURCE 1
#define _POSIX_SOURCE 1
#define _POSIX_C_SOURCE 202405L
#define _XOPEN_SOURCE 800
#define _XOPEN_SOURCE_EXTENDED 1
#define _LARGEFILE_SOURCE 1
#define _LARGEFILE64_SOURCE 1
#define _DEFAULT_SOURCE 1
#define _ATFILE_SOURCE 1
#define _DYNAMIC_STACK_SIZE_SOURCE 1
```

## Toolchain versions

- gcc 16.0
- glibc 2.43
- cmake 4.4
- ninja 1.13
- ctest 4.4
- valgrind 3.26
- cpack 4.4
- gcov 16.0
- clang-format 21.1

## EditorConfig

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 4
indent_style = space
insert_final_newline = true
max_line_length = 200
trim_trailing_whitespace = true

[*.go]
indent_size = tab
indent_style = tab
tab_width = 8

[*.ini]
max_line_length = off

[*.md]
indent_size = unset
indent_style = unset
max_line_length = off

[*.txt]
indent_size = unset
indent_style = unset
max_line_length = off

[LICENSE]
indent_size = unset
indent_style = unset
max_line_length = off

[Makefile]
indent_style = tab
max_line_length = off
```

## Clang-Format

```yaml
---
BasedOnStyle: LLVM
ColumnLimit: 200
IndentWidth: 4
BreakBeforeBraces: Linux
AllowShortFunctionsOnASingleLine: None
InsertNewlineAtEOF: true
LineEnding: LF
...
```

## Repository layout

```text
.
|-- .clang-format
|-- .editorconfig
|-- .gitattributes
|-- .gitignore
|-- .npmrc
|-- .prettierignore
|-- AGENTS.md
|-- AUTHORS.md
|-- CMakeLists.txt
|-- CMakePresets.json
|-- LICENSE
|-- Makefile
|-- package-lock.json
|-- package.json
|-- prettier.config.js
|-- src/
|   `-- ...
`-- tests/
    `-- ...
```

## Makefile targets

- `never`: Require an explicit target.
- `fix`: `prettier_fix` + `clang_format_fix` + `trimmer_fix`
- `check`: `doctor` + `lint` + `test` + `all` + `audit`
- `doctor`: `git_check` + `npm_config_check` + `npm_doctor` + `npm_check` + `toolchain_check`
- `lint`: `prettier_check` + `clang_format_check` + `trimmer_check`
- `test`: Run all tests.
- `debug`: Build the debug application.
- `fanalyzer`: Run static analysis.
- `coverage`: Report test coverage.
- `valgrind`: Run all tests with Valgrind.
- `audit`: `npm_audit`
- `update`: `npm_config_check` + `npm_update`
- `asan`: Run all tests with AddressSanitizer.
- `ubsan`: Run all tests with UndefinedBehaviorSanitizer.
- `tsan`: Run all tests with ThreadSanitizer.
- `lsan`: Run all tests with LeakSanitizer.
- `sanitize`: `asan` + `ubsan` + `tsan` + `lsan`
- `native`: Build the application for the current CPU.
- `release`: Build the release application.
- `linux_amd64_v1`: Build the application for x86-64-v1.
- `linux_amd64_v2`: Build the application for x86-64-v2.
- `linux_amd64_v3`: Build the application for x86-64-v3.
- `all`: `debug` + `native` + `release`
- `dist_native`: Package the application for the current CPU.
- `dist_debug`: Package the debug application.
- `dist_release`: Package the release application.
- `dist_linux_amd64_v1`: Package the application for x86-64-v1.
- `dist_linux_amd64_v2`: Package the application for x86-64-v2.
- `dist_linux_amd64_v3`: Package the application for x86-64-v3.
- `dist`: `dist_native` + `dist_debug` + `dist_release`
- `install`: Build and install the application.
- `uninstall`: Uninstall the application.
- `installcheck`: Check the application installation.
- `nuke`: `distclean`
- `clean`: Remove generated files.
- `distclean`: `clean` + `deps_clean`
- `deps_install`: `npm_install`
- `deps_clean`: `npm_clean`
- `trimmer_fix`: `./node_modules/.package-lock.json` + `./package.json` + `./package-lock.json` — Fix whitespace formatting.
- `trimmer_check`: `./node_modules/.package-lock.json` + `./package.json` + `./package-lock.json` — Check whitespace formatting.
- `prettier_fix`: `./node_modules/.package-lock.json` + `./package.json` + `./package-lock.json` + `./prettier.config.js` — Format files with Prettier.
- `prettier_check`: `./node_modules/.package-lock.json` + `./package.json` + `./package-lock.json` + `./prettier.config.js` — Check formatting with Prettier.
- `clang_format_fix`: `./.clang-format` — Format code with clang-format.
- `clang_format_check`: `./.clang-format` — Check formatting with clang-format.
- `npm_config_check`: `./.npmrc` — Check npm configuration.
- `npm_doctor`: Check the npm environment.
- `npm_check`: `npm_config_check` + `./node_modules/.package-lock.json` — Check npm dependencies.
- `npm_audit`: `npm_config_check` + `./node_modules/.package-lock.json` + `./package.json` + `./package-lock.json` — Audit npm dependency security.
- `npm_install`: `npm_config_check` + `./package.json` + `./package-lock.json` — Install npm dependencies.
- `npm_update`: `npm_config_check` + `./package.json` + `./package-lock.json` + `npm_clean` — Update npm dependencies.
- `npm_clean`: Remove installed npm dependencies.
- `git_check`: Check repository integrity.
- `toolchain_check`: Print toolchain versions.
- `./node_modules/.package-lock.json`: `./.npmrc` + `./package.json` + `./package-lock.json` — Prepare npm dependencies.
