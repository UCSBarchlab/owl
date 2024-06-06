#include <gtest/gtest.h>
#include <ilang/ilang++.h>
#include "../ilas/ila-include/pipe_ila.h"
#include "../include/translator.h"
#include <string>


TEST(DecodeExprTest, BasicAssertions) {
    auto pipe = ilang::SimplePipe::BuildModel();
    Translator t(pipe.get());
    std::string actual = t.create_decode_for_instr(pipe.get()->instr(0));
    std::string expected = "(define (NOP-SetDecode pre ports)"
                           "(assume (bveq (extract 7 6 (pre (ports \"simplePipe_inst\"))) (bv 0 2))))";
    EXPECT_EQ(actual, expected);
}
