#include <assert.h>

#include "todo.h"

static void test_todo_returns_zero(void)
{
    assert(template_iso_c_todo() == 0);
}

int main(void)
{
    test_todo_returns_zero();

    return 0;
}
