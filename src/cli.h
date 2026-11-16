#pragma once

#include <argp.h>

[[nodiscard]] error_t cli_run(int argument_count, char *arguments[], unsigned flags);
