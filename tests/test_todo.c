#include "test_support.h"

#include "todo.h"

static void test_todo_returns_zero(void)
{
    EXPECT_TRUE(template_iso_c_todo() == 0);
}

int main(void)
{
    test_todo_returns_zero();

    return test_done();
}
