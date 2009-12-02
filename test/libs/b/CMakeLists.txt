#
# Copyright Troy D. Straszheim
#
# Distributed under the Boost Software License, Version 1.0.
# See http://www.boost.org/LICENSE_1_0.txt
#
#----------------------------------------------------------------------------
# This file was automatically generated from the original CMakeLists.txt file
# Add a variable to hold the headers for the library
set (lib_headers
    system
)

# Add a library target to the build system
ryppl_library_project(
  b
  SRCDIRS  src
  TESTDIRS test
  #  DOCDIRS 
  #  DESCRIPTION 
  #  AUTHORS 
  #  MAINTAINERS 
)


