#define LV_BEHAVIOR

/*
 *  Uncomment above macro and compile the program with std library to printout the result
 *  You can generate sha256sum for certain string with command 
 *  echo -n $(YOURSTRING) | sha256sum 
 *
 *  The string input in this design are hard coded, you may need to recompile to test
 *  with your custom string
 * */

#ifdef LV_BEHAVIOR
#include "stdio.h"
#endif

#ifdef LV_BEHAVIOR

/*
cmov rs1, rs2, rd
move rs2 to rd once rs1 is non-zero

cmov belongs to 
*/

#define CMOV(rs1, rs2, rd)  \
    ((rs1)? (rd = rs2) : (rd = rd))

#else
#define CMOV(rs1, rs2, rd) \
    __asm__ __volatile__(   \
        "nop    \n\t"/*"sc.w %1, %2, %0    \n\t"*/   \
        :"=r"(rd)   \
        :"r"(rs1),"r"(rs2)  \
        :   \
    );
#endif

#define ENDIAN_REVERSE32(val)   \
    (((val & 0x000000FF) << 24u) | \
    ((val & 0x0000FF00) <<  8u) |  \
    ((val & 0x00FF0000) >>  8u) |  \
    ((val & 0xFF000000) >> 24u))

#define RIGHT_ROT(val, cnt)    \
    (((val) >> (cnt)) | ((val) << (32 - (cnt))))

#define CONC_NAME(a, b)     __CONC_NAME__(a, b)
#define __CONC_NAME__(a, b)   a##b

#define DEFINE_LIST32VAR(base, ext, val)     unsigned int CONC_NAME(base, ext) = val
#define _TEMP_H_VAL_DEF_(val, ext)     DEFINE_LIST32VAR(t, ext, val)
#define TEMP_H_VAL_DEF(val)   _TEMP_H_VAL_DEF_(val, __COUNTER__)

//initial hash value(RO)
const unsigned int h[8] __attribute__((__aligned__( 32 ), section(".sha256_rodata"))) = {0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19};

//initial round const(RO)
const unsigned int k[64] __attribute__((__aligned__( 32 ), section(".sha256_rodata"))) = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2};

//By the limitation of single chunk implementation, the length of the string should be smaller than 50 characters
unsigned char msg[256] = "Hayase_Yuuka";

unsigned int w[256] = {0};

unsigned int sha256[8] = {0};

unsigned char c0 = 0;
unsigned int str_len = 0, step = 1, K = 0, bitslen = 0;
unsigned int *copy_pt = (unsigned int*)msg;

unsigned int s0, s1;
unsigned int S0 = 0, S1 = 0, ch = 0, tmp1 = 0, tmp2 = 0, maj = 0;

TEMP_H_VAL_DEF(h[0]);
TEMP_H_VAL_DEF(h[1]);
TEMP_H_VAL_DEF(h[2]);
TEMP_H_VAL_DEF(h[3]);
TEMP_H_VAL_DEF(h[4]);
TEMP_H_VAL_DEF(h[5]);
TEMP_H_VAL_DEF(h[6]);
TEMP_H_VAL_DEF(h[7]);

int main(void){

    for(int i=0; i<256; i++){
        c0 = msg[i];
        CMOV(c0, str_len + 1, str_len);
    }

    msg[str_len] = 0x80;

    bitslen = str_len << 3;
    *(unsigned int*)(&msg[60]) = ENDIAN_REVERSE32(bitslen);

    for(int i = 0; i < 16; i++){//copy first 16 word (aka 64 byte)
        w[i] = ENDIAN_REVERSE32(copy_pt[i]);
    }

    for(int i = 16; i < 64; i++){
        s0 = RIGHT_ROT(w[i - 15], 7) ^ RIGHT_ROT(w[i - 15], 18) ^ (w[i - 15] >> 3);
        s1 = RIGHT_ROT(w[i - 2], 17) ^ RIGHT_ROT(w[i - 2], 19) ^ (w[i - 2] >> 10);
        w[i] = w[i - 16] + s0 + w[i - 7] + s1;
    }

    for(int i = 0; i < 64; i++){
        S1 = RIGHT_ROT(t4, 6) ^ RIGHT_ROT(t4, 11) ^ RIGHT_ROT(t4, 25);
        ch = (t4 & t5) ^ ((~t4) & t6);
        tmp1 = t7 + S1 + ch + k[i] + w[i];
        S0 = RIGHT_ROT(t0, 2) ^ RIGHT_ROT(t0, 13) ^ RIGHT_ROT(t0, 22);
        maj = (t0 & t1) ^ (t0 & t2) ^ (t1 & t2);
        tmp2 = S0 + maj;

        t7 = t6;
        t6 = t5;
        t5 = t4;
        t4 = t3 + tmp1;
        t3 = t2;
        t2 = t1;
        t1 = t0;
        t0 = tmp1 + tmp2;
    }

    sha256[0] = h[0] + t0;
    sha256[1] = h[1] + t1;
    sha256[2] = h[2] + t2;
    sha256[3] = h[3] + t3;
    sha256[4] = h[4] + t4;
    sha256[5] = h[5] + t5;
    sha256[6] = h[6] + t6;
    sha256[7] = h[7] + t7;
    
    #ifdef LV_BEHAVIOR
    for(int i=0 ;i<8; i++)
        printf("%08x", sha256[i]);
    #endif

    return 0;
}
