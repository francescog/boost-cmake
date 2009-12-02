# Copyright (C) Troy Straszheim
#
# Distributed under the Boost Software License, Version 1.0. 
# See accompanying file LICENSE_1_0.txt or copy at 
#   http://www.boost.org/LICENSE_1_0.txt 
#

message(STATUS "")
colormsg(_HIBLUE_ "Looking for (optional) dependencies on the system")

macro(ryppl_external_report NAME)
  string(TOUPPER ${NAME} VARNAME)
  set(VARNAMES ${ARGV})
  list(REMOVE_AT VARNAMES 0)
  set(SUCCESS ${${VARNAME}_FOUND})
  if(NOT SUCCESS) 
    message(STATUS "${NAME} not found, some libraries or features will be disabled.")
    message(STATUS "See the documentation for ${NAME} or manually set these variables:")
  endif()
  foreach(variable ${VARNAMES})
    ryppl_report_value(${VARNAME}_${variable})
  endforeach()
endmacro()

#
#  Some externals default to OFF
#
option(WITH_VALGRIND "Run tests under valgrind" OFF)

#
#
#
foreach(external
    BZip2
    Doxygen
    Expat
    ICU
    MPI
    Python
    Xsltproc
    Valgrind
    ZLib
    )
  message(STATUS "")
  string(TOUPPER "${external}" EXTERNAL)
  option(WITH_${EXTERNAL} "Attempt to find and configure ${external}" ON)
  if(WITH_${EXTERNAL})
    colormsg(HICYAN "${external}:")
    include(${CMAKE_CURRENT_SOURCE_DIR}/${RYPPL_CMAKE_DIR}/externals/${external}.cmake)
  else()
    set(${EXTERNAL}_FOUND FALSE CACHE BOOL "${external} found" FORCE)
    colormsg(HIRED "${external}:" RED "disabled, since WITH_${EXTERNAL}=OFF")
  endif()
endforeach()
message(STATUS "")