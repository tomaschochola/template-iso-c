#ifndef TEMPLATE_ISO_C_TEST_H
#define TEMPLATE_ISO_C_TEST_H

void test_check(bool ok, char const *file, int line, char const *func, char const *expr);
int test_done(void);

#define EXPECT_TRUE(expr) test_check((expr), __FILE__, __LINE__, __func__, #expr)

#endif
