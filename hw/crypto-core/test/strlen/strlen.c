//#define LV_BEHAVIOR

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

#define CMOV(rs1, rs2, rd)  \
    ((rs1)? (rd = rs2) : (rd = rd))

#else

/*
sh1add instruction is defined in extension `zba` of rv32, here we use the encoding of sh1add as cmov 

Mnemonic:
    sh1add rd, rs1, rs2
___________________________________________________________________________________________________________
|31                   25|24           20|19           15|14       12|11            7|6                   0|
+-----------------------+---------------+---------------+-----------+---------------+---------------------|
|  0  0  1  0  0  0  0  |       rs2     |       rs1     |  0  1  0  |       rd      |  0  1  1  0  0  1  1|
+-----------------------+---------------+---------------+-----------+---------------+---------------------|
|       SH1ADD          |               |               |   SH1ADD  |               |           OP        |

Description:
    Check if rs1 <= 0. If rs1 <= 0 then rd = rd, else rd = rs2
    (rs1)?(rd = rs2):(rd = rd)
*/
#define CMOV(rs1, rs2, rd)               \
    __asm__ __volatile__(                \
        "lw x16, 0(%2)   \n\t"           \
        "sh1add x16, %0, %1   \n\t"      \
        "sw x16, 0(%2)   \n\t"           \
        :                                \
        : "r"(rs1), "r"(rs2), "r"(&(rd)) \
        : "x16");
#endif

#define ENDIAN_REVERSE32(val)   \
    (((val & 0x000000FF) << 24u) | \
    ((val & 0x0000FF00) <<  8u) |  \
    ((val & 0x00FF0000) >>  8u) |  \
    ((val & 0xFF000000) >> 24u))

#define RIGHT_ROT(val, cnt)    \
    (((val) >> (cnt)) | ((val) << (32 - (cnt))))

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

const unsigned int loop_cons[6] __attribute__((__aligned__( 32 ), section(".sha256_rodata"))) = {64, 64 + 1, 64 + 1 + 16, 64 + 1 + 16 + 64 - 16, 64 + 1 + 64 + 64, 64 + 1 + 64 + 64 + 8};

//By the limitation of single chunk implementation, the length of the string should be smaller than 50 characters
unsigned char msg[256] = "Hayase_Yuuka";

unsigned int w[256] = {0};

unsigned int sha256[8] = {0};

unsigned char c0 = 0;
unsigned int str_len = 0, step = 1, K = 0, bitslen = 0;
unsigned int *copy_pt = (unsigned int*)msg;

unsigned int s0 = 0, s1 = 0;
unsigned int S0 = 0, S1 = 0, ch = 0, tmp1 = 0, tmp2 = 0, maj = 0;

unsigned int t[8] = {0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19};

unsigned int loopvar = 0;

int finish = 0;

int inspec_val[64] = {0};

int padding[12] = {0};

unsigned int loopvar_0 = 0;

int main(void){
    while(1){
        //int loopvar_0 = 0;
        CMOV((loopvar < loop_cons[0]), loopvar, loopvar_0);
        CMOV((loopvar < loop_cons[0]), msg[loopvar_0], c0);
        CMOV(((loopvar < loop_cons[0]) & (c0 > 0)), str_len + 1, str_len);
        //inspec_val[loopvar] = (loopvar < loop_cons[0]);

        loopvar++;

        //finish should be 1 after result is stable
        
        #ifdef LV_BEHAVIOR
        if(loopvar > 10000) break;
        #endif
    }

    #ifdef LV_BEHAVIOR
        printf("String length: %d\n", str_len);

        for(int i=0; i<32; i++)
            printf("%d ", inspec_val[i]);
    #endif

    return 0;
}
