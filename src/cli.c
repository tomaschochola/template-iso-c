#include "cli.h"
#include "cli_config.h"

const char *argp_program_version = APP_NAME " " APP_VERSION;

error_t cli_run(int argument_count, char *arguments[], unsigned flags) {
    return argp_parse(nullptr, argument_count, arguments, flags, nullptr, nullptr);
}
