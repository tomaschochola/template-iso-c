# AGENTS.md

This application uses ISO C23 (ISO/IEC 9899:2024) on 64-bit GNU/Linux and is compiled with GCC's `gcc`. It uses glibc for the C standard library and GNU/Linux APIs, with `_GNU_SOURCE=1` enabled. CMake builds the application, CTest runs automated tests, and CPack creates binary packages.

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
- python3 3.14
- clang-format 21.1
- node 24.22
- npm 11.19

## Development environment

The development environment is configured in `.devcontainer/`. Manage it from the repository root on the host using the Makefile targets or directly through the `devcontainer`, `docker` and `docker compose` CLIs.

- `devcontainer`: `ubuntu` 26.04 — Run development tools and workspace commands.
- `wiremock`: `wiremock/wiremock` 3.13.2 — Mock HTTP APIs for automated tests.

```sh
# start the development environment
make up

# run a workspace command
devcontainer exec --workspace-folder . COMMAND ARG...

# run a shell command
devcontainer exec --workspace-folder . bash -c 'COMMAND ARG... | COMMAND ARG...'

# run a sidecar command
docker compose -f .devcontainer/docker-compose.yml exec -T SERVICE COMMAND ARG...
```

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
|-- .devcontainer/
|   |-- .dockerignore
|   |-- Dockerfile
|   |-- devcontainer.json
|   |-- docker-compose.yml
|   `-- ...
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
- `check`: `devcontainer_gate` + `doctor` + `lint` + `headers` + `test` + `all` + `verify` + `audit`
- `extended`: `check` + `fanalyzer` + `valgrind` + `sanitize`
- `doctor`: `git_check` + `npm_config_check` + `npm_doctor` + `npm_check` + `toolchain_check`
- `lint`: `prettier_check` + `clang_format_check` + `trimmer_check`
- `test`: `devcontainer_gate` — Run tests in a debug build.
- `verify`: `devcontainer_gate` — Run tests in a release build.
- `headers`: `devcontainer_gate` — Check standalone header compilation.
- `debug`: Build the debug application.
- `fanalyzer`: `devcontainer_gate` — Analyze code with GCC.
- `coverage`: `devcontainer_gate` — Measure and report test coverage.
- `valgrind`: `devcontainer_gate` — Run tests with Valgrind.
- `audit`: `npm_audit`
- `update`: `npm_config_check` + `npm_update`
- `asan`: `devcontainer_gate` — Run tests with AddressSanitizer.
- `ubsan`: `devcontainer_gate` — Run tests with UndefinedBehaviorSanitizer.
- `tsan`: `devcontainer_gate` — Run tests with ThreadSanitizer.
- `lsan`: `devcontainer_gate` — Run tests with LeakSanitizer.
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
- `install`: Install the application.
- `uninstall`: Uninstall the application.
- `installcheck`: Check the application installation.
- `postcreate`: `deps_install` + `toolchain_check`
- `up`: `host_gate` + `devcontainer_check` — Start the development environment.
- `shell`: `interactive_gate` + `host_gate` + `up` — Open a shell in the development environment.
- `stop`: `host_gate` — Stop the development environment.
- `down`: `host_gate` — Remove the development environment.
- `rebuild`: `host_gate` + `devcontainer_check` + `down` — Rebuild the development environment.
- `nuke`: `distclean` + `prune`
- `prune`: `host_gate` — Remove project container resources.
- `clean`: Remove generated project files.
- `distclean`: `clean` + `deps_clean`
- `host_gate`: Require execution on the host.
- `devcontainer_gate`: Require execution in a Docker container.
- `interactive_gate`: Require an interactive terminal.
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
- `devcontainer_check`: `host_gate` — Check development environment configuration.
- `./node_modules/.package-lock.json`: `./.npmrc` + `./package.json` + `./package-lock.json` — Prepare npm dependencies.
