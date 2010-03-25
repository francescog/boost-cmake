#!/usr/bin/python

import sys, os
from os.path import *

if not hasattr(os.path, 'relpath'):
    def relpath(path, reldir):
        """Returns 'path' relative to 'reldir'."""

        # use normpath to ensure path separators are uniform
        path = os.path.normpath(path)

        # find length of reldir as prefix of path (or zero if it isn't)
        prelen = len(os.path.commonprefix((
            os.path.normcase(path),
            # add a separator to get correct prefix length
            # (normpath removes trailing separators)
            os.path.normcase(os.path.normpath(reldir)) + os.sep
            )))
        return path[prelen:]


print "Projects located under     : ", sys.argv[1]
print "Fwding headers generated in: ", sys.argv[2]
print ""

dirs = os.listdir(sys.argv[1])
filtered_dirs = [x for x in dirs if isdir(join(sys.argv[1], x, "include"))]

for projdir in filtered_dirs:
    print "%27s: " % projdir,
    srcdir = join(sys.argv[1], projdir, 'include')
    #print srcdir
    os.chdir(srcdir)
    n = 0
    for (ospath, dirnames, filenames) in os.walk(srcdir):
        #print ospath, dirnames, filenames
        rp = relpath(ospath, srcdir)
        #print "RP:", rp
        fwding_header_dir = join(sys.argv[2], rp)
        if not isdir(fwding_header_dir):
            os.makedirs(fwding_header_dir)
        fwdpath = relpath(ospath, join(sys.argv[2], rp))

        for f in filenames:
            n += 1
            fwdfile = join(sys.argv[2], rp, f)
            #print "fwdfile:", fwdfile
            includefile = join(fwdpath, f)
            #print "...", includefile
            f = open(join(fwding_header_dir, f), 'w')
            f.write('#include "%s"\n' % includefile)
            f.close()
            # print "writing", fwdpath, to,    
        #if not os.isdir(join(sys.argv[2], ospath
    print n
