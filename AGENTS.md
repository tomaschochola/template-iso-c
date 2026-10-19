# AGENTS.md

Do serious software engineering and serious computer science in ISO/IEC 9899:2024 C (`-std=c23`) for native 64-bit little-endian GNU/Linux (LP64) on Linux 7.x with glibc 2.43. Target `x86_64-pc-linux-gnu` across x86-64-v1, x86-64-v2, and x86-64-v3 and `aarch64-linux-gnu` across armv8-a and armv9-a. Always define `_GNU_SOURCE=1` to use public glibc APIs, including GNU extensions, Linux-specific interfaces, POSIX.1-2024 (`_POSIX_C_SOURCE=202405L`) and XSI (`_XOPEN_SOURCE=800`). Use Linux UAPI where needed; keep ISO C23 syntax, not the GNU C dialect, staying GNU/Linux native. Do not target Windows, macOS, or any other operating system, nor architectures, ISAs, or triples outside the build matrix below. Do not add backward compatibility, legacy support, or broad portability shims.

## Target

- OS: GNU/Linux
- Kernel: Linux 7.x
- Triple: x86_64-pc-linux-gnu, aarch64-linux-gnu
- Arch: x86_64, aarch64
- Bits: 64-bit, LP64, little-endian
- ISA: x86-64-v1, x86-64-v2, x86-64-v3, armv8-a, armv9-a
- Libc: glibc 2.43
- Interfaces: glibc public APIs, GNU extensions, Linux UAPI, POSIX.1-2024, XSI, ISO C23

## Language

- `-std=c23`
- `-Wall -Wextra -Wpedantic -pedantic-errors`

## Features

glibc 2.43 feature-test macros enabled by `_GNU_SOURCE=1`:

- `_ISOC95_SOURCE=1`
- `_ISOC99_SOURCE=1`
- `_ISOC11_SOURCE=1`
- `_ISOC23_SOURCE=1`
- `_ISOC2Y_SOURCE=1`
- `_POSIX_SOURCE=1`
- `_POSIX_C_SOURCE=202405L`
- `_XOPEN_SOURCE=800`
- `_XOPEN_SOURCE_EXTENDED=1`
- `_LARGEFILE_SOURCE=1`
- `_LARGEFILE64_SOURCE=1`
- `_DEFAULT_SOURCE=1`
- `_ATFILE_SOURCE=1`
- `_DYNAMIC_STACK_SIZE_SOURCE=1`

## Stack

- gcc 16.0.1
- glibc 2.43
- cmake 4.4.4
- ninja 1.13.2
- ctest 4.4.4
- valgrind 3.26.0
- cpack 4.4.4
- gcov 16.0.1
- gcovr 7.2
- python3 3.14.4
- clang-format 21.1.8
- node 24.22.0
- npm 11.19.1

## Libs

- libcurl: `libcurl4-openssl-dev`
- json-c: `libjson-c-dev`
- SQLite: `libsqlite3-dev`, `sqlite3`

## API preference

Target defines the available interfaces. Preference order when several APIs fit: GNU extensions > Linux-specific interfaces > POSIX.1-2024 base interfaces > XSI extensions > ISO C23 library interfaces > vetted third-party libraries > direct Linux system calls > custom implementations

Prefer public glibc wrappers to direct syscalls. Do not reimplement what the installed libraries provide.

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
Standard: Latest
ColumnLimit: 200
IndentWidth: 4
ContinuationIndentWidth: 4
BreakBeforeBraces: Linux
AllowShortFunctionsOnASingleLine: None
MaxEmptyLinesToKeep: 1
SortIncludes: true
InsertNewlineAtEOF: true
LineEnding: LF
UseTab: Never
...
```

## Tree

```text
.
├── AGENTS.md
├── AUTHORS.md
├── .clang-format
├── CMakeLists.txt
├── CMakePresets.json
├── .devcontainer/
│   ├── devcontainer.json
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── .dockerignore
├── .editorconfig
├── .gitattributes
├── .gitignore
├── LICENSE
├── Makefile
├── .npmrc
├── package.json
├── package-lock.json
├── prettier.config.js
├── .prettierignore
├── src/
│   ├── CMakeLists.txt
│   └── ...
└── tests/
    ├── CMakeLists.txt
    └── ...
```

## Devcontainer Boundary

The host is the workstation for editing, Git operations and container lifecycle, while the devcontainer runs all non-host targets. Writes produced by those targets are allowed, so do not run them on the host.

Use `devcontainer` for lifecycle and execution, `docker` for individual containers and `docker compose` for services and sidecars, starting once with `make up` before the first `devcontainer exec` and reusing the environment afterward.

Pass arguments as argv. Use `env` for variables and an explicit shell for shell syntax.

```bash
make up
devcontainer exec --workspace-folder . <program> [arguments...]
devcontainer exec --workspace-folder . env NAME=value <program> [arguments...]
devcontainer exec --workspace-folder . make <target> [VARIABLE=value ...]
devcontainer exec --workspace-folder . /bin/bash -Eeuo pipefail -c '<make commands>'
devcontainer exec --workspace-folder . /bin/sh -eu -c '<make commands>'
docker <command> [arguments...]
docker compose -f .devcontainer/docker-compose.yml <command> [arguments...]
docker compose -f .devcontainer/docker-compose.yml exec -T <service> <program> [arguments...]
```

## Makefile

Run repository tasks with Make targets, on the host or in the devcontainer per mark: `[host]` means host only via `host_gate`, `[devcontainer]` means devcontainer only via `devcontainer_gate`, `[interactive]` means terminal required via `interactive_gate`.

- `fix`: `prettier_fix` + `clang_format_fix` + `trimmer_fix`
- `check` [devcontainer]: `doctor` + `lint` + `fanalyzer` + `test` + `coverage` + `valgrind` + `all` + `sanitize` + `audit`
- `doctor`: `git_check` + `npm_config_check` + `npm_doctor` + `npm_check` + `toolchain_check`
- `lint`: `prettier_check` + `clang_format_check` + `trimmer_check`
- `test` [devcontainer]: configure, build and test via test workflow
- `fanalyzer` [devcontainer]: configure, build and test via fanalyzer workflow
- `coverage` [devcontainer]: configure, build, test and report coverage for src
- `valgrind` [devcontainer]: configure, build and memcheck tests
- `asan` [devcontainer]: configure, build and test via asan workflow
- `ubsan` [devcontainer]: configure, build and test via ubsan workflow
- `tsan` [devcontainer]: configure, build and test via tsan workflow
- `lsan` [devcontainer]: configure, build and test via lsan workflow
- `sanitize` [devcontainer]: `asan` + `ubsan` + `tsan` + `lsan`
- `native`: native release build
- `release`: release build
- `debug`: debug build
- `linux_amd64_v1`: release build for x86-64-v1
- `linux_amd64_v2`: release build for x86-64-v2
- `linux_amd64_v3`: release build for x86-64-v3
- `linux_arm64_armv8_a`: release build for armv8-a
- `linux_arm64_armv9_a`: release build for armv9-a
- `all`: `debug` + `native` + `release`
- `dist_native`: native cpack tarball
- `dist_debug`: debug cpack tarball
- `dist_release`: release cpack tarball
- `dist_linux_amd64_v1`: cpack tarball for x86-64-v1
- `dist_linux_amd64_v2`: cpack tarball for x86-64-v2
- `dist_linux_amd64_v3`: cpack tarball for x86-64-v3
- `dist_linux_arm64_armv8_a`: cpack tarball for armv8-a
- `dist_linux_arm64_armv9_a`: cpack tarball for armv9-a
- `dist`: `dist_native` + `dist_debug` + `dist_release`
- `audit`: audit npm dependencies
- `install`: install native release
- `uninstall`: remove installed binary and documentation
- `installcheck`: verify installed binary and license
- `update`: `npm_config_check` + `npm_update`
- `postcreate`: `deps_install` + `toolchain_check`
- `up` [host]: check config and start devcontainer
- `shell` [host] [interactive]: open shell in devcontainer via `up`
- `stop` [host]: stop devcontainer
- `down` [host]: remove compose services and networks
- `clean`: remove out, dist and devcontainer tmp
- `distclean`: `clean` + `deps_clean`
- `rebuild` [host]: check config, drop containers and rebuild devcontainer
- `nuke`: `distclean` + `prune`
- `prune` [host]: remove containers, networks, volumes and images
- `deps_install`: install npm dependencies
- `deps_clean`: remove node_modules
- `trimmer_fix`: fix with trimmer
- `trimmer_check`: check with trimmer
- `prettier_fix`: fix with prettier
- `prettier_check`: check with prettier
- `clang_format_fix`: fix C sources with clang-format
- `clang_format_check`: check C sources with clang-format
- `npm_config_check`: verify npm config
- `npm_doctor`: check npm connectivity and setup
- `npm_check`: verify npm tree via `npm_config_check`
- `npm_audit`: audit npm dependencies via `npm_config_check`
- `npm_install`: install npm dependencies via `npm_config_check`
- `npm_update`: clean and update npm dependencies via `npm_config_check`
- `npm_clean`: remove node_modules
- `git_check`: verify clean git tree
- `toolchain_check`: print toolchain versions
- `devcontainer_check` [host]: validate devcontainer config
- `host_gate` [host]: fail inside container
- `interactive_gate` [interactive]: fail without terminal, required by `shell`
- `devcontainer_gate` [devcontainer]: fail outside devcontainer

## Workflows

- `test`: configure, build and test with debug preset
- `fanalyzer`: configure, build and test with fanalyzer preset
- `asan`: configure, build and test with asan preset
- `ubsan`: configure, build and test with ubsan preset
- `tsan`: configure, build and test with tsan preset
- `lsan`: configure, build and test with lsan preset
- `valgrind`: configure and build with valgrind preset
- `coverage`: configure, build and test with coverage preset
- `build-debug`: configure and build with debug preset
- `build-linux-amd64-v1`: configure and build for x86-64-v1
- `build-linux-amd64-v2`: configure and build for x86-64-v2
- `build-linux-amd64-v3`: configure and build for x86-64-v3
- `build-linux-arm64-armv8-a`: configure and build for armv8-a
- `build-linux-arm64-armv9-a`: configure and build for armv9-a
- `build-native`: configure and build for native architecture
- `build-release`: configure and build for release
- `dist-linux-amd64-v1`: configure, build and package for x86-64-v1
- `dist-linux-amd64-v2`: configure, build and package for x86-64-v2
- `dist-linux-amd64-v3`: configure, build and package for x86-64-v3
- `dist-linux-arm64-armv8-a`: configure, build and package for armv8-a
- `dist-linux-arm64-armv9-a`: configure, build and package for armv9-a
- `dist-native`: configure, build and package for native architecture
- `dist-debug`: configure, build and package with debug preset
- `dist-release`: configure, build and package for release

## Quality gate

Mirror each `src` unit with `tests/test_*.c`. `src/main.c` is covered by `integration.main`, no `tests/test_main.c` needed, and require 100% line and function coverage in `src`, enforced by gcovr with gcov. Collect from the full coverage build, filter to `src`, exclude tests from report and gate. No exclusion markers, no suppressed collection or parsing errors. Fault injection with test-only `ld --wrap`, production code unchanged.

WireMock tests use `WIREMOCK_URL` and `RESOURCE_LOCK wiremock`. Finish with `make fix`, then `make check`. Both must pass with no warnings, failures, leaks, or audit findings. On failure fix code or tests and repeat. Never leave a red `make check`.

## ISO/IEC 9899:2024

### Language syntax

```text
token:
	keyword
	identifier
	constant
	string-literal
	punctuator
preprocessing-token:
	header-name
	identifier
	pp-number
	character-constant
	string-literal
	punctuator
	each universal character name that cannot be one of the above
	each non-white-space character that cannot be one of the above
keyword: one of
	alignas do int struct while
	alignof double long switch _Atomic
	auto else nullptr thread_local _BitInt
	bool enum register true _Complex
	break extern restrict typedef _Decimal128
	case false return typeof _Decimal32
	char float short typeof_unqual _Decimal64
	const for signed union _Generic
	constexpr goto sizeof unsigned _Imaginary
	continue if static void _Noreturn
	default inline static_assert volatile
identifier:
	identifier-start
	identifier identifier-continue
identifier-start:
	nondigit
	XID_Start character
	universal character name of class XID_Start
identifier-continue:
	digit
	nondigit
	XID_Continue character
	universal character name of class XID_Continue
nondigit: one of
	_ a b c d e f g h i j k l m
	n o p q r s t u v w x y z
	A B C D E F G H I J K L M
	N O P Q R S T U V W X Y Z
digit: one of
	0 1 2 3 4 5 6 7 8 9
universal-character-name:
	\u hex-quad
	\U hex-quad hex-quad
hex-quad:
	hexadecimal-digit hexadecimal-digit hexadecimal-digit hexadecimal-digit
constant:
	integer-constant
	floating-constant
	enumeration-constant
	character-constant
	predefined-constant
integer-constant:
	decimal-constant integer-suffixopt
	octal-constant integer-suffixopt
	hexadecimal-constant integer-suffixopt
	binary-constant integer-suffixopt
decimal-constant:
	nonzero-digit
	decimal-constant ’opt digit
octal-constant:
	0
	octal-constant ’opt octal-digit
hexadecimal-constant:
	hexadecimal-prefix hexadecimal-digit-sequence
binary-constant:
	binary-prefix binary-digit
	binary-constant ’opt binary-digit
hexadecimal-prefix: one of
	0x 0X
binary-prefix: one of
	0b 0B
nonzero-digit: one of
	1 2 3 4 5 6 7 8 9
octal-digit: one of
	0 1 2 3 4 5 6 7
hexadecimal-digit-sequence:
	hexadecimal-digit
	hexadecimal-digit-sequence ’opt hexadecimal-digit
hexadecimal-digit: one of
	0 1 2 3 4 5 6 7 8 9
	a b c d e f
	A B C D E F
binary-digit: one of
	0 1
integer-suffix:
	unsigned-suffix long-suffixopt
	unsigned-suffix long-long-suffix
	unsigned-suffix bit-precise-int-suffix
	long-suffix unsigned-suffixopt
	long-long-suffix unsigned-suffixopt
	bit-precise-int-suffix unsigned-suffixopt
bit-precise-int-suffix: one of
	wb WB
unsigned-suffix: one of
	u U
long-suffix: one of
	l L
long-long-suffix: one of
	ll LL
floating-constant:
	decimal-floating-constant
	hexadecimal-floating-constant
decimal-floating-constant:
	fractional-constant exponent-partopt floating-suffixopt
	digit-sequence exponent-part floating-suffixopt
hexadecimal-floating-constant:
	hexadecimal-prefix hexadecimal-fractional-constant binary-exponent-part floating-suffixopt
	hexadecimal-prefix hexadecimal-digit-sequence binary-exponent-part floating-suffixopt
fractional-constant:
	digit-sequenceopt . digit-sequence
	digit-sequence .
exponent-part:
	e signopt digit-sequence
	E signopt digit-sequence
sign: one of
	+ -
digit-sequence:
	digit
	digit-sequence ’opt digit
hexadecimal-fractional-constant:
	hexadecimal-digit-sequenceopt . hexadecimal-digit-sequence
	hexadecimal-digit-sequence .
binary-exponent-part:
	p signopt digit-sequence
	P signopt digit-sequence
floating-suffix: one of
	f l F L df dd dl DF DD DL
enumeration-constant:
	identifier
character-constant:
	encoding-prefixopt ’ c-char-sequence ’
encoding-prefix: one of
	u8 u U L
c-char-sequence:
	c-char
	c-char-sequence c-char
c-char:
	any member of the source character set except the single-quote ’, backslash \, or new-line character
	escape-sequence
escape-sequence:
	simple-escape-sequence
	octal-escape-sequence
	hexadecimal-escape-sequence
	universal-character-name
simple-escape-sequence: one of
	\’ \" \? \\
	\a \b \f \n \r \t \v
octal-escape-sequence:
	\ octal-digit
	\ octal-digit octal-digit
	\ octal-digit octal-digit octal-digit
hexadecimal-escape-sequence:
	\x hexadecimal-digit
	hexadecimal-escape-sequence hexadecimal-digit
predefined-constant:
	false
	true
	nullptr
string-literal:
	encoding-prefixopt " s-char-sequenceopt "
s-char-sequence:
	s-char
	s-char-sequence s-char
s-char:
	any member of the source character set except the double-quote ", backslash \, or new-line character
	escape-sequence
punctuator: one of
	[ ] ( ) { } . ->
	++ -- & * + - ~ !
	/ % << >> < > <= >= == != ^ | && ||
	? : :: ; ...
	= *= /= %= += -= <<= >>= &= ^= |=
	, # ##
	<: :> <% %> %: %:%:
header-name:
	< h-char-sequence >
	" q-char-sequence "
h-char-sequence:
	h-char
	h-char-sequence h-char
h-char:
	any member of the source character set except the new-line character and >
q-char-sequence:
	q-char
	q-char-sequence q-char
q-char:
	any member of the source character set except the new-line character and "
pp-number:
	digit
	. digit
	pp-number identifier-continue
	pp-number ’ digit
	pp-number ’ nondigit
	pp-number e sign
	pp-number E sign
	pp-number p sign
	pp-number P sign
	pp-number .
primary-expression:
	identifier
	constant
	string-literal
	( expression )
	generic-selection
generic-selection:
	_Generic ( assignment-expression , generic-assoc-list )
generic-assoc-list:
	generic-association
	generic-assoc-list , generic-association
generic-association:
	type-name : assignment-expression
	default : assignment-expression
postfix-expression:
	primary-expression
	postfix-expression [ expression ]
	postfix-expression ( argument-expression-listopt )
	postfix-expression . identifier
	postfix-expression -> identifier
	postfix-expression ++
	postfix-expression --
	compound-literal
argument-expression-list:
	assignment-expression
	argument-expression-list , assignment-expression
compound-literal:
	( storage-class-specifiersopt type-name ) braced-initializer
storage-class-specifiers:
	storage-class-specifier
	storage-class-specifiers storage-class-specifier
unary-expression:
	postfix-expression
	++ unary-expression
	-- unary-expression
	unary-operator cast-expression
	sizeof unary-expression
	sizeof ( type-name )
	alignof ( type-name )
unary-operator: one of
	& * + - ~ !
cast-expression:
	unary-expression
	( type-name ) cast-expression
multiplicative-expression:
	cast-expression
	multiplicative-expression * cast-expression
	multiplicative-expression / cast-expression
	multiplicative-expression % cast-expression
additive-expression:
	multiplicative-expression
	additive-expression + multiplicative-expression
	additive-expression - multiplicative-expression
shift-expression:
	additive-expression
	shift-expression << additive-expression
	shift-expression >> additive-expression
relational-expression:
	shift-expression
	relational-expression < shift-expression
	relational-expression > shift-expression
	relational-expression <= shift-expression
	relational-expression >= shift-expression
equality-expression:
	relational-expression
	equality-expression == relational-expression
	equality-expression != relational-expression
AND-expression:
	equality-expression
	AND-expression & equality-expression
exclusive-OR-expression:
	AND-expression
	exclusive-OR-expression ^ AND-expression
inclusive-OR-expression:
	exclusive-OR-expression
	inclusive-OR-expression | exclusive-OR-expression
logical-AND-expression:
	inclusive-OR-expression
	logical-AND-expression && inclusive-OR-expression
logical-OR-expression:
	logical-AND-expression
	logical-OR-expression || logical-AND-expression
conditional-expression:
	logical-OR-expression
	logical-OR-expression ? expression : conditional-expression
assignment-expression:
	conditional-expression
	unary-expression assignment-operator assignment-expression
assignment-operator: one of
	= *= /= %= += -= <<= >>= &= ^= |=
expression:
	assignment-expression
	expression , assignment-expression
constant-expression:
	conditional-expression
declaration:
	declaration-specifiers init-declarator-listopt ;
	attribute-specifier-sequence declaration-specifiers init-declarator-list ;
	static_assert-declaration
	attribute-declaration
declaration-specifiers:
	declaration-specifier attribute-specifier-sequenceopt
	declaration-specifier declaration-specifiers
declaration-specifier:
	storage-class-specifier
	type-specifier-qualifier
	function-specifier
init-declarator-list:
	init-declarator
	init-declarator-list , init-declarator
init-declarator:
	declarator
	declarator = initializer
attribute-declaration:
	attribute-specifier-sequence ;
storage-class-specifier:
	auto
	constexpr
	extern
	register
	static
	thread_local
	typedef
type-specifier:
	void
	char
	short
	int
	long
	float
	double
	signed
	unsigned
	_BitInt ( constant-expression )
	bool
	_Complex
	_Decimal32
	_Decimal64
	_Decimal128
	atomic-type-specifier
	struct-or-union-specifier
	enum-specifier
	typedef-name
	typeof-specifier
struct-or-union-specifier:
	struct-or-union attribute-specifier-sequenceopt identifieropt { member-declaration-list }
	struct-or-union attribute-specifier-sequenceopt identifier
struct-or-union:
	struct
	union
member-declaration-list:
	member-declaration
	member-declaration-list member-declaration
member-declaration:
	attribute-specifier-sequenceopt specifier-qualifier-list member-declarator-listopt ;
	static_assert-declaration
specifier-qualifier-list:
	type-specifier-qualifier attribute-specifier-sequenceopt
	type-specifier-qualifier specifier-qualifier-list
type-specifier-qualifier:
	type-specifier
	type-qualifier
	alignment-specifier
member-declarator-list:
	member-declarator
	member-declarator-list , member-declarator
member-declarator:
	declarator
	declaratoropt : constant-expression
enum-specifier:
	enum attribute-specifier-sequenceopt identifieropt enum-type-specifieropt { enumerator-list }
	enum attribute-specifier-sequenceopt identifieropt enum-type-specifieropt { enumerator-list , }
	enum identifier enum-type-specifieropt
enumerator-list:
	enumerator
	enumerator-list , enumerator
enumerator:
	enumeration-constant attribute-specifier-sequenceopt
	enumeration-constant attribute-specifier-sequenceopt = constant-expression
enum-type-specifier:
	: specifier-qualifier-list
atomic-type-specifier:
	_Atomic ( type-name )
typeof-specifier:
	typeof ( typeof-specifier-argument )
	typeof_unqual ( typeof-specifier-argument )
typeof-specifier-argument:
	expression
	type-name
type-qualifier:
	const
	restrict
	volatile
	_Atomic
function-specifier:
	inline
	_Noreturn
alignment-specifier:
	alignas ( type-name )
	alignas ( constant-expression )
declarator:
	pointeropt direct-declarator
direct-declarator:
	identifier attribute-specifier-sequenceopt
	( declarator )
	array-declarator attribute-specifier-sequenceopt
	function-declarator attribute-specifier-sequenceopt
array-declarator:
	direct-declarator [ type-qualifier-listopt assignment-expressionopt ]
	direct-declarator [ static type-qualifier-listopt assignment-expression ]
	direct-declarator [ type-qualifier-list static assignment-expression ]
	direct-declarator [ type-qualifier-listopt * ]
function-declarator:
	direct-declarator ( parameter-type-listopt )
pointer:
	* attribute-specifier-sequenceopt type-qualifier-listopt
	* attribute-specifier-sequenceopt type-qualifier-listopt pointer
type-qualifier-list:
	type-qualifier
	type-qualifier-list type-qualifier
parameter-type-list:
	parameter-list
	parameter-list , ...
	...
parameter-list:
	parameter-declaration
	parameter-list , parameter-declaration
parameter-declaration:
	attribute-specifier-sequenceopt declaration-specifiers declarator
	attribute-specifier-sequenceopt declaration-specifiers abstract-declaratoropt
type-name:
	specifier-qualifier-list abstract-declaratoropt
abstract-declarator:
	pointer
	pointeropt direct-abstract-declarator
direct-abstract-declarator:
	( abstract-declarator )
	array-abstract-declarator attribute-specifier-sequenceopt
	function-abstract-declarator attribute-specifier-sequenceopt
array-abstract-declarator:
	direct-abstract-declaratoropt [ type-qualifier-listopt assignment-expressionopt ]
	direct-abstract-declaratoropt [ static type-qualifier-listopt assignment-expression ]
	direct-abstract-declaratoropt [ type-qualifier-list static assignment-expression ]
	direct-abstract-declaratoropt [ * ]
function-abstract-declarator:
	direct-abstract-declaratoropt ( parameter-type-listopt )
typedef-name:
	identifier
braced-initializer:
	{ }
	{ initializer-list }
	{ initializer-list , }
initializer:
	assignment-expression
	braced-initializer
initializer-list:
	designationopt initializer
	initializer-list , designationopt initializer
designation:
	designator-list =
designator-list:
	designator
	designator-list designator
designator:
	[ constant-expression ]
	. identifier
static_assert-declaration:
	static_assert ( constant-expression , string-literal ) ;
	static_assert ( constant-expression ) ;
attribute-specifier-sequence:
	attribute-specifier-sequenceopt attribute-specifier
attribute-specifier:
	[ [ attribute-list ] ]
attribute-list:
	attributeopt
	attribute-list , attributeopt
attribute:
	attribute-token attribute-argument-clauseopt
attribute-token:
	standard-attribute
	attribute-prefixed-token
standard-attribute:
	identifier
attribute-prefixed-token:
	attribute-prefix :: identifier
attribute-prefix:
	identifier
attribute-argument-clause:
	( balanced-token-sequenceopt )
balanced-token-sequence:
	balanced-token
	balanced-token-sequence balanced-token
balanced-token:
	( balanced-token-sequenceopt )
	[ balanced-token-sequenceopt ]
	{ balanced-token-sequenceopt }
	any token other than a parenthesis, a bracket, or a brace
statement:
	labeled-statement
	unlabeled-statement
unlabeled-statement:
	expression-statement
	attribute-specifier-sequenceopt primary-block
	attribute-specifier-sequenceopt jump-statement
primary-block:
	compound-statement
	selection-statement
	iteration-statement
secondary-block:
	statement
label:
	attribute-specifier-sequenceopt identifier :
	attribute-specifier-sequenceopt case constant-expression :
	attribute-specifier-sequenceopt default :
labeled-statement:
	label statement
compound-statement:
	{ block-item-listopt }
block-item-list:
	block-item
	block-item-list block-item
block-item:
	declaration
	unlabeled-statement
	label
expression-statement:
	expressionopt ;
	attribute-specifier-sequence expression ;
selection-statement:
	if ( expression ) secondary-block
	if ( expression ) secondary-block else secondary-block
	switch ( expression ) secondary-block
iteration-statement:
	while ( expression ) secondary-block
	do secondary-block while ( expression ) ;
	for ( expressionopt ; expressionopt ; expressionopt ) secondary-block
	for ( declaration expressionopt ; expressionopt ) secondary-block
jump-statement:
	goto identifier ;
	continue ;
	break ;
	return expressionopt ;
translation-unit:
	external-declaration
	translation-unit external-declaration
external-declaration:
	function-definition
	declaration
function-definition:
	attribute-specifier-sequenceopt declaration-specifiers declarator function-body
function-body:
	compound-statement
preprocessing-file:
	groupopt
group:
	group-part
	group group-part
group-part:
	if-section
	control-line
	text-line
	# non-directive
if-section:
	if-group elif-groupsopt else-groupopt endif-line
if-group:
	# if constant-expression new-line groupopt
	# ifdef identifier new-line groupopt
	# ifndef identifier new-line groupopt
elif-groups:
	elif-group
	elif-groups elif-group
elif-group:
	# elif constant-expression new-line groupopt
	# elifdef identifier new-line groupopt
	# elifndef identifier new-line groupopt
else-group:
	# else new-line groupopt
endif-line:
	# endif new-line
control-line:
	# include pp-tokens new-line
	# embed pp-tokens new-line
	# define identifier replacement-list new-line
	# define identifier lparen identifier-listopt ) replacement-list new-line
	# define identifier lparen ... ) replacement-list new-line
	# define identifier lparen identifier-list , ... ) replacement-list new-line
	# undef identifier new-line
	# line pp-tokens new-line
	# error pp-tokensopt new-line
	# warning pp-tokensopt new-line
	# pragma pp-tokensopt new-line
	# new-line
text-line:
	pp-tokensopt new-line
non-directive:
	pp-tokens new-line
lparen:
	a ( character not immediately preceded by white space
replacement-list:
	pp-tokensopt
pp-tokens:
	preprocessing-token
	pp-tokens preprocessing-token
new-line:
	the new-line character
identifier-list:
	identifier
	identifier-list , identifier
pp-parameter:
	pp-parameter-name pp-parameter-clauseopt
pp-parameter-name:
	pp-standard-parameter
	pp-prefixed-parameter
pp-standard-parameter:
	identifier
pp-prefixed-parameter:
	identifier :: identifier
pp-parameter-clause:
	( pp-balanced-token-sequenceopt )
pp-balanced-token-sequence:
	pp-balanced-token
	pp-balanced-token-sequence pp-balanced-token
pp-balanced-token:
	( pp-balanced-token-sequenceopt )
	[ pp-balanced-token-sequenceopt ]
	{ pp-balanced-token-sequenceopt }
	any pp-token other than a parenthesis, a bracket, or a brace
embed-parameter-sequence:
	pp-parameter
	embed-parameter-sequence pp-parameter
defined-macro-expression:
	defined identifier
	defined ( identifier )
h-preprocessing-token:
	any preprocessing-token other than >
h-pp-tokens:
	h-preprocessing-token
	h-pp-tokens h-preprocessing-token
header-name-tokens:
	string-literal
	< h-pp-tokens >
has-include-expression:
	__has_include ( header-name )
	__has_include ( header-name-tokens )
has-embed-expression:
	__has_embed ( header-name embed-parameter-sequenceopt )
	__has_embed ( header-name-tokens pp-balanced-token-sequenceopt )
has-c-attribute-express:
	__has_c_attribute ( pp-tokens )
va-opt-replacement:
	__VA_OPT__ ( pp-tokensopt )
standard-pragma:
	# pragma STDC FP_CONTRACT on-off-switch
	# pragma STDC FENV_ACCESS on-off-switch
	# pragma STDC FENV_DEC_ROUND dec-direction
	# pragma STDC FENV_ROUND direction
	# pragma STDC CX_LIMITED_RANGE on-off-switch
on-off-switch: one of
	ON OFF DEFAULT
direction: one of
	FE_DOWNWARD FE_TONEAREST FE_TONEARESTFROMZERO
	FE_TOWARDZERO FE_UPWARD FE_DYNAMIC
dec-direction: one of
	FE_DEC_DOWNWARD FE_DEC_TONEAREST FE_DEC_TONEARESTFROMZERO
	FE_DEC_TOWARDZERO FE_DEC_UPWARD FE_DEC_DYNAMIC
n-char-sequence:
	digit
	nondigit
	n-char-sequence digit
	n-char-sequence nondigit
n-wchar-sequence:
	digit
	nondigit
	n-wchar-sequence digit
	n-wchar-sequence nondigit
d-char-sequence:
	digit
	nondigit
	d-char-sequence digit
	d-char-sequence nondigit
d-wchar-sequence:
	digit
	nondigit
	d-wchar-sequence digit
	d-wchar-sequence nondigit
```

### Implementation limits

```text
#define BOOL_WIDTH 1 // exact value
#define CHAR_BIT 8
#define USHRT_WIDTH 16
#define UINT_WIDTH 16
#define ULONG_WIDTH 32
#define ULLONG_WIDTH 64
#define BITINT_MAXWIDTH ULLONG_WIDTH // at minimum as large as unsigned long long
#define MB_LEN_MAX 1

#define BOOL_MAX 1 // 2^BOOL_WIDTH - 1
#define CHAR_MAX UCHAR_MAX or SCHAR_MAX
#define CHAR_MIN 0 or SCHAR_MIN
#define CHAR_WIDTH 8 // CHAR_BIT
#define UCHAR_MAX 255 // 2^UCHAR_WIDTH - 1
#define UCHAR_WIDTH 8 // CHAR_BIT
#define USHRT_MAX 65535 // 2^USHRT_WIDTH - 1
#define SCHAR_MAX +127 // 2^(SCHAR_WIDTH-1) - 1
#define SCHAR_MIN -128 // -2^(SCHAR_WIDTH-1)
#define SCHAR_WIDTH 8 // CHAR_BIT
#define SHRT_MAX +32767 // 2^(SHRT_WIDTH-1) - 1
#define SHRT_MIN -32768 // -2^(SHRT_WIDTH-1)
#define SHRT_WIDTH 16 // USHRT_WIDTH
#define INT_MAX +32767 // 2^(INT_WIDTH-1) - 1
#define INT_MIN -32768 // -2^(INT_WIDTH-1)
#define INT_WIDTH 16 // UINT_WIDTH
#define UINT_MAX 65535 // 2^UINT_WIDTH - 1
#define LONG_MAX +2147483647 // 2^(LONG_WIDTH-1) - 1
#define LONG_MIN -2147483648 // -2^(LONG_WIDTH-1)
#define LONG_WIDTH 32 // ULONG_WIDTH
#define LLONG_MAX +9223372036854775807 // 2^(LLONG_WIDTH-1) - 1
#define LLONG_MIN -9223372036854775808 // -2^(LLONG_WIDTH-1)
#define LLONG_WIDTH 64 // ULLONG_WIDTH
#define ULONG_MAX 4294967295 // 2^ULONG_WIDTH - 1
#define ULLONG_MAX 18446744073709551615 // 2^ULLONG_WIDTH - 1

#define FLT_EVAL_METHOD
#define FLT_ROUNDS

#ifdef __STDC_IEC_60559_DFP__
#define DEC_EVAL_METHOD
#endif

#define DBL_DECIMAL_DIG 10
#define DBL_DIG 10
#define DBL_MANT_DIG
#define DBL_MAX_10_EXP +37
#define DBL_MAX_EXP
#define DBL_MIN_10_EXP -37
#define DBL_MIN_EXP
#define DECIMAL_DIG 10
#define FLT_DECIMAL_DIG 6
#define FLT_DIG 6
#define FLT_MANT_DIG
#define FLT_MAX_10_EXP +37
#define FLT_MAX_EXP
#define FLT_MIN_10_EXP -37
#define FLT_MIN_EXP
#define FLT_RADIX 2
#define LDBL_DECIMAL_DIG 10
#define LDBL_DIG 10
#define LDBL_MANT_DIG
#define LDBL_MAX_10_EXP +37
#define LDBL_MAX_EXP
#define LDBL_MIN_10_EXP -37
#define LDBL_MIN_EXP

#define DBL_MAX 1E+37
#define DBL_NORM_MAX 1E+37
#define FLT_MAX 1E+37
#define FLT_NORM_MAX 1E+37
#define LDBL_MAX 1E+37
#define LDBL_NORM_MAX 1E+37

#define DBL_EPSILON 1E-9
#define DBL_MIN 1E-37
#define FLT_EPSILON 1E-5
#define FLT_MIN 1E-37
#define LDBL_EPSILON 1E-9
#define LDBL_MIN 1E-37

#ifdef __STDC_IEC_60559_DFP__
#define DEC32_EPSILON 1E-6DF
#define DEC32_MANT_DIG 7
#define DEC32_MAX 9.999999E96DF
#define DEC32_MAX_EXP 97
#define DEC32_MIN 1E-95DF
#define DEC32_MIN_EXP -94
#define DEC32_TRUE_MIN 0.000001E-95DF
#define DEC64_EPSILON 1E-15DD
#define DEC64_MANT_DIG 16
#define DEC64_MAX 9.999999999999999E384DD
#define DEC64_MAX_EXP 385
#define DEC64_MIN 1E-383DD
#define DEC64_MIN_EXP -382
#define DEC64_TRUE_MIN 0.000000000000001E-383DD
#define DEC128_EPSILON 1E-33DL
#define DEC128_MANT_DIG 34
#define DEC128_MAX 9.999999999999999999999999999999999E6144DL
#define DEC128_MAX_EXP 6145
#define DEC128_MIN 1E-6143DL
#define DEC128_MIN_EXP -6142
#define DEC128_TRUE_MIN 0.000000000000000000000000000000001E-6143DL
#endif
```
