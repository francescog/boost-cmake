#
# Copyright Troy D. Straszheim
#
# Distributed under the Boost Software License, Version 1.0.
# See http://www.boost.org/LICENSE_1_0.txt
#
add_definitions(-DLIBNAME=b)

ryppl_add_library(b

  lib.cpp

  SHARED_COMPILE_FLAGS           "-DSHARED_OR_STATIC=SHARED"
  STATIC_COMPILE_FLAGS           "-DSHARED_OR_STATIC=STATIC"
  DEBUG_COMPILE_FLAGS            "-DDEBUG_OR_RELEASE=DEBUG"
  RELEASE_COMPILE_FLAGS          "-DDEBUG_OR_RELEASE=RELEASE"
  SINGLE_THREADED_COMPILE_FLAGS  "-DSINGLE_OR_MULTI=SINGLE_THREADED"
  MULTI_THREADED_COMPILE_FLAGS   "-DSINGLE_OR_MULTI=MULTI_THREADED"
  )

ryppl_add_executable(SHARED_RELEASE_MULTI_THREADED main.cpp  DEPENDS ryppl_b-mt-shared) 
ryppl_add_executable(SHARED_RELEASE_SINGLE_THREADED main.cpp DEPENDS ryppl_b-shared)
ryppl_add_executable(STATIC_RELEASE_MULTI_THREADED main.cpp  DEPENDS ryppl_b-mt-static)
ryppl_add_executable(STATIC_RELEASE_SINGLE_THREADED main.cpp DEPENDS ryppl_b-static)
ryppl_add_executable(SHARED_DEBUG_MULTI_THREADED main.cpp    DEPENDS ryppl_b-mt-shared-debug)
ryppl_add_executable(SHARED_DEBUG_SINGLE_THREADED main.cpp   DEPENDS ryppl_b-shared-debug)
ryppl_add_executable(STATIC_DEBUG_MULTI_THREADED main.cpp    DEPENDS ryppl_b-mt-static-debug)
ryppl_add_executable(STATIC_DEBUG_SINGLE_THREADED main.cpp   DEPENDS ryppl_b-static-debug)


