cmake_minimum_required(VERSION 3.15)
project(Ouroboros LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Findet alle .cpp Dateien im aktuellen Ordner
file(GLOB SOURCES "*.cpp")

add_executable(Ouroboros ${SOURCES})

# Das include-Verzeichnis für den Compiler öffnen
target_include_directories(Ouroboros PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

# Optimierungen für den MSVC Compiler (Standard bei Visual Studio)
if(MSVC)
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
endif()