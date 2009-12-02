#
# Copyright Troy D. Straszheim
#
# Distributed under the Boost Software License, Version 1.0.
# See http://www.boost.org/LICENSE_1_0.txt
#
ryppl_add_library(b

  lib.cpp

  SHARED_COMPILE_FLAGS           "-DSHARED_OR_STATIC=SHARED"
  STATIC_COMPILE_FLAGS           "-DSHARED_OR_STATIC=STATIC"
  DEBUG_COMPILE_FLAGS            "-DDEBUG_OR_RELEASE=DEBUG"
  RELEASE_COMPILE_FLAGS          "-DDEBUG_OR_RELEASE=RELEASE"
  SINGLE_THREADED_COMPILE_FLAGS  "-DSINGLE_OR_MULTI=SINGLE_THREADED"
  MULTI_THREADED_COMPILE_FLAGS   "-DSINGLE_OR_MULTI=MULTI_THREADED"
  )

ryppl_add_executable(SHARED-RELEASE-MULTI_THREADED main.cpp  DEPENDS b-mt-shared)
ryppl_add_executable(SHARED-RELEASE-SINGLE_THREADED main.cpp DEPENDS b-shared)
ryppl_add_executable(STATIC-RELEASE-MULTI_THREADED main.cpp  DEPENDS b-mt-static)
ryppl_add_executable(STATIC-RELEASE-SINGLE_THREADED main.cpp DEPENDS b-static)
ryppl_add_executable(SHARED-DEBUG-MULTI_THREADED main.cpp    DEPENDS b-mt-shared-debug)
ryppl_add_executable(SHARED-DEBUG-SINGLE_THREADED main.cpp   DEPENDS b-shared-debug)
ryppl_add_executable(STATIC-DEBUG-MULTI_THREADED main.cpp    DEPENDS b-mt-static-debug)
ryppl_add_executable(STATIC-DEBUG-SINGLE_THREADED main.cpp   DEPENDS b-static-debug)


