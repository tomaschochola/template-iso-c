# Makefile

SHELL := /usr/bin/env bash

GNUMAKEFLAGS ?=

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

.SHELLFLAGS := -Eeuo pipefail -c

.DELETE_ON_ERROR:
.SUFFIXES:
.NOTPARALLEL:

# Default goal

.DEFAULT_GOAL := never

.PHONY: never
.SILENT: never
never:
	printf '%s\n' 'No default target. Run an explicit target' >&2
	exit 1

# Options

DESTDIR ?=
prefix ?= /usr/local
SUDO ?= sudo

LC_ALL := C.UTF-8
SOURCE_DATE_EPOCH := $(shell git log -1 --format=%ct)

export LC_ALL
export SOURCE_DATE_EPOCH

# Public goals

.PHONY: fix
fix: prettier_fix clang_format_fix trimmer_fix

.PHONY: check
check: doctor lint test all audit

.PHONY: doctor
doctor: git_check npm_config_check npm_doctor npm_check toolchain_check

.PHONY: lint
lint: prettier_check clang_format_check trimmer_check

.PHONY: test
test:
	cmake --workflow --preset test

.PHONY: debug
debug:
	cmake --workflow --preset build-debug

.PHONY: fanalyzer
fanalyzer:
	cmake --workflow --preset fanalyzer

.PHONY: coverage
coverage:
	rm --force --recursive --one-file-system -- ./out/build/coverage
	cmake --workflow --preset coverage
	find ./out/build/coverage/src -type f -name '*.gcno' -exec gcov --no-output {} +

.PHONY: valgrind
valgrind:
	cmake --workflow --preset valgrind
	ctest --preset valgrind --test-dir ./out/build/valgrind -T MemCheck

.PHONY: audit
audit: npm_audit

.PHONY: update
update: npm_config_check npm_update

.PHONY: asan
asan:
	cmake --workflow --preset asan

.PHONY: ubsan
ubsan:
	cmake --workflow --preset ubsan

.PHONY: tsan
tsan:
	cmake --workflow --preset tsan

.PHONY: lsan
lsan:
	cmake --workflow --preset lsan

.PHONY: sanitize
sanitize: asan ubsan tsan lsan

.PHONY: native
native:
	cmake --workflow --preset build-native

.PHONY: release
release:
	cmake --workflow --preset build-release

.PHONY: linux_amd64_v1
linux_amd64_v1:
	cmake --workflow --preset build-linux-amd64-v1

.PHONY: linux_amd64_v2
linux_amd64_v2:
	cmake --workflow --preset build-linux-amd64-v2

.PHONY: linux_amd64_v3
linux_amd64_v3:
	cmake --workflow --preset build-linux-amd64-v3

.PHONY: all
all: debug native release

.PHONY: dist_native
dist_native:
	cmake --workflow --preset dist-native

.PHONY: dist_debug
dist_debug:
	cmake --workflow --preset dist-debug

.PHONY: dist_release
dist_release:
	cmake --workflow --preset dist-release

.PHONY: dist_linux_amd64_v1
dist_linux_amd64_v1:
	cmake --workflow --preset dist-linux-amd64-v1

.PHONY: dist_linux_amd64_v2
dist_linux_amd64_v2:
	cmake --workflow --preset dist-linux-amd64-v2

.PHONY: dist_linux_amd64_v3
dist_linux_amd64_v3:
	cmake --workflow --preset dist-linux-amd64-v3

.PHONY: dist
dist: dist_native dist_debug dist_release

.PHONY: install
install:
	cmake --workflow --preset build-native
	$(SUDO) env DESTDIR="$(DESTDIR)" cmake --install ./out/build/native --prefix "$(prefix)" --component Unspecified

.PHONY: uninstall
uninstall:
	test -f ./out/build/native/install_manifest_Unspecified.txt
	$(SUDO) xargs --no-run-if-empty --delimiter='\n' --replace='{}' rm --force -- "$(DESTDIR){}" < ./out/build/native/install_manifest_Unspecified.txt

.PHONY: installcheck
installcheck:
	test -f ./out/build/native/install_manifest_Unspecified.txt
	xargs --no-run-if-empty --delimiter='\n' --replace='{}' test -f "$(DESTDIR){}" < ./out/build/native/install_manifest_Unspecified.txt

.PHONY: nuke
nuke: distclean

.PHONY: clean
clean:
	rm --force --recursive --one-file-system -- ./dist ./out

.PHONY: distclean
distclean: clean deps_clean

# Protected goals

.PHONY: deps_install
deps_install: npm_install

.PHONY: deps_clean
deps_clean: npm_clean

.PHONY: trimmer_fix
trimmer_fix: ./node_modules/.package-lock.json ./package.json ./package-lock.json
	npm exec --no --ignore-scripts -- tooling-trimmer fix .

.PHONY: trimmer_check
trimmer_check: ./node_modules/.package-lock.json ./package.json ./package-lock.json
	npm exec --no --ignore-scripts -- tooling-trimmer check .

.PHONY: prettier_fix
prettier_fix: ./node_modules/.package-lock.json ./package.json ./package-lock.json ./prettier.config.js
	npm exec --no --ignore-scripts -- prettier -w .

.PHONY: prettier_check
prettier_check: ./node_modules/.package-lock.json ./package.json ./package-lock.json ./prettier.config.js
	npm exec --no --ignore-scripts -- prettier -c .

.PHONY: clang_format_fix
clang_format_fix: ./.clang-format
	find ./src ./tests -type f '(' -name '*.c' -o -name '*.h' ')' -print0 | xargs -0 -r clang-format -i --style=file --

.PHONY: clang_format_check
clang_format_check: ./.clang-format
	find ./src ./tests -type f '(' -name '*.c' -o -name '*.h' ')' -print0 | xargs -0 -r clang-format -n --Werror --style=file --

.PHONY: npm_config_check
npm_config_check: ./.npmrc
	test "$$(npm config get ignore-scripts)" = "true"
	test "$$(npm config get allow-directory)" = "root"
	test "$$(npm config get allow-file)" = "root"
	test "$$(npm config get allow-git)" = "root"
	test "$$(npm config get allow-remote)" = "root"
	test "$$(npm config get audit)" = "false"
	test "$$(npm config get strict-ssl)" = "true"
	test "$$(npm config get registry)" = "https://registry.npmjs.org/"

.PHONY: npm_doctor
npm_doctor:
	npm doctor connection registry environment permissions cache

.PHONY: npm_check
npm_check: npm_config_check ./node_modules/.package-lock.json
	npm ci --dry-run --ignore-scripts --audit=false --install-links --include=prod --include=dev --include=peer --include=optional
	npm ls --all --install-links --include=prod --include=dev --include=peer --include=optional >/dev/null

.PHONY: npm_audit
npm_audit: npm_config_check ./node_modules/.package-lock.json ./package.json ./package-lock.json
	npm audit --ignore-scripts --audit-level=critical --install-links --include=prod --include=dev --include=peer --include=optional

.PHONY: npm_install
npm_install: npm_config_check ./package.json ./package-lock.json
	npm ci --ignore-scripts --install-links --include=prod --include=dev --include=peer --include=optional

.PHONY: npm_update
npm_update: npm_config_check ./package.json ./package-lock.json npm_clean
	npm update --ignore-scripts --install-links --include=prod --include=dev --include=peer --include=optional

.PHONY: npm_clean
npm_clean:
	rm --force --recursive --one-file-system -- ./node_modules

.PHONY: git_check
git_check:
	test -z "$$(git ls-files --unmerged)"
	test -z "$$(git ls-files --cached --ignored --exclude-standard)"
	git diff --check
	git diff --cached --check
	git fsck --full --strict --no-dangling --no-progress

.PHONY: toolchain_check
toolchain_check:
	cmake --version
	gcc --version
	ninja --version
	ctest --version
	valgrind --version
	gcov --version
	clang-format --version

# Private targets

./node_modules/.package-lock.json: ./.npmrc ./package.json ./package-lock.json
	$(MAKE) npm_install
