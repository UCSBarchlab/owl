.global _start
.section .text

_start:
    la sp, _stack_begin
    j main

