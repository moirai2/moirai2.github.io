#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)
AC_INIT(Tagdust, 2.33, timolassmann@gmail.com)


AM_INIT_AUTOMAKE([ -Wno-portability ])

CXXFLAGS="$CXXFLAGS"


AC_ARG_ENABLE(debugging,
[AS_HELP_STRING([--enable-debugging],[include debugging code])
AS_HELP_STRING([--enable-debugging=x],[also set diagnostics verbosity level to <x> (1-3)])],
enable_debugging=$enableval, enable_debugging=no)

case $enable_debugging in
yes)  AC_DEFINE(kslDEBUGLEVEL, 0,[No debugging. ]);;
1)  AC_DEFINE(kslDEBUGLEVEL, 1,[Defines debugging level 1.]);;
2)  AC_DEFINE(kslDEBUGLEVEL, 2,[Defines debugging level 2.]);;
3)  AC_DEFINE(kslDEBUGLEVEL, 3,[Defines debugging level 3.]);;
no)  AC_DEFINE(kslDEBUGLEVEL, 0,[No debugging.]);;
*)  AC_MSG_ERROR([Unknown argument to --enable-debugging: $enable_debugging]);;
esac



if test "$enable_debugging" != "no"; then
	AC_DEFINE(DEBUG,1,[Defines debugging .])
	CFLAGS="$CFLAGS -ggdb  -Wall -m64 -std=gnu99    "
else
	CFLAGS="$CFLAGS  -O2 -funroll-loops   -Wall  -std=gnu99 "
	DEBUG=0
fi



AC_CHECK_SIZEOF(long, 4)
AM_CONDITIONAL([GOT_64BIT], [ test $ac_cv_sizeof_long -eq 8 ])




AC_ARG_ENABLE(valgrind-tests,
    [--enable-valgrind-tests run self tests under valgrind],
    opt_valgrind_tests="$enableval", opt_valgrind_tests="no")
    

OPTS="-q --trace-children=yes --error-exitcode=1 --dsymutil=yes --leak-check=yes"
  # Run self-tests under valgrind?
if test "$opt_valgrind_tests" = "yes"; then
	CFLAGS="-DDEBUG -ggdb -pedantic -Wall -m64 -std=gnu99"
	AC_CHECK_PROGS(VALGRIND, valgrind)
	VALGRIND="$VALGRIND $OPTS"
else
	VALGRIND=
fi

AC_MSG_CHECKING([whether self tests are run under valgrind])
AC_MSG_RESULT($opt_valgrind_tests)




#
AC_CHECK_PROGS([PANDOC], [pandoc])
if test -z "$PANDOC";
   then AC_MSG_WARN([Pandoc not found - continuing without automatically generating the documentation.])
else
	TMPVERSION=`$PANDOC --version | head -n 1 | sed  's/pandoc //g' `
	if test "$TMPVERSION" != "$PANDOC_VERSION" ; then
		if test "$TMPVERSION" > "$PANDOC_VERSION" ; then
			PANDOC=
		fi
	fi
fi
AM_CONDITIONAL([HAVE_PANDOC], [test -n "$PANDOC"])

#AM_CONDITIONAL([HAVE_PANDOC], [test -n "$PANDOC"])AM_COND_IF([HAVE_PANDOC], [AC_CONFIG_FILES([reproducibility/doc/Makefile])])


# Checks for programs.
AC_PROG_CC
AM_PROG_CC_C_O

# Checks for libraries.

# Checks for header files.
AC_HEADER_STDC

AC_CHECK_HEADERS([ assert.h ctype.h float.h getopt.h limits.h math.h pthread.h stdio.h stdlib.h string.h sys/stat.h time.h unistd.h xmmintrin.h ])


# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST

# Checks for library functions.
AC_FUNC_MALLOC
AC_FUNC_REALLOC

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([src/Makefile])

AC_CONFIG_FILES([dev/Makefile])
#AC_CONFIG_FILES([doc/Makefile])
AC_CONFIG_FILES([casava_demo/Makefile])
AC_CONFIG_FILES([reproducibility/Makefile])
AC_CONFIG_FILES([reproducibility/builder/Makefile])
AC_CONFIG_FILES([reproducibility/scripts/Makefile])
AC_CONFIG_FILES([reproducibility/doc/Makefile])
AC_CONFIG_FILES([reproducibility/bin/Makefile])

AC_CONFIG_HEADER([src/config.h])
AC_OUTPUT


echo "
     Configuration:
     
     compiler: ${CFLAGS}
     valgrind: ${VALGRIND}
     pandoc: ${PANDOC}
"
if test "$ac_cv_sizeof_long" = 8;then

echo "
     You should be able to reproduce the TagDust2 paper figures on your system.
     
     Simply:

     cd reproducibility/scripts 
     make -f run.mk benchmark
     
     This may take a while...
"

fi

