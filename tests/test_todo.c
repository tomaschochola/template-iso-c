#include <assert.h>

#include "todo.h"

static void test_app_todo_returns_zero(void)
{
    assert(app_todo() == 0);
}

[[nodiscard]] int main(void)
{
    test_app_todo_returns_zero();

    return 0;
}
