cmake_minimum_required(VERSION 3.16)
project(VelaSU C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

add_library(velasu_core STATIC
    core/src/capability.c
)
target_include_directories(velasu_core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

add_library(velasu_probe STATIC
    probe/src/probe.c
)
target_include_directories(velasu_probe PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/probe/include
)

add_executable(velasu-probe
    probe/src/main.c
)
target_link_libraries(velasu-probe PRIVATE velasu_probe)
