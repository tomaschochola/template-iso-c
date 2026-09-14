# template-iso-c

ISO C23 application template: strict warnings, sanitizers, and portable release artifacts.

## Target

- OS: GNU/Linux
- Kernel: Linux 7
- Triple: x86_64-unknown-linux-gnu
- Arch: x86_64
- Bits: 64-bit, LP64, little-endian
- ISA: x86-64-v1, x86-64-v2, x86-64-v3
- Libc: glibc 2.41
- Interface: POSIX.1-2024

## Language

- `-std=c23`
- `-Wall -Wextra -Wpedantic -pedantic-errors`

## Features

- `_GNU_SOURCE=1`
- `_ISOC95_SOURCE=1`
- `_ISOC99_SOURCE=1`
- `_ISOC11_SOURCE=1`
- `_ISOC23_SOURCE=1`
- `_ISOC2Y_SOURCE=1`
- `_POSIX_SOURCE=1`
- `_POSIX_C_SOURCE=202405L`
- `_XOPEN_SOURCE=800`
- `_XOPEN_SOURCE_EXTENDED=1`
- `_LARGEFILE64_SOURCE=1`
- `_DEFAULT_SOURCE=1`
- `_ATFILE_SOURCE=1`
- `_DYNAMIC_STACK_SIZE_SOURCE=1`

## Stack

- CC: gcc 16
- Libc: glibc
- Build: cmake 4.4 + ninja
- Test: ctest + valgrind
- Pack: cpack (TGZ)
- Format: prettier + trimmer (node 24)
- Orchestration: makefile

## Devcontainer

- Base: official GCC 16 image + Kitware CMake 4.4.3 + Node.js v24.20.0 tarballs (amd64/arm64)
- User: devcontainer
- Sidecars: none
- Ports: 61220-61229

## Makefile

- `fix`: prettier + trimmer autofix
- `check`: doctor + lint + analyze + test + coverage + memcheck + all + san + audit
- `doctor`: git + npm + toolchain ok (npm_doctor green in container; skip on lived-in hosts)
- `lint`: prettier + trimmer check
- `test`: dev ctest
- `analyze`: fanalyzer clean (raised --param budgets, tripwires stay -Werror)
- `coverage`: gcov 100% lines/branches/calls/conditions (gate on Taken, not Branches executed)
- `memcheck`: valgrind clean (leak-check=full + track-origins)
- `san`: asan + ubsan + tsan + lsan clean
- `all`: v1 + v2 + v3 binaries
- `dist`: v1 + v2 + v3 tarballs
- `audit`: npm audit clean
- `native`: local build + test
- `install`: native build + install to prefix (/usr/local, sudo)
- `uninstall`: remove install
- `installcheck`: install ok (10 tests)
- `stage`: native build + install tree to ./stage (runs wherever called)
- `deploy`: copy stage to prefix (system: sudo; user-level: prefix=~/.local SUDO=)
- `update`: refresh locks, only tool that may touch them
- `postcreate`: first-time setup, runs automatically on create
- `up`: start devcontainer
- `shell`: open shell in devcontainer
- `stop`: stop container, keep it
- `down`: stop and remove container
- `clean`: drop out + dist + stage
- `distclean`: clean + drop node_modules
- `rebuild`: full rebuild, only when broken
- `devcontainer_check`: validate devcontainer config

## Workflows

- `dev`: debug
- `analyzer`: fanalyzer
- `asan`: address, UB
- `ubsan`: UB (+ float-cast-overflow)
- `tsan`: threads
- `lsan`: leaks
- `memcheck`: valgrind build
- `coverage`: coverage build
- `native`: local build
- `build-linux-amd64-v1`: v1
- `build-linux-amd64-v2`: v2
- `build-linux-amd64-v3`: v3
- `dist-linux-amd64-v1`: v1 tarball
- `dist-linux-amd64-v2`: v2 tarball
- `dist-linux-amd64-v3`: v3 tarball

## Layout

```text
├── Makefile
├── .editorconfig
├── .devcontainer/
├── CMakeLists.txt
├── CMakePresets.json
├── cmake/
├── package.json
├── prettier.config.js
├── LICENSE
├── AUTHORS.md
├── include/
├── src/
└── tests/
```
