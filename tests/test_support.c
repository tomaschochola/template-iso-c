#include "test_support.h"

#include <stdio.h>
#include <stdlib.h>

static int failures = 0;

void test_check(bool ok, char const *file, int line, char const *func, char const *expr)
{
    if (!ok) {
        ++failures;
        (void)fprintf(stderr, "%s:%d:%s: FAILED: %s\n", file, line, func, expr);
    }
}

int test_done(void)
{
    if (failures != 0) {
        (void)fprintf(stderr, "%d failure(s)\n", failures);
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
