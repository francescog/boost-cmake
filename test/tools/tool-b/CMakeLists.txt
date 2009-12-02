#
# Copyright Troy D. Straszheim
#
# Distributed under the Boost Software License, Version 1.0.
# See http://www.boost.org/LICENSE_1_0.txt
#
ryppl_tool_project(b
  DESCRIPTION "tool-b"
  AUTHORS "author-b"
  )

ryppl_add_executable(tool-b-SHARED-RELEASE-MULTI_THREADED main.cpp  DEPENDS b-mt-shared)
ryppl_add_executable(tool-b-SHARED-RELEASE-SINGLE_THREADED main.cpp DEPENDS b-shared)
ryppl_add_executable(tool-b-STATIC-RELEASE-MULTI_THREADED main.cpp  DEPENDS b-mt-static)
ryppl_add_executable(tool-b-STATIC-RELEASE-SINGLE_THREADED main.cpp DEPENDS b-static)
ryppl_add_executable(tool-b-SHARED-DEBUG-MULTI_THREADED main.cpp    DEPENDS b-mt-shared-debug)
ryppl_add_executable(tool-b-SHARED-DEBUG-SINGLE_THREADED main.cpp   DEPENDS b-shared-debug)
ryppl_add_executable(tool-b-STATIC-DEBUG-MULTI_THREADED main.cpp    DEPENDS b-mt-static-debug)
ryppl_add_executable(tool-b-STATIC-DEBUG-SINGLE_THREADED main.cpp   DEPENDS b-static-debug)

foreach(shared_or_static SHARED STATIC)
  foreach(debug_or_release DEBUG RELEASE)
    foreach(single_or_multi SINGLE_THREADED MULTI_THREADED)
  
      set(testname ${shared_or_static}-${debug_or_release}-${single_or_multi})
      add_test(tool-b-${testname} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/tool-b-${testname})
      set_tests_properties(tool-b-${testname}
	PROPERTIES
	PASS_REGULAR_EXPRESSION "${testname}")

    endforeach() 
  endforeach() 
endforeach()


