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

const unsigned int loop_cons[6] __attribute__((__aligned__( 32 ), section(".sha256_rodata"))) = {256, 256 + 1, 256 + 1 + 16, 256 + 1 + 16 + 64 - 16, 256 + 1 + 64 + 64, 256 + 1 + 64 + 64 + 8};

//By the limitation of single chunk implementation, the length of the string should be smaller than 50 characters
unsigned char msg[256] = "Hayase_Yuuka";

unsigned int w[256] = {0};

unsigned int sha256[8] = {0};

unsigned char c0 = 0;
unsigned int str_len = 0, step = 1, K = 0, bitslen = 0;
unsigned int *copy_pt = (unsigned int*)msg;

unsigned int s0, s1;
unsigned int S0 = 0, S1 = 0, ch = 0, tmp1 = 0, tmp2 = 0, maj = 0;

unsigned int t[8] = {0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19};

int loopvar = 0;

int main(void){
    while(1){
        int loopvar_0 = 0;
        int is_end;
        CMOV((loopvar < loop_cons[0]), loopvar, loopvar_0);
        CMOV((loopvar < loop_cons[0]), msg[loopvar_0], c0);
        CMOV(((loopvar < loop_cons[0]) & (c0 > 0)), str_len + 1, str_len);

        CMOV(((loopvar >= loop_cons[0]) & (loopvar < loop_cons[1])), 0x80, msg[str_len]);
        bitslen = str_len << 3;
        CMOV(((loopvar >= loop_cons[0]) & (loopvar < loop_cons[1])), ENDIAN_REVERSE32(bitslen), *(unsigned int*)(&msg[60]));

        int loopvar_1 = loop_cons[1] + 10;
        CMOV(((loopvar >= loop_cons[1]) & (loopvar < loop_cons[2])), (loopvar - loop_cons[1]), (loopvar_1));
        CMOV(((loopvar >= loop_cons[1]) & (loopvar < loop_cons[2])), \
            ENDIAN_REVERSE32(copy_pt[loopvar_1]), \
            w[loopvar_1]);
        
        int loopvar_2 = loop_cons[2] + 20;
        CMOV(((loopvar >= loop_cons[2]) & (loopvar < loop_cons[3])), (loopvar - loop_cons[2] + 16), (loopvar_2));
        s0 = RIGHT_ROT(w[loopvar_2 - 15], 7) ^ RIGHT_ROT(w[loopvar_2 - 15], 18) ^ (w[loopvar_2 - 15] >> 3);
        s1 = RIGHT_ROT(w[loopvar_2 - 2], 17) ^ RIGHT_ROT(w[loopvar_2 - 2], 19) ^ (w[loopvar_2 - 2] >> 10);
        CMOV(((loopvar >= loop_cons[2]) & (loopvar < loop_cons[3])), (w[loopvar_2 - 16] + s0 + w[loopvar_2 - 7] + s1), w[loopvar_2]);

        int loopvar_3 = loop_cons[3] + 20;
        CMOV(((loopvar >= loop_cons[3]) & (loopvar < loop_cons[4])), (loopvar - loop_cons[3]), (loopvar_3));
        S1 = RIGHT_ROT(t[4], 6) ^ RIGHT_ROT(t[4], 11) ^ RIGHT_ROT(t[4], 25);
        ch = (t[4] & t[5]) ^ ((~t[4]) & t[6]);
        CMOV(((loopvar >= loop_cons[3]) & (loopvar < loop_cons[4])), (t[7] + S1 + ch + k[loopvar_3] + w[loopvar_3]), tmp1);
        S0 = RIGHT_ROT(t[0], 2) ^ RIGHT_ROT(t[0], 13) ^ RIGHT_ROT(t[0], 22);
        maj = (t[0] & t[1]) ^ (t[0] & t[2]) ^ (t[1] & t[2]);
        CMOV(((loopvar >= loop_cons[3]) & (loopvar < loop_cons[4])), (S0 + maj), tmp2);

        CMOV(((loopvar >= loop_cons[3]) & (loopvar < loop_cons[4])), t[6], t[7]);
        CMOV(((loopvar >= loop_cons[3]) & (loopvar < loop_cons[4])), t[5], t[6]);
        CMOV(((loopvar >= loop_cons[3]) & (loopvar < loop_cons[4])), t[4], t[5]);
        CMOV(((loopvar >= loop_cons[3]) & (loopvar < loop_cons[4])), t[3] + tmp1, t[4]);
        CMOV(((loopvar >= loop_cons[3]) & (loopvar < loop_cons[4])), t[2], t[3]);
        CMOV(((loopvar >= loop_cons[3]) & (loopvar < loop_cons[4])), t[1], t[2]);
        CMOV(((loopvar >= loop_cons[3]) & (loopvar < loop_cons[4])), t[0], t[1]);
        CMOV(((loopvar >= loop_cons[3]) & (loopvar < loop_cons[4])), (tmp1 + tmp2), t[0]);

        int loopvar_4 = 0;
        CMOV(((loopvar >= loop_cons[4]) & (loopvar < loop_cons[5])), (loopvar - loop_cons[4]), (loopvar_4));
        CMOV(((loopvar >= loop_cons[4]) & (loopvar < loop_cons[5])), (h[loopvar_4] + t[loopvar_4]), (sha256[loopvar_4]));

        loopvar++;

        //Need to find a way to terminate our program
        
        #ifdef LV_BEHAVIOR
        if(loopvar > 10000) break;
        #endif
    }

    #ifdef LV_BEHAVIOR
    for(int i=0 ;i<8; i++)
        printf("%08x", sha256[i]);
    #endif

    return 0;
}
