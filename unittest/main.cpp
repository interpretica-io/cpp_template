#include <iostream>
#include "gtest/gtest.h"

TEST(test1, test2)
{
    ASSERT_EQ(5, 5);
}

int
main(int argc, char **argv)
{
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
