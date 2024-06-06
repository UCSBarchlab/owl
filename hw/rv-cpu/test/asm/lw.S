# See LICENSE for license details.

#*****************************************************************************
# lw.S
#-----------------------------------------------------------------------------
#
# Test lw instruction.
#

#include "include/riscv_test.h"
#include "include/test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Set up memory
  #-------------------------------------------------------------

  li t0, 0x1000
  li t1, 0x00ff00ff
  sw t1, 0x0(t0)
  li t1, 0xff00ff00
  sw t1, 0x4(t0)
  li t1, 0x0ff00ff0
  sw t1, 0x8(t0)
  li t1, 0xf00ff00f
  sw t1, 0xc(t0)
  li t0, 0x0
  li t1, 0x0

  #-------------------------------------------------------------
  # Basic tests
  #-------------------------------------------------------------

  TEST_LD_OP( 2, lw, 0x00ff00ff, 0,  tdat );
  TEST_LD_OP( 3, lw, 0xff00ff00, 4,  tdat );
  TEST_LD_OP( 4, lw, 0x0ff00ff0, 8,  tdat );
  TEST_LD_OP( 5, lw, 0xf00ff00f, 12, tdat );

  # Test with negative offset

  TEST_LD_OP( 6, lw, 0x00ff00ff, -12, tdat4 );
  TEST_LD_OP( 7, lw, 0xff00ff00, -8,  tdat4 );
  TEST_LD_OP( 8, lw, 0x0ff00ff0, -4,  tdat4 );
  TEST_LD_OP( 9, lw, 0xf00ff00f, 0,   tdat4 );

  # Test with a negative base

  TEST_CASE( 10, x3, 0x00ff00ff, \
    la  x1, tdat; \
    addi x1, x1, -32; \
    lw x3, 32(x1); \
  )

  # Test with unaligned base

  TEST_CASE( 11, x3, 0xff00ff00, \
    la  x1, tdat; \
    addi x1, x1, -3; \
    lw x3, 7(x1); \
  )

  #-------------------------------------------------------------
  # Bypassing tests
  #-------------------------------------------------------------

  TEST_LD_DEST_BYPASS( 12, 0, lw, 0x0ff00ff0, 4, tdat2 );
  TEST_LD_DEST_BYPASS( 13, 1, lw, 0xf00ff00f, 4, tdat3 );
  TEST_LD_DEST_BYPASS( 14, 2, lw, 0xff00ff00, 4, tdat1 );

  TEST_LD_SRC1_BYPASS( 15, 0, lw, 0x0ff00ff0, 4, tdat2 );
  TEST_LD_SRC1_BYPASS( 16, 1, lw, 0xf00ff00f, 4, tdat3 );
  TEST_LD_SRC1_BYPASS( 17, 2, lw, 0xff00ff00, 4, tdat1 );

  #-------------------------------------------------------------
  # Test write-after-write hazard
  #-------------------------------------------------------------

  TEST_CASE( 18, x2, 2, \
    la  x3, tdat; \
    lw  x2, 0(x3); \
    li  x2, 2; \
  )

  TEST_CASE( 19, x2, 2, \
    la  x3, tdat; \
    lw  x2, 0(x3); \
    nop; \
    li  x2, 2; \
  )

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

tdat:
tdat1:  .word 0x00ff00ff
tdat2:  .word 0xff00ff00
tdat3:  .word 0x0ff00ff0
tdat4:  .word 0xf00ff00f

RVTEST_DATA_END
