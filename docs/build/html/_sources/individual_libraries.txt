..
.. Copyright (C) 2009 Troy Straszheim <troy@resophonic.com>
..
.. Distributed under the Boost Software License, Version 1.0. 
.. See accompanying file LICENSE_1_0.txt or copy at 
..   http://www.boost.org/LICENSE_1_0.txt 
..

Building individual libraries with cmake
========================================

In a configured cmake workspace, ``make help`` will display a list of available targets.  Example::

  % make help 
  The following are some of the valid targets for this Makefile:
  ... all (the default if no target is provided)
  ... clean
  ... depend
  ... edit_cache
  ... install
  ... install/local
  ... install/strip
  ... list_install_components
  ... package
  ... package_source
  ... rebuild_cache
  ... ryppl_date_time
  ... ryppl_date_time-mt-shared
  ... ryppl_date_time-mt-shared-debug
  ... ryppl_date_time-mt-static
  ... ryppl_date_time-mt-static-debug
  ... ryppl_date_time-shared
  ... ryppl_date_time-shared-debug
  ... ryppl_date_time-static
  ... ryppl_date_time-static-debug
  ... ryppl_filesystem
  ... ryppl_filesystem-mt-shared
  ... ryppl_filesystem-mt-shared-debug
  ... ryppl_filesystem-mt-static
  ... ryppl_filesystem-mt-static-debug
  ... ryppl_filesystem-shared
  ... ryppl_filesystem-shared-debug
  ... ryppl_filesystem-static
  ... ryppl_filesystem-static-debug
  [etc]
  

You can build any target by passing it as an argument::


  % make ryppl_signals-static
  [  0%] Building CXX object libs/signals/src/CMakeFiles/ryppl_signals-static.dir/trackable.cpp.o
  [  0%] Building CXX object libs/signals/src/CMakeFiles/ryppl_signals-static.dir/connection.cpp.o
  [100%] Building CXX object libs/signals/src/CMakeFiles/ryppl_signals-static.dir/named_slot_map.cpp.o
  [100%] Building CXX object libs/signals/src/CMakeFiles/ryppl_signals-static.dir/signal_base.cpp.o
  [100%] Building CXX object libs/signals/src/CMakeFiles/ryppl_signals-static.dir/slot.cpp.o
  Linking CXX static library ../../../lib/libryppl_signals-gcc41-1_35.a
  [100%] Built target ryppl_signals-static

Preprocessing
-------------

In build directories corresponding to a source library containing a
``CMakeLists.txt`` containing a :ref:`ryppl_add_library_macro` invocation
(e.g. ``build/libs/signals/src, build/libs/filesystem/src``), more
detailed targets are available::

  % cd libs/signals/src
  % make help
  The following are some of the valid targets for this Makefile:
    [many omitted]
  ... signal_base.o
  ... signal_base.i
  ... signal_base.s
  ... slot.o
  ... slot.i
  ... slot.s
  

making ``slot.i`` will run ``slot.cpp`` through the preprocessor::

  % make slot.i
  Preprocessing CXX source to CMakeFiles/ryppl_signals-mt-shared.dir/slot.cpp.i

If you are always interested in seeing the compiler flags you can
enable ``CMAKE_VERBOSE_MAKEFILES`` via ``ccmake``, or for a one-off
just pass ``VERBOSE=1`` on the command line::

  % make VERBOSE=1 slot.i
  make[1]: Entering directory `/home/troy/Projects/ryppl/branches/CMake/Ryppl_1_35_0-build'
  Preprocessing CXX source to CMakeFiles/ryppl_signals-mt-shared.dir/slot.cpp.i
  cd /home/troy/Projects/ryppl/branches/CMake/Ryppl_1_35_0-build/libs/signals/src && /usr/bin/gcc-4.1  
  -DRYPPL_ALL_NO_LIB=1 -DRYPPL_SIGNALS_NO_LIB=1 -Dryppl_signals_mt_shared_EXPORTS -fPIC 
  -I/home/troy/Projects/ryppl/branches/CMake/Ryppl_1_35_0     -O3 -DNDEBUG -DRYPPL_SIGNALS_DYN_LINK=1   
  -pthread -D_REENTRANT -E /home/troy/Projects/ryppl/branches/CMake/Ryppl_1_35_0/libs/signals/src/slot.cpp > CMakeFiles/ryppl_signals-mt-shared.dir/slot.cpp.i

Tests and examples
------------------

Tests and examples are typically grouped into subdirectories, e.g.::

  libs/
    iostreams/
      test/
      examples/

CMake builds a parallel directory hierarchy in the build directory. If
you are working on, say, the examples for iostreams, you can just
``cd`` into the directory $BUILDDIR/libs/iostreams/examples and type
``make``::

  % cd libs/iostreams/example
  % make
  [  0%] Built target ryppl_iostreams-mt-static
  Scanning dependencies of target iostreams-examples-ryppl_back_inserter_example
  [  0%] Building CXX object libs/iostreams/example/CMakeFiles/iostreams-examples-ryppl_back_inserter_example.dir/ryppl_back_inserter_example.cpp.o
  Linking CXX executable ../../../bin/iostreams-examples-ryppl_back_inserter_example
  [  0%] Built target iostreams-examples-ryppl_back_inserter_example
  Scanning dependencies of target iostreams-examples-container_device_example
  [  0%] Building CXX object libs/iostreams/example/CMakeFiles/iostreams-examples-container_device_example.dir/container_device_example.cpp.o
  Linking CXX executable ../../../bin/iostreams-examples-container_device_example
  [  0%] Built target iostreams-examples-container_device_example
  Scanning dependencies of target iostreams-examples-container_sink_example
  [  0%] Building CXX object libs/iostreams/example/CMakeFiles/iostreams-examples-container_sink_example.dir/container_sink_example.cpp.o

Building individual targets, ignoring prerequisites
---------------------------------------------------

If you find yourself working on a compiler error in a file that takes
a long time to compile, waiting for make to check all of the
prerequisites might become tedious.  You can have make skip the
prerequisite testing (you do this at your own risk), by appending
``/fast`` to the target name.  For instance, bcp depends on the
``system``, ``filesystem`` ``regex`` and ``prg_exec_monitor``
libraries::

  % cd tools/bcp
  % make bcp
  [  0%] Built target ryppl_system-mt-static
  [  0%] Built target ryppl_filesystem-mt-static
  [ 50%] Built target ryppl_regex-mt-static
  [ 75%] Built target ryppl_prg_exec_monitor-mt-static
  [ 75%] Building CXX object tools/bcp/CMakeFiles/bcp.dir/add_path.cpp.o
  
if I make ``bcp/fast``, the dependencies are assumed to be built
already::

  % make bcp/fast
  [ 75%] Building CXX object tools/bcp/CMakeFiles/bcp.dir/add_path.cpp.o
  [ 75%] Building CXX object tools/bcp/CMakeFiles/bcp.dir/bcp_imp.cpp.o
  (etc)



  





