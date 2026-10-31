# Makefile
SHELL := bash

GNUMAKEFLAGS ?=

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

.SHELLFLAGS := -Eeuo pipefail -c

.DELETE_ON_ERROR:
.SUFFIXES:
.NOTPARALLEL:

# Default
.DEFAULT_GOAL := never

.PHONY: never
.SILENT: never
never:
	printf '%s\n' 'No default target. Specify a target explicitly.' >&2
	exit 1

# Variables
LC_ALL := C.UTF-8
SOURCE_DATE_EPOCH := $(shell git log -1 --format=%ct)

DESTDIR ?=
prefix ?= /usr/local
SUDO ?= sudo

export LC_ALL
export SOURCE_DATE_EPOCH

# Phony
.PHONY: all
all: debug native release

.PHONY: asan
asan:
	cmake --workflow --preset asan

.PHONY: audit
audit: npm_audit

.PHONY: check
check: doctor lint test all audit

.PHONY: clang_format_check
clang_format_check: ./.clang-format
	find ./src ./tests -type f '(' -name '*.c' -o -name '*.h' ')' -print0 | xargs -0 -r clang-format -n --Werror --style=file --

.PHONY: clang_format_fix
clang_format_fix: ./.clang-format
	find ./src ./tests -type f '(' -name '*.c' -o -name '*.h' ')' -print0 | xargs -0 -r clang-format -i --Werror --style=file --

.PHONY: clean
clean:
	rm --force --recursive --one-file-system -- ./dist ./out ./temp ./temporary ./tmp ./.temp ./.temporary ./.tmp

.PHONY: coverage
coverage:
	rm --force --recursive --one-file-system -- ./out/build/coverage
	cmake --workflow --preset coverage
	find ./out/build/coverage/src -type f -name '*.gcno' -exec gcov --no-output {} +

.PHONY: debug
debug:
	cmake --workflow --preset build-debug

.PHONY: deps_clean
deps_clean: npm_clean

.PHONY: deps_install
deps_install: npm_install

.PHONY: dirclean
dirclean:
	fd --hidden --exclude .git --type directory --print0 | sort --zero-terminated --reverse | xargs --null --no-run-if-empty rmdir --ignore-fail-on-non-empty --

.PHONY: dist
dist: dist_native dist_debug dist_release

.PHONY: dist_debug
dist_debug:
	cmake --workflow --preset dist-debug

.PHONY: dist_linux_amd64_v1
dist_linux_amd64_v1:
	cmake --workflow --preset dist-linux-amd64-v1

.PHONY: dist_linux_amd64_v2
dist_linux_amd64_v2:
	cmake --workflow --preset dist-linux-amd64-v2

.PHONY: dist_linux_amd64_v3
dist_linux_amd64_v3:
	cmake --workflow --preset dist-linux-amd64-v3

.PHONY: dist_native
dist_native:
	cmake --workflow --preset dist-native

.PHONY: dist_release
dist_release:
	cmake --workflow --preset dist-release

.PHONY: distclean
distclean: clean deps_clean

.PHONY: doctor
doctor: git_check npm_config_check npm_doctor npm_check toolchain_check

.PHONY: fanalyzer
fanalyzer:
	cmake --workflow --preset fanalyzer

.PHONY: fix
fix: prettier_fix clang_format_fix trimmer_fix

.PHONY: git_check
git_check:
	test -z "$$(git ls-files --unmerged)"
	test -z "$$(git ls-files --cached --ignored --exclude-standard)"
	git diff --check
	git diff --cached --check
	git fsck --full --strict --no-dangling --no-progress

.PHONY: install
install:
	cmake --workflow --preset build-native
	$(SUDO) env DESTDIR="$(DESTDIR)" cmake --install ./out/build/native --prefix "$(prefix)" --component Unspecified

.PHONY: installcheck
installcheck:
	test -f ./out/build/native/install_manifest_Unspecified.txt
	xargs --no-run-if-empty --delimiter='\n' --replace='{}' test -f "$(DESTDIR){}" < ./out/build/native/install_manifest_Unspecified.txt

.PHONY: lint
lint: prettier_check clang_format_check trimmer_check

.PHONY: linux_amd64_v1
linux_amd64_v1:
	cmake --workflow --preset build-linux-amd64-v1

.PHONY: linux_amd64_v2
linux_amd64_v2:
	cmake --workflow --preset build-linux-amd64-v2

.PHONY: linux_amd64_v3
linux_amd64_v3:
	cmake --workflow --preset build-linux-amd64-v3

.PHONY: lsan
lsan:
	cmake --workflow --preset lsan

.PHONY: native
native:
	cmake --workflow --preset build-native

.PHONY: npm_audit
npm_audit: npm_config_check ./node_modules/.package-lock.json ./package.json ./package-lock.json
	npm audit --ignore-scripts --audit-level=critical --install-links --include=prod --include=dev --include=peer --include=optional

.PHONY: npm_check
npm_check: npm_config_check ./node_modules/.package-lock.json
	npm ci --dry-run --ignore-scripts --audit=false --install-links --include=prod --include=dev --include=peer --include=optional
	npm ls --all --install-links --include=prod --include=dev --include=peer --include=optional >/dev/null

.PHONY: npm_clean
npm_clean:
	rm --force --recursive --one-file-system -- ./node_modules

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

.PHONY: npm_install
npm_install: npm_config_check ./package.json ./package-lock.json
	npm ci --ignore-scripts --install-links --include=prod --include=dev --include=peer --include=optional

.PHONY: npm_update
npm_update: npm_config_check ./package.json ./package-lock.json npm_clean
	npm update --ignore-scripts --install-links --include=prod --include=dev --include=peer --include=optional

.PHONY: nuke
nuke: distclean xfd dirclean

.PHONY: prettier_check
prettier_check: ./node_modules/.package-lock.json ./package.json ./package-lock.json ./prettier.config.js
	npm exec --no --ignore-scripts -- prettier -c .

.PHONY: prettier_fix
prettier_fix: ./node_modules/.package-lock.json ./package.json ./package-lock.json ./prettier.config.js
	npm exec --no --ignore-scripts -- prettier -w .

.PHONY: release
release:
	cmake --workflow --preset build-release

.PHONY: test
test:
	cmake --workflow --preset test

.PHONY: toolchain_check
toolchain_check:
	cmake --version
	gcc --version
	ninja --version
	ctest --version
	valgrind --version
	gcov --version
	clang-format --version

.PHONY: trimmer_check
trimmer_check: ./node_modules/.package-lock.json ./package.json ./package-lock.json
	npm exec --no --ignore-scripts -- tooling-trimmer check .

.PHONY: trimmer_fix
trimmer_fix: ./node_modules/.package-lock.json ./package.json ./package-lock.json
	npm exec --no --ignore-scripts -- tooling-trimmer fix .

.PHONY: tsan
tsan:
	cmake --workflow --preset tsan

.PHONY: ubsan
ubsan:
	cmake --workflow --preset ubsan

.PHONY: uninstall
uninstall:
	test -f ./out/build/native/install_manifest_Unspecified.txt
	$(SUDO) xargs --no-run-if-empty --delimiter='\n' --replace='{}' rm --force -- "$(DESTDIR){}" < ./out/build/native/install_manifest_Unspecified.txt

.PHONY: update
update: npm_config_check npm_update

.PHONY: valgrind
valgrind:
	cmake --workflow --preset valgrind
	ctest --preset valgrind --test-dir ./out/build/valgrind -T MemCheck

.PHONY: xfd
xfd:
	git clean -Xfd

# Non-phony
./node_modules/.package-lock.json: ./.npmrc ./package.json ./package-lock.json
	$(MAKE) npm_install
