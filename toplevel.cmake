##########################################################################
# CMake Build Rules for Ryppl                                            #
##########################################################################
# Copyright (C) 2007, 2008 Douglas Gregor <doug.gregor@gmail.com>        #
# Copyright (C) 2007, 2009 Troy Straszheim <troy@resophonic.com>         #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################
# Basic Usage:                                                           #
#                                                                        #
#   On Unix variants:                                                    #
#     ccmake RYPPL_DIRECTORY                                             #
#                                                                        #
#     (c)onfigure options to your liking, then (g)enerate                #
#     makefiles. Use "make" to build, "make test" to test, "make         #
#     install" to install, and "make package" to build binary            #
#     packages.                                                          #
#                                                                        #
#   On Windows:                                                          #
#     run the CMake GUI, load the Ryppl directory, and generate          #
#     project files or makefiles for your environment.                   #
#                                                                        #
# For more information about CMake, see http://www.cmake.org             #
##########################################################################
cmake_minimum_required(VERSION 2.6.4 FATAL_ERROR)
project(Ryppl)

##########################################################################
# Ryppl CMake modules                                                    #
##########################################################################
set(RYPPL_CMAKE_DIR cmake)
list(APPEND CMAKE_MODULE_PATH ${Ryppl_SOURCE_DIR}/${RYPPL_CMAKE_DIR})
include(RypplUtils)

message(STATUS "")
colormsg(_HIBLUE_ "Ryppl starting")

##########################################################################
# Version information                                                    #
##########################################################################

# We parse the version information from the ryppl/version.hpp header.
# file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/libs/core/include/ryppl/version.hpp RYPPL_VERSIONSTR
#   REGEX "#define[ ]+RYPPL_VERSION[ ]+[0-9]+")
# string(REGEX MATCH "[0-9]+" RYPPL_VERSIONSTR ${RYPPL_VERSIONSTR})
# if (RYPPL_VERSIONSTR)
#   math(EXPR RYPPL_VERSION_MAJOR "${RYPPL_VERSIONSTR} / 100000")
#   math(EXPR RYPPL_VERSION_MINOR "${RYPPL_VERSIONSTR} / 100 % 1000")
#   math(EXPR RYPPL_VERSION_SUBMINOR "${RYPPL_VERSIONSTR} % 100")
#   set(RYPPL_VERSION "${RYPPL_VERSION_MAJOR}.${RYPPL_VERSION_MINOR}.${RYPPL_VERSION_SUBMINOR}")
# else()
#   message(FATAL_ERROR 
#     "Unable to parse Ryppl version from ${CMAKE_CURRENT_SOURCE_DIR}/ryppl/version.hpp")
# endif()
# 
# #
# # Make sure that we reconfigure when ryppl/version.hpp changes.
# #
# configure_file(libs/core/include/ryppl/version.hpp
#    ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/version.stamp)


#
#  This for automatic testing of multiple versioned installs
#
if(RYPPL_VERSION_OVERRIDE)
  set(RYPPL_VERSION ${RYPPL_VERSION_OVERRIDE})
  set(RYPPL_VERSION_NUMERIC ${RYPPL_VERSION_NUMERIC_OVERRIDE})
  set(RYPPL_VERSION_UNDERSCORES ${RYPPL_VERSION_UNDERSCORES_OVERRIDE})
  configure_file(${RYPPL_CMAKE_DIR}/install_me/version.hpp.override.in ${CMAKE_BINARY_DIR}/version.hpp)
endif()

set(RYPPL_CMAKE_VERSION "${RYPPL_VERSION}.cmake0")

#
#  For intermittent deployment of docs
#
set(RYPPL_CMAKE_HOST sodium.resophonic.com)
set(RYPPL_CMAKE_DOCROOT /var/www/htdocs/ryppl-cmake/)
set(RYPPL_CMAKE_VERSIONED_DOCROOT ${RYPPL_CMAKE_DOCROOT}/${RYPPL_CMAKE_VERSION})
set(RYPPL_CMAKE_URL ${RYPPL_CMAKE_HOST}:${RYPPL_CMAKE_VERSIONED_DOCROOT})

#
# RYPPL_MAINTAINER: undocced variable that sets up maintainer mode
#
if(RYPPL_MAINTAINER)  
  #
  #  Put the ryppl.cmake version someplace sphinx can get it
  #  for use in generated documentation
  #
  set(CMAKE_DOCS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${RYPPL_CMAKE_DIR}/docs/)
  set(UPSTREAM_TAG "Ryppl_1_41_0")
  
  set(gitdiff "git diff --stat=100,90 ${UPSTREAM_TAG}") 
  add_custom_target(make-diff
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND echo "% ${gitdiff}" > ${CMAKE_DOCS_DIR}/source/git_diff.txt
    COMMAND git diff --stat=100,90 ${UPSTREAM_TAG} >> ${CMAKE_DOCS_DIR}/source/git_diff.txt
    COMMAND make -C ${CMAKE_DOCS_DIR} html
    )

  add_custom_target(do-release
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND git archive --format=tar --prefix=ryppl-${RYPPL_CMAKE_VERSION}/ ${RYPPL_CMAKE_VERSION} | gzip --best > ryppl-${RYPPL_CMAKE_VERSION}.tar.gz
    COMMAND git archive --format=zip -9 --prefix=ryppl-${RYPPL_CMAKE_VERSION}/ ${RYPPL_CMAKE_VERSION} > ryppl-${RYPPL_CMAKE_VERSION}.zip
    # COMMAND git log --quiet ${RYPPL_CMAKE_VERSION} > /dev/null
    COMMAND ssh ${RYPPL_CMAKE_HOST} mkdir -p ${RYPPL_CMAKE_VERSIONED_DOCROOT}
    COMMAND scp ryppl-${RYPPL_CMAKE_VERSION}.tar.gz ryppl-${RYPPL_CMAKE_VERSION}.zip ${RYPPL_CMAKE_URL}
    COMMAND make -C ${CMAKE_DOCS_DIR} deploy
    )
    
  colormsg(HIRED "*** MAINTAINER TARGETS ADDED ***")

endif()

##########################################################################

# Put the libaries and binaries that get built into directories at the
# top of the build tree rather than in hard-to-find leaf
# directories. This simplifies manual testing and the use of the build
# tree rather than installed Ryppl libraries.
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)


message(STATUS "")
ryppl_report_pretty("Ryppl.CMake version" RYPPL_CMAKE_VERSION)

include(RypplConfig)
include(RypplCore)
include(RypplDocs)
include(RypplTesting)
##########################################################################

##########################################################################
# Build Features and Variants                                            #
##########################################################################


# User-level options deciding which variants we will build. 
option(ENABLE_STATIC "Whether to build static libraries" ON)
option(ENABLE_SHARED "Whether to build shared libraries" ON)
option(ENABLE_DEBUG "Whether to build debugging libraries" ON)
option(ENABLE_RELEASE "Whether to build release libraries" ON)
option(ENABLE_SINGLE_THREADED "Whether to build single-threaded libraries" OFF)
option(ENABLE_MULTI_THREADED "Whether to build multi-threaded libraries" ON)

if(BUILD_VERSIONED)
  message(FATAL_ERROR "Option 'BUILD_VERSIONED' has changed, the new name is WINMANGLE_LIBNAMES")
endif(BUILD_VERSIONED)

#if(BUILD_TESTING)
#  message(FATAL_ERROR "Option 'BUILD_TESTING' is gone, new name is BUILD_TESTS, see the docs")
#endif()

option(WINMANGLE_LIBNAMES
  "mangle toolset and ryppl version tags to into library names" 
  ${WIN32})

option(BUILD_SOVERSIONED "Create libraries with SONAMES" ${UNIX})

if(UNIX)
  option(INSTALL_VERSIONED "Install to versioned directories" ON)
endif()


# the default set of library variants that we will be building
ryppl_add_default_variant(RELEASE DEBUG)
ryppl_add_default_variant(SHARED STATIC)
ryppl_add_default_variant(MULTI_THREADED SINGLE_THREADED)

if (MSVC)
  # For now, we only actually support static/dynamic run-time variants for 
  # Visual C++. Provide both options for Visual C++ users, but just fix
  # the values of the variables for all other platforms.
  option(ENABLE_STATIC_RUNTIME 
    "Whether to build libraries linking against the static runtime" 
    ON)

  option(ENABLE_DYNAMIC_RUNTIME 
    "Whether to build libraries linking against the dynamic runtime" 
    ON)

  ryppl_add_default_variant(DYNAMIC_RUNTIME STATIC_RUNTIME)
endif()

# Extra features used by some libraries
set(ENABLE_PYTHON_NODEBUG ON)
ryppl_add_extra_variant(PYTHON_NODEBUG PYTHON_DEBUG)
##########################################################################

##########################################################################
# Installation                                                           #
##########################################################################
if (WIN32)
  set(sep "_")
else()
  set(sep ".")
endif()

if (RYPPL_VERSION_OVERRIDE)
  set(verdir "ryppl-${RYPPL_VERSION_OVERRIDE}")
elseif(INSTALL_VERSIONED)
  set(verdir "ryppl-${RYPPL_VERSION_MAJOR}${sep}${RYPPL_VERSION_MINOR}${sep}${RYPPL_VERSION_SUBMINOR}")
else()
  set(verstring "")
endif()

set(RYPPL_INCLUDE_INSTALL_DIR 
  "include/${verdir}"
  CACHE STRING "Destination path under CMAKE_INSTALL_PREFIX for header files"
  )

set(RYPPL_LIB_INSTALL_DIR
  "lib${LIB_SUFFIX}/${verdir}"
  CACHE STRING "Destination path under CMAKE_INSTALL_PREFIX for libraries"
  )

ryppl_report_pretty("Install prefix" CMAKE_INSTALL_PREFIX)
ryppl_report_pretty("Install include dir" RYPPL_INCLUDE_INSTALL_DIR)
ryppl_report_pretty("Install lib dir" RYPPL_LIB_INSTALL_DIR)

include(RypplExternals)

if (RYPPL_VERSION_OVERRIDE)
  install(FILES ${CMAKE_BINARY_DIR}/version.hpp 
    DESTINATION ${RYPPL_INCLUDE_INSTALL_DIR}/ryppl
    RENAME version.hpp)
  install(DIRECTORY ryppl 
    DESTINATION ${RYPPL_INCLUDE_INSTALL_DIR}
    PATTERN "CVS" EXCLUDE
    PATTERN ".svn" EXCLUDE
    PATTERN "ryppl/version.hpp" EXCLUDE)
else()
  install(DIRECTORY ryppl 
    DESTINATION ${RYPPL_INCLUDE_INSTALL_DIR}
    PATTERN "CVS" EXCLUDE
    PATTERN ".svn" EXCLUDE)
endif()

#
# for testing
#
if (RYPPL_VERSION_OVERRIDE)
  install(FILES ${CMAKE_BINARY_DIR}/version.hpp 
    DESTINATION ${RYPPL_INCLUDE_INSTALL_DIR}/ryppl
    RENAME version.hpp)
endif()


##########################################################################
# Binary packages                                                        #
##########################################################################
#
#  CPACK_PACKAGE_NAME may not contain spaces when generating rpms
#
set(CPACK_PACKAGE_NAME "Ryppl")
set(CPACK_PACKAGE_VENDOR "Ryppl.org")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Ryppl ${RYPPL_VERSION} prerelease")
set(CPACK_PACKAGE_FILE_NAME "ryppl-${RYPPL_VERSION}-${RYPPL_PLATFORM}-${RYPPL_TOOLSET}")

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/README.txt")
  message(STATUS "Using generic cpack package description file.")
  set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.txt")
  set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.txt")
endif ()

# set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE_1_0.txt")
# if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Welcome.txt")
#   message(STATUS "Using generic cpack welcome file.")
#   set(CPACK_RESOURCE_FILE_WELCOME "${CMAKE_CURRENT_SOURCE_DIR}/Welcome.txt")
# endif()
# 
# set(CPACK_PACKAGE_VERSION "${RYPPL_VERSION}")
# set(CPACK_PACKAGE_VERSION_MAJOR "${RYPPL_VERSION_MAJOR}")
# set(CPACK_PACKAGE_VERSION_MINOR "${RYPPL_VERSION_MINOR}")
# set(CPACK_PACKAGE_VERSION_PATCH "${RYPPL_VERSION_SUBMINOR}")
# set(CPACK_PACKAGE_INSTALL_DIRECTORY "Ryppl")

# if(WIN32 AND NOT UNIX)
#   # There is a bug in NSI that does not handle full unix paths properly. Make
#   # sure there is at least one set of four (4) backlasshes.
#   # NOTE: No Ryppl icon yet
#   set(CPACK_MONOLITHIC_INSTALL ON) # don't be modular for now
#   set(CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}/${RYPPL_CMAKE_DIR}\\\\Ryppl.bmp")
# #  set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\MyExecutable.exe")
#   set(CPACK_NSIS_DISPLAY_NAME "Ryppl ${RYPPL_VERSION_MAJOR}.${RYPPL_VERSION_MINOR}.${RYPPL_VERSION_SUBMINOR} prerelease")
#   set(CPACK_NSIS_HELP_LINK "http:\\\\\\\\www.ryppl.org")
#   set(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\www.ryppl.org")
#   set(CPACK_NSIS_CONTACT "ryppl-users@lists.ryppl.org")
#   set(CPACK_NSIS_MODIFY_PATH ON)
#   
#   # Encode the compiler name in the package 
#   if (MSVC60)
#     set(CPACK_PACKAGE_FILE_NAME "Ryppl-${RYPPL_VERSION}-vc6")
#     set(CPACK_NSIS_DISPLAY_NAME "${CPACK_NSIS_DISPLAY_NAME} for Microsoft Visual C++ 6")
#   elseif (MSVC70)
#     set(CPACK_PACKAGE_FILE_NAME "Ryppl-${RYPPL_VERSION}-vc7")
#     set(CPACK_NSIS_DISPLAY_NAME "${CPACK_NSIS_DISPLAY_NAME} for Microsoft Visual Studio 2002")
#   elseif (MSVC71)
#     set(CPACK_PACKAGE_FILE_NAME "Ryppl-${RYPPL_VERSION}-vc71")
#     set(CPACK_NSIS_DISPLAY_NAME "${CPACK_NSIS_DISPLAY_NAME} for Microsoft Visual Studio 2003")
#   elseif (MSVC80)
#     set(CPACK_PACKAGE_FILE_NAME "Ryppl-${RYPPL_VERSION}-vc8")
#     set(CPACK_NSIS_DISPLAY_NAME "${CPACK_NSIS_DISPLAY_NAME} for Microsoft Visual Studio 2005")    
#   elseif (MSVC90)
#     set(CPACK_PACKAGE_FILE_NAME "Ryppl-${RYPPL_VERSION}-vc9")
#     set(CPACK_NSIS_DISPLAY_NAME "${CPACK_NSIS_DISPLAY_NAME} for Microsoft Visual Studio 2008")
#   elseif (BORLAND)
#     set(CPACK_PACKAGE_FILE_NAME "Ryppl-${RYPPL_VERSION}-borland")  
#     set(CPACK_NSIS_DISPLAY_NAME "${CPACK_NSIS_DISPLAY_NAME} for Borland C++ Builder")    
#   endif (MSVC60)
#   set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${CPACK_NSIS_DISPLAY_NAME}")
# endif(WIN32 AND NOT UNIX)
# include(CPack)
# 
# if (FALSE)
#   option(RYPPL_INSTALLER_ON_THE_FLY
#     "Whether to build installers that download components on-the-fly" OFF)
#  
#   if (RYPPL_INSTALLER_ON_THE_FLY)
#     if(COMMAND cpack_configure_downloads)
#       cpack_configure_downloads(
# 	"http://www.osl.iu.edu/~dgregor/Ryppl-CMake/${RYPPL_VERSION}/"
# 	ALL ADD_REMOVE)
#     endif()
#   endif()
# endif()
# ##########################################################################
# 
# ##########################################################################
# # Building Ryppl libraries                                               #
# ##########################################################################
# # Always include the directory where Ryppl's include files will be.
if (RYPPL_CMAKE_SELFTEST)
  # Use selftest headers
  include_directories("${RYPPL_CMAKE_SELFTEST_ROOT}/include")
endif()

# and regular ryppl headers
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# # Ryppl.Build version 2 does this due to trouble with autolinking
# # during building and testing.  
# # TODO: See if we can actually use auto-linking in our regression tests.
# add_definitions(-DRYPPL_ALL_NO_LIB=1)
# 
# #
# # Get build space set up for exports file
# #
set(RYPPL_EXPORTS_FILE ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/Exports.cmake
  CACHE FILEPATH "File to export targets from ryppl build directory")
# 
file(MAKE_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
file(REMOVE ${RYPPL_EXPORTS_FILE})
# 
if(NOT INSTALL_VERSIONED)
  set(pathelem "ryppl/")
endif()
# 
if (NOT RYPPL_EXPORTS_INSTALL_DIR)
  set(RYPPL_EXPORTS_INSTALL_DIR ${RYPPL_LIB_INSTALL_DIR}
    CACHE STRING "Install location for cmake exports")
endif()
# 
mark_as_advanced(RYPPL_EXPORTS_FILE)
# 
# # Add build rules for documentation
# add_subdirectory(doc)
# 
# # Add build rules for all of the Ryppl libraries
add_subdirectory(src)
# 
# # Add build rules for all of the Ryppl tools
# # TODO: On hold while I work on the modularity code
# add_subdirectory(tools)
# ##########################################################################
# 
# if(NOT RYPPL_ALL_COMPONENTS)
#   #
#   # This is a dummy target to suppress the warning from
#   # install(EXPORT,....) below.
#   # 
#   add_executable(this_is_a_dummy_no_libs_were_built
#     ${CMAKE_CURRENT_SOURCE_DIR}/${RYPPL_CMAKE_DIR}/main.cpp)
#   
#   install(TARGETS this_is_a_dummy_no_libs_were_built
#     EXPORT Ryppl
#     DESTINATION ${RYPPL_LIB_INSTALL_DIR}
#     COMPONENT Ryppl)
# 
# endif()
# 
# install(EXPORT Ryppl DESTINATION ${RYPPL_EXPORTS_INSTALL_DIR})

add_subdirectory(${RYPPL_CMAKE_DIR})

add_custom_target(genheaders
  COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/${RYPPL_CMAKE_DIR}/genheaders.py 
  ${CMAKE_CURRENT_SOURCE_DIR}/src ${CMAKE_CURRENT_SOURCE_DIR}/include
  COMMENT "Generating central header directory")


