cmake_minimum_required(VERSION 3.15)
project(Ouroboros LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Sammelt alle .c Dateien ein
file(GLOB SOURCES "*.c" "src/*.c")

add_executable(Ouroboros ${SOURCES})

# Include-Verzeichnis bekannt machen
target_include_directories(Ouroboros PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

if(MSVC)
    # Windows/MSVC Flags
    target_compile_options(Ouroboros PRIVATE 
        /Ox
        /Oi
        /Ot
        /Oy
        /GL
        /arch:AVX2
        /fp:fast
        /favor:INTEL64
    )

    # Linker-Flags für das Zusammenfügen der optimierten Teile
    target_link_options(Ouroboros PRIVATE 
        /LTCG
        /OPT:REF
        /OPT:ICF
    )
else()
    # GCC/Clang Flags (Linux/macOS)
    # -O3: Maximale Optimierung
    # -Wall -Wextra: Viele Warnungen einschalten
    # -march=native: Optimiert für deinen speziellen Prozessor
    target_compile_options(Ouroboros PRIVATE -O3 -Wall -Wextra -march=native)
endif()