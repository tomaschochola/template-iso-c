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

DEVCONTAINER_COMPOSE := ./.devcontainer/docker-compose.yml

CC ?= gcc
CFLAGS ?=
LDFLAGS ?=
LC_ALL ?= C.UTF-8
DESTDIR ?=
VERSION ?= $(shell v=$$(git describe --tags --abbrev=0 2>/dev/null || echo 0.0.0); v=$${v#v}; echo "$$v")
SOURCE_DATE_EPOCH ?= $(shell git log -1 --format=%ct 2>/dev/null || echo 0)
PROGRAM := template-iso-c
prefix ?= /usr/local
SUDO ?= sudo

export CC
export CFLAGS
export LDFLAGS
export LC_ALL
export VERSION
export SOURCE_DATE_EPOCH

# Public goals

.PHONY: fix
fix: prettier_fix clang_format_fix trimmer_fix

.PHONY: check
check: doctor lint fanalyzer test coverage valgrind all sanitize audit

.PHONY: doctor
doctor: git_check npm_config_check npm_doctor npm_check cc_check

.PHONY: lint
lint: prettier_check clang_format_check trimmer_check

.PHONY: test
test:
	cmake --workflow --preset debug

.PHONY: debug
debug:
	cmake --workflow --preset debug

.PHONY: fanalyzer
fanalyzer:
	cmake --workflow --preset fanalyzer

.PHONY: coverage
coverage:
	rm --force --recursive --one-file-system -- ./out/build/coverage
	cmake --workflow --preset coverage
	cd ./out/build/coverage && find ./src -name '*.gcno' -print0 | xargs -0 -r gcov --branch-counts --branch-probabilities --conditions --function-summaries --all-blocks --unconditional-branches --preserve-paths
	cd ./out/build/coverage && find ./src -name '*.gcno' -print0 | xargs -0 -r gcov --json-format --stdout | python3 -c 'import json,pathlib,sys; root=pathlib.Path("../../../src").resolve(); files=[f for s in sys.stdin if s.startswith("{") for f in json.loads(s)["files"] if pathlib.Path(f["file"]).resolve().is_relative_to(root)]; lines=[l for f in files for l in f["lines"]]; functions=[f for file in files for f in file["functions"]]; sys.exit(not (lines and functions and all(l["count"]>0 for l in lines) and all(f["execution_count"]>0 for f in functions)))'

.PHONY: valgrind
valgrind:
	cmake --workflow --preset valgrind
	ctest --test-dir ./out/build/valgrind --output-on-failure --stop-on-failure --no-tests=error -T MemCheck

.PHONY: audit
audit: npm_audit

.PHONY: update
update: npm_config_check ./package.json ./package-lock.json npm_update

.PHONY: sanitize
sanitize:
	cmake --workflow --preset asan
	cmake --workflow --preset ubsan
	cmake --workflow --preset tsan
	cmake --workflow --preset lsan

.PHONY: native
native:
	cmake --workflow --preset build-native

.PHONY: linux_amd64_v1
linux_amd64_v1:
	cmake --workflow --preset build-linux-amd64-v1

.PHONY: linux_amd64_v2
linux_amd64_v2:
	cmake --workflow --preset build-linux-amd64-v2

.PHONY: linux_amd64_v3
linux_amd64_v3:
	cmake --workflow --preset build-linux-amd64-v3

.PHONY: linux_arm64_armv8_a
linux_arm64_armv8_a:
	cmake --workflow --preset build-linux-arm64-armv8-a

.PHONY: linux_arm64_armv9_a
linux_arm64_armv9_a:
	cmake --workflow --preset build-linux-arm64-armv9-a

.PHONY: all
all: debug native

.PHONY: dist_native
dist_native:
	cmake --workflow --preset dist-native

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

.PHONY: dist_linux_arm64_armv8_a
dist_linux_arm64_armv8_a:
	cmake --workflow --preset dist-linux-arm64-armv8-a

.PHONY: dist_linux_arm64_armv9_a
dist_linux_arm64_armv9_a:
	cmake --workflow --preset dist-linux-arm64-armv9-a

.PHONY: dist
dist: dist_native dist_debug

.PHONY: install
install:
	cmake --workflow --preset build-native
	$(SUDO) env DESTDIR="$(DESTDIR)" cmake --install ./out/build/native --prefix "$(prefix)"

.PHONY: uninstall
uninstall:
	$(SUDO) rm --force -- "$(DESTDIR)$(prefix)/bin/$(PROGRAM)"
	$(SUDO) rm --force -- "$(DESTDIR)$(prefix)/share/doc/template-iso-c/LICENSE"

.PHONY: installcheck
installcheck:
	test -f "$(DESTDIR)$(prefix)/bin/$(PROGRAM)"
	test -x "$(DESTDIR)$(prefix)/bin/$(PROGRAM)"
	test -f "$(DESTDIR)$(prefix)/share/doc/template-iso-c/LICENSE"

.PHONY: postcreate
postcreate: deps_install

.PHONY: up
up: devcontainer_check
	devcontainer up --workspace-folder .

.PHONY: shell
shell: up
	devcontainer exec --workspace-folder . /bin/bash

.PHONY: stop
stop:
	docker compose -f "$(DEVCONTAINER_COMPOSE)" stop

.PHONY: down
down:
	docker compose -f "$(DEVCONTAINER_COMPOSE)" down --remove-orphans

.PHONY: rebuild
rebuild: devcontainer_check down
	devcontainer up --workspace-folder . --build-no-cache

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
	find ./src ./tests -type f '(' -name '*.c' -o -name '*.h' ')' -print0 | xargs -0 -r clang-format -n --Werror --style=file --fallback-style=none --

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
	npm audit --ignore-scripts --audit-level=moderate --install-links --include=prod --include=dev --include=peer --include=optional

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

.PHONY: cc_check
cc_check:
	cmake --version
	gcc --version
	ninja --version
	ctest --version
	valgrind --version
	gcov --version
	clang-format --version

.PHONY: devcontainer_check
devcontainer_check:
	devcontainer read-configuration --workspace-folder . >/dev/null
	docker compose -f "$(DEVCONTAINER_COMPOSE)" config --quiet
	docker build --check --file ./.devcontainer/Dockerfile ./.devcontainer

# Private targets

./node_modules/.package-lock.json: ./.npmrc ./package.json ./package-lock.json
	$(MAKE) npm_install
