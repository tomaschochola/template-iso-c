#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "cli.h"
#include "cli_config.h"

#ifdef NDEBUG
#error "Unit tests require assertions"
#endif

static void test_version_metadata(void) {
    assert(argp_program_version != nullptr);
    assert(strcmp(argp_program_version, APP_NAME " " APP_VERSION) == 0);
}

static void test_no_arguments(void) {
    char *arguments[] = {APP_NAME, nullptr};
    const error_t result = cli_run(1, arguments, ARGP_SILENT);
    assert(result == 0);
}

static void test_option_terminator(void) {
    char *arguments[] = {APP_NAME, "--", nullptr};
    const error_t result = cli_run(2, arguments, ARGP_SILENT);
    assert(result == 0);
}

static void test_unknown_option(void) {
    char *arguments[] = {APP_NAME, "--unknown", nullptr};
    const error_t result = cli_run(2, arguments, ARGP_SILENT);
    assert(result != 0);
}

static void test_unexpected_operand(void) {
    char *arguments[] = {APP_NAME, "operand", nullptr};
    const error_t result = cli_run(2, arguments, ARGP_SILENT);
    assert(result != 0);
}

static void test_empty_operand(void) {
    char *arguments[] = {APP_NAME, "", nullptr};
    const error_t result = cli_run(2, arguments, ARGP_SILENT);
    assert(result != 0);
}

static void test_operand_after_terminator(void) {
    char *arguments[] = {APP_NAME, "--", "operand", nullptr};
    const error_t result = cli_run(3, arguments, ARGP_SILENT);
    assert(result != 0);
}

[[nodiscard]] int main(void) {
    test_version_metadata();
    test_no_arguments();
    test_option_terminator();
    test_operand_after_terminator();
    test_unknown_option();
    test_unexpected_operand();
    test_empty_operand();

    return EXIT_SUCCESS;
}
