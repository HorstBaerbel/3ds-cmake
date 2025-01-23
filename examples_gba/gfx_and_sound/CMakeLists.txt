cmake_minimum_required(VERSION 3.21)

# Note that you must copy the cmake folder and the DevkitArmGBA.cmake file in this directory
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/../../DevkitArmGBA.cmake)
# Add the cmake folder to the modules paths, so that we can use the tools
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../../cmake)

project(cmake_vscode)

# ASM must be enabled to support .S files
enable_language(ASM)
# Include all the macros and tools needed for GBA development.
include(ToolsGBA)

# List all the source files in out directory
LIST(APPEND SOURCE_FILES
	./main.cpp
	./memcpy.s
)

LIST(APPEND EXTRA_SOURCE_FILES
)

LIST(APPEND EXTRA_DATA_FILES
	./data/dkp_logo.c
)

LIST(APPEND INCLUDE_DIRECTORIES
	${DEVKITPRO}/libgba/include
	${DEVKITARM}/arm-none-eabi/include/
)

LIST(APPEND LIBRARY_DIRECTORIES
	${DEVKITPRO}/libgba/lib
)

LIST(APPEND LIBRARIES
	gba
	mm
)

add_executable(cmake_vscode ${SOURCE_FILES} ${INCLUDE_FILES} ${EXTRA_SOURCE_FILES} ${EXTRA_DATA_FILES}) # Create the GBA binary
add_gba_executables(cmake_vscode "CMAKE_VSCODE" "CMVS" "HB" 1) # Generate the .elf and .gba from the binary
add_map_file(cmake_vscode) # Generate a .map file for the binary
add_sections_file(cmake_vscode) # Generate a markdown sections overview for the binary
target_include_directories(cmake_vscode PRIVATE ${INCLUDE_DIRECTORIES})
target_link_directories(cmake_vscode PRIVATE ${LIBRARY_DIRECTORIES})
target_link_libraries(cmake_vscode ${LIBRARIES}) # Link the application, libgba and maxmod

# List all the MaxMOD music files
file(GLOB_RECURSE MUSIC_FILES
	./music/*
)
target_maxmod_file(cmake_vscode ${MUSIC_FILES}) # Build soundbank file from music files

# List all the binary files
file(GLOB_RECURSE DATA_FILES
	./data/*.bin
)
