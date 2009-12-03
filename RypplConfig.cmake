##########################################################################
# Ryppl Configuration Support                                            #
##########################################################################
# Copyright (C) 2007 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2007 Troy Straszheim                                     #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################
# This module defines several variables that provide information about   #
# the target compiler and platform.                                      #
#                                                                        #
# Variables defined:                                                     #
#                                                                        #
#   RYPPL_TOOLSET:                                                       #
#     The Ryppl toolset name, used by the library version mechanism to   #
#     encode the compiler and version into the name of the               #
#     library. This toolset name will correspond with Ryppl.Build        #
#     version 2's toolset name, including version number.                #
#                                                                        #
#   MULTI_THREADED_COMPILE_FLAGS:                                        #
#     Compilation flags when building multi-threaded programs.           #
#                                                                        #
#   MULTI_THREADED_LINK_FLAGS:                                           #
#     Linker flags when building multi-threaded programs.                #
##########################################################################
include(CheckCXXSourceCompiles)


# Toolset detection.
if (NOT RYPPL_TOOLSET)
  set(RYPPL_TOOLSET "unknown")
  if (MSVC60)
    set(RYPPL_TOOLSET "vc6")
    set(RYPPL_COMPILER "msvc")
    set(RYPPL_COMPILER_VERSION "6.0")
  elseif(MSVC70)
    set(RYPPL_TOOLSET "vc7")
    set(RYPPL_COMPILER "msvc")
    set(RYPPL_COMPILER_VERSION "7.0")
  elseif(MSVC71)
    set(RYPPL_TOOLSET "vc71")
    set(RYPPL_COMPILER "msvc")
    set(RYPPL_COMPILER_VERSION "7.1")
  elseif(MSVC80)
    set(RYPPL_TOOLSET "vc80")
    set(RYPPL_COMPILER "msvc")
    set(RYPPL_COMPILER_VERSION "8.0")
  elseif(MSVC90)
    set(RYPPL_TOOLSET "vc90")
    set(RYPPL_COMPILER "msvc")
    set(RYPPL_COMPILER_VERSION "9.0")
  elseif(MSVC)
    set(RYPPL_TOOLSET "vc")
    set(RYPPL_COMPILER "msvc")
    set(RYPPL_COMPILER_VERSION "unknown")
  elseif(BORLAND)
    set(RYPPL_TOOLSET "bcb")
    set(RYPPL_COMPILER "msvc")
    set(RYPPL_COMPILER_VERSION "unknown")
  elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
    set(RYPPL_COMPILER "gcc")

    # Execute GCC with the -dumpversion option, to give us a version string
    execute_process(
      COMMAND ${CMAKE_CXX_COMPILER} "-dumpversion" 
      OUTPUT_VARIABLE GCC_VERSION_STRING)
    
    # Match only the major and minor versions of the version string
    string(REGEX MATCH "[0-9]+.[0-9]+" GCC_MAJOR_MINOR_VERSION_STRING
      "${GCC_VERSION_STRING}")

    # Match the full compiler version for the build name
    string(REGEX MATCH "[0-9]+.[0-9]+.[0-9]+" RYPPL_COMPILER_VERSION
      "${GCC_VERSION_STRING}")
    
    # Strip out the period between the major and minor versions
    string(REGEX REPLACE "\\." "" RYPPL_VERSIONING_GCC_VERSION
      "${GCC_MAJOR_MINOR_VERSION_STRING}")
    
    # Set the GCC versioning toolset
    set(RYPPL_TOOLSET "gcc${RYPPL_VERSIONING_GCC_VERSION}")
  elseif(CMAKE_CXX_COMPILER MATCHES "/icpc$" 
      OR CMAKE_CXX_COMPILER MATCHES "/icpc.exe$" 
      OR CMAKE_CXX_COMPILER MATCHES "/icl.exe$")
    set(RYPPL_TOOLSET "intel")
    set(RYPPL_COMPILER "intel")
    set(CMAKE_COMPILER_IS_INTEL ON)
    execute_process(
      COMMAND ${CMAKE_CXX_COMPILER} "-dumpversion"
      OUTPUT_VARIABLE INTEL_VERSION_STRING
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(RYPPL_COMPILER_VERSION ${INTEL_VERSION_STRING})
  endif(MSVC60)
endif (NOT RYPPL_TOOLSET)

ryppl_report_pretty("Ryppl compiler" RYPPL_COMPILER)
ryppl_report_pretty("Ryppl toolset"  RYPPL_TOOLSET)

# create cache entry
set(RYPPL_PLATFORM "unknown")

# Multi-threading support
if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  set(MULTI_THREADED_COMPILE_FLAGS "-pthreads")
  set(MULTI_THREADED_LINK_LIBS rt)
  set(RYPPL_PLATFORM "sunos")
elseif(CMAKE_SYSTEM_NAME STREQUAL "BeOS")
  # No threading options necessary for BeOS
  set(RYPPL_PLATFORM "beos")
elseif(CMAKE_SYSTEM_NAME MATCHES ".*BSD")
  set(MULTI_THREADED_COMPILE_FLAGS "-pthread")
  set(MULTI_THREADED_LINK_LIBS pthread)
  set(RYPPL_PLATFORM "bsd")
elseif(CMAKE_SYSTEM_NAME STREQUAL "DragonFly")
  # DragonFly is a FreeBSD bariant
  set(MULTI_THREADED_COMPILE_FLAGS "-pthread")
  set(RYPPL_PLATFORM "dragonfly")
elseif(CMAKE_SYSTEM_NAME STREQUAL "IRIX")
  # TODO: GCC on Irix doesn't support multi-threading?
  set(RYPPL_PLATFORM "irix")
elseif(CMAKE_SYSTEM_NAME STREQUAL "HP-UX")
  # TODO: gcc on HP-UX does not support multi-threading?
  set(RYPPL_PLATFORM "hpux")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  # No threading options necessary for Mac OS X
  set(RYPPL_PLATFORM "macos")
elseif(UNIX)
  # Assume -pthread and -lrt on all other variants
  set(MULTI_THREADED_COMPILE_FLAGS "-pthread -D_REENTRANT")
  set(MULTI_THREADED_LINK_FLAGS "")  
  set(MULTI_THREADED_LINK_LIBS pthread rt)

  if (MINGW)
    set(RYPPL_PLATFORM "mingw")
  elseif(CYGWIN)
    set(RYPPL_PLATFORM "cygwin")
  elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(RYPPL_PLATFORM "linux")
  else()
    set(RYPPL_PLATFORM "unix")
  endif()
elseif(WIN32)
  set(RYPPL_PLATFORM "windows")
else()
  set(RYPPL_PLATFORM "unknown")
endif()

# create cache entry
set(RYPPL_PLATFORM ${RYPPL_PLATFORM} CACHE STRING "Ryppl platform name")

ryppl_report_pretty("Ryppl platform" RYPPL_PLATFORM)

# Setup DEBUG_COMPILE_FLAGS, RELEASE_COMPILE_FLAGS, DEBUG_LINK_FLAGS and
# and RELEASE_LINK_FLAGS based on the CMake equivalents
if(CMAKE_CXX_FLAGS_DEBUG)
  if(MSVC)
    # Eliminate the /MDd flag; we'll add it back when we need it
    string(REPLACE "/MDd" "" CMAKE_CXX_FLAGS_DEBUG 
      "${CMAKE_CXX_FLAGS_DEBUG}") 
  endif(MSVC)
  set(DEBUG_COMPILE_FLAGS "${CMAKE_CXX_FLAGS_DEBUG}" CACHE STRING "Compilation flags for debug libraries")
endif(CMAKE_CXX_FLAGS_DEBUG)
if(CMAKE_CXX_FLAGS_RELEASE)
  if(MSVC)
    # Eliminate the /MD flag; we'll add it back when we need it
    string(REPLACE "/MD" "" CMAKE_CXX_FLAGS_RELEASE
      "${CMAKE_CXX_FLAGS_RELEASE}") 
  endif(MSVC)
  set(RELEASE_COMPILE_FLAGS "${CMAKE_CXX_FLAGS_RELEASE}" CACHE STRING "Compilation flags for release libraries")
endif(CMAKE_CXX_FLAGS_RELEASE)
if(CMAKE_SHARED_LINKER_FLAGS_DEBUG)
  set(DEBUG_LINK_FLAGS "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}" CACHE STRING "Linker flags for debug libraries")
endif(CMAKE_SHARED_LINKER_FLAGS_DEBUG)
if(CMAKE_SHARED_LINKER_FLAGS_RELEASE)
  set(RELEASE_LINK_FLAGS "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}" CACHE STRING "Link flags for release libraries")
endif(CMAKE_SHARED_LINKER_FLAGS_RELEASE)

# Set DEBUG_EXE_LINK_FLAGS, RELEASE_EXE_LINK_FLAGS
if (CMAKE_EXE_LINKER_FLAGS_DEBUG)
  set(DEBUG_EXE_LINK_FLAGS "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
endif (CMAKE_EXE_LINKER_FLAGS_DEBUG)
if (CMAKE_EXE_LINKER_FLAGS_RELEASE)
  set(RELEASE_EXE_LINK_FLAGS "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
endif (CMAKE_EXE_LINKER_FLAGS_RELEASE)

# Tweak the configuration and build types appropriately.
if(CMAKE_CONFIGURATION_TYPES)
  # Limit CMAKE_CONFIGURATION_TYPES to Debug and Release
  set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Semicolon-separate list of supported configuration types" FORCE)
else(CMAKE_CONFIGURATION_TYPES)
  # Build in release mode by default
  if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build, options are Release or Debug" FORCE)
  endif (NOT CMAKE_BUILD_TYPE)
endif(CMAKE_CONFIGURATION_TYPES)

# Clear out the built-in C++ compiler and link flags for each of the 
# configurations.
set(CMAKE_CXX_FLAGS_DEBUG "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_MODULE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_CXX_FLAGS_RELEASE "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_CXX_FLAGS_MINSIZEREL "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO "" CACHE INTERNAL "Unused by Ryppl")
set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "" CACHE INTERNAL "Unused by Ryppl")

# Set the build name 
set(BUILDNAME "${RYPPL_COMPILER}-${RYPPL_COMPILER_VERSION}-${RYPPL_PLATFORM}")
ryppl_report_pretty("Build name" BUILDNAME)

set(BUILD_EXAMPLES "NONE" CACHE STRING "Semicolon-separated list of lowercase project names that should have their examples built, or \"ALL\"")

set(BUILD_PROJECTS "ALL"  CACHE STRING "Semicolon-separated list of project to build, or \"ALL\"")

set(LIB_SUFFIX "" CACHE STRING "Name of suffix on 'lib' directory to which libs will be installed (e.g. add '64' here on certain 64 bit unices)")
if(LIB_SUFFIX)
  ryppl_report_pretty("Lib suffix" LIB_SUFFIX)
endif()

set(root "${CMAKE_CURRENT_SOURCE_DIR}")

set(RYPPL_LIBS_PARENT_DIR "${root}/src" CACHE INTERNAL
  "Directory to glob tools from...  only change to test the build system itself")

set(RYPPL_TOOLS_PARENT_DIR "${root}/tools" CACHE INTERNAL
  "Directory to glob tools from...  only change to test the build system itself")

