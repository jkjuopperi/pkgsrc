# $NetBSD: buildlink2.mk,v 1.2 2002/09/27 13:56:33 jlam Exp $

.if !defined(GCC_BUILDLINK2_MK)
GCC_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.prefs.mk"

# If you want to allow EGCS to satisfy the GCC requirement, then set
# GCC_REQD to "2.8.0".
#
GCC_REQD?=			2.95.3
BUILDLINK_DEPENDS.gcc?=		gcc>=${GCC_REQD}
BUILDLINK_PKGSRCDIR.gcc?=	../../lang/gcc

# Packages that use the C++ compiler and subsequently link against the
# shared libstdc++ from the package need a full dependency.
#
.if defined(USE_CXX)
BUILDLINK_DEPMETHOD.gcc+=	full
.else
BUILDLINK_DEPMETHOD.gcc?=	build
.endif

BUILDLINK_PREFIX.gcc=	${LOCALBASE}
.if ${OPSYS} == "SunOS"
_GCC_PREFIX=		${BUILDLINK_PREFIX.gcc}
_GCC_SUBPREFIX=		# empty
.else
_GCC_PREFIX=		${BUILDLINK_PREFIX.gcc}/gcc-2.95.3
_GCC_SUBPREFIX=		gcc-2.95.3/
.endif

.if defined(USE_PKGSRC_GCC)
_NEED_PKGSRC_GCC=	YES
.else
_GCC_VERSION!=		( gcc --version ) 2>/dev/null || ${ECHO} 0
.  if !empty(_GCC_VERSION:Megcs-[0-9]*)
#
# Consider EGCS to be gcc-2.8.1, so it will match 'gcc>=2.8.0'.
#
_GCC_PKG=		gcc-2.8.1
.  else
_GCC_PKG=		gcc-${_GCC_VERSION}
.  endif
_NEED_PKGSRC_GCC!= \
	if ${PKG_ADMIN} pmatch '${BUILDLINK_DEPENDS.gcc}' ${_GCC_PKG}; then \
		gccpath=`${TYPE} gcc | ${AWK} '{ print $$NF }'`;	\
		if [ "$$gccpath" = "${_GCC_PREFIX}/bin/gcc" ]; then \
			${ECHO} "YES";					\
		else							\
			${ECHO} "NO";					\
		fi;							\
	else								\
		echo "YES";						\
	fi
.endif

.if ${_NEED_PKGSRC_GCC} == "YES"
BUILDLINK_PACKAGES+=	gcc
PATH:=		${_GCC_PREFIX}/bin:${PATH}
CC=		${_GCC_PREFIX}/bin/gcc
CPP=		${_GCC_PREFIX}/bin/cpp
CXX=		${_GCC_PREFIX}/bin/g++
F77=		${_GCC_PREFIX}/bin/g77
PKG_FC=		${F77}

BUILDLINK_LDFLAGS.gcc=	-Wl,-R${_GCC_PREFIX}/lib
LDFLAGS+=		${BUILDLINK_LDFLAGS.gcc}
.endif	# _NEED_PKGSRC_GCC == YES

_GCC_ARCHSUBDIR=	lib/gcc-lib/${MACHINE_GNU_PLATFORM}/2.95.3

# These file are from gcc>=2.95.3.
BUILDLINK_FILES.gcc=	${_GCC_SUBPREFIX}include/g++-3/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}include/g++-3/*/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}${_GCC_ARCHSUBDIR}/include/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}${_GCC_ARCHSUBDIR}/include/*/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}${_GCC_ARCHSUBDIR}/include/*/*/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}${_GCC_ARCHSUBDIR}/include/*/*/*/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}${_GCC_ARCHSUBDIR}/lib*.*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}${_GCC_ARCHSUBDIR}/specs
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}${MACHINE_GNU_PLATFORM}/include/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}${MACHINE_GNU_PLATFORM}/include/*/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}lib/libiberty.*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}lib/libstdc++.*

BUILDLINK_TARGETS+=	gcc-buildlink

gcc-buildlink: _BUILDLINK_USE

.endif	# GCC_BUILDLINK2_MK
