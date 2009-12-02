..
.. Copyright (C) 2009 Troy Straszheim <troy@resophonic.com>
..
.. Distributed under the Boost Software License, Version 1.0. 
.. See accompanying file LICENSE_1_0.txt or copy at 
..   http://www.boost.org/LICENSE_1_0.txt 
..

Ryppl |release|
===============

.. rubric:: FIXME These docs still talk about boost.cmake

`Ryppl <www.ryppl.org>`_ is an effort to standardize build, test,
documentation and distribution practices for large C++ projects.  The
effort as Boost.CMake at `BoostCon '07 <http://www.rypplcon.com>`_; by
the end of which it was possible to do a basic build of boost with
cmake.  In 2009, the project moved out to git version control.  Today,
``Ryppl`` builds boost as well as other things.  It is stable, mature,
and supported by the developers, a large base of expert users, and
occasionally by the authors of CMake itself.

.. index:: Mailing List, IRC

**ryppl mailing list**    

  http://groups.google.com/group/ryppl?hl=en

**IRC**             

  ``#ryppl`` on the `freenode network <http://freenode.net>`_

**CMake home page**

  http://www.cmake.org

**Source code**

  Ryppl is distributed *separately* from upstream boost.  Code
  is in a `git <http://git-scm.com>`_ repository at
  http://gitorious.org/ryppl/boost.git.  These documents correspond to
  tag |release|.  See also :ref:`hacking_cmake_with_git`.

Users's guide
=============

.. toctree::
   :maxdepth: 3

   quickstart
   build_configuration
   build_variants
   exported_targets
   install_customization
   faq
   externals/index
   git
   diff

Developer's guide
=================

.. toctree::
   :maxdepth: 3

   individual_libraries
   add_ryppl_library
   add_compiled_library
   testing
   adding_regression_tests
   build_installer
   notes_by_version
   
Reference
=========

.. toctree::
   :maxdepth: 1

   reference/ryppl_library_project
   reference/ryppl_module
   reference/ryppl_add_library
   reference/ryppl_add_executable
   reference/ryppl_python_module
   reference/ryppl_additional_test_dependencies
   reference/ryppl_test_compile
   reference/ryppl_test_compile_fail
   reference/ryppl_test_run
   reference/ryppl_test_run_fail

About this documentation
========================

This documentation was created with `Sphinx
<http://sphinx.pocoo.org>`_.  

The source is in the restructuredtext files in subdirectory
``tools/build/CMake/docs/source/``.  Hack on them (see the
`documentation for Sphinx <http://sphinx.pocoo.org/contents.html>`_).
When you're ready to see the html::

  make html

Once you've written a ton of docs, push them someplace where I can see
them (or use ``git diff`` to send a patch).

Release checklist
-----------------

* Update ``RYPPL_CMAKE_VERSION`` in toplevel ``CMakeLists.txt``
* Update notes by version in ``tools/build/CMake/docs/notes_by_version.rst``
* Reconfig cmake with ``RYPPL_MAINTAINER`` set to ON
* set UPSTREAM_TAG in root ``CMakeLists.txt``
* make make-diff
* Rebuild docs and commit
* Tag commit with ``RYPPL_CMAKE_VERSION``
* ``make do-release``
* push tag
* update wiki

.. index:: alt.ryppl
   single: Anarchists; Lunatics, Terrorists and
   single: Lunatics; Anarchists Terrorists and
   single: Terrorists; Anarchists Lunatics and

.. _alt_ryppl:

Why "alt.ryppl"?
----------------

The 'alt' is a reference to the ``alt.*`` Usenet hierarchy.  Here, as
in Usenet, *alt* stands for `Anarchists, Lunatics and Terrorists
<http://nylon.net/alt/index.htm>`_.  This independent effort explores
and applies alternate techniques/technologies in the areas of build,
version control, testing, packaging, documentation and release
management.  

