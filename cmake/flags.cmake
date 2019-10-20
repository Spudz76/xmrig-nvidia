set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 11)

if ("${CMAKE_BUILD_TYPE}" STREQUAL "")
    set(CMAKE_BUILD_TYPE Release)
endif()

if (CMAKE_BUILD_TYPE STREQUAL "Release")
    add_definitions(/DNDEBUG)
endif()

include(CheckSymbolExists)
set(CMAKE_REQUIRED_QUIET TRUE)
message(STATUS "Looking for _rotr in <x86intrin.h>...")
check_symbol_exists("_rotr" "x86intrin.h" HAVE_X86ROTR)
if (NOT HAVE_X86ROTR)
    message(STATUS "Looking for _rotr in <intrin.h>...")
    check_symbol_exists("_rotr" "intrin.h" HAVE_ROTR)
endif()
if (HAVE_X86ROTR OR HAVE_ROTR)
    message(STATUS "Looking for _rotr - found")
    add_definitions(/DHAVE_ROTR)
endif()
unset(CMAKE_REQUIRED_QUIET)

if (CMAKE_CXX_COMPILER_ID MATCHES GNU)

    if (XMRIG_ARM)
         set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")
    else()
         set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -maes -Wall")
    endif()
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -Wno-strict-aliasing")

    if (XMRIG_ARM)
         set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -flax-vector-conversions")
    else()
	 set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -maes -Wall")
    endif()

    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -s -Wno-sign-compare")

    if (WIN32)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
    else()
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc -static-libstdc++")
    endif()

    add_definitions(/D_GNU_SOURCE)

    #set(CMAKE_C_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -gdwarf-2")

elseif (CMAKE_CXX_COMPILER_ID MATCHES MSVC)

    set(CMAKE_C_FLAGS_RELEASE "/MT /O2 /Ob2 /DNDEBUG")
    set(CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Ob2 /DNDEBUG")
    add_definitions(/D_CRT_SECURE_NO_WARNINGS)
    add_definitions(/D_CRT_NONSTDC_NO_WARNINGS)
    add_definitions(/DNOMINMAX)

elseif (CMAKE_CXX_COMPILER_ID MATCHES Clang)

    if (XMRIG_ARM)
         set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")
    else()
         set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -maes -Wall")
    endif()

    if (XMRIG_ARM)
         set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -fno-exceptions -fno-rtti")
    else()
         set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -maes -Wall -fno-exceptions -fno-rtti")
    endif()

    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -s")

elseif (CMAKE_CXX_COMPILER_ID MATCHES Intel)

    if(("${ICC_COMPILERS}" STREQUAL "") AND (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 17) AND (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 20))
        # locate best gcc version to pass to icc 18 or 19 (gcc-8 doesn't work, for example)
        # Use -DICC_GCCVER=6 for example to force 'gcc-6' and 'g++-6'
        # Otherwise, the newest available and compatible pair will be selected
        find_program(ICC_GXX NAMES "g++-${ICC_GCCVER}" "g++-7" "g++-6" "g++")
        get_filename_component(ICC_GXX ${ICC_GXX} NAME)
        find_program(ICC_GCC NAMES "gcc-${ICC_GCCVER}" "gcc-7" "gcc-6" "gcc")
        get_filename_component(ICC_GCC ${ICC_GCC} NAME)
        set(ICC_COMPILERS "-gxx-name=${ICC_GXX} -gcc-name=${ICC_GCC}")
        unset(ICC_GXX)
        unset(ICC_GCC)
    endif()
    message(STATUS "Intel ICC subcompiler flags: ${ICC_COMPILERS}")

    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${ICC_COMPILERS} -Wall")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -funroll-loops -xHost -ipo -msse -msse2 -mfpmath=sse")

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ICC_COMPILERS} -Wall -fno-exceptions -fno-rtti")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -funroll-loops -xHost -ipo -msse -msse2 -mfpmath=sse")
endif()
