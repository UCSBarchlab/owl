# See LICENSE for license details.

#*****************************************************************************
# lb.S
#-----------------------------------------------------------------------------
#
# Test lb instruction.
#

#include "include/riscv_test.h"
#include "include/test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Set up memory
  #-------------------------------------------------------------

  li t0, 0x1000
  li t1, 0xff
  sb t1, 0x0(t0)
  li t1, 0x00
  sb t1, 0x1(t0)
  li t1, 0xf0
  sb t1, 0x2(t0)
  li t1, 0x0f
  sb t1, 0x3(t0)
  li t0, 0x0
  li t1, 0x0

  #-------------------------------------------------------------
  # Basic tests
  #-------------------------------------------------------------

  TEST_LD_OP( 2, lb, 0xffffffff, 0,  tdat );
  TEST_LD_OP( 3, lb, 0x00000000, 1,  tdat );
  TEST_LD_OP( 4, lb, 0xfffffff0, 2,  tdat );
  TEST_LD_OP( 5, lb, 0x0000000f, 3, tdat );

  # Test with negative offset

  TEST_LD_OP( 6, lb, 0xffffffff, -3, tdat4 );
  TEST_LD_OP( 7, lb, 0x00000000, -2,  tdat4 );
  TEST_LD_OP( 8, lb, 0xfffffff0, -1,  tdat4 );
  TEST_LD_OP( 9, lb, 0x0000000f, 0,   tdat4 );

  # Test with a negative base

  TEST_CASE( 10, x3, 0xffffffff, \
    la  x1, tdat; \
    addi x1, x1, -32; \
    lb x3, 32(x1); \
  )

  # Test with unaligned base

  TEST_CASE( 11, x3, 0x00000000, \
    la  x1, tdat; \
    addi x1, x1, -6; \
    lb x3, 7(x1); \
  )

  #-------------------------------------------------------------
  # Bypassing tests
  #-------------------------------------------------------------

  TEST_LD_DEST_BYPASS( 12, 0, lb, 0xfffffff0, 1, tdat2 );
  TEST_LD_DEST_BYPASS( 13, 1, lb, 0x0000000f, 1, tdat3 );
  TEST_LD_DEST_BYPASS( 14, 2, lb, 0x00000000, 1, tdat1 );

  TEST_LD_SRC1_BYPASS( 15, 0, lb, 0xfffffff0, 1, tdat2 );
  TEST_LD_SRC1_BYPASS( 16, 1, lb, 0x0000000f, 1, tdat3 );
  TEST_LD_SRC1_BYPASS( 17, 2, lb, 0x00000000, 1, tdat1 );

  #-------------------------------------------------------------
  # Test write-after-write hazard
  #-------------------------------------------------------------

  TEST_CASE( 18, x2, 2, \
    la  x3, tdat; \
    lb  x2, 0(x3); \
    li  x2, 2; \
  )

  TEST_CASE( 19, x2, 2, \
    la  x3, tdat; \
    lb  x2, 0(x3); \
    nop; \
    li  x2, 2; \
  )

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

tdat:
tdat1:  .byte 0xff
tdat2:  .byte 0x00
tdat3:  .byte 0xf0
tdat4:  .byte 0x0f

RVTEST_DATA_END
