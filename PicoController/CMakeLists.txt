
cmake_minimum_required(VERSION 3.13)

set(PICO_BOARD pico2_w CACHE STRING "Board type")

include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(led_pico C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(led_pico
    src/main.cpp
)

target_include_directories(led_pico PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/include
)

target_link_libraries(led_pico PRIVATE
    pico_stdlib
    pico_cyw43_arch_none
    pico_btstack_ble
    pico_btstack_cyw43
)

pico_enable_stdio_usb(led_pico 1)
pico_enable_stdio_uart(led_pico 0)

pico_add_extra_outputs(led_pico)

