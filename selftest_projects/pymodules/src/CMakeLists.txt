#
# Copyright Troy D. Straszheim
#
# Distributed under the Boost Software License, Version 1.0.
# See http://www.boost.org/LICENSE_1_0.txt
#

include_directories(${PYTHON_INCLUDE_PATH})

ryppl_python_extension(fooext_rel
  
  extension.cpp

  COMPILE_FLAGS "-DMODNAME=fooext_rel"
  RELEASE_COMPILE_FLAGS "-DFLAGS=\"RELFLAGS\""
  DEPENDS boost_python
  LINK_LIBS ${PYTHON_LIBRARIES}
  RELEASE)

ryppl_python_extension(fooext_dbg
  
  extension.cpp

  COMPILE_FLAGS "-DMODNAME=fooext_dbg"
  DEBUG_COMPILE_FLAGS "-DFLAGS=DBGFLAGS"
  DEPENDS boost_python
  LINK_LIBS ${PYTHON_LIBRARIES}
  DEBUG)

ryppl_python_extension(fooext_default
  
  extension.cpp

  COMPILE_FLAGS "-DMODNAME=fooext_default -DFLAGS=NOFLAGS"
  
  DEPENDS boost_python
  LINK_LIBS ${PYTHON_LIBRARIES})




ryppl_python_extension(fooext_test_linkflags
  
  extension.cpp

  DEPENDS boost_python
  LINK_LIBS ${PYTHON_LIBRARIES}
  LINK_FLAGS bogus_linkflags
  )




