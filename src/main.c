#include "cli.h"
#include "cli_config.h"

#include <error.h>
#include <stdio.h>
#include <stdlib.h>

static void close_output(void) {
    bool failed = ferror(stdout) != 0;

    if (fclose(stdout) == EOF) {
        failed = true;
    }

    if (failed) {
        (void)fputs(APP_NAME ": could not write output\n", stderr);
        (void)fflush(stderr);
        _Exit(EXIT_FAILURE);
    }
}

[[nodiscard]] int main(int argc, char *argv[]) {
    if (atexit(close_output) != 0) {
        error(EXIT_FAILURE, 0, "could not register output cleanup");
    }

    if (cli_run(argc, argv, 0) != 0) {
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
