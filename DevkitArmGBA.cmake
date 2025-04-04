set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION DKA-GBA-52)
set(CMAKE_SYSTEM_PROCESSOR armv4t)
set(GBA TRUE)# To be used for multiplatform projects

set(CMAKE_SYSTEM_INCLUDE_PATH /include)
set(CMAKE_SYSTEM_LIBRARY_PATH /lib)

# DevkitPro paths are broken on windows, so we have to fix those
macro(msys_to_cmake_path MsysPath ResultingPath)
    if(WIN32)
        string(REGEX REPLACE "^/([a-zA-Z])/" "\\1:/" ${ResultingPath} "${MsysPath}")
    else()
        set(${ResultingPath} "${MsysPath}")
    endif()
endmacro()

msys_to_cmake_path("$ENV{DEVKITPRO}" DEVKITPRO)
if(NOT IS_DIRECTORY ${DEVKITPRO})
    message(FATAL_ERROR "Please set DEVKITPRO in your environment")
endif()

msys_to_cmake_path("$ENV{DEVKITARM}" DEVKITARM)
if(NOT IS_DIRECTORY ${DEVKITARM})
    message(FATAL_ERROR "Please set DEVKITARM in your environment")
endif()

# Prefix detection only works with compiler id "GNU"
# CMake will look for prefixed g++, cpp, ld, etc. automatically
set(CMAKE_C_COMPILER "${DEVKITARM}/bin/arm-none-eabi-gcc${CMAKE_EXECUTABLE_SUFFIX}")
set(CMAKE_CXX_COMPILER "${DEVKITARM}/bin/arm-none-eabi-g++${CMAKE_EXECUTABLE_SUFFIX}")
set(CMAKE_LINKER "${DEVKITARM}/bin/arm-none-eabi-ld${CMAKE_EXECUTABLE_SUFFIX}")
set(CMAKE_OBJCOPY "${DEVKITARM}/bin/arm-none-eabi-objcopy${CMAKE_EXECUTABLE_SUFFIX}")
set(CMAKE_AR "${DEVKITARM}/bin/arm-none-eabi-gcc-ar${CMAKE_EXECUTABLE_SUFFIX}" CACHE STRING "")
set(CMAKE_AS "${DEVKITARM}/bin/arm-none-eabi-as${CMAKE_EXECUTABLE_SUFFIX}" CACHE STRING "")
set(CMAKE_NM "${DEVKITARM}/bin/arm-none-eabi-gcc-nm${CMAKE_EXECUTABLE_SUFFIX}" CACHE STRING "")
set(CMAKE_RANLIB "${DEVKITARM}/bin/arm-none-eabi-gcc-ranlib${CMAKE_EXECUTABLE_SUFFIX}" CACHE STRING "")

set(WITH_PORTLIBS ON CACHE BOOL "use portlibs ?")

if(WITH_PORTLIBS)
    set(CMAKE_FIND_ROOT_PATH ${DEVKITARM} ${DEVKITPRO} ${DEVKITPRO}/portlibs/gba ${DEVKITPRO}/portlibs/armv4)
else()
    set(CMAKE_FIND_ROOT_PATH ${DEVKITARM} ${DEVKITPRO})
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)

add_definitions(-DARM4 -D_GBA)

set(ARCH "-mthumb -mthumb-interwork")
set(CMAKE_C_FLAGS "-mcpu=arm7tdmi -mtune=arm7tdmi ${ARCH}" CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "" CACHE STRING "C++ flags")
set(CMAKE_ASM_FLAGS "-x assembler-with-cpp ${ARCH}" CACHE STRING "ASM flags")
set(CMAKE_EXE_LINKER_FLAGS "" CACHE STRING "Executable LD flags")
set(CMAKE_STATIC_LINKER_FLAGS "" CACHE STRING "Library LD flags")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS} --specs=gba.specs") # Needed so _start is found
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS} --specs=gba.specs") # Needed so _start is found
set(DKA_SUGGESTED_C_FLAGS "-fomit-frame-pointer -ffast-math")
set(DKA_SUGGESTED_CXX_FLAGS "${DKA_SUGGESTED_C_FLAGS} -fno-rtti -fno-exceptions")

set(CMAKE_INSTALL_PREFIX ${DEVKITPRO}/portlibs/gba
    CACHE PATH "Install libraries in the portlibs dir")
