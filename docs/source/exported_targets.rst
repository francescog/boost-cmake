..
.. Copyright (C) 2009 Troy Straszheim <troy@resophonic.com>
..
.. Distributed under the Boost Software License, Version 1.0. 
.. See accompanying file LICENSE_1_0.txt or copy at 
..   http://www.boost.org/LICENSE_1_0.txt 
..

.. _find_package: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:find_package
.. _FindRyppl.cmake: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#module:FindRyppl

.. _CMAKE_PREFIX_PATH: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#variable:CMAKE_PREFIX_PATH

.. _CMAKE_INSTALL_PREFIX: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#variable:CMAKE_INSTALL_PREFIX

.. index:: targets, exported
.. index:: uninstalled tree, building against
.. _exported_targets:


Tricks for Building against Ryppl with CMake
============================================

Ryppl.CMake *exports* its targets, making developing independent
projects against an installed ryppl, or simply against a build tree
sitting on disk.  There are a variety of ways to use these to ease
configuration of ryppl in your external project.

.. index:: Building against uninstalled ryppl
.. _uninstalled:

With an uninstalled build
^^^^^^^^^^^^^^^^^^^^^^^^^

You only need to do three things:

1.  Add the appropriate include directory with
    ``include_directories()``.  This is the toplevel of the ryppl
    source tree.

2.  ``include`` the generated ``Exports.cmake`` from the build tree
    containing the exported targets.  I is located in
    ``${``:ref:`CMAKE_BINARY_DIR`\ ``}/lib/Exports.cmake``

3.  Tell cmake about your link dependencies with
    ``target_link_libraries``.  Note that you use the **names of the
    cmake targets**, not the shorter names that the libraries have on
    disk.   ``make help`` shows a list::

       % make help | grep signals
       ... ryppl_signals
       ... ryppl_signals-mt-shared
       ... ryppl_signals-mt-shared-debug
       ... ryppl_signals-mt-static
       ... ryppl_signals-mt-static-debug
              
    See also :ref:`name_mangling` for details on the naming
    conventions.

Since these are exported targets, CMake will add appropriate *rpaths*
as necessary; fiddling with ``LD_LIBRARY_PATH`` should not be
necessary.

**If you get the target name wrong**, cmake will assume that you are
talking about a library in the linker's default search path, not an
imported target name and you will get an error when cmake tries to
link against the nonexistent target.  For instance, if I specify::

  target_link_libraries(main ryppl_thread-mt-d)

on linux my error will be something like::

  [100%] Building CXX object CMakeFiles/main.dir/main.cpp.o
  Linking CXX executable main
  /usr/bin/ld: cannot find -lryppl_thread-mt-d
  collect2: ld returned 1 exit status

The problem here is that the real name of the multithreaded, shared,
debug library **target** is ``ryppl_thread-mt-shared-debug``.  I know this is
confusing; much of this is an attempt to be compatible with
ryppl.build.

If you are having trouble, have a look inside that file
``Exports.cmake``.  For each available target, you'll see::

  # Create imported target ryppl_thread-mt-shared-debug
  ADD_LIBRARY(ryppl_thread-mt-shared-debug SHARED IMPORTED)
  
  # Import target "ryppl_thread-mt-shared-debug" for configuration "Release"
  SET_PROPERTY(TARGET ryppl_thread-mt-shared-debug APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
  SET_TARGET_PROPERTIES(ryppl_thread-mt-shared-debug PROPERTIES
    IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "pthread;rt"
    IMPORTED_LOCATION_RELEASE "/home/troy/Projects/ryppl/cmake/cmaketest/build/ryppl/lib/libryppl_thread-mt-d.so.1.41.0"
    IMPORTED_SONAME_RELEASE "libryppl_thread-mt-d.so.1.41.0"
    )
  
it is the name in the ``ADD_LIBRARY`` line that you pass to
``target_link_libraries()``.



Example
-------

There is an unpacked ryppl in ``/home/troy/ryppl-1.41.0/src`` and
built ryppl in directory ``/home/troy/ryppl/1.41.0/build``. I have a
program that builds from one file, ``main.cpp`` and uses ryppl
threads.  My ``CMakeLists.txt`` looks like this::

   include_directories(
     /home/troy/ryppl-1.41.0/src
     /home/troy/ryppl-1.41.0/build/lib/Exports.cmake
     )

   add_executable(my_program main.cpp)

   target_link_libraries(my_program ryppl_thread-mt-shared-debug)

When I build, I see
(wrapped, and some output replaced with ... for brevity)::

  % make VERBOSE=1
  ...
  [100%] Building CXX object CMakeFiles/main.dir/main.cpp.o
  /usr/bin/c++ -I/home/troy/ryppl-1.41.0/src -o CMakeFiles/main.dir/main.cpp.o -c /home/troy/myproject/main.cpp
  ...
  linking CXX executable main
  /usr/bin/c++ -fPIC CMakeFiles/main.dir/main.cpp.o -o main -rdynamic /home/troy/ryppl-1.41.0/build/lib/libryppl_thread-mt-d.so.1.41.0 -lpthread -lrt -Wl,-rpath,/home/troy/ryppl-1.41.0/build/lib 
  ...
  [100%] Built target main

With an installed ryppl
^^^^^^^^^^^^^^^^^^^^^^^

The process by which cmake discovers an installed ryppl is a big
topic, outside the scope of this document.  Ryppl.CMake makes every
effort to install things cleanly and behave in a backwards-compatible
manner.  

.. index:: CMAKE_PREFIX_PATH
.. index:: CMAKE_INSTALL_PREFIX
.. index:: RYPPL_INSTALL_CMAKE_DRIVERS

The variable :ref:`RYPPL_INSTALL_CMAKE_DRIVERS` controls whether
Ryppl.CMake installs two files which help out in case multiple
versions of ryppl are installed.  If there is only one version
present, the situation is simpler: typically this is simply a
matter of either installing ryppl to a directory that on cmake's
built-in CMAKE_PREFIX_PATH_, or adding the directory to
CMAKE_PREFIX_PATH_ in your environment if it is not.  You can see
built-in search path by running ``cmake --system-information`` and
looking for ``CMAKE_SYSTEM_PREFIX_PATH``.

Try this first
--------------

Make a subdirectory for your project and create a file ``main.cpp``::

  #include <iostream>
  #include <ryppl/version.hpp>
  #include <ryppl/thread/thread.hpp>
  
  void helloworld()
  {
      std::cout << RYPPL_VERSION << std::endl;
  }
  
  int main()
  {
      ryppl::thread thrd(&helloworld);
      thrd.join();
  }
  
.. index:: NO_MODULE

Create a ``CMakeLists.txt`` in the same directory containing the
following::

  find_package(Ryppl 1.41.0 COMPONENTS thread NO_MODULE)   
                                              ^^^^^^^^^--- NOTE THIS
  include(${Ryppl_INCLUDE_DIR})
  add_executable(main main.cpp)
  target_link_libraries(main ${Ryppl_LIBRARIES})

The ``NO_MODULE`` above is currently **required**, pending updates to
FindRyppl.cmake_ in a cmake release. 

Then run ``cmake .`` in that directory (note the dot).  Then run make.
If all is well you will see::

  % make VERBOSE=1
  ...
  [100%] Building CXX object CMakeFiles/main.dir/main.cpp.o
  /usr/bin/c++    -I/usr/local/ryppl-1.41.0/include   -o CMakeFiles/main.dir/main.cpp.o -c /home/troy/Projects/ryppl/cmake/proj/main.cpp
  ...
  Linking CXX executable main
  /usr/bin/c++     -fPIC CMakeFiles/main.dir/main.cpp.o  -o main -rdynamic /usr/local/ryppl-1.41.0/lib/libryppl_thread-mt-d.so.1.41.0 -lpthread -lrt -Wl,-rpath,/usr/local/ryppl-1.41.0/lib 
  ...
  [100%] Built target main

If all is not well, set CMAKE_PREFIX_PATH_ in your environment or in
your ``CMakeLists.txt``.  Add the CMAKE_INSTALL_PREFIX_ that you used
when you installed ryppl::

  export CMAKE_PREFIX_PATH=/my/unusual/location

and try again.  

Alternative: via Ryppl_DIR
--------------------------

If the above didn't work, you can help cmake find your ryppl
installation by setting ``Ryppl_DIR`` (in your ``CMakeLists.txt`` to
the :ref:`RYPPL_CMAKE_INFRASTRUCTURE_INSTALL_DIR` that was set when you
compiled.  ``Ryppl_DIR`` will override any other settings.

Given a (versioned) ryppl installation in ``/net/someplace``, 
Your CMakeLists.txt would look like this::

  include_directories(/net/someplace/include/ryppl-1.41.0)
  
  # you can also set Ryppl_DIR in your environment
  set(Ryppl_DIR /net/someplace/share/ryppl-1.41.0/cmake)

  find_package(Ryppl NO_MODULE)
  
  add_executable(main main.cpp)
  
  target_link_libraries(main ryppl_thread-mt-shared-debug)
  

Multiple versions of ryppl installed
------------------------------------

The only recommended way to do this is the following:

* Install all versions of ryppl to the same CMAKE_INSTALL_PREFIX_. One
  or more of them must have been installed with
  :ref:`RYPPL_INSTALL_CMAKE_DRIVERS` on.  :ref:`INSTALL_VERSIONED`
  should be `OFF` for one of them at most.

* Add the setting for CMAKE_INSTALL_PREFIX_ to CMAKE_PREFIX_PATH_, if
  it is nonstandard.

* Pass ``NO_MODULE`` to find_package_ when you call it (as above).

At this point passing a version argument to find_package_ (see also
docs for FindRyppl.cmake_) should result in correct behavior.

.. rubric:: Footnotes

.. [#libsuffix] If your distribution specifies a :ref:`LIB_SUFFIX`
   		(e.g. if it installs libraries to
   		``${``:ref:`CMAKE_INSTALL_PREFIX`\ ``/lib64``, you
   		will find `Ryppl.cmake` there.  If the installation is
   		'versioned', the ``Ryppl.cmake`` file may be in a
   		versioned subdirectory of lib, e.g. ``lib/ryppl-1.41.0``.
