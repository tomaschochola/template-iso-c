#include "cli.h"
#include "cli_config.h"

#include <stdlib.h>

[[nodiscard]] int main(int argc, char *argv[]) {
    if (cli_run(argc, argv, 0) != 0) {
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
