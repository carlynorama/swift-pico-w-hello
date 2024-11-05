cmake_minimum_required(VERSION 3.28)
set(PROJECT_NAME new-project-name)
set(MAIN_TARGET_NAME ${PROJECT_NAME})


# This CMake file generates a .o file from the swift using the "custom command" 
# This is currently more flexible than using the Swift mode, as not all build
# tools know how to use that. 
# The binary directory is being passed in by cmake call in build script


# If didn't want to do in build script 
#set($ENV{PICO_SDK_PATH} /your/path/to/sdk)
#set($ENV{TOOLCHAINS} /your/toolchain)
#set(PICO_BOARD pico_w)
#set(PICO_TOOLCHAIN_PATH /path/to/arm/gcc) # i.e. $ENV{HOMEBREW_REPOSITORY}/bin

include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(${PROJECT_NAME})
pico_sdk_init()

# Load the name of the swift to use into the variable SWIFTC depending on platform
if(APPLE)
execute_process(COMMAND xcrun -f swiftc OUTPUT_VARIABLE SWIFTC OUTPUT_STRIP_TRAILING_WHITESPACE)
else()
execute_process(COMMAND which swiftc OUTPUT_VARIABLE SWIFTC OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

add_executable(${MAIN_TARGET_NAME}
    helper.c
)

target_link_libraries(${MAIN_TARGET_NAME}
    pico_stdlib 
    hardware_uart 
    hardware_gpio 
    pico_lwip_arch 
    pico_cyw43_arch_none
    hardware_i2c
)

# Gather compile definitions from all dependencies
# Output is giant blob of -DLIB_PICO settings for -Xcc 
set_property(GLOBAL PROPERTY visited_targets "")
set_property(GLOBAL PROPERTY compilerdefs_list "")

function(gather_compile_definitions_recursive target)
    # Get the current value of visited_targets
    get_property(visited_targets GLOBAL PROPERTY visited_targets)
    
    # make sure we don't visit the same target twice
    # and that we don't visit the special generator expressions
    # i.e. https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html
    if (${target} MATCHES "\\$<" OR ${target} MATCHES "::@" OR ${target} IN_LIST visited_targets)
        return()
    endif()

    # Append the target to visited_targets
    list(APPEND visited_targets ${target})
    set_property(GLOBAL PROPERTY visited_targets "${visited_targets}")

    # Get the current value of compilerdefs_list
    get_property(compilerdefs_list GLOBAL PROPERTY compilerdefs_list)

    get_target_property(target_definitions ${target} INTERFACE_COMPILE_DEFINITIONS)
    if (target_definitions)
        # Append the target definitions to compilerdefs_list
        list(APPEND compilerdefs_list ${target_definitions})
        set_property(GLOBAL PROPERTY compilerdefs_list "${compilerdefs_list}")
    endif()

    get_target_property(target_linked_libs ${target} INTERFACE_LINK_LIBRARIES)
    if (target_linked_libs)
        foreach(linked_target ${target_linked_libs})
            # Recursively gather compile definitions from dependencies
            gather_compile_definitions_recursive(${linked_target})
        endforeach()
    endif()
endfunction()

message(" ----- SOURCES: ${SOURCES} ---- ")

# HMMMM... will this still be appropriate when not all are pico's? 
gather_compile_definitions_recursive(${MAIN_TARGET_NAME})
get_property(COMPILE_DEFINITIONS GLOBAL PROPERTY compilerdefs_list)

# Parse compiler definitions into a format that swiftc can understand
list(REMOVE_DUPLICATES COMPILE_DEFINITIONS)
list(PREPEND COMPILE_DEFINITIONS "") # adds a semicolon at the beginning
string(REPLACE "$<TARGET_PROPERTY:PICO_TARGET_BINARY_TYPE>" "$<TARGET_PROPERTY:${MAIN_TARGET_NAME},PICO_TARGET_BINARY_TYPE>" COMPILE_DEFINITIONS "${COMPILE_DEFINITIONS}")
string(REPLACE ";" ";-Xcc;-D" COMPILE_DEFINITIONS "${COMPILE_DEFINITIONS}")

message("${COMPILE_DEFINITIONS}")

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
        # Got all the specifications from the included libraries
        ${COMPILE_DEFINITIONS}
        # Misc Pico W specific extras for networking stack.
        # Unclear to me why previous sweep did not catch them.
                # Also unclear why this setup needs to setup the WiFi when I'm
        # not using the wifi. TODO: is this realted to why PIN25 as LED didn't work?
        -Xcc -DCYW43_LWIP
        -Xcc -DPICO_CYW43_ARCH_THREADSAFE_BACKGROUND
        -Xcc -I$ENV{PICO_SDK_PATH}/lib/lwip/src/include
        # tell CC to look in include folder
        # (need to add an empty header for lwip. TODO - why?)
        -Xcc -I${CMAKE_CURRENT_LIST_DIR}/include
        -Xcc -I${CMAKE_CURRENT_LIST_DIR}/helper.h
        $$\( echo '$<TARGET_PROPERTY:${MAIN_TARGET_NAME},INCLUDE_DIRECTORIES>' | tr '\;' '\\n' | sed -e 's/\\\(.*\\\)/-Xcc -I\\1/g' \)
        $$\( echo '${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES}'             | tr ' '  '\\n' | sed -e 's/\\\(.*\\\)/-Xcc -I\\1/g' \)
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
pico_add_extra_outputs(${MAIN_TARGET_NAME})
# Enable USB output and disable UART output for the executable
pico_enable_stdio_usb(${MAIN_TARGET_NAME} 1)
pico_enable_stdio_uart(${MAIN_TARGET_NAME} 0)
