# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.13)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Initialise pico_sdk from installed location
# (note this can come from environment, CMake cache etc)

# == DO NEVER EDIT THE NEXT LINES for Raspberry Pi Pico VS Code Extension to work ==
if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()
set(sdkVersion 2.0.0)
set(toolchainVersion 13_2_Rel1)
set(picotoolVersion 2.0.0)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)
if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()
# ====================================================================================
set(PICO_BOARD pico2 CACHE STRING "Board type")

# Pull in Raspberry Pi Pico SDK (must be before project)
include(pico_sdk_import.cmake)

project(z80gpu C CXX ASM)

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()

# Add executable. Default name is the project name, version 0.1

add_subdirectory(MCP23S17)

add_executable(z80gpu 
    z80gpu.cpp
    pico_dvi.cpp
    gpumain.cpp
    gpu_protocol.cpp gpu_protocol.h
    gpu.h gpu.cpp
    font.h
    circular.h
    debug_protocol.cpp debug_protocol.h
    bus_access.cpp bus_access.h
    handlers.cpp
    disk_transaction.cpp

    filesystem/filesys.cpp
    filesystem/sdcard.cpp
    filesystem/platform_utils.cpp
    filesystem/ff.c
)

set(CMAKE_EXE_LINKER_FLAGS "-Wl,--print-memory-usage")

pico_set_program_name(z80gpu "z80gpu")
pico_set_program_version(z80gpu "0.1")

# Modify the below lines to enable/disable output over UART/USB
pico_enable_stdio_uart(z80gpu 0)
pico_enable_stdio_usb(z80gpu 0)

# Add the standard include files to the build
target_include_directories(z80gpu PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}
  ${CMAKE_CURRENT_LIST_DIR}/.. # for our common lwipopts or any other standard includes, if required
  ${CMAKE_CURRENT_LIST_DIR}/images
)

# Add any user requested libraries
target_link_libraries(z80gpu 
        pico_stdlib
        pico_multicore
        hardware_dma
        hardware_pwm
        hardware_spi
        pico_sync
        pico_rand
        pico_platform
		MCP23S17
        )

pico_add_extra_outputs(z80gpu)
