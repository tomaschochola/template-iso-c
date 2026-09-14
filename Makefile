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

DEVCONTAINER_FILTER := label=devcontainer.local_folder=$(CURDIR)

CC ?= gcc
CFLAGS ?=
LDFLAGS ?=
DESTDIR ?=
VERSION ?= 0.0.0
SOURCE_DATE_EPOCH ?= 0
PROGRAM := template-iso-c
prefix ?= /usr/local
SUDO ?= sudo

COVERAGE_MIN ?= 100
COVERAGE_BRANCH_MIN ?= 100
COVERAGE_CALL_MIN ?= 100
COVERAGE_CONDITION_MIN ?= 100

export CC
export CFLAGS
export LDFLAGS
export VERSION
export SOURCE_DATE_EPOCH

# Public goals

.PHONY: fix
fix: prettier_fix trimmer_fix

.PHONY: check
check: doctor lint analyze test coverage memcheck all san audit

.PHONY: doctor
doctor: git_check npm_config_check npm_doctor cc_check

.PHONY: lint
lint: prettier_check trimmer_check

.PHONY: test
test:
	cmake --workflow --preset dev

.PHONY: analyze
analyze: npm_check
	cmake --workflow --preset analyzer

.PHONY: coverage
coverage:
	rm --force --recursive --one-file-system -- ./out/build/coverage
	cmake --workflow --preset coverage
	cd ./out/build/coverage && LC_ALL=C gcov --branch-counts --branch-probabilities --conditions --function-summaries $$(find . -name '*.gcda')
	cd ./out/build/coverage && LC_ALL=C gcov --branch-counts --branch-probabilities --conditions --function-summaries $$(find . -name '*.gcda') | awk -v lines_min="$(COVERAGE_MIN)" -v branch_min="$(COVERAGE_BRANCH_MIN)" -v calls_min="$(COVERAGE_CALL_MIN)" -v cond_min="$(COVERAGE_CONDITION_MIN)" 'BEGIN { bad = 0 } /^Lines executed:/ { coverage = $$2; sub(/^[^:]*:/, "", coverage); sub(/%$$/, "", coverage); if (lines_min != "" && coverage + 0 < lines_min + 0) { print "lines below minimum: " $$0 > "/dev/stderr"; bad = 1 } } /^Taken at least once:/ { coverage = $$4; sub(/^[^:]*:/, "", coverage); sub(/%$$/, "", coverage); if (branch_min != "" && coverage + 0 < branch_min + 0) { print "branches below minimum: " $$0 > "/dev/stderr"; bad = 1 } } /^Calls executed:/ { coverage = $$2; sub(/^[^:]*:/, "", coverage); sub(/%$$/, "", coverage); if (calls_min != "" && coverage + 0 < calls_min + 0) { print "calls below minimum: " $$0 > "/dev/stderr"; bad = 1 } } /^Condition outcomes covered:/ { coverage = $$2; sub(/^[^:]*:/, "", coverage); sub(/%$$/, "", coverage); if (cond_min != "" && coverage + 0 < cond_min + 0) { print "conditions below minimum: " $$0 > "/dev/stderr"; bad = 1 } } END { exit bad }'

.PHONY: memcheck
memcheck:
	cmake --workflow --preset memcheck
	ctest --test-dir ./out/build/valgrind --output-on-failure -T MemCheck

.PHONY: audit
audit: npm_audit

.PHONY: update
update: npm_config_check ./package.json ./package-lock.json npm_update

.PHONY: san
san:
	cmake --workflow --preset asan
	cmake --workflow --preset ubsan
	cmake --workflow --preset tsan
	cmake --workflow --preset lsan

.PHONY: all
all:
	cmake --workflow --preset build-linux-amd64-v1
	cmake --workflow --preset build-linux-amd64-v2
	cmake --workflow --preset build-linux-amd64-v3

.PHONY: dist
dist: dist_metadata_check
	cmake --workflow --preset dist-linux-amd64-v1
	cmake --workflow --preset dist-linux-amd64-v2
	cmake --workflow --preset dist-linux-amd64-v3

.PHONY: native
native:
	cmake --workflow --preset native

.PHONY: install
install: native
	DESTDIR="$(DESTDIR)" cmake --install ./out/build/native --prefix "$(prefix)"

.PHONY: uninstall
uninstall:
	rm --force -- "$(DESTDIR)$(prefix)/bin/$(PROGRAM)"
	rm --force -- "$(DESTDIR)$(prefix)/lib/libtemplate_iso_c_app.a"
	rm --force -- "$(DESTDIR)$(prefix)/include/template_iso_c/todo.h"
	rm --force -- "$(DESTDIR)$(prefix)/include/template_iso_c/export.h"
	rm --force -- "$(DESTDIR)$(prefix)/lib/cmake/template-iso-c/template-iso-cConfig.cmake"
	rm --force -- "$(DESTDIR)$(prefix)/lib/cmake/template-iso-c/template-iso-cConfigVersion.cmake"
	rm --force -- "$(DESTDIR)$(prefix)/lib/cmake/template-iso-c/template-iso-cTargets.cmake"
	rm --force -- "$(DESTDIR)$(prefix)/lib/cmake/template-iso-c/template-iso-cTargets-release.cmake"
	rm --force -- "$(DESTDIR)$(prefix)/share/doc/template-iso-c/LICENSE"

.PHONY: installcheck
installcheck:
	test -f "$(DESTDIR)$(prefix)/bin/$(PROGRAM)"
	test -x "$(DESTDIR)$(prefix)/bin/$(PROGRAM)"
	test -f "$(DESTDIR)$(prefix)/lib/libtemplate_iso_c_app.a"
	test -f "$(DESTDIR)$(prefix)/include/template_iso_c/todo.h"
	test -f "$(DESTDIR)$(prefix)/include/template_iso_c/export.h"
	test -f "$(DESTDIR)$(prefix)/lib/cmake/template-iso-c/template-iso-cConfig.cmake"
	test -f "$(DESTDIR)$(prefix)/lib/cmake/template-iso-c/template-iso-cConfigVersion.cmake"
	test -f "$(DESTDIR)$(prefix)/lib/cmake/template-iso-c/template-iso-cTargets.cmake"
	test -f "$(DESTDIR)$(prefix)/lib/cmake/template-iso-c/template-iso-cTargets-release.cmake"
	test -f "$(DESTDIR)$(prefix)/share/doc/template-iso-c/LICENSE"

.PHONY: stage
stage: native
	cmake --install ./out/build/native --prefix ./stage/usr/local

.PHONY: deploy
deploy:
	$(SUDO) install --directory -- $(DESTDIR)$(prefix)
	$(SUDO) cp --archive -- stage/usr/local/. $(DESTDIR)$(prefix)/

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
	docker container ls --quiet --filter "$(DEVCONTAINER_FILTER)" | while IFS= read -r container; do docker container stop "$$container"; done

.PHONY: down
down: stop
	docker container ls --all --quiet --filter "$(DEVCONTAINER_FILTER)" | while IFS= read -r container; do docker container rm "$$container"; done

.PHONY: rebuild
rebuild: devcontainer_check down
	devcontainer up --workspace-folder . --build-no-cache

.PHONY: clean
clean:
	rm --force --recursive --one-file-system -- ./dist ./out ./stage

.PHONY: distclean
distclean: clean deps_clean

# Protected goals

.PHONY: deps_install
deps_install: npm_install

.PHONY: deps_clean
deps_clean: npm_clean

.PHONY: dist_metadata_check
dist_metadata_check:
	if [[ ! "$${SOURCE_DATE_EPOCH}" =~ ^[0-9]+$$ ]]; then printf '%s\n' 'SOURCE_DATE_EPOCH must contain only decimal digits' >&2; exit 1; fi
	if [[ ! "$${VERSION}" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]*$$ ]]; then printf '%s\n' 'VERSION contains unsupported characters' >&2; exit 1; fi

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

.PHONY: devcontainer_check
devcontainer_check:
	devcontainer read-configuration --workspace-folder . >/dev/null
	docker build --check --file ./.devcontainer/Dockerfile ./.devcontainer

# Private targets

./node_modules/.package-lock.json: ./.npmrc ./package.json ./package-lock.json
	$(MAKE) npm_install
