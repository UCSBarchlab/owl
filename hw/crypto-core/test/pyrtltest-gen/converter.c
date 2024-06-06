#include "stdio.h"
#include "stdlib.h"
#include "errno.h"
#include "string.h"
#include "stdint.h"

int main(void){
    char filepath[] = "instr.dat";

    FILE *fd = fopen((char*)filepath, "r");

    if(!fd){
        fprintf(stderr, "Failed to open the file: %s", strerror(errno));
        return -1;
    }

    uint32_t instr[1024];

    memset(instr, 0, sizeof(uint32_t) * 1024);

    int read_ret = fread(&instr, sizeof(uint32_t) * 1024, 1, fd);

    int printpt = 0;
    while(instr[printpt] != 0x0){
        printf("0x%08x,\n", instr[printpt]);
        printpt++;
    }

    printf("There're %d lines of assembly code\n", printpt);

    fclose(fd);

}