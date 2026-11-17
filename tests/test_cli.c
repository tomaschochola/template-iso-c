#include <assert.h>
#include <stdlib.h>

#include "cli.h"
#include "cli_config.h"

#ifdef NDEBUG
#error NDEBUG
#endif

static void test_no_arguments(void) {
    char *arguments[] = {APP_NAME, nullptr};
    const error_t result = cli_run(1, arguments, ARGP_SILENT);
    assert(result == 0);
}

[[nodiscard]] int main(void) {
    test_no_arguments();

    return EXIT_SUCCESS;
}
