#
# Copyright (C) Troy D. Straszheim
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
#   http://www.boost.org/LICENSE_1_0.txt
#
#
# On unix this is '/usr/share/cmake/ryppl'
#
set(RYPPL_CMAKE_INFRASTRUCTURE_INSTALL_DIR
  "share/ryppl-${RYPPL_VERSION}/cmake"
  CACHE STRING 
  "Directory to install Ryppl-${RYPPL_VERSION} to")

#
# Provides version number to sphinx build
#
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/docs/source/ryppl_version.py.in
  ${CMAKE_CURRENT_SOURCE_DIR}/docs/source/ryppl_version.py)

#
# Makefile for sphinx build with maintainer targets
#
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/docs/Makefile.in
  ${CMAKE_CURRENT_SOURCE_DIR}/docs/Makefile)

#
# File used by RypplConfigVersion to import targets/src/etc 
# into users's cmake build
#
foreach (file 
    RypplConfig
    RypplConfigVersion
    RypplConfigAgnostic
    RypplConfigVersionAgnostic)
  configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/install_me/${file}.cmake.in 
    ${CMAKE_CURRENT_SOURCE_DIR}/install_me/${file}.cmake @ONLY)
endforeach()


#
#  These are generated, version-specific
#
install(FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/install_me/RypplConfigVersion.cmake
  ${CMAKE_CURRENT_SOURCE_DIR}/install_me/RypplConfig.cmake
  DESTINATION ${RYPPL_CMAKE_INFRASTRUCTURE_INSTALL_DIR}
  )

#
# The files that go in <prefix>/share/cmake/ryppl that search for
# Ryppl-<version>.cmake files (user specifies <version>)
#
option(RYPPL_INSTALL_CMAKE_DRIVERS
  "Install version-agnostic RypplConfig.cmake and RypplConfigVersion.cmake to this subdirectory of CMAKE_INSTALL_PREFIX" ON)

if (RYPPL_INSTALL_CMAKE_DRIVERS)
  if (NOT RYPPL_CMAKE_DRIVERS_INSTALL_DIR)
    set(agnostic_infra_dir "share/cmake/ryppl")
  else()
    set(agnostic_infra_dir ${RYPPL_CMAKE_DRIVERS_INSTALL_DIR})
  endif()
  install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/install_me/RypplConfigAgnostic.cmake
    DESTINATION ${agnostic_infra_dir}
    RENAME RypplConfig.cmake
    )
  install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/install_me/RypplConfigVersionAgnostic.cmake
    DESTINATION ${agnostic_infra_dir}
    RENAME RypplConfigVersion.cmake
    )
endif()


