cmake_minimum_required(VERSION 3.9.6)

# ---------------------------------------------------------------------------- #
# PROJECT
# name version language
# ---------------------------------------------------------------------------- #
project(ILAngToRosette VERSION 1.0 LANGUAGES CXX)

# ---------------------------------------------------------------------------- #
# VARIABLE
# alias and configurations
# ---------------------------------------------------------------------------- #
set(MyTarget ${PROJECT_NAME})

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

# ---------------------------------------------------------------------------- #
# External dependencies
# ---------------------------------------------------------------------------- #
##
## ilang
##
find_package(ilang REQUIRED)





# ---------------------------------------------------------------------------- #
# TARGET
# executable
# ---------------------------------------------------------------------------- #
add_executable(${MyTarget}
        src/main.cc
        ilas/ila-src/simple_cpu.cc
        ilas/ila-src/pipe_ila.cc
        include/translator.h src/translator.cc
        ilas/ila-include/riscvila.h ilas/ila-src/riscvila.cc
        ilas/ila-src/helpers.cc ilas/ila-include/helpers.h
        ilas/ila-include/encoding.h
        include/state_map.h src/state_map.cc
        ilas/ila-include/aes_ila.h ilas/ila-src/aes_ila.cc
        ilas/ila-include/aes_128.h ilas/ila-src/aes_128.cc)

target_include_directories(${MyTarget} PRIVATE include /opt/homebrew/include)

target_link_libraries(${MyTarget} ilang::ilang)

## Google Test
include(FetchContent)
#FetchContent_Declare(
#        googletest
#        GIT_REPOSITORY https://github.com/google/googletest.git
#        GIT_TAG release-1.12.1
#)
#FetchContent_MakeAvailable(googletest)
#enable_testing()
##add_executable(
##        test_decode
##        test/test_decode.cc
##        ilas/ila-src/pipe_ila.cc
##        include/translator.h src/translator.cc
##)
#
#target_link_libraries(
##        test_decode
#        GTest::gtest_main
#
#        ilang::ilang
#)
#include(GoogleTest)
#gtest_discover_tests(test_decode)


