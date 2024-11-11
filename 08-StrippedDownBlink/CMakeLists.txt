cmake_minimum_required(VERSION 3.13)
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)
# include($ENV{PICO_SDK_PATH}/external/pico_extras_import_optional.cmake)

set(PROJECT_NAME blink_project)
set(MAIN_TARGET_NAME blink)


project(${PROJECT_NAME} C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

if (PICO_SDK_VERSION_STRING VERSION_LESS "2.0.0")
    message(FATAL_ERROR "Raspberry Pi Pico SDK version 2.0.0 (or later) required. Your version is ${PICO_SDK_VERSION_STRING}")
endif()

# If you want debug output from USB (pass -DPICO_STDIO_USB=1) this ensures you don't lose any debug output while USB is set up
if (NOT DEFINED PICO_STDIO_USB_CONNECT_WAIT_TIMEOUT_MS)
    set(PICO_STDIO_USB_CONNECT_WAIT_TIMEOUT_MS 3000)
endif()

pico_sdk_init()

# Load the name of the swift to use into the variable SWIFTC depending on platform
if(APPLE)
execute_process(COMMAND xcrun -f swiftc OUTPUT_VARIABLE SWIFTC OUTPUT_STRIP_TRAILING_WHITESPACE)
else()
execute_process(COMMAND which swiftc OUTPUT_VARIABLE SWIFTC OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

# These apply to the C compilation
add_compile_options(-Wall
        -Wno-format          # int != int32_t as far as the compiler is concerned because gcc has int32_t as long int
        -Wno-unused-function # we have some for the docs that aren't called
        )
if (CMAKE_C_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-Wno-maybe-uninitialized)
endif()


add_executable(${MAIN_TARGET_NAME}
    blink.c
)

# pull in common dependencies
target_link_libraries(${MAIN_TARGET_NAME} pico_stdlib)

if (PICO_CYW43_SUPPORTED)
    target_link_libraries(${MAIN_TARGET_NAME} pico_cyw43_arch_none)
endif()

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
    COMMAND
        ${SWIFTC}
        # destination "Generate code for the given target"
        -target armv6m-none-none-eabi 
        # pass to CC: floating-point ABI to use `soft' allows fp
        -Xcc -mfloat-abi=soft
        # default enum size is short (at least one byte, as forced with -fshort-enums)
        -Xcc -fshort-enums
        # Include: 
        -Xcc -I${CMAKE_CURRENT_LIST_DIR}/blink.h
        # tell the Swift compiler: 
        -Xfrontend 
        # Emit functions to separate sections
        -function-sections 
        # Speaks for itself
        -enable-experimental-feature Embedded 
        # Whole-module optimization
        # https://www.swift.org/blog/whole-module-optimizations/
        -wmo 
        # allows @main https://forums.swift.org/t/main-in-a-single-swift-file/63079/3
        -parse-as-library
        # don't allow for runtime allocations, 
        # prevents posix_memalign issue, but PITA
        -no-allocations
        # Add the briding header 
        -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        # list the swift files to compile
        ${CMAKE_CURRENT_LIST_DIR}/Main.swift
        # Compile or assemble the source files, but do not link.
        # note that the .c file is part of the sources.
        -c 
        # Output to the file name below (TODO, is this not redundant to OUTPUT?)
        -o ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
    DEPENDS
        ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        ${CMAKE_CURRENT_LIST_DIR}/Main.swift
)
add_custom_target(${MAIN_TARGET_NAME}-swiftcode DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o)

target_link_libraries(${MAIN_TARGET_NAME}
    ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
)

add_dependencies(${MAIN_TARGET_NAME} ${MAIN_TARGET_NAME}-swiftcode)

# create map/bin/hex file etc.
pico_add_extra_outputs(${MAIN_TARGET_NAME})

#setup for USB
pico_enable_stdio_usb(${MAIN_TARGET_NAME} 1)
pico_enable_stdio_uart(${MAIN_TARGET_NAME} 1)
