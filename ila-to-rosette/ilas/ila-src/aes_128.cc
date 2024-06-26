/// \file The definition of AES 128 function
///  Hongce Zhang (hongcez@princeton.edu)

#include "../ila-include/aes_128.h"
#include <ilang/ila/ast/expr.h>

#include <cassert>
#include <ilang/ila/ast/expr_const.h>

unsigned S_table[256] = {
        0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b,
        0xfe, 0xd7, 0xab, 0x76, 0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0,
        0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0, 0xb7, 0xfd, 0x93, 0x26,
        0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
        0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2,
        0xeb, 0x27, 0xb2, 0x75, 0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0,
        0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84, 0x53, 0xd1, 0x00, 0xed,
        0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
        0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f,
        0x50, 0x3c, 0x9f, 0xa8, 0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5,
        0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2, 0xcd, 0x0c, 0x13, 0xec,
        0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
        0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14,
        0xde, 0x5e, 0x0b, 0xdb, 0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c,
        0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79, 0xe7, 0xc8, 0x37, 0x6d,
        0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
        0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f,
        0x4b, 0xbd, 0x8b, 0x8a, 0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e,
        0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e, 0xe1, 0xf8, 0x98, 0x11,
        0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
        0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f,
        0xb0, 0x54, 0xbb, 0x16};

unsigned xS_table[256] = {
        0xc6, 0xf8, 0xee, 0xf6, 0xff, 0xd6, 0xde, 0x91, 0x60, 0x02, 0xce, 0x56,
        0xe7, 0xb5, 0x4d, 0xec, 0x8f, 0x1f, 0x89, 0xfa, 0xef, 0xb2, 0x8e, 0xfb,
        0x41, 0xb3, 0x5f, 0x45, 0x23, 0x53, 0xe4, 0x9b, 0x75, 0xe1, 0x3d, 0x4c,
        0x6c, 0x7e, 0xf5, 0x83, 0x68, 0x51, 0xd1, 0xf9, 0xe2, 0xab, 0x62, 0x2a,
        0x08, 0x95, 0x46, 0x9d, 0x30, 0x37, 0x0a, 0x2f, 0x0e, 0x24, 0x1b, 0xdf,
        0xcd, 0x4e, 0x7f, 0xea, 0x12, 0x1d, 0x58, 0x34, 0x36, 0xdc, 0xb4, 0x5b,
        0xa4, 0x76, 0xb7, 0x7d, 0x52, 0xdd, 0x5e, 0x13, 0xa6, 0xb9, 0x00, 0xc1,
        0x40, 0xe3, 0x79, 0xb6, 0xd4, 0x8d, 0x67, 0x72, 0x94, 0x98, 0xb0, 0x85,
        0xbb, 0xc5, 0x4f, 0xed, 0x86, 0x9a, 0x66, 0x11, 0x8a, 0xe9, 0x04, 0xfe,
        0xa0, 0x78, 0x25, 0x4b, 0xa2, 0x5d, 0x80, 0x05, 0x3f, 0x21, 0x70, 0xf1,
        0x63, 0x77, 0xaf, 0x42, 0x20, 0xe5, 0xfd, 0xbf, 0x81, 0x18, 0x26, 0xc3,
        0xbe, 0x35, 0x88, 0x2e, 0x93, 0x55, 0xfc, 0x7a, 0xc8, 0xba, 0x32, 0xe6,
        0xc0, 0x19, 0x9e, 0xa3, 0x44, 0x54, 0x3b, 0x0b, 0x8c, 0xc7, 0x6b, 0x28,
        0xa7, 0xbc, 0x16, 0xad, 0xdb, 0x64, 0x74, 0x14, 0x92, 0x0c, 0x48, 0xb8,
        0x9f, 0xbd, 0x43, 0xc4, 0x39, 0x31, 0xd3, 0xf2, 0xd5, 0x8b, 0x6e, 0xda,
        0x01, 0xb1, 0x9c, 0x49, 0xd8, 0xac, 0xf3, 0xcf, 0xca, 0xf4, 0x47, 0x10,
        0x6f, 0xf0, 0x4a, 0x5c, 0x38, 0x57, 0x73, 0x97, 0xcb, 0xa1, 0xe8, 0x3e,
        0x96, 0x61, 0x0d, 0x0f, 0xe0, 0x7c, 0x71, 0xcc, 0x90, 0x06, 0xf7, 0x1c,
        0xc2, 0x6a, 0xae, 0x69, 0x17, 0x99, 0x3a, 0x27, 0xd9, 0xeb, 0x2b, 0x22,
        0xd2, 0xa9, 0x07, 0x33, 0x2d, 0x3c, 0x15, 0xc9, 0x87, 0xaa, 0x50, 0xa5,
        0x03, 0x59, 0x09, 0x1a, 0x65, 0xd7, 0x84, 0xd0, 0x82, 0x29, 0x5a, 0x1e,
        0x7b, 0xa8, 0x6d, 0x2c};

std::map<uint64_t, uint64_t> get_map_from_array(unsigned array[]) {
    std::map<uint64_t, uint64_t> map;
    for (int i = 0; i < 256; i++) {
        map[i] = array[i];
    }
    return map;
}


unsigned rcon_table[10] = {0x1,  0x2,  0x4,  0x8,  0x10,
                           0x20, 0x40, 0x80, 0x1b, 0x36};

std::map<uint64_t, uint64_t> rcon_map = {{0, 0xdd},
                                         {1, 0x1},
                                         {2, 0x2},
                                         {3, 0x4},
                                         {4, 0x8},
                                         {5, 0x10},
                                         {6, 0x20},
                                         {7, 0x40},
                                         {8, 0x80},
                                         {9, 0x1b},
                                         {10, 0x36},
                                         {11, 0x36}
                                         };
ExprRef AES_128::_round_table = (MemConst(0, rcon_map, 4, 8));
ExprRef AES_128::_s_table = MemConst(0, get_map_from_array(S_table), 8, 8);
ExprRef AES_128::_xs_table = MemConst(0, get_map_from_array(xS_table), 8, 8);

ExprRef AES_128::read_rcon_mem(const ExprRef& rnd) {
    return _round_table.Load(rnd);
}

ExprRef AES_128::rcon(const ExprRef& rnd) {
    assert(rnd.bit_width() == 4);

    ExprRef ret = BvConst(rcon_table[0], 8);
    for (int i = 1; i < 10; i++)
        ret = Ite(rnd == i + 1, BvConst(rcon_table[i], 8), ret); // rnd : 1..10
    return ret;
}

ExprRef AES_128::s_table_read(const ExprRef& idx) {
    assert(idx.bit_width() == 8);

    ExprRef ret = BvConst(S_table[0], 8);
    for (int i = 1; i < 256; i++) {
        ret = Ite(idx == i, BvConst(S_table[i], 8), ret);
    }
    return ret;
}

ExprRef AES_128::xs_table_read(const ExprRef& idx) {
    assert(idx.bit_width() == 8);

    ExprRef ret = BvConst(xS_table[0], 8);
    for (int i = 1; i < 256; i++) {
        ret = Ite(idx == i, BvConst(xS_table[i], 8), ret);
    }
    return ret;
}

ExprRef AES_128::combine_vec4(const vec4& l) {
    return Concat(Concat(Concat(l[0], l[1]), l[2]), l[3]);
}

AES_128::vec4 AES_128::slice_128_to_32(const ExprRef& bv) {
    assert(bv.bit_width() == 128);

    vec4 ret;
    for (int bidx = 3; bidx >= 0; bidx--)
        ret.push_back(bv(32 * bidx + 31, bidx * 32));
    return ret;
}

AES_128::vec4 AES_128::slice_32_to_8(const ExprRef& _32) {
    assert(_32.bit_width() == 32);

    vec4 ret;
    for (int bidx = 3; bidx >= 0; bidx--)
        ret.push_back(_32(bidx * 8 + 7, bidx * 8));
    return ret;
}

ExprRef AES_128::S(const ExprRef& inp) { return _s_table.Load(inp); }
ExprRef AES_128::xS(const ExprRef& inp) { return _xs_table.Load(inp); }
ExprRef AES_128::S4(const ExprRef& inp) { // inp is 32bits
    assert(inp.bit_width() == 32);

    auto ret = S(inp(31, 24));
    ret = Concat(ret, S(inp(23, 16)));
    ret = Concat(ret, S(inp(15, 8)));
    ret = Concat(ret, S(inp(7, 0)));

    return ret;
}

AES_128::vec4 AES_128::T(const ExprRef& inp) { // inp: 8
    assert(inp.bit_width() == 8);
    auto sl0 = S(inp);
    auto sl1 = sl0;
    auto sl3 = xS(inp);
    auto sl2 = sl1 ^ sl3;

    return {sl0, sl1, sl2, sl3};
}

ExprRef AES_128::expand_key_128_a(const ExprRef& in, const ExprRef& rc) {
    assert(in.bit_width() == 128);
    assert(rc.bit_width() == 8);

    auto K = slice_128_to_32(in);
    auto v0 = Concat(K[0](31, 24) ^ rc, K[0](23, 0));
    auto v1 = v0 ^ K[1];
    auto v2 = v1 ^ K[2];
    auto v3 = v2 ^ K[3];

    return combine_vec4({v0, v1, v2, v3});
}

ExprRef AES_128::expand_key_128_b(const ExprRef& in, const ExprRef& rc) {
    assert(in.bit_width() == 128);
    assert(rc.bit_width() == 8);

    auto K = slice_128_to_32(in);
    auto v0 = Concat(K[0](31, 24) ^ rc, K[0](23, 0));
    auto v1 = v0 ^ K[1];
    auto v2 = v1 ^ K[2];
    auto v3 = v2 ^ K[3];

    auto k0a = v0;
    auto k1a = v1;
    auto k2a = v2;
    auto k3a = v3;

    auto k4a = S4(Concat(K[3](23, 0), K[3](31, 24)));

    auto k0b = k0a ^ k4a;
    auto k1b = k1a ^ k4a;
    auto k2b = k2a ^ k4a;
    auto k3b = k3a ^ k4a;

    return combine_vec4({k0b, k1b, k2b, k3b});
}

AES_128::vec4 AES_128::table_lookup(const ExprRef& s32) { // s32: 32 bit wide
    auto b = slice_32_to_8(s32);
    auto rl = T(b[0]);
    auto p0 = combine_vec4({rl[3], rl[0], rl[1], rl[2]});
    rl = T(b[1]);
    auto p1 = combine_vec4({rl[2], rl[3], rl[0], rl[1]});
    rl = T(b[2]);
    auto p2 = combine_vec4({rl[1], rl[2], rl[3], rl[0]});
    rl = T(b[3]);
    auto p3 = combine_vec4({rl[0], rl[1], rl[2], rl[3]});

    return {p0, p1, p2, p3};
}

ExprRef AES_128::GetCipherUpdate_MidRound(const ExprRef& state_in,
                                          const ExprRef rnd,
                                          const ExprRef& key) {
    auto enc_key = expand_key_128_b(key, read_rcon_mem(rnd));
    auto K0_4 = slice_128_to_32(enc_key);
    auto S0_4 = slice_128_to_32(state_in);

    auto p0 = table_lookup(S0_4[0]);
    auto p1 = table_lookup(S0_4[1]);
    auto p2 = table_lookup(S0_4[2]);
    auto p3 = table_lookup(S0_4[3]);

    auto z0 = p0[0] ^ p1[1] ^ p2[2] ^ p3[3] ^ K0_4[0];
    auto z1 = p0[3] ^ p1[0] ^ p2[1] ^ p3[2] ^ K0_4[1];
    auto z2 = p0[2] ^ p1[3] ^ p2[0] ^ p3[1] ^ K0_4[2];
    auto z3 = p0[1] ^ p1[2] ^ p2[3] ^ p3[0] ^ K0_4[3];

    return combine_vec4({z0, z1, z2, z3});
}

ExprRef AES_128::GetCipherUpdate_FinalRound(const ExprRef& state_in,
                                            const ExprRef rnd,
                                            const ExprRef& key) {
    auto enc_key = expand_key_128_b(key, read_rcon_mem(rnd));
    auto K0_4 = slice_128_to_32(enc_key);
    auto S0_4 = slice_128_to_32(state_in);

    auto p0 = slice_32_to_8(S4(S0_4[0]));
    auto p1 = slice_32_to_8(S4(S0_4[1]));
    auto p2 = slice_32_to_8(S4(S0_4[2]));
    auto p3 = slice_32_to_8(S4(S0_4[3]));

    auto z0 = combine_vec4({p0[0], p1[1], p2[2], p3[3]}) ^ K0_4[0];
    auto z1 = combine_vec4({p1[0], p2[1], p3[2], p0[3]}) ^ K0_4[1];
    auto z2 = combine_vec4({p2[0], p3[1], p0[2], p1[3]}) ^ K0_4[2];
    auto z3 = combine_vec4({p3[0], p0[1], p1[2], p2[3]}) ^ K0_4[3];

    return combine_vec4({z0, z1, z2, z3});
}

ExprRef AES_128::GetKeyUpdate_MidRound(const ExprRef& key, const ExprRef rnd) {
    return expand_key_128_b(key, read_rcon_mem(rnd));
}

AES_128::AES_128() : model("AES_128_Rnd") {

    auto plaintext = model.NewBvInput("plaintext", 128);
    auto key_in = model.NewBvInput("key_in", 128);

    auto ciphertext = model.NewBvState("ciphertext", 128);
    auto round_key = model.NewBvState("round_key", 128);

    auto round = model.NewBvState("round", 4); // maximum 10 round

    model.AddInit(round == 0);
    model.SetValid(
            Ule(round, 10) );  // round <= 10 (unsigned)
    // 0: init  1-10 , all bvs are treated as unsigned number by default

    // initial round

    { // FirstRound : just an xor
        auto instr = model.NewInstr("FirstRound");

        instr.SetDecode(round == 0);

        instr.SetUpdate(ciphertext, key_in ^ plaintext);
        instr.SetUpdate(round_key, key_in);
        instr.SetUpdate(round, round + 1);
    }

    // intermediate round

    { // Midround
        auto instr = model.NewInstr("IntermediateRound");

        instr.SetDecode((Ugt(round , 0) & Ult(round , 9)));//(Ugt(round , 0) & Ule(round , 9));

        instr.SetUpdate(ciphertext,
                        GetCipherUpdate_MidRound(ciphertext, round, round_key));
        instr.SetUpdate(round_key, GetKeyUpdate_MidRound(round_key, round));
        instr.SetUpdate(round, round + 1);
    }

    { // FinalRound
        auto instr = model.NewInstr("FinalRound");

        instr.SetDecode((round == 9));

        instr.SetUpdate(ciphertext,
                        GetCipherUpdate_FinalRound(ciphertext, round, round_key));
        // we don't specify it as it does not matter
        // instr.SetUpdate( round_key,  unknown(128) );
        instr.SetUpdate(round, round + 1);
    }
}