#	$NetBSD: bsd.pkg.mk,v 1.377 1999/12/23 03:12:44 dmcmahill Exp $
#
# This file is in the public domain.
#
# This file is derived from bsd.port.mk - 940820 Jordan K. Hubbard.
#
# Please see the NetBSD packages(7) manual page for details on the
# that variables used in this make file template.

# Default sequence for "all" is:  fetch checksum extract patch configure build
#
# Please read the comments in the targets section below, you
# should be able to use the pre-* or post-* targets/scripts
# (which are available for every stage except checksum) or
# override the do-* targets to do pretty much anything you want.
#
# NEVER override the "regular" targets unless you want to open
# a major can of worms.

##### Include any preferences, if not already included, and common definitions
.include "../../mk/bsd.prefs.mk"

##### Define __PLATFORM_OK only if the OS matches the pkg's allowed list.
.if defined(ONLY_FOR_PLATFORM) && !empty(ONLY_FOR_PLATFORM)
.for __tmp__ in ${ONLY_FOR_PLATFORM}
.if ${MACHINE_PLATFORM:M${__tmp__}} != ""
__PLATFORM_OK?=
.endif
.endfor
.else
__PLATFORM_OK?=
.endif

.for __tmp__ in ${NOT_FOR_PLATFORM}
.if ${MACHINE_PLATFORM:M${__tmp__}} != ""
.undef __PLATFORM_OK
.endif
.endfor

.if !defined(__PLATFORM_OK)
IGNORE=			"does not work on ${MACHINE_PLATFORM}"
.endif

##### Some overrides of defaults below on a per-OS basis.
.if (${OPSYS} == "NetBSD")
LOCALBASE?=		${DESTDIR}/usr/pkg
.elif (${OPSYS} == "SunOS")
DEF_UMASK?=		022
X11BASE?=		${DESTDIR}/usr/openwin
.elif (${OPSYS} == "OpenBSD")
DEF_UMASK?=		022
NOMANCOMPRESS?=		yes
.elif (${OPSYS} == "Linux")
DEF_UMASK?=		022
NOMANCOMPRESS?=		yes
.endif

DEF_UMASK?=		0022
CLEANDEPENDS?=		NO
DEINSTALLDEPENDS?=	NO	# add -R to pkg_delete
REINSTALL?=		NO	# reinstall upon update
NOCLEAN?=		NO	# don't clean up after update

LOCALBASE?=		${DESTDIR}/usr/local
X11BASE?=		${DESTDIR}/usr/X11R6
CROSSBASE?=		${LOCALBASE}/cross

PKGSRCDIR=		${.CURDIR:C|/[^/]*/[^/]*$||}
DISTDIR?=		${PKGSRCDIR}/distfiles
_DISTDIR?=		${DISTDIR}/${DIST_SUBDIR}
PACKAGES?=		${PKGSRCDIR}/packages
TEMPLATES?=		${PKGSRCDIR}/templates

PATCHDIR?=		${.CURDIR}/patches
SCRIPTDIR?=		${.CURDIR}/scripts
FILESDIR?=		${.CURDIR}/files
PKGDIR?=		${.CURDIR}/pkg

.if defined(USE_MOTIF)
.if defined(USE_LOCALBASE_FOR_X11)
MOTIFBASE?=		${LOCALBASE}
.elif ${OPSYS} == "SunOS"
MOTIFBASE?=		/usr/dt
.else
MOTIFBASE?=		${X11BASE}
.endif
.endif # USE_MOTIF

.if defined(USE_IMAKE) || defined(USE_MOTIF) || defined(USE_X11BASE)
.if defined(USE_LOCALBASE_FOR_X11)
PREFIX=			${LOCALBASE}
BUILD_DEPENDS+=		${X11BASE}/lib/X11/config/xpkgwedge.def:${PKGSRCDIR}/pkgtools/xpkgwedge
.else
PREFIX=			${X11BASE}
.endif
.elif defined(USE_CROSSBASE)
PREFIX=			${CROSSBASE}
NO_MTREE=		yes
.else
PREFIX=			${LOCALBASE}
.endif

.if defined(USE_GMAKE)
BUILD_DEPENDS+=		${GMAKE}:${PKGSRCDIR}/devel/gmake
MAKE_PROGRAM=		${GMAKE}
GMAKE?=			gmake
.else
MAKE_PROGRAM=		${MAKE}
.endif

.if defined(USE_KERBEROS)
RESTRICTED?=		uses Kerberos encryption code
BUILD_DEFS+=		KERBEROS
.endif

.if defined(USE_PERL5)
DEPENDS+=		perl-5.00404:${PKGSRCDIR}/lang/perl5
.endif

.if defined(USE_FORTRAN)
.if !exists(/usr/bin/f77)
PKG_FC?=		f2c-f77
.endif
# it is anticipated that once /usr/bin/f77 is more stable that the following
# default will be changed to f77.  However, in the case where there is no
# /usr/bin/f77, the default will remain as f2c-f77.
PKG_FC?=		f2c-f77
.if  (${PKG_FC} == "f2c-f77")
BUILD_DEPENDS+=       f2c-f77:${PKGSRCDIR}/lang/f2c
.endif
FC=             ${PKG_FC}
F77=            ${PKG_FC}
MAKE_ENV+=	F77="${F77}"
MAKE_ENV+=	FC="${FC}"
.endif

.if defined(INFO_FILES)
USE_GTEXINFO=		yes
.endif

.if defined(USE_GTEXINFO) && !exists(/usr/bin/install-info)
DEPENDS+=		gtexinfo-3.12:${PKGSRCDIR}/devel/gtexinfo
.endif

.if defined(USE_LIBTOOL)
.if ${OPSYS} == "NetBSD" || ${OPSYS} == "SunOS"
LIBTOOL=		${LOCALBASE}/bin/pkglibtool-${OBJECT_FMT}-1.2p2
BUILD_DEPENDS+=		${LIBTOOL}:${PKGSRCDIR}/pkgtools/pkglibtool
.else
LIBTOOL=		${LOCALBASE}/bin/libtool
BUILD_DEPENDS+=		${LIBTOOL}:${PKGSRCDIR}/devel/libtool
.endif
CONFIGURE_ENV+=		LIBTOOL="${LIBTOOL} ${LIBTOOL_FLAGS}"
MAKE_ENV+=		LIBTOOL="${LIBTOOL} ${LIBTOOL_FLAGS}"
.endif

.if defined(USE_XAW)
XAW_TYPE?=		standard
.if ${XAW_TYPE} == "xpm"
DEPENDS+=		Xaw-Xpm-1.1:${PKGSRCDIR}/x11/Xaw-Xpm
.elif ${XAW_TYPE} == "3d"
DEPENDS+=		Xaw3d-1.5:${PKGSRCDIR}/x11/Xaw3d
.endif
.endif

# Don't change these!!!  These names are built into the _TARGET_USE macro,
# there is no way to refer to them cleanly from within the macro AFAIK.
EXTRACT_COOKIE=		${WRKDIR}/.extract_done
CONFIGURE_COOKIE=	${WRKDIR}/.configure_done
INSTALL_COOKIE=		${WRKDIR}/.install_done
BUILD_COOKIE=		${WRKDIR}/.build_done
PATCH_COOKIE=		${WRKDIR}/.patch_done
PACKAGE_COOKIE=		${WRKDIR}/.package_done

# Miscellaneous overridable commands:
SHCOMMENT?=		${ECHO_MSG} >/dev/null '***'
XMKMF?=			xmkmf -a
.if exists(/sbin/md5)
MD5?=			/sbin/md5
.elif exists(/bin/md5)
MD5?=			/bin/md5
.elif exists(/usr/bin/md5)
MD5?=			/usr/bin/md5
.elif exists(${LOCALBASE}/bsd/bin/md5)
MD5?=			${LOCALBASE}/bsd/bin/md5
.else
MD5?=			md5
.endif
MD5_FILE?=		${FILESDIR}/md5
PATCH_SUM_FILE?=	${FILESDIR}/patch-sum

.if defined(USE_MOTIF) || defined(USE_X11BASE) || defined(USE_X11)
LDFLAGS+=		-Wl,-R${MOTIFBASE}/lib -L${MOTIFBASE}/lib -Wl,-R${X11BASE}/lib -L${X11BASE}/lib
.endif
LDFLAGS+=		-Wl,-R${LOCALBASE}/lib -L${LOCALBASE}/lib
MAKE_ENV+=		LDFLAGS="${LDFLAGS}"
CONFIGURE_ENV+=		LDFLAGS="${LDFLAGS}"

MAKE_FLAGS?=
MAKEFILE?=		Makefile
MAKE_ENV+=		PATH=${PATH}:${LOCALBASE}/bin:${X11BASE}/bin PREFIX=${PREFIX} LOCALBASE=${LOCALBASE} X11BASE=${X11BASE} MOTIFLIB="${MOTIFLIB}" CFLAGS="${CFLAGS}"

.if exists(/usr/bin/fetch)
FETCH_CMD?=		/usr/bin/fetch
.elif exists(${LOCALBASE}/bsd/bin/ftp)
FETCH_CMD?=		${LOCALBASE}/bsd/bin/ftp
.else
FETCH_CMD?=		/usr/bin/ftp
.endif

# By default, distfiles have no restrictions placed on them
MIRROR_DISTFILE?=	yes

TOUCH_FLAGS?=		-f

PATCH_STRIP?=		-p0
PATCH_DIST_STRIP?=	-p0
.if defined(PATCH_DEBUG) || defined(PKG_VERBOSE)
PATCH_DEBUG_TMP=	yes
PATCH_ARGS?=		-d ${WRKSRC} -E ${PATCH_STRIP}
PATCH_DIST_ARGS?=	-d ${WRKSRC} -E ${PATCH_DIST_STRIP}
.else
PATCH_DEBUG_TMP=	no
PATCH_ARGS?=		-d ${WRKSRC} --forward --quiet -E ${PATCH_STRIP}
PATCH_DIST_ARGS?=	-d ${WRKSRC} --forward --quiet -E ${PATCH_DIST_STRIP}
.endif
.if defined(BATCH)
PATCH_ARGS+=		--batch
PATCH_DIST_ARGS+=	--batch
.endif

.if defined(PATCH_CHECK_ONLY)
PATCH_ARGS+=		-C
PATCH_DIST_ARGS+=	-C
.endif

# New decompress and extract definitions

# If the archive has a .bz2 suffix, use bzip2 to extract information
# If EXTRACT_USING_PAX is defined, use pax in preference to (GNU) tar,
# and append 2 tar blocks of zero bytes on the end, in case the archive
# was written with a buggy version of GNU tar.

EXTRACT_SUFX?=		.tar.gz

.if ${EXTRACT_SUFX} == ".tar.bz2"
.if exists(/usr/bin/bzcat)
BZCAT=			/usr/bin/bzcat
.else
BZCAT=			${LOCALBASE}/bin/bzcat
BUILD_DEPENDS+=		${BZCAT}:${PKGSRCDIR}/archivers/bzip2
.endif # !exists bzcat
DECOMPRESS_CMD?=	${BZCAT}
.else
DECOMPRESS_CMD?=	${GZCAT}
.endif

# If this is empty, then everything gets extracted.
EXTRACT_ELEMENTS?=	

.if defined(EXTRACT_USING_PAX)
EXTRACT_CMD?=		(${DECOMPRESS_CMD} ${DOWNLOADED_DISTFILE} ; dd if=/dev/zero bs=10k count=2) | ${PAX} -r ${EXTRACT_ELEMENTS}
.else
EXTRACT_CMD?=		${DECOMPRESS_CMD} ${DOWNLOADED_DISTFILE} | ${GTAR} -xf - ${EXTRACT_ELEMENTS}
.endif

# Figure out where the local mtree file is
.if !defined(MTREE_FILE)
.if defined(USE_IMAKE) || defined(USE_MOTIF) || defined(USE_X11BASE)
MTREE_FILE=	${PKGSRCDIR}/mk/${OPSYS}.x11.dist
.else
MTREE_FILE=	${PKGSRCDIR}/mk/${OPSYS}.pkg.dist
.endif
.endif # ! MTREE_FILE

MTREE_ARGS?=	-U -f ${MTREE_FILE} -d -e -p

# Debugging levels for this file, dependent on PKG_DEBUG_LEVEL definition
# 0 == normal, default, quiet operation
# 1 == all shell commands echoed before invocation
# 2 == shell "set -x" operation
PKG_DEBUG_LEVEL?=	0
_PKG_SILENT=		@
_PKG_DEBUG=		

.if ${PKG_DEBUG_LEVEL} > 0
_PKG_SILENT=	
.endif

.if ${PKG_DEBUG_LEVEL} > 1
_PKG_DEBUG=		set -x;
.endif

# If WRKOBJDIR is set, use that tree to build
.ifdef WRKOBJDIR
__canonical_PKGSRCDIR!=	cd ${PKGSRCDIR} && pwd -P
__canonical_CURDIR!=	cd ${.CURDIR} && pwd -P
PKGSRC_SUBDIR=		${__canonical_CURDIR:S,${__canonical_PKGSRCDIR}/,,}
BUILD_ROOT=     	${WRKOBJDIR}
BUILD_DIR?=		${WRKOBJDIR}/${PKGSRC_SUBDIR}
.else
BUILD_ROOT=     	${PKGSRCDIR}
BUILD_DIR?=		${.CURDIR}
.endif # WRKOBJDIR

# If OBJMACHINE is set, use ${MACHINE_ARCH} in the working directory name
.ifdef OBJMACHINE
WRKDIR_BASENAME?=	work.${MACHINE_ARCH}
.else
WRKDIR_BASENAME?=	work
.endif

.ifdef NO_WRKDIR
WRKDIR?=		${BUILD_DIR}
.else
WRKDIR?=		${BUILD_DIR}/${WRKDIR_BASENAME}
.endif # !NO_WRKDIR

.if defined(NO_WRKSUBDIR)
WRKSRC?=		${WRKDIR}
.else # NO_WRKSUBDIR
WRKSRC?=		${WRKDIR}/${DISTNAME}
.endif # NO_WRKSUBDIR

# A few aliases for *-install targets
INSTALL_PROGRAM?= \
	${INSTALL} ${COPY} ${STRIPFLAG} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE}
INSTALL_SCRIPT?= \
	${INSTALL} ${COPY} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE}
INSTALL_DATA?= \
	${INSTALL} ${COPY} -o ${SHAREOWN} -g ${SHAREGRP} -m ${SHAREMODE}
INSTALL_MAN?= \
	${INSTALL} ${COPY} -o ${MANOWN} -g ${MANGRP} -m ${MANMODE}
INSTALL_PROGRAM_DIR?= \
	${INSTALL} -d -o ${BINOWN} -g ${BINGRP} -m ${BINMODE}
INSTALL_SCRIPT_DIR?= \
	${INSTALL_PROGRAM_DIR}
INSTALL_DATA_DIR?= \
	${INSTALL} -d -o ${SHAREOWN} -g ${SHAREGRP} -m ${BINMODE}
INSTALL_MAN_DIR?= \
	${INSTALL} -d -o ${MANOWN} -g ${MANGRP} -m ${BINMODE}

INSTALL_MACROS=	BSD_INSTALL_PROGRAM="${INSTALL_PROGRAM}" \
			BSD_INSTALL_SCRIPT="${INSTALL_SCRIPT}" \
			BSD_INSTALL_DATA="${INSTALL_DATA}" \
			BSD_INSTALL_MAN="${INSTALL_MAN}" \
			BSD_INSTALL_PROGRAM_DIR="${INSTALL_PROGRAM_DIR}" \
			BSD_INSTALL_SCRIPT_DIR="${INSTALL_SCRIPT_DIR}" \
			BSD_INSTALL_DATA_DIR="${INSTALL_DATA_DIR}" \
			BSD_INSTALL_MAN_DIR="${INSTALL_MAN_DIR}"
MAKE_ENV+=	${INSTALL_MACROS}
SCRIPTS_ENV+=	${INSTALL_MACROS}

# The user can override the NO_PACKAGE by specifying this from
# the make command line
.if defined(FORCE_PACKAGE)
.undef NO_PACKAGE
.endif

COMMENT?=		${PKGDIR}/COMMENT
DESCR_SRC?=		${PKGDIR}/DESCR
DESCR=			${WRKDIR}/.DESCR
PLIST=			${WRKDIR}/.PLIST
DLIST=			${WRKDIR}/.DLIST
DDIR=			${WRKDIR}/.DDIR

# Set PLIST_SUBST to substitute "${variable}" to "value" in PLIST
PLIST_SUBST+=	OPSYS=${OPSYS}					\
		OS_VERSION=${OS_VERSION}			\
		MACHINE_ARCH=${MACHINE_ARCH}			\
		MACHINE_GNU_ARCH=${MACHINE_GNU_ARCH}		\
		MACHINE_GNU_PLATFORM=${MACHINE_GNU_PLATFORM}	\
		LOWER_VENDOR=${LOWER_VENDOR}			\
		LOWER_OPSYS=${LOWER_OPSYS}			\
		PKGNAME=${PKGNAME}

# Set INSTALL_FILE to be the name of any INSTALL file
.if !defined(INSTALL_FILE) && exists(${PKGDIR}/INSTALL)
INSTALL_FILE=		${PKGDIR}/INSTALL
.endif

# Set DEINSTALL_FILE to be the name of any DEINSTALL file
.if !defined(DEINSTALL_FILE) && exists(${PKGDIR}/DEINSTALL)
DEINSTALL_FILE=		${PKGDIR}/DEINSTALL
.endif

# Set REQ_FILE to be the name of any REQ file
.if !defined(REQ_FILE) && exists(${PKGDIR}/REQ)
REQ_FILE=		${PKGDIR}/REQ
.endif

# Set MESSAGE_FILE to be the name of any MESSAGE file
.if !defined(MESSAGE_FILE) && exists(${PKGDIR}/MESSAGE)
MESSAGE_FILE=		${PKGDIR}/MESSAGE
.endif

# Latest version of pkgtools required for this file.
# XXX See below for a few test on PKGTOOLS_REQD > 19990909
#     that can be removed when this is bumped. (size code - HF)
PKGTOOLS_REQD=		19990909

# Check that we're using up-to-date pkg_* tools with this file.
uptodate-pkgtools:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	pkgtools_version=`${MAKE} show-pkgtools-version`;		\
	if [ $$pkgtools_version -lt ${PKGTOOLS_REQD} ]; then		\
		case ${PKGNAME} in					\
		pkg_install-*)						\
			;;						\
		*)							\
			${ECHO} "Your package tools need to be updated to `${ECHO} ${PKGTOOLS_REQD} | ${SED} -e 's|\(....\)\(..\)\(..\)|\1/\2/\3|'` versions."; \
			${ECHO} "The installed package tools were last updated on `${ECHO} $$pkgtools_version | ${SED} -e 's|\(....\)\(..\)\(..\)|\1/\2/\3|'`."; \
			${ECHO} "Please make and install the pkgsrc/pkgtools/pkg_install package."; \
			${FALSE} ;;					\
		esac							\
	fi

# Files to create for versioning and build information
BUILD_VERSION_FILE=	${WRKDIR}/BuildVersion
BUILD_INFO_FILE=	${WRKDIR}/BuildInfo

# Files containing size of pkg w/o and w/ all required pkgs
SIZE_PKG_FILE=		${WRKDIR}/SizePkg
SIZE_ALL_FILE=		${WRKDIR}/SizeAll

.ifndef PKG_ARGS
PKG_ARGS=		-v -c ${COMMENT} -d ${DESCR} -f ${PLIST} -l
PKG_ARGS+=		-b ${BUILD_VERSION_FILE} -B ${BUILD_INFO_FILE}
.if ${PKGTOOLS_REQD} > 19990909
# Size storing options, only available since 19991123 or so
# I don't want to force people using this.
# This .if block should be removed next time PKGTOOLS_REQD is bumped.
PKG_ARGS+=		-s ${SIZE_PKG_FILE} -S ${SIZE_ALL_FILE}
.endif 	# ${PKGTOOLS_REQD) > 19990909
PKG_ARGS+=		-p ${PREFIX} -P "`${MAKE} package-depends PACKAGE_DEPENDS_WITH_PATTERNS=false|sort -u`"
.ifdef CONFLICTS
PKG_ARGS+=		-C "${CONFLICTS}"
.endif
.ifdef INSTALL_FILE
PKG_ARGS+=		-i ${INSTALL_FILE}
.endif
.ifdef DEINSTALL_FILE
PKG_ARGS+=		-k ${DEINSTALL_FILE}
.endif
.ifdef REQ_FILE
PKG_ARGS+=		-r ${REQ_FILE}
.endif
.ifdef MESSAGE_FILE
PKG_ARGS+=		-D ${MESSAGE_FILE}
.endif
.ifndef NO_MTREE
PKG_ARGS+=		-m ${MTREE_FILE}
.endif
.endif # !PKG_ARGS
PKG_SUFX?=		.tgz
# where pkg_add records its dirty deeds.
PKG_DBDIR?=		/var/db/pkg

# shared/dynamic motif libs
MOTIFLIB?=	-L${MOTIFBASE}/lib -L${X11BASE}/lib -L${LOCALBASE}/lib -Wl,-R${MOTIFBASE}/lib -Wl,-R${X11BASE}/lib -Wl,-R${LOCALBASE}/lib -lXm

.if (${OPSYS} == "SunOS")
AWK?=		/usr/bin/nawk
BASENAME?=	/usr/bin/basename
CAT?=		/usr/bin/cat
CHMOD?=		/usr/bin/chmod
CHOWN?=		/usr/bin/chown
CHGRP?=		/usr/bin/chgrp
CP?=		/usr/bin/cp
CUT?=		/usr/bin/cut
ECHO?=		/usr/ucb/echo
EGREP?=		/usr/xpg4/bin/egrep
FALSE?=		/usr/bin/false
FILE?=		/usr/bin/file
GREP?=		/usr/bin/grep
GTAR?=		${LOCALBASE}/bin/gtar
GUNZIP_CMD?=	${LOCALBASE}/bin/gunzip -f
GZCAT?=		${LOCALBASE}/bin/zcat
GZIP?=		-9
GZIP_CMD?=	${LOCALBASE}/bin/gzip -nf ${GZIP}
ID?=		/usr/xpg4/bin/id
IDENT?=		${LOCALBASE}/bin/ident
LDCONFIG?=	/usr/bin/true
LN?=		/usr/bin/ln
MKDIR?=		/usr/bin/mkdir -p
MTREE?=		${LOCALBASE}/bsd/bin/mtree
MV?=		/usr/bin/mv
PATCH?=		${LOCALBASE}/bin/patch -b
PAX?=		/bin/pax
PKG_ADD?=	${LOCALBASE}/bsd/bin/pkg_add
PKG_CREATE?=	${LOCALBASE}/bsd/bin/pkg_create
PKG_DELETE?=	${LOCALBASE}/bsd/bin/pkg_delete
PKG_INFO?=	${LOCALBASE}/bsd/bin/pkg_info
RM?=		/usr/bin/rm
RMDIR?=		/usr/bin/rmdir
SED?=		/usr/bin/sed
SETENV?=	/usr/bin/env
SH?=		/bin/ksh
SU?=		/usr/bin/su
TAIL?=		/usr/xpg4/bin/tail
TEST?=		/usr/bin/test
TOUCH?=		/usr/bin/touch
TR?=		/usr/bin/tr
TRUE?=		/usr/bin/true
TYPE?=		/usr/bin/type
.elif (${OPSYS} == "Linux")
AWK?=		/usr/bin/awk
BASENAME?=	/bin/basename
CAT?=		/bin/cat
CHMOD?=		/bin/chmod
CHOWN?=		/usr/sbin/chown
CHGRP?=		/usr/bin/chgrp
CP?=		/bin/cp
CUT?=		/bin/cut
ECHO?=		/bin/echo
EGREP?=		/bin/egrep
FALSE?=		/bin/false
FILE?=		/usr/bin/file
GREP?=		/bin/grep
GTAR?=		/bin/tar
GUNZIP_CMD?=	/usr/bin/gunzip -f
GZCAT?=		/bin/zcat
GZIP?=		-9
GZIP_CMD?=	/usr/bin/gzip -nf ${GZIP}
ID?=		/usr/bin/id
IDENT?=		/usr/bin/ident
LDCONFIG?=	/sbin/ldconfig
LN?=		/bin/ln
MKDIR?=		/bin/mkdir -p
MTREE?=		${LOCALBASE}/bsd/bin/mtree
MV?=		/bin/mv
PATCH?=		/usr/bin/patch
PAX?=		/usr/local/bsd/bin/pax
PKG_ADD?=	${LOCALBASE}/bsd/bin/pkg_add
PKG_CREATE?=	${LOCALBASE}/bsd/bin/pkg_create
PKG_DELETE?=	${LOCALBASE}/bsd/bin/pkg_delete
PKG_INFO?=	${LOCALBASE}/bsd/bin/pkg_info
RM?=		/bin/rm
RMDIR?=		/bin/rmdir
SED?=		/bin/sed
SETENV?=	/usr/bin/env
SH?=		/bin/sh
SU?=		/bin/su
TAIL?=		/usr/bin/tail
TEST?=		/usr/bin/test
TOUCH?=		/bin/touch
TR?=		/usr/bin/tr
TRUE?=		/bin/true
TYPE?=		type
.else
AWK?=		/usr/bin/awk
BASENAME?=	/usr/bin/basename
CAT?=		/bin/cat
CHMOD?=		/bin/chmod
CHOWN?=		/usr/sbin/chown
CHGRP?=		/usr/bin/chgrp
CP?=		/bin/cp
CUT?=		/usr/bin/cut
ECHO?=		/bin/echo
EGREP?=		/usr/bin/egrep
FALSE?=		/usr/bin/false
FILE?=		/usr/bin/file
GREP?=		/usr/bin/grep
GTAR?=		/usr/bin/tar
GUNZIP_CMD?=	/usr/bin/gunzip -f
GZCAT?=		/usr/bin/gzcat
GZIP?=		-9
GZIP_CMD?=	/usr/bin/gzip -nf ${GZIP}
ID?=		/usr/bin/id
IDENT?=		/usr/bin/ident
LDCONFIG?=	/sbin/ldconfig
LN?=		/bin/ln
MKDIR?=		/bin/mkdir -p
MTREE?=		/usr/sbin/mtree
MV?=		/bin/mv
PATCH?=		/usr/bin/patch
PAX?=		/bin/pax
PKG_ADD?=	/usr/sbin/pkg_add
PKG_CREATE?=	/usr/sbin/pkg_create
PKG_DELETE?=	/usr/sbin/pkg_delete
PKG_INFO?=	/usr/sbin/pkg_info
RM?=		/bin/rm
RMDIR?=		/bin/rmdir
SED?=		/usr/bin/sed
SETENV?=	/usr/bin/env
SH?=		/bin/sh
SU?=		/usr/bin/su
TAIL?=		/usr/bin/tail
TEST?=		/bin/test
TOUCH?=		/usr/bin/touch
TR?=		/usr/bin/tr
TRUE?=		/usr/bin/true
TYPE?=		type
.endif # !SunOS

# Used to print all the '===>' style prompts - override this to turn them off.
ECHO_MSG?=		${ECHO}

# How to do nothing.  Override if you, for some strange reason, would rather
# do something.
DO_NADA?=		${TRUE}

ALL_TARGET?=		all
INSTALL_TARGET?=	install

.if defined(USE_IMAKE) && !defined(NO_INSTALL_MANPAGES)
INSTALL_TARGET+=	install.man
.endif

# If this host is behind a filtering firewall, use passive ftp(1)
.if defined(PASSIVE_FETCH)
FETCH_BEFORE_ARGS += -p
.endif

# Check if we got a real Motif, Lesstif or no Motif at all.
.if defined(USE_MOTIF)
.if exists(${MOTIFBASE}/include/Xm/Xm.h)
IS_LESSTIF!=	${EGREP} -c LESSTIF ${MOTIFBASE}/include/Xm/Xm.h || ${TRUE}
.if (${IS_LESSTIF} != "0")
DEPENDS+=	lesstif-*:${PKGSRCDIR}/x11/lesstif
.endif
.else
DEPENDS+=	lesstif-*:${PKGSRCDIR}/x11/lesstif
.endif
.endif

# Popular master sites
MASTER_SITE_XCONTRIB+=	\
	ftp://crl.dec.com/pub/X11/contrib/ \
	ftp://ftp.sunsite.auc.dk/pub/X/X.org/contrib/ \
	ftp://ftp.uni-paderborn.de/pub/X11/contrib/ \
	ftp://ftp.x.org/contrib/

MASTER_SITE_GNU+=	\
	ftp://ftp.gnu.org/pub/gnu/ \
	ftp://ftp.wustl.edu/systems/gnu/ \
	ftp://ftp.gwdg.de/pub/gnu/

MASTER_SITE_PERL_CPAN+=	\
	ftp://ftp.digital.com/pub/plan/perl/CPAN/modules/by-module/ \
	ftp://ftp.cdrom.com/pub/perl/CPAN/modules/by-module/

MASTER_SITE_TEX_CTAN+=  \
	ftp://ftp.cdrom.com/pub/tex/ctan/  \
	ftp://ftp.wustl.edu/packages/TeX/  \
	ftp://ftp.funet.fi/pub/TeX/CTAN/  \
	ftp://ftp.tex.ac.uk/public/ctan/tex-archive/  \
	ftp://ftp.dante.de/tex-archive/

MASTER_SITE_SUNSITE+=	\
	ftp://sunsite.unc.edu/pub/Linux/ \
	ftp://ftp.infomagic.com/pub/mirrors/linux/sunsite/

MASTER_SITE_GNOME+=	\
	ftp://ftp.gnome.org/pub/GNOME/ \
	ftp://ftp.sunet.se/pub/X11/GNOME/ \
	ftp://ftp.informatik.uni-bonn.de/pub/os/unix/gnome/ \
	ftp://ftp.tuwien.ac.at/hci/gnome.org/GNOME/

# Empty declaration to avoid "variable MASTER_SITES recursive" error
MASTER_SITES?=
PATCH_SITES?=

# The primary backup site.
MASTER_SITE_BACKUP?=	\
	ftp://ftp.netbsd.org/pub/NetBSD/packages/distfiles/ \
	ftp://ftp.freebsd.org/pub/FreeBSD/distfiles/
.if defined(DIST_SUBDIR)
MASTER_SITE_BACKUP:=	${MASTER_SITE_BACKUP:=${DIST_SUBDIR}/}
.endif

# Where to put distfiles that don't have any other master site
.if defined(DIST_SUBDIR)
MASTER_SITE_LOCAL?= \
	${MASTER_SITE_BACKUP:S,${DIST_SUBDIR},LOCAL_PORTS,}
.else	# DIST_SUBDIR
MASTER_SITE_LOCAL?= \
	${MASTER_SITE_BACKUP:=LOCAL_PORTS/}
.endif	# DIST_SUBDIR

# I guess we're in the master distribution business! :)  As we gain mirror
# sites for distfiles, add them to this list.
.if !defined(MASTER_SITE_OVERRIDE)
MASTER_SITES+=	${MASTER_SITE_BACKUP}
PATCH_SITES+=	${MASTER_SITE_BACKUP}
.else
MASTER_SITES:=	${MASTER_SITE_OVERRIDE} ${MASTER_SITES}
PATCH_SITES:=	${MASTER_SITE_OVERRIDE} ${PATCH_SITES}
.endif

# Derived names so that they're easily overridable.
DISTFILES?=		${DISTNAME}${EXTRACT_SUFX}
PKGNAME?=		${DISTNAME}

MAINTAINER?=		packages@netbsd.org

ALLFILES?=	${DISTFILES} ${PATCHFILES}
CKSUMFILES?=	${ALLFILES}
.for __tmp__ in ${IGNOREFILES}
CKSUMFILES:=	${CKSUMFILES:N${__tmp__}}
.endfor

# List of all files, with ${DIST_SUBDIR} in front.  Used for fetch and checksum.
.if defined(DIST_SUBDIR)
_CKSUMFILES?=	${CKSUMFILES:S/^/${DIST_SUBDIR}\//}
_DISTFILES?=	${DISTFILES:S/^/${DIST_SUBDIR}\//}
_IGNOREFILES?=	${IGNOREFILES:S/^/${DIST_SUBDIR}\//}
_PATCHFILES?=	${PATCHFILES:S/^/${DIST_SUBDIR}\//}
.else
_CKSUMFILES?=	${CKSUMFILES}
_DISTFILES?=	${DISTFILES}
_IGNOREFILES?=	${IGNOREFILES}
_PATCHFILES?=	${PATCHFILES}
.endif

# This is what is actually going to be extracted, and is overridable
#  by user.
EXTRACT_ONLY?=	${DISTFILES}

.if !defined(CATEGORIES) || !defined(DISTNAME)
.BEGIN:
	@${ECHO_MSG} "CATEGORIES and DISTNAME are mandatory."
	@${FALSE}
.endif

.if defined(LIB_DEPENDS)
.BEGIN:
	@${ECHO_MSG} "LIB_DEPENDS is deprecated and must be replaced with DEPENDS."
	@${FALSE}
.endif

.if defined(MASTER_SITE_SUBDIR)
.BEGIN:
	@${ECHO_MSG} 'MASTER_SITE_SUBDIR is deprecated and must be replaced with MASTER_SITES.'
	@${FALSE}
.endif

.if defined(PATCH_SITE_SUBDIR)
.BEGIN:
	@${ECHO_MSG} 'PATCH_SITE_SUBDIR is deprecated and must be replaced with PATCH_SITES.'
	@${FALSE}
.endif

.if defined(ONLY_FOR_ARCHS) || defined(NOT_FOR_ARCHS) \
	|| defined(ONLY_FOR_OPSYS) || defined(NOT_FOR_OPSYS)
.BEGIN:
	@${ECHO_MSG} 'ONLY/NOT_FOR_ARCHS/OPSYS are deprecated and must be replaced with ONLY/NOT_FOR_PLATFORM.'
	@${FALSE}
.endif

# Note this has to start with a capital letter (or more accurately, it
#  shouldn't match "[a-z]*"), see the target "delete-package-links" below.
PKGREPOSITORYSUBDIR?=	All
PKGREPOSITORY?=		${PACKAGES}/${PKGREPOSITORYSUBDIR}
PKGFILE?=		${PKGREPOSITORY}/${PKGNAME}${PKG_SUFX}

CONFIGURE_SCRIPT?=	configure
CONFIGURE_ENV+=		PATH=${PATH}:${LOCALBASE}/bin:${X11BASE}/bin

.if defined(GNU_CONFIGURE)
CONFIGURE_ARGS+=	--host=${MACHINE_GNU_PLATFORM} --prefix=${PREFIX}
HAS_CONFIGURE=		yes
.if defined(USE_LOCALBASE_FOR_X11)
CONFIGURE_ARGS+=        --x-libraries=${X11BASE}/lib --x-includes=${X11BASE}/include
.endif
.endif

# Passed to most of script invocations
SCRIPTS_ENV+= CURDIR=${.CURDIR} DISTDIR=${DISTDIR} \
	PATH=${PATH}:${LOCALBASE}/bin:${X11BASE}/bin \
	WRKDIR=${WRKDIR} WRKSRC=${WRKSRC} PATCHDIR=${PATCHDIR} \
	SCRIPTDIR=${SCRIPTDIR} FILESDIR=${FILESDIR} \
	PKGSRCDIR=${PKGSRCDIR} DEPENDS="${DEPENDS}" \
	PREFIX=${PREFIX} LOCALBASE=${LOCALBASE} X11BASE=${X11BASE}

.if defined(BATCH)
SCRIPTS_ENV+=	BATCH=yes
.endif

.MAIN: all

# Use aliases, so that all versions of English are acceptable
.if defined(LICENCE) && !defined(LICENSE)
LICENSE=	${LICENCE}
.endif

.if defined(ACCEPTABLE_LICENCES) && !defined(ACCEPTABLE_LICENSES)
ACCEPTABLE_LICENSES=	${ACCEPTABLE_LICENCES}
.endif

################################################################
# Many ways to disable a package.
#
# If we're in BATCH mode and the package is interactive, or we're
# in interactive mode and the package is non-interactive, skip all
# the important targets.  The reason we have two modes is that
# one might want to leave a build in BATCH mode running
# overnight, then come back in the morning and do _only_ the
# interactive ones that required your intervention.
#
# Don't attempt to build packages that require Motif if you don't
# have Motif.
#
# Ignore packages that can't be resold if building for a CDROM.
#
# Don't build a package if it's restricted and we don't want to get
# into that.
#
# Don't build a package if it's broken.
################################################################

.if !defined(NO_IGNORE)
.if (defined(IS_INTERACTIVE) && defined(BATCH))
IGNORE=	"is an interactive package"
.elif (!defined(IS_INTERACTIVE) && defined(INTERACTIVE))
IGNORE=	"is not an interactive package"
.elif (defined(NO_CDROM) && defined(FOR_CDROM))
IGNORE=	"may not be placed on a CDROM: ${NO_CDROM}"
.elif (defined(RESTRICTED) && defined(NO_RESTRICTED))
IGNORE=	"is restricted: ${RESTRICTED}"
.elif ((defined(USE_IMAKE) || defined(USE_MOTIF) || \
	defined(USE_X11BASE) || defined(USE_X11)) && \
       !exists(${X11BASE}))
IGNORE=	"uses X11, but ${X11BASE} not found"
.elif defined(BROKEN)
IGNORE=	"is marked as broken: ${BROKEN}"
.elif defined(LICENSE)
.ifdef ACCEPTABLE_LICENSES
.for _lic in ${ACCEPTABLE_LICENSES}
.if ${LICENSE} == "${_lic}"
_ACCEPTABLE=	yes
.endif
.endfor	# _lic
.endif	# ACCEPTABLE_LICENSES
.ifndef _ACCEPTABLE
IGNORE=	"Unacceptable license: ${LICENSE}." \
	"	To build this package, add this line to your /etc/mk.conf:" \
	"	ACCEPTABLE_LICENSES+=${LICENSE}"
.endif
.endif

.if defined(IGNORE)
.if defined(IGNORE_SILENT)
IGNORECMD?=	${DO_NADA}
.endif
IGNORECMD?=	${ECHO} -n "===>  ${PKGNAME} " ; \
		for str in ${IGNORE} ; \
		do \
			${ECHO} "$$str" ; \
		done
.if defined(IGNORE_FAIL)
IGNORECMD+=	&& ${FALSE}
.endif
fetch checksum extract patch configure all build install deinstall package \
depends check-depends:
	@${IGNORECMD}
.endif # IGNORE
.endif # !NO_IGNORE

# Add these defs to the ones dumped into +BUILD_DEFS
BUILD_DEFS+=	OPSYS OS_VERSION MACHINE_ARCH MACHINE_GNU_ARCH
BUILD_DEFS+=	CPPFLAGS CFLAGS LDFLAGS LICENSE
BUILD_DEFS+=	CONFIGURE_ENV CONFIGURE_ARGS
BUILD_DEFS+=	OBJECT_FMT

.if !target(all)
all: build
.endif

.if !defined(DEPENDS_TARGET)
.if make(reinstall)
DEPENDS_TARGET=	reinstall
.else
DEPENDS_TARGET=	install
.endif
.endif

################################################################
# The following are used to create easy dummy targets for
# disabling some bit of default target behavior you don't want.
# They still check to see if the target exists, and if so don't
# do anything, since you might want to set this globally for a
# group of packages in a Makefile.inc, but still be able to
# override from an individual Makefile.
################################################################

# Disable checksum
.if (defined(NO_CHECKSUM) && !target(checksum)) || exists(${EXTRACT_COOKIE})
checksum: fetch
	@${DO_NADA}
.endif

# Disable extract
.if defined(NO_EXTRACT) && !target(extract)
extract: checksum
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${EXTRACT_COOKIE}
checksum: fetch
	@${DO_NADA}
makesum:
	@${DO_NADA}
.endif

# Disable patch
.if defined(NO_PATCH) && !target(patch)
patch: extract
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${PATCH_COOKIE}
.endif

# Disable configure
.if defined(NO_CONFIGURE) && !target(configure)
configure: patch
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${CONFIGURE_COOKIE}
.endif

# Disable build
.if defined(NO_BUILD) && !target(build)
build: configure
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${BUILD_COOKIE}
.endif

# Disable install
.if defined(NO_INSTALL) && !target(install)
install: build
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${INSTALL_COOKIE}
.endif

# Disable package
.if defined(NO_PACKAGE) && !target(package)
package:
.if defined(IGNORE_SILENT)
	@${DO_NADA}
.else
	@${ECHO_MSG} "===>  ${PKGNAME} may not be packaged: ${NO_PACKAGE}."
.endif
.endif

# Disable describe
.if defined(NO_DESCRIBE) && !target(describe)
describe:
	@${DO_NADA}
.endif

################################################################
# More standard targets start here.
#
# These are the body of the build/install framework.  If you are
# not happy with the default actions, and you can't solve it by
# adding pre-* or post-* targets/scripts, override these.
################################################################

# Fetch
_FETCH_FILE=								\
	if [ ! -f $$file -a ! -f $$bfile -a ! -h $$bfile ]; then	\
		${ECHO_MSG} ">> $$bfile doesn't seem to exist on this system."; \
		for site in $$sites; do					\
			${ECHO_MSG} ">> Attempting to fetch $$bfile from $${site}."; \
			if ${FETCH_CMD} ${FETCH_BEFORE_ARGS} $${site}$${bfile} ${FETCH_AFTER_ARGS}; then \
				if [ -n "${FAILOVER_FETCH}" -a -f ${MD5_FILE} -a -f ${_DISTDIR}/$$bfile ]; then	\
					CKSUM=`${MD5} < ${_DISTDIR}/$$bfile`; \
					CKSUM2=`${AWK} '$$1 == "MD5" && $$2 == "('$$file')"{print $$4;}' ${MD5_FILE}`; \
					if [ "$$CKSUM" = "$$CKSUM2" -o "$$CKSUM2" = "IGNORE" ]; then \
						continue 2;		\
					else				\
						${ECHO_MSG} ">> Checksum failure - trying next site."; \
					fi;				\
				elif [ ! -f ${_DISTDIR}/$$bfile ]; then \
					${ECHO_MSG} ">> FTP didn't fetch expected file, trying next site." ; \
				else					\
					continue 2;			\
				fi;					\
			fi						\
		done;							\
		${ECHO_MSG} ">> Couldn't fetch it - please try to retrieve this";\
		${ECHO_MSG} ">> file manually into ${_DISTDIR} and try again."; \
		exit 1;							\
	fi

_CHECK_DIST_PATH=							\
	if [ "X${DIST_PATH}" != "X" ]; then				\
		for d in "" `${ECHO} ${DIST_PATH} | ${TR} ':' ' '`; do	\
			if [ "X$$d" = "X" -o "X$$d" = "X${DISTDIR}" ]; then continue; fi; \
			if [ -f $$d/${DIST_SUBDIR}/$$bfile ]; then	\
				${ECHO} "Using $$d/${DIST_SUBDIR}/$$bfile"; \
				${RM} -f $$bfile;			\
				${LN} -s $$d/${DIST_SUBDIR}/$$bfile $$bfile; \
				break;					\
			fi;						\
		done;							\
	fi

#
# Sort the master site list according to the patterns in MASTER_SORT
#

MASTER_SORT?=
MASTER_SORT_REGEX?=
MASTER_SORT_REGEX+= ${MASTER_SORT:S/./\\./g:C/.*/:\/\/[^\/]*&\//}

MASTER_SORT_AWK= BEGIN { RS = " "; ORS = " "; IGNORECASE = 1 ; gl = "${MASTER_SORT_REGEX}"; }
.for srt in ${MASTER_SORT_REGEX}
MASTER_SORT_AWK+= /${srt:C/\//\\\//g}/ { good["${srt}"] = good["${srt}"] " " $$0 ; next; } 
.endfor
MASTER_SORT_AWK+= { rest = rest " " $$0; } END { n=split(gl, gla); for(i=1;i<=n;i++) { print good[gla[i]]; } print rest; } 
SORTED_MASTER_SITES!= echo '${MASTER_SITES}' | awk '${MASTER_SORT_AWK}'

.if !target(do-fetch)
do-fetch:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${_DISTDIR}
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${_DISTDIR};			\
	 sites="${SORTED_MASTER_SITES}";				\
	 for file in "" ${_DISTFILES}; do				\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		bfile=`${BASENAME} $$file`;				\
		${_CHECK_DIST_PATH};					\
		${_FETCH_FILE}						\
	 done)
.if defined(_PATCHFILES)
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${_DISTDIR};			\
	 sites="${PATCH_SITES}";					\
	 for file in "" ${_PATCHFILES}; do				\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		bfile=`${BASENAME} $$file`;				\
		${_CHECK_DIST_PATH};					\
		${_FETCH_FILE}						\
	 done)
.endif
.endif

.if !target(show-distfiles)
show-distfiles:
.if defined(IGNORE)
	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}
.else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for file in "" ${_CKSUMFILES}; do				\
		if [ "X$$file" = "X" ]; then continue; fi;		\
		${ECHO} $$file;						\
	done
.endif
.endif

.if !target(show-downlevel)
show-downlevel:
.if defined(IGNORE)
	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}
.else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	base=`${ECHO} ${PKGNAME} | ${SED} -e 's|\(.*\)-.*|\1|'`;	\
	found=`${PKG_INFO} -e "$$base-[0-9]*" || ${TRUE}`;		\
	if [ "X$$found" != "X" -a "X$$found" != "X${PKGNAME}" ]; then	\
		${ECHO} "$$base package: $$found installed, pkgsrc version ${PKGNAME}"; \
	fi
.endif
.endif


# Extract

DOWNLOADED_DISTFILE=	${_DISTDIR}/$$file

.if !target(do-extract)
do-extract:
.ifndef NO_WRKDIR
.ifndef KEEP_WRKDIR
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -rf ${WRKDIR}
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${WRKDIR}
.ifdef WRKOBJDIR
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${RM} -f ${WRKDIR_BASENAME} || ${TRUE};				\
	if ${LN} -s ${WRKDIR} ${WRKDIR_BASENAME} 2>/dev/null; then	\
		${ECHO} "${WRKDIR_BASENAME} -> ${WRKDIR}";		\
	fi
.endif # WRKOBJDIR
.endif
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for file in "" ${EXTRACT_ONLY}; do				\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		(cd ${WRKDIR} && ${EXTRACT_CMD});			\
	done
.endif

# Patch

.if !target(do-patch)
do-patch:
.if defined(PATCHFILES)
	@${ECHO_MSG} "===>  Applying distribution patches for ${PKGNAME}"
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${_DISTDIR}; \
	  for i in ${PATCHFILES}; do \
		if [ ${PATCH_DEBUG_TMP} = yes ]; then \
			${ECHO_MSG} "===>   Applying distribution patch $$i" ; \
		fi; \
		case $$i in \
			*.Z|*.gz) \
				${GZCAT} $$i | ${PATCH} ${PATCH_DIST_ARGS} \
				|| ( ${ECHO} Patch $$i failed ; exit 1 ) ; \
				;; \
			*) \
				${PATCH} ${PATCH_DIST_ARGS} < $$i \
				|| ( ${ECHO} Patch $$i failed ; exit 1 ) ; \
				;; \
		esac; \
	  done)
.endif
	${_PKG_SILENT}${_PKG_DEBUG}if [ -d ${PATCHDIR} ]; then		\
		if [ "`${ECHO} ${PATCHDIR}/patch-*`" = "${PATCHDIR}/patch-*" ]; then \
			${ECHO_MSG} "===>   Ignoring empty patch directory"; \
			if [ -d ${PATCHDIR}/CVS ]; then			\
				${ECHO_MSG} "===>   Perhaps you forgot the -P flag to cvs co or update?"; \
			fi;						\
		else							\
			${ECHO_MSG} "===>  Applying ${OPSYS} patches for ${PKGNAME}" ; \
			fail="";					\
			for i in ${PATCHDIR}/patch-*; do		\
				case $$i in				\
				*.orig|*.rej|*~)			\
					${ECHO_MSG} "===>   Ignoring patchfile $$i" ; \
					continue;			\
					;;				\
				${PATCHDIR}/patch-local-*) 		\
					;;				\
				*)					\
					if [ -f ${PATCH_SUM_FILE} ]; then \
						filename=`expr $$i : '.*/\(.*\)'`; \
						calcsum=`${SED} -e '/\$$NetBSD.*/d' $$i | ${MD5}`; \
						recorded=`${AWK} '$$1 == "MD5" && $$2 == "('$$filename')" { print $$4; }' ${PATCH_SUM_FILE} || ${TRUE}`; \
						if [ "X$$recorded" = "X" ]; then \
							${ECHO_MSG} "**************************************"; \
							${ECHO_MSG} "Ignoring unknown patch file: $$i"; \
							${ECHO_MSG} "**************************************"; \
							continue;	\
						fi;			\
						if [ "X$$calcsum" != "X$$recorded" ]; then \
							${ECHO_MSG} "**************************************"; \
							${ECHO_MSG} "Patch file $$i has been modified"; \
							${ECHO_MSG} "**************************************"; \
							fail="$$fail $$filename"; \
							continue;	\
						fi;			\
					fi;				\
					;;				\
				esac;					\
				if [ ${PATCH_DEBUG_TMP} = yes ]; then	\
					${ECHO_MSG} "===>   Applying ${OPSYS} patch $$i" ; \
				fi;					\
				fuzz="";				\
				${PATCH} -v > /dev/null 2>&1 && fuzz="${PATCH_FUZZ_FACTOR}"; \
				${PATCH} $$fuzz ${PATCH_ARGS} < $$i ||	\
					( ${ECHO} "*** Fuzzy patch $$i ***"; ${PATCH} ${PATCH_ARGS} < $$i) || \
					( ${ECHO} Patch $$i failed ; exit 1 ) ; \
			done;						\
			if [ "X$$fail" != "X" ]; then			\
				${ECHO_MSG} "Patching failed due to modified patch file(s): $$fail"; \
				exit 1;					\
			fi;						\
		fi;							\
	fi
.endif

# Configure

.if !target(do-configure)
do-configure:
.if defined(USE_LIBTOOL) && defined(LTCONFIG_OVERRIDE) && !defined(LIBTOOL_OVERRIDE)
.for ltconfig in ${LTCONFIG_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${ltconfig} ]; then \
		${ECHO} "${RM} -f libtool; ${LN} -s ${LIBTOOL} libtool" \
			> ${ltconfig}; \
	fi
.endfor
.endif
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/configure ]; then \
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH} \
		  ${SCRIPTDIR}/configure; \
	fi
.if defined(HAS_CONFIGURE)
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} CC="${CC}" ac_cv_path_CC="${CC}" \
	    CFLAGS="${CFLAGS}" \
	    INSTALL="`${TYPE} ${INSTALL} | ${AWK} '{ print $$NF }'` -c -o ${BINOWN} -g ${BINGRP}" \
	    INSTALL_DATA="${INSTALL_DATA}" \
	    INSTALL_PROGRAM="${INSTALL_PROGRAM}" \
	    INSTALL_SCRIPT="${INSTALL_SCRIPT}" \
	    ${CONFIGURE_ENV} ./${CONFIGURE_SCRIPT} ${CONFIGURE_ARGS})
.endif
.if defined(USE_IMAKE)
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} ${SCRIPTS_ENV} XPROJECTROOT=${X11BASE} ${XMKMF})
.endif
.if defined(USE_LIBTOOL) && defined(LIBTOOL_OVERRIDE) && !defined(LTCONFIG_OVERRIDE)
.for libtool in ${LIBTOOL_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${libtool} ]; then \
		${RM} -f ${libtool}; \
		${LN} -s ${LIBTOOL} ${libtool}; \
	fi
.endfor
.endif
.endif

# Build

.if !target(do-build)
do-build:
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} -f ${MAKEFILE} ${ALL_TARGET})
.endif

# Install

.if !target(do-install)
do-install:
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} -f ${MAKEFILE} ${INSTALL_TARGET})
.endif

# Package

.if !target(do-package)
do-package: ${PLIST} ${DESCR}
	${_PKG_SILENT}${_PKG_DEBUG}if ${TEST} -e ${PLIST}; then		\
		${ECHO_MSG} "===>  Building binary package for ${PKGNAME}"; \
		if [ ! -d ${PKGREPOSITORY} ]; then			\
			${MKDIR} ${PKGREPOSITORY};			\
			if [ $$? -ne 0 ]; then				\
				${ECHO_MSG} ">> Can't create directory ${PKGREPOSITORY}."; \
				exit 1;					\
			fi;						\
		fi;							\
		if ${PKG_CREATE} ${PKG_ARGS} ${PKGFILE}; then		\
			${MAKE} ${.MAKEFLAGS} package-links;		\
		else							\
			${MAKE} ${.MAKEFLAGS} delete-package;		\
			exit 1;						\
		fi;							\
	fi
.endif

# Some support rules for do-package

.if !target(package-links)
package-links:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${.MAKEFLAGS} delete-package-links
	${_PKG_SILENT}${_PKG_DEBUG}for cat in ${CATEGORIES}; do		\
		if [ ! -d ${PACKAGES}/$$cat ]; then			\
			${MKDIR} ${PACKAGES}/$$cat;			\
			if [ $$? -ne 0 ]; then				\
				${ECHO_MSG} ">> Can't create directory ${PACKAGES}/$$cat."; \
				exit 1;					\
			fi;						\
		fi;							\
		${LN} -s ../${PKGREPOSITORYSUBDIR}/${PKGNAME}${PKG_SUFX} ${PACKAGES}/$$cat; \
	done;
.endif

.if !target(delete-package-links)
delete-package-links:
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${PACKAGES}/[a-z]*/${PKGNAME}${PKG_SUFX};
.endif

.if !target(delete-package)
delete-package:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${.MAKEFLAGS} delete-package-links
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${PKGFILE}
.endif

# Set the PLIST_SRC definition, if necessary
.if !defined(PLIST_SRC)
.if exists(${PKGDIR}/PLIST)
PLIST_SRC=	${PKGDIR}/PLIST
.elif exists(${PKGDIR}/PLIST-mi) && \
      exists(${PKGDIR}/PLIST-md.shared) && \
      exists(${PKGDIR}/PLIST-md.static)
PLIST_SRC=	${PKGDIR}/PLIST-mi
.if defined(NOPIC)
PLIST_SRC+=	${PKGDIR}/PLIST-md.static
.else
PLIST_SRC+=	${PKGDIR}/PLIST-md.shared
.endif  # NOPIC
.else   # no PLIST at all
PLIST_SRC=
.endif  # ${PKGDIR}/PLIST
.endif  # !PLIST_SRC

################################################################
# This is the "generic" package target, actually a macro used from the
# six main targets.  See below for more.
################################################################

_PORT_USE: .USE
.if make(real-fetch)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} fetch-depends
.endif
.if make(real-extract)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} build-depends misc-depends
.endif
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} ${.TARGET:S/^real-/pre-/}
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/${.TARGET:S/^real-/pre-/} ]; then		\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/${.TARGET:S/^real-/pre-/};		\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} ${.TARGET:S/^real-/do-/}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} ${.TARGET:S/^real-/post-/}
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/${.TARGET:S/^real-/post-/} ]; then	\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/${.TARGET:S/^real-/post-/};	\
	fi
.if !make(real-fetch)							\
	&& (!make(real-patch) || !defined(PATCH_CHECK_ONLY))		\
	&& (!make(real-package) || !defined(PACKAGE_NOINSTALL))
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${WRKDIR}/.${.TARGET:S/^real-//}_done
.endif

root-install:
.if !defined(NO_PKG_REGISTER) && !defined(FORCE_PKG_REGISTER)
.if defined(CONFLICTS)
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${WRKDIR}/.CONFLICTS
.for conflict in ${CONFLICTS}
	${_PKG_SILENT}${_PKG_DEBUG}found="`${PKG_INFO} -e \"${conflict}\" || ${TRUE}`"; \
	if [ X"$$found" != X"" ]; then					\
		${ECHO} "$$found" >> ${WRKDIR}/.CONFLICTS;		\
	fi
.endfor
	${_PKG_SILENT}${_PKG_DEBUG}if [ -s ${WRKDIR}/.CONFLICTS ]; then \
		found=`cat ${WRKDIR}/.CONFLICTS | ${SED} -e s'|${PKG_DBDIR}/||g' | tr '\012' ' '`; \
		${ECHO_MSG} "===>  ${PKGNAME} conflicts with installed package(s): $$found found."; \
		${ECHO_MSG} "      They install the same files into the same place."; \
		${ECHO_MSG} "      Please remove $$found first with pkg_delete(1)."; \
		${RM} -f ${WRKDIR}/.CONFLICTS;				\
		exit 1;							\
	fi
.endif	# CONFLICTS
	${_PKG_SILENT}${_PKG_DEBUG}found="`${PKG_INFO} -e \"${PKGNAME:C/-[^-]*$/-[0-9]*/}\" || ${TRUE}`"; \
	if [ "$$found" != "" ]; then					\
		${ECHO_MSG} "===>  $$found is already installed - perhaps an older version?"; \
		${ECHO_MSG} "      If so, you may wish to \`\`pkg_delete $$found'' and install"; \
		${ECHO_MSG} "      this package again by \`\`${MAKE} reinstall'' to upgrade it properly,"; \
		${ECHO_MSG} "      or use \`\`${MAKE} update'' to upgrade it and all of its dependencies."; \
		${ECHO_MSG} "      If you really wish to overwrite the old package of $$found"; \
		${ECHO_MSG} "      without deleting it first, set the variable \"FORCE_PKG_REGISTER\""; \
		${ECHO_MSG} "      in your environment or the \"${MAKE} install\" command line."; \
		exit 1;							\
	fi
.endif # !NO_PKG_REGISTER && !NO_FORCE_REGISTER
	${_PKG_SILENT}${_PKG_DEBUG}if [ `${SH} -c umask` != ${DEF_UMASK} ]; then \
		${ECHO_MSG} "===>  Warning: your umask is \"`${SH} -c umask`"\".; \
		${ECHO_MSG} "      If this is not desired, set it to an appropriate value (${DEF_UMASK})"; \
		${ECHO_MSG} "      and install this package again by \`\`${MAKE} deinstall reinstall''."; \
	fi
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} run-depends
.if !defined(NO_MTREE)
	${_PKG_SILENT}${_PKG_DEBUG}if [ `${ID} -u` = 0 ]; then		\
		if [ ! -f ${MTREE_FILE} ]; then				\
			${ECHO_MSG} "Error: mtree file \"${MTREE_FILE}\" is missing."; \
			exit 1;						\
		else							\
			if [ ! -d ${PREFIX} ]; then			\
				mkdir -p ${PREFIX};			\
			fi;						\
			${MTREE} ${MTREE_ARGS} ${PREFIX}/;		\
		fi;							\
	else								\
		${ECHO_MSG} "Warning: not superuser, can't run mtree."; \
		${ECHO_MSG} "Become root and try again to ensure correct permissions."; \
	fi
.endif # !NO_MTREE
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} pre-install
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/pre-install ]; then		\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/pre-install;		\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} do-install
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} post-install
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/post-install ]; then	\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/post-install;	\
	fi
.for f in ${INFO_FILES}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} "install-info --info-dir=${PREFIX}/info ${PREFIX}/info/${f}"; \
	install-info --remove --info-dir=${PREFIX}/info ${PREFIX}/info/${f}; \
	install-info --info-dir=${PREFIX}/info ${PREFIX}/info/${f}
.endfor
	${_PKG_SILENT}(${_PKG_DEBUG}newmanpages=`${EGREP} -h		\
		'^([^@/]*/)*man/([^/]*/)?(man[1-9ln]/.*\.[1-9ln]|cat[1-9ln]/.*\.0)(\.gz)?$$' \
		${PLIST_SRC} || ${TRUE}`;				\
	if [ X"${MANCOMPRESSED}" != X"" -a X"${MANZ}" = X"" ]; then	\
		${ECHO_MSG} "===>   [Automatic manual page handling]";	\
		${ECHO_MSG} "===>   Decompressing manual pages for ${PKGNAME}";	\
		for manpage in $$newmanpages; do			\
			manpage=`${ECHO} $$manpage | ${SED} -e 's|\.gz$$||'`; \
			if [ -h ${PREFIX}/$$manpage.gz ]; then		\
				set - `${FILE} ${PREFIX}/$$manpage.gz | ${SED} -e 's|\.gz$$||'`; \
				shift `expr $$# - 1`;			\
				${RM} -f ${PREFIX}/$$manpage;		\
				${LN} -s $${1} ${PREFIX}/$$manpage;	\
				${RM} ${PREFIX}/$$manpage.gz;		\
			else						\
				${GUNZIP_CMD} ${PREFIX}/$$manpage.gz;	\
			fi;						\
			if [ X"${PKG_VERBOSE}" != X"" ]; then		\
				${ECHO_MSG} "$$manpage";		\
			fi;						\
		done;							\
	fi;								\
	if [ X"${MANCOMPRESSED}" = X"" -a X"${MANZ}" != X"" ]; then	\
		${ECHO_MSG} "===>   [Automatic manual page handling]";	\
		${ECHO_MSG} "===>   Compressing manual pages for ${PKGNAME}"; \
		for manpage in $$newmanpages; do			\
			manpage=`${ECHO} $$manpage | ${SED} -e 's|\.gz$$||'`; \
			if [ -h ${PREFIX}/$$manpage ]; then		\
				set - `${FILE} ${PREFIX}/$$manpage`;	\
				shift `expr $$# - 1`;			\
				${RM} -f ${PREFIX}/$$manpage.gz; 	\
				${LN} -s $${1}.gz ${PREFIX}/$$manpage.gz; \
				${RM} ${PREFIX}/$$manpage;		\
			else						\
				${GZIP_CMD} ${PREFIX}/$$manpage;	\
			fi;						\
			if [ X"${PKG_VERBOSE}" != X"" ]; then		\
				${ECHO_MSG} "$$manpage";		\
			fi;						\
		done;							\
	fi)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} ${PLIST}
.if ${OPSYS} == "NetBSD" || ${OPSYS} == "SunOS"
	${_PKG_SILENT}(${_PKG_DEBUG}					\
	sos=`${EGREP} -h -x '.*/lib[^/]+\.so\.[0-9]+(\.[0-9]+)+' ${PLIST} || ${TRUE}`; \
	if [ "X$$sos" != "X" ]; then					\
		shlib_type=`${MAKE} ${.MAKEFLAGS} show-shlib-type`;	\
		case "$$shlib_type" in					\
		"ELF")							\
			${ECHO_MSG} "===>   [Automatic ELF shared object handling]";\
			${AWK} 'function makelinks(target, lib, v1, v2, v3) { \
					print target;			\
					slashc = split(target, slashes, "/"); \
					if (v3 >= 0) {			\
						system(sprintf("${RM} -f ${PREFIX}/%s.%s.%s.%s; ${LN} -s %s ${PREFIX}/%s.%s.%s.%s", lib, v1, v2, v3, slashes[slashc], lib, v1, v2, v3)); \
						printf("%s.%s.%s.%s\n", lib, v1, v2, v3); \
					}				\
					system(sprintf("${RM} -f ${PREFIX}/%s.%s.%s; ${LN} -s %s ${PREFIX}/%s.%s.%s", lib, v1, v2, slashes[slashc], lib, v1, v2)); \
					system(sprintf("${RM} -f ${PREFIX}/%s.%s; ${LN} -s %s ${PREFIX}/%s.%s", lib, v1, slashes[slashc], lib, v1)); \
					printf("%s.%s.%s\n%s.%s\n", lib, v1, v2, lib, v1); \
				}					\
				/^@/ { print; next }			\
				/.*\/lib[^\/]+\.so\.[0-9]+\.[0-9]+\.[0-9]+$$/ { \
					dotc = split($$0, dots, "\.");	\
					lib = dots[1];			\
					for (i = 2 ; i <= dotc - 4 ; i++) \
						lib = lib "." dots[i];	\
					makelinks($$0, lib, dots[dotc - 3], dots[dotc - 2], dots[dotc - 1]); \
					next;				\
				}					\
				/.*\/lib[^\/]+\.so\.[0-9]+\.[0-9]+$$/ {	\
					dotc = split($$0, dots, "\.");	\
					lib = dots[1];			\
					for (i = 2 ; i <= dotc - 3 ; i++) \
						lib = lib "." dots[i];	\
					makelinks($$0, lib, dots[dotc - 2], dots[dotc - 1], -1); \
					next;				\
				}					\
				/.*\/lib[^\/]+\.so\.[0-9]+$$/ { next; }	\
				/.*\/lib[^\/]+\.so$$/ { next; }		\
				{ print; }' < ${PLIST} > ${PLIST}.tmp && ${MV} ${PLIST}.tmp ${PLIST}; \
			;;						\
		"a.out")						\
			${ECHO_MSG} "===>   [Automatic a.out shared object handling]";\
			cnt=`${EGREP} -c -x '@exec[ 	]*${LDCONFIG}' ${PLIST} || ${TRUE}`; \
			if [ $$cnt -eq 0 ]; then			\
				${ECHO} "@exec ${LDCONFIG}" >> ${PLIST}; \
				${ECHO} "@unexec ${LDCONFIG}" >> ${PLIST}; \
			fi;						\
			if [ X"${PKG_VERBOSE}" != X"" ]; then		\
				${ECHO_MSG} "$$sos";			\
				${ECHO_MSG} "Running ${LDCONFIG}";	\
			fi;						\
			${LDCONFIG} || ${TRUE};				\
			;;						\
		"*")							\
			${ECHO_MSG} "No shared libraries for ${MACHINE_ARCH}"; \
			for so in $$sos; do				\
				if [ X"${PKG_VERBOSE}" != X"" ]; then	\
					${ECHO_MSG} "Ignoring $$so";	\
				fi;					\
				${SED} -e "s;^$$so$$;@comment No shared objects - &;" ${PLIST} > ${PLIST}.tmp && \
					${MV} ${PLIST}.tmp ${PLIST};	\
			done;						\
			;;						\
		esac;							\
	fi)
.endif
.ifdef MESSAGE_FILE
	@${ECHO_MSG} "===>   Please note the following:"
	@${ECHO_MSG} ""
	@${CAT} ${MESSAGE_FILE}
	@${ECHO_MSG} ""
.endif
.if !defined(NO_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} fake-pkg
.endif # !NO_PKG_REGISTER
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${WRKDIR}/.install_done


# Show the shared lib type being built: one of ELF, a.out or none
show-shlib-type:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cd ${WRKDIR} &&							\
	sotype=none;							\
	if [ "X${MKPIC}" != "Xno" -a "X${NOPIC}" = "X" ]; then		\
		${ECHO} "int main() { exit(0); }" > a.$$$$.c;		\
		${CC} ${CFLAGS} a.$$$$.c -o a.$$$$.out;			\
		case `${FILE} a.$$$$.out` in				\
		*ELF*dynamically*)					\
			sotype=ELF ;;					\
		*dynamically*)						\
			sotype="a.out" ;;				\
		esac;							\
	fi;								\
	${ECHO} "$$sotype";						\
	${RM} -f a.$$$$.c a.$$$$.out
 

################################################################
# Skeleton targets start here
# 
# You shouldn't have to change these.  Either add the pre-* or
# post-* targets/scripts or redefine the do-* targets.  These
# targets don't do anything other than checking for cookies and
# call the necessary targets/scripts.
################################################################

.if !target(fetch)
fetch:
	@cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-fetch
.endif

.if !target(extract)
extract: checksum ${EXTRACT_COOKIE}
.endif

.if !target(patch)
patch: extract ${PATCH_COOKIE}
.endif

.if !target(configure)
configure: patch ${CONFIGURE_COOKIE}
.endif

.if !target(build)
build: configure ${BUILD_COOKIE}
.endif

.if !target(install)
install: uptodate-pkgtools build ${INSTALL_COOKIE}
.endif

.if !target(package)
package: uptodate-pkgtools install ${PACKAGE_COOKIE}
.endif

${EXTRACT_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-extract
${PATCH_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-patch
${CONFIGURE_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-configure
${BUILD_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-build
${INSTALL_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-install
${PACKAGE_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-package

# And call the macros

real-fetch: _PORT_USE
real-extract: _PORT_USE
	@${ECHO_MSG} "===>  Extracting for ${PKGNAME}"
real-patch: _PORT_USE
	@${ECHO_MSG} "===>  Patching for ${PKGNAME}"
real-configure: _PORT_USE
	@${ECHO_MSG} "===>  Configuring for ${PKGNAME}"
real-build: _PORT_USE
	@${ECHO_MSG} "===>  Building for ${PKGNAME}"
real-install: pkg-su-install
real-package: _PORT_USE

# sudo or priv are acceptable substitutes
SU_CMD?=	${SU} - root -c
PRE_ROOT_CMD?=	${TRUE}

pkg-su-install:
	@${ECHO_MSG} "===>  Installing for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ `${ID} -u` = 0 ]; then					\
		${MAKE} ${.MAKEFLAGS} root-install;			\
	elif [ "X${BATCH}" != X"" ]; then				\
		${ECHO_MSG} "Warning: Batch mode, not superuser, can't run mtree."; \
		${ECHO_MSG} "Become root and try again to ensure correct permissions."; \
	else								\
		make=`${TYPE} ${MAKE} | ${AWK} '{ print $$NF }'`;	\
		args="";						\
		if [ "X${FORCE_PKG_REGISTER}" != X"" ]; then		\
			args="FORCE_PKG_REGISTER=1";			\
		fi;							\
		if [ "X${PKG_DEBUG_LEVEL}" != X"" ]; then		\
			args="$$args PKG_DEBUG_LEVEL=${PKG_DEBUG_LEVEL}"; \
		fi;							\
		if [ "X${PRE_ROOT_CMD}" != "X${TRUE}" ]; then		\
			${ECHO} "*** WARNING *** Running: ${PRE_ROOT_CMD}"; \
			${PRE_ROOT_CMD};				\
		fi;                                             	\
		${ECHO_MSG} "===>  Becoming root@`/bin/hostname` to install ${PKGNAME}."; \
		${ECHO_MSG} -n "`${ECHO} ${SU_CMD} | ${AWK} '{ print $$1 }'` ";\
		${SU_CMD} "cd ${.CURDIR}; $$make $$args ${.MAKEFLAGS} root-install"; \
	fi

# Empty pre-* and post-* targets, note we can't use .if !target()
# in the _PORT_USE macro

.for name in fetch extract patch configure build install package

.if !target(pre-${name})
pre-${name}:
	@${DO_NADA}
.endif

.if !target(post-${name})
post-${name}:
	@${DO_NADA}
.endif

.endfor

# Checkpatch
#
# Special target to verify patches

.if !target(checkpatch)
checkpatch:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} PATCH_CHECK_ONLY=yes ${.MAKEFLAGS} patch
.endif

# Reinstall
#
# Special target to re-run install

.if !target(reinstall)
reinstall:
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${INSTALL_COOKIE} ${PACKAGE_COOKIE} ${PLIST}
	${_PKG_SILENT}${_PKG_DEBUG}DEPENDS_TARGET=${DEPENDS_TARGET} ${MAKE} install
.endif

# Deinstall
#
# Special target to remove installation

.if !target(deinstall)
deinstall: pkg-su-deinstall

pkg-su-deinstall: uptodate-pkgtools
	@${ECHO_MSG} "===> Deinstalling for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ `${ID} -u` = 0 ]; then					\
		${MAKE} ${.MAKEFLAGS} root-deinstall;			\
	else								\
		make=`${TYPE} ${MAKE} | ${AWK} '{ print $$NF }'`;	\
		${ECHO_MSG} "===>  Becoming root@`/bin/hostname` to deinstall ${PKGNAME}."; \
		${SU_CMD} "cd ${.CURDIR}; $$make ${.MAKEFLAGS} PKG_DEBUG_LEVEL=${PKG_DEBUG_LEVEL} root-deinstall DEINSTALLDEPENDS=${DEINSTALLDEPENDS}"; \
	fi


.if (${DEINSTALLDEPENDS} != "NO")
.if (${DEINSTALLDEPENDS} != "ALL")
# used for removing stuff in bulk builds
root-install-flags+=	-r -R
# used for "update" target
.else
root-install-flags+=	-r
.endif
.endif
.ifdef PKG_VERBOSE
root-install-flags+=	-v
.endif

root-deinstall:
	${_PKG_SILENT}${_PKG_DEBUG} \
	found=`${PKG_INFO} -e "${PKGNAME:C/-[^-]*$/-[0-9]*/}" || ${TRUE}` ; \
	if [ "$$found" != "" ]; then \
		${ECHO} Running ${PKG_DELETE} ${root-install-flags} $$found ; \
		${PKG_DELETE} ${root-install-flags} $$found || ${TRUE} ; \
	fi
	@${RM} -f ${INSTALL_COOKIE} ${PACKAGE_COOKIE}
.endif						# target(deinstall)


################################################################
# Some more targets supplied for users' convenience
################################################################

# The 'update' target can be used to update a package and all
# currently installed packages that depend upon this package.

.if exists(${DDIR})
RESUMEUPDATE?=	YES

update:
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO_MSG}				\
		"===> Resuming update for ${PKGNAME}"
.else
RESUMEUPDATE?=	NO

update:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${DDIR}
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} deinstall DEINSTALLDEPENDS=ALL
.endif
.if ${REINSTALL} == "NO"
	${_PKG_SILENT}${_PKG_DEBUG}					\
		${MAKE} ${DEPENDS_TARGET} KEEP_WRKDIR=YES
.else
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} reinstall
.endif
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -s ${DDIR} ] ; then					\
		for dep in `${CAT} ${DDIR}` ; do			\
			${ECHO_MSG} "===>  Installing in $${dep}" ;	\
			(cd "../../$${dep}" && 				\
			if [ "${RESUMEUPDATE}" = "NO" ] ; then		\
			  ${MAKE} deinstall ;				\
			fi &&						\
			if [ "${REINSTALL}" = "NO" ] ; then		\
				${MAKE} ${DEPENDS_TARGET} ;		\
			else						\
				${MAKE} reinstall ;			\
			fi) ;						\
		done ;							\
	fi
.if ${NOCLEAN} == "NO"
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} clean-update CLEAR_DIRLIST=YES
.endif


clean-update:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${DDIR}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -s ${DDIR} ] ; then					\
		for dep in `${CAT} ${DDIR}` ; do			\
			(cd "../../$${dep}" && ${MAKE} clean) ;		\
		done ;							\
	fi
.ifdef CLEAR_DIRLIST
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} clean
.else
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} clean update-dirlist		\
		DIRLIST="`${CAT} ${DDIR}`" PKGLIST="`${CAT} ${DLIST}`"
.endif


update-dirlist:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} -p ${WRKDIR}
.ifdef PKGLIST
.for __tmp__ in ${PKGLIST}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} >>${DLIST} "${__tmp__}"
.endfor
.endif
.ifdef DIRLIST
.for __tmp__ in ${DIRLIST}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} >>${DDIR} "${__tmp__}"
.endfor
.endif


${DDIR}: ${DLIST}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	ddir=`${SED} 's:-[^-]*$$::' <${DLIST}` ;			\
	if ${PKG_INFO} -b $${ddir} >/dev/null 2>&1 ; then		\
		${PKG_INFO} -b $${ddir} |				\
			${EGREP} '^[^/]+/[^/]+/Makefile:' |		\
			${CUT} -d'/' -f1-2 >${DDIR} ;			\
	else 								\
		${ECHO} >${DDIR} ;					\
	fi

${DLIST}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} -p ${WRKDIR}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	(${PKG_INFO} -R "${PKGNAME:C/-[^-]*$/-[0-9]*/}" || ${TRUE}) |	\
		${TAIL} -n +4 >${DLIST}

# This is for the use of sites which store distfiles which others may
# fetch - only fetch the distfile if it is allowed to be
# re-distributed freely
mirror-distfiles:
.if (${MIRROR_DISTFILE} == "yes")
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} fetch NO_IGNORE=yes NO_CHECK_DEPENDS=yes
.endif


# Cleaning up

.if !target(pre-clean)
pre-clean:
	@${DO_NADA}
.endif

.if !target(clean)
clean: pre-clean
.if (${CLEANDEPENDS} != "NO")
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} clean-depends
.endif
	@${ECHO_MSG} "===>  Cleaning for ${PKGNAME}"
.if !defined(NO_WRKDIR)
.ifdef WRKOBJDIR
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -rf ${WRKOBJDIR}/${PKGSRC_SUBDIR}
	-${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${WRKDIR_BASENAME}
.else
	${_PKG_SILENT}${_PKG_DEBUG}if [ -d ${WRKDIR} ]; then		\
		if [ -w ${WRKDIR} ]; then				\
			${RM} -rf ${WRKDIR};				\
		else							\
			${ECHO_MSG} "===>   ${WRKDIR} not writable, skipping"; \
		fi;							\
	fi
.endif
.else
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${WRKDIR}/.*_done
.endif
.endif

.if !target(pre-distclean)
pre-distclean:
	@${DO_NADA}
.endif

.if !target(cleandir)
cleandir: clean
.endif

.if !target(distclean)
distclean: pre-distclean clean
	${_PKG_SILENT}${ECHO_MSG} "===>  Dist cleaning for ${PKGNAME}"
	${_PKG_SILENT}(${_PKG_DEBUG}if [ -d ${_DISTDIR} ]; then		\
		cd ${_DISTDIR} &&					\
		${TEST} -z "${DISTFILES}" || ${RM} -f ${DISTFILES};	\
		${TEST} -z "${PATCHFILES}" || ${RM} -f ${PATCHFILES};	\
	fi)
.if defined(DIST_SUBDIR)
	-${_PKG_SILENT}${_PKG_DEBUG}${RMDIR} ${_DISTDIR}  
.endif
	-${_PKG_SILENT}${_PKG_DEBUG}${RM} -f README.html
.endif

# Prints out a list of files to fetch (useful to do a batch fetch)

# are we called from bsd.pkg.subdir.mk (i.e. do we scan all dirs anyway)? XXX
.ifdef(_THISDIR_)
RECURSIVE_FETCH_LIST?=	NO
.else
RECURSIVE_FETCH_LIST?=	YES
.endif

.if !target(fetch-list)
fetch-list:
	@${MAKE} fetch-list-recursive RECURSIVE_FETCH_LIST=${RECURSIVE_FETCH_LIST} | sort -u
.endif # !target(fetch-list)

.if !target(fetch-list-recursive)
fetch-list-recursive:
	@${MAKE} fetch-list-one-pkg
.if ${RECURSIVE_FETCH_LIST} != "NO"
	@for dir in `${ECHO} ${BUILD_DEPENDS} ${DEPENDS} ${RUN_DEPENDS} | ${TR} '\040' '\012' | ${SED} -e 's/^[^:]*://' -e 's/:.*//' | sort -u` ; do \
		(cd $$dir && ${MAKE} fetch-list-recursive; );		\
	done
.endif # ${RECURSIVE_FETCH_LIST} != "NO"
.endif # !target(fetch-list-recursive)

.if !target(fetch-list-one-pkg)
fetch-list-one-pkg:
	@${MKDIR} ${_DISTDIR}
	@[ -z "${_DISTDIR}" ] || ${ECHO} "${MKDIR} ${_DISTDIR}"
.if defined(DISTFILES)
	@(cd ${_DISTDIR};						\
	for file in "" ${DISTFILES}; do					\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		if [ ! -f $$file -a ! -f `${BASENAME} $$file` ]; then	\
			${ECHO} -n "cd ${_DISTDIR} && [ -f $$file -o -f `${BASENAME} $$file` ] || " ; \
			for site in "" ${SORTED_MASTER_SITES}; do	\
				if [ "X$$site" = X"" ]; then continue; fi; \
				${ECHO} -n ${FETCH_CMD} ${FETCH_BEFORE_ARGS} $${site}$${file} "${FETCH_AFTER_ARGS}" '|| ' ; \
			done;						\
			${ECHO} "${ECHO} $${file} not fetched";		\
		fi							\
	done)
.endif # DISTFILES
.if defined(PATCHFILES)
	@(cd ${_DISTDIR};						\
	for file in "" ${PATCHFILES}; do				\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		if [ ! -f $$file -a ! -f `${BASENAME} $$file` ]; then	\
			${ECHO} -n "cd ${_DISTDIR} && [ -f $$file -o -f `${BASENAME} $$file` ] || " ; \
			for site in ${PATCH_SITES}; do			\
				${ECHO} -n ${FETCH_CMD} ${FETCH_BEFORE_ARGS} $${site}$${file} "${FETCH_AFTER_ARGS}" '|| ' ; \
			done;						\
			${ECHO} "${ECHO} $${file} not fetched";		\
		fi							\
	done)
.endif # defined(PATCHFILES)
.endif # !target(fetch-list-one-pkg)

# Checksumming utilities

.if !target(makesum)
makesum: fetch
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${FILESDIR}
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${MD5_FILE} ]; then ${RM} -f ${MD5_FILE}; fi
	@${ECHO} -n "$$" > ${MD5_FILE};					\
		${ECHO} -n "NetBSD" >> ${MD5_FILE}; 			\
		${ECHO} "$$" >> ${MD5_FILE};				\
		${ECHO} "" >> ${MD5_FILE}
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${DISTDIR};			\
	for sumfile in "" ${_CKSUMFILES}; do				\
		if [ "X$$sumfile" = X"" ]; then continue; fi;		\
		${MD5} $$sumfile >> ${MD5_FILE};			\
	done)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for ignore in "" ${_IGNOREFILES}; do				\
		if [ "X$$sumfile" = X"" ]; then continue; fi;		\
		${ECHO} "MD5 ($$ignore) = IGNORE" >> ${MD5_FILE};	\
	done
.endif

.if !target(makepatchsum)
makepatchsum:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	(${MKDIR} ${FILESDIR};						\
	${ECHO_MSG} "===> Making patch checksums";			\
	if [ -f "${PATCH_SUM_FILE}" ]; then				\
		${AWK} -- '{print ; exit}' < ${PATCH_SUM_FILE} > ${PATCH_SUM_FILE}.new; \
	else								\
		${ECHO} -n "$$" > ${PATCH_SUM_FILE}.new;		\
		${ECHO} -n "NetBSD" >> ${PATCH_SUM_FILE}.new;		\
		${ECHO} "$$" >> ${PATCH_SUM_FILE}.new;			\
	fi;								\
	${ECHO} "" >> ${PATCH_SUM_FILE}.new;				\
	havepatches=0;							\
	if [ -d ${PATCHDIR} ]; then					\
		cd ${PATCHDIR};						\
		for sumfile in "" patch-*; do				\
			if [ "X$$sumfile" = "X" ]; then continue; fi;	\
			if [ "X$$sumfile" = "Xpatch-*" ]; then break; fi; \
			case $$sumfile in				\
				patch-local-*) ;;			\
				*.orig) continue ;;			\
				*)	${ECHO} "MD5 ($$sumfile) = `${SED} -e '/\$$NetBSD.*/d' $$sumfile | ${MD5}`" >> ${PATCH_SUM_FILE}.new; \
					havepatches=1 ;;		\
			esac;						\
		done;							\
	fi;								\
	if [ $$havepatches = 0 ]; then					\
		if [ -f "${PATCH_SUM_FILE}" ]; then			\
			${ECHO} "This placeholder file is generated by the \`\`makepatchsum'' target" >> ${PATCH_SUM_FILE}.new; \
			${ECHO} "whenever the patches directory is empty or missing. Its purpose" >> ${PATCH_SUM_FILE}.new; \
			${ECHO} "is to ensure that the presence of any obsolete patches will cause" >> ${PATCH_SUM_FILE}.new; \
			${ECHO} "the proper error to be emitted at build time." >> ${PATCH_SUM_FILE}.new; \
			${ECHO_MSG} ">> placeholder patch-sum file created"; \
		else							\
			${RM} -f ${PATCH_SUM_FILE}.new;			\
			${ECHO_MSG} ">> no patch-sum file created";	\
			exit 0;						\
		fi;							\
	fi;								\
	if cmp -s ${PATCH_SUM_FILE}.new ${PATCH_SUM_FILE}; then		\
		${RM} -f ${PATCH_SUM_FILE}.new;				\
		${ECHO_MSG} ">> patch-sum file unchanged";		\
	else								\
		${MV} ${PATCH_SUM_FILE}.new ${PATCH_SUM_FILE};		\
	fi)
.endif

.if !target(checksum)
checksum: fetch
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -f ${MD5_FILE} ]; then					\
		${ECHO_MSG} ">> No MD5 checksum file.";			\
	else								\
		(cd ${DISTDIR}; OK="true";				\
		  for file in "" ${_CKSUMFILES}; do			\
		  	if [ "X$$file" = X"" ]; then continue; fi; 	\
			CKSUM=`${MD5} < $$file`;			\
			CKSUM2=`${AWK} '$$1 == "MD5" && $$2 == "('$$file')"{print $$4;}' ${MD5_FILE}`; \
			if [ "$$CKSUM2" = "" ]; then			\
				${ECHO_MSG} ">> No checksum recorded for $$file."; \
				OK="false";				\
			elif [ "$$CKSUM2" = "IGNORE" ]; then		\
				${ECHO_MSG} ">> Checksum for $$file is set to IGNORE in md5 file even though"; \
				${ECHO_MSG} "   the file is not in the "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			elif [ "$$CKSUM" = "$$CKSUM2" ]; then		\
				${ECHO_MSG} ">> Checksum OK for $$file."; \
			else						\
				${ECHO_MSG} ">> Checksum mismatch for $$file."; \
				OK="false";				\
			fi;						\
		  done;							\
		  for file in "" ${_IGNOREFILES}; do			\
		  	if [ "X$$file" = X"" ]; then continue; fi; 	\
			CKSUM2=`${AWK} '$$1 == "MD5" && $$2 == "('$$file')"{print $$4;}' ${MD5_FILE}`; \
			if [ "$$CKSUM2" = "" ]; then			\
				${ECHO_MSG} ">> No checksum recorded for $$file, file is in "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			elif [ "$$CKSUM2" != "IGNORE" ]; then		\
				${ECHO_MSG} ">> Checksum for $$file is not set to IGNORE in md5 file even though"; \
				${ECHO_MSG} "   the file is in the "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			fi;						\
		  done;							\
		  if [ "$$OK" != "true" ]; then				\
			${ECHO_MSG} "Make sure the Makefile and md5 file (${MD5_FILE})"; \
			${ECHO_MSG} "are up to date.  If you want to override this check, type"; \
			${ECHO_MSG} "\"${MAKE} NO_CHECKSUM=yes [other args]\"."; \
			exit 1;						\
		  fi) ;							\
	fi
.endif

################################################################
# The special package-building targets
# You probably won't need to touch these
################################################################

HTMLIFY=	${SED} -e 's/&/\&amp;/g' -e 's/>/\&gt;/g' -e 's/</\&lt;/g'

# Set to "html" by the README.html target (and passed via depends-list
# and package-depends)
PACKAGE_NAME_TYPE?=	name

# Nobody should want to override this unless PKGNAME is simply bogus.

.if !target(package-name)
package-name:
.if (${PACKAGE_NAME_TYPE} == "html")
	@${ECHO} '<A HREF="../../'`${MAKE} package-path | ${HTMLIFY}`'/README.html">'`${ECHO} ${PKGNAME} | ${HTMLIFY}`'</A>'
.else
	@${ECHO} '${PKGNAME}'
.endif # PACKAGE_NAME_TYPE
.endif # !target(package-name)

.if !target(package-path)
package-path:
	@pwd | sed s@`cd ${PKGSRCDIR} && pwd`/@@g
.endif

# Show (recursively) all the packages this package depends on.
# if PACKAGE_DEPENDS_WITH_PATTERNS is set, print as pattern (if possible)
PACKAGE_DEPENDS_WITH_PATTERNS?=false
.if !target(package-depends)
package-depends:
.for dep in ${DEPENDS}
	@pkg="`${ECHO} \"${dep}\" | ${SED} -e 's/:.*//'`";		\
	dir="`${ECHO} \"${dep}\" | ${SED} -e 's/[^:]*://'`";		\
	if [ -d $$dir ]; then						\
		if ${PACKAGE_DEPENDS_WITH_PATTERNS}; then		\
			${ECHO} "$$pkg";				\
		else							\
			(cd $$dir && ${MAKE} package-name PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}); \
		fi;							\
		(cd $$dir && ${MAKE} package-depends PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}); \
	else								\
		${ECHO_MSG} "Warning: \"$$dir\" non-existent -- @pkgdep registration incomplete" >&2; \
	fi
.endfor
.for dep in ${RUN_DEPENDS}
	@pkg="`${ECHO} \"${dep}\" | ${SED} -e 's/:.*//'`";		\
	dir="`${ECHO} \"${dep}\" | ${SED} -e 's/[^:]*://'`";		\
	if [ -d $$dir ]; then						\
		if ${PACKAGE_DEPENDS_WITH_PATTERNS}; then		\
			${ECHO} "$$pkg";				\
		else							\
			(cd $$dir && ${MAKE} package-name PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}); \
		fi;							\
		(cd $$dir && ${MAKE} package-depends PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}); \
	else								\
		${ECHO_MSG} "Warning: \"$$dir\" non-existent -- @pkgdep registration incomplete" >&2; \
	fi
.endfor
.endif # target(package-depends)

# Build a package but don't check the package cookie

.if !target(repackage)
repackage: pre-repackage package

pre-repackage:
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${PACKAGE_COOKIE}
.endif

# Build a package but don't check the cookie for installation, also don't
# install package cookie

.if !target(package-noinstall)
package-noinstall:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} PACKAGE_NOINSTALL=yes real-package
.endif

################################################################
# Dependency checking
################################################################

.if !target(depends)
depends: misc-depends
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} fetch-depends
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} build-depends
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} run-depends

.if make(build-depends)
DEPENDS_TMP+=	${BUILD_DEPENDS}
.endif

.if make(run-depends)
DEPENDS_TMP+=	${RUN_DEPENDS}
.endif

_DEPENDS_USE:
.if defined(DEPENDS_TMP)
.if !defined(NO_DEPENDS)
.for i in ${DEPENDS_TMP}
	${_PKG_SILENT}${_PKG_DEBUG}prog="`${ECHO} \"${i}\" | ${SED} -e 's/:.*//'`"; \
	dir="`${ECHO} \"${i}\" | ${SED} -e 's/[^:]*://'`";		\
	if [ ${_DEPENDS_TARGET_OVERRIDE}X != X ]; then			\
		target=${DEPENDS_TARGET};				\
	elif expr "$$dir" : '.*:' > /dev/null; then			\
		target=`${ECHO} $$dir | ${SED} -e 's/.*://'`;		\
		dir=`${ECHO} $$dir | ${SED} -e 's/:.*//'`;		\
	else								\
		target=${DEPENDS_TARGET};				\
	fi;								\
	found=not;							\
	if expr "$$prog" : '.*/' >/dev/null; then			\
		if ${TEST} -e "$$prog" ; then				\
			${ECHO_MSG} "===>  ${PKGNAME} depends on file: $$prog - found"; \
			found="";					\
		else							\
			${ECHO_MSG} "===>  ${PKGNAME} depends on file: $$prog - not found"; \
		fi;							\
	else								\
		for d in `${ECHO} $$PATH | tr ':' ' '`; do		\
			if [ -x $$d/$$prog ]; then			\
				found="$$d/$$prog";			\
				break;					\
			fi						\
		done;							\
		${ECHO_MSG} "===>  ${PKGNAME} depends on executable: $$prog - $$found found"; \
	fi;								\
	if [ X"$$found" = Xnot ]; then					\
		${ECHO_MSG} "===>  Verifying $$target for $$prog in $$dir"; \
		if [ ! -d "$$dir" ]; then				\
			${ECHO_MSG} ">> No directory for $$prog.  Skipping.."; \
		else							\
			(cd $$dir && ${MAKE} ${.MAKEFLAGS} $$target) &&	\
			${ECHO_MSG} "===>  Returning to build of ${PKGNAME}"; \
		fi;							\
	fi
.endfor
.endif
.else
	@${DO_NADA}
.endif

fetch-depends:	_DEPENDS_USE
build-depends:	_DEPENDS_USE
run-depends:	_DEPENDS_USE

misc-depends: uptodate-pkgtools
.if defined(DEPENDS)
.if !defined(NO_DEPENDS)
.for dep in ${DEPENDS}
	${_PKG_SILENT}${_PKG_DEBUG}package="`${ECHO} \"${dep}\" | ${SED} -e s/:.\*//`"; \
	dir="`${ECHO} \"${dep}\" | ${SED} -e s/.\*://`";		\
	found="`${PKG_INFO} -e \"$$package\" || ${TRUE}`";		\
	if [ X"$$found" != X"" ]; then					\
		${ECHO_MSG} "===>  ${PKGNAME} depends on installed package: $$package - `${ECHO} $$found | ${SED} -e 's|${PKG_DBDIR}/||g' | tr '\012' '\040'`found"; \
	else								\
		${ECHO_MSG} "===>  ${PKGNAME} depends on package: $$package"; \
		target=${DEPENDS_TARGET};				\
		${ECHO_MSG} "===>  Verifying $$target for $$dir"; 	\
		if [ ! -d $$dir ]; then					\
			${ECHO_MSG} ">> No directory for $$dir.  Skipping.."; \
		else							\
			(cd $$dir && ${MAKE} ${.MAKEFLAGS} $$target) &&	\
			${ECHO_MSG} "===>  Returning to build of ${PKGNAME}"; \
		fi;							\
	fi
.endfor
.endif	# !NO_DEPENDS
.else
	@${DO_NADA}
.endif	# DEPENDS

.endif

real-fetch: check-depends
.if !target(check-depends)
check-depends:
.if (defined(DEPENDS) || defined(BUILD_DEPENDS) || defined(RUN_DEPENDS)) && \
    !defined(NO_DEPENDS) && !defined(NO_CHECK_DEPENDS) && !exists(${EXTRACT_COOKIE})
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO_MSG} "===>  Validating dependencies for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} DEPENDS_TARGET=check-depends ECHO_MSG=${TRUE:Q} IGNORE_FAIL=1 _DEPENDS_TARGET_OVERRIDE=1 depends || \
		(${ECHO_MSG} "===>  ${PKGNAME} cannot build necessary dependencies."; ${FALSE})
.endif
.endif

.if !target(clean-depends)
clean-depends:
.if defined(BUILD_DEPENDS) || defined(DEPENDS) || defined(RUN_DEPENDS)
	@for dir in `${ECHO} ${BUILD_DEPENDS} ${DEPENDS} ${RUN_DEPENDS} | ${TR} '\040' '\012' | ${SED} -e 's/^[^:]*://' -e 's/:.*//' | sort -u`; do \
		if [ -d $$dir ] ; then					\
			(cd $$dir && ${MAKE} CLEANDEPENDS=${CLEANDEPENDS} clean ); \
		fi							\
	done
.endif
.endif

.if !target(depends-list)
depends-list:
.for dir in ${BUILD_DEPENDS} ${DEPENDS}
	@cd ${dir:C/^[^:]*://:C/:.*//} && ${MAKE} package-name depends-list PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}
.endfor
.endif

# If PACKAGES is set to the default (../../pkgsrc/packages), the current
# ${MACHINE_ARCH} and "release" (uname -r) will be used. Otherwise a directory
# structure of ...pkgsrc/packages/`uname -r`/${MACHINE_ARCH} is assumed.
# The PKG_URL is set from FTP_PKG_URL_* or CDROM_PKG_URL_*, depending on
# the target used to generate the README.html file.
.if !target(binpkg-list)
binpkg-list:
	@cd ${PACKAGES};						\
	case `/bin/pwd` in						\
	*/pkgsrc/packages)						\
		for pkg in ${PKGREPOSITORYSUBDIR}/${PKGNAME:C/-[^-]*$/-[0-9]*/}${PKG_SUFX} ; \
		do 							\
			if [ -f "$$pkg" ] ; then			\
				${ECHO} "<TR><TD> ${MACHINE_ARCH}: <TD><a href=\"${PKG_URL}/$$pkg\"> <TD>(${OPSYS} ${OS_VERSION}) </a>)"; \
			fi ;						\
		done ; 							\
		;;							\
	*)								\
		cd ${PACKAGES}/../..;					\
		for i in [1-9].*/*; do (				\
			d=$$i/${PKGREPOSITORYSUBDIR} ; 			\
			if [ -d "$$d" ]; then 				\
				cd "$$d" ; 				\
				for j in ${PKGNAME:C/-[^-]*$/-[0-9]*/}${PKG_SUFX} ;	\
				do 					\
					if [ -f "$$j" ] ; then		\
						${ECHO} $$i/$$j; 	\
					fi ;				\
				done ; 					\
			fi ) ; 						\
		done | ${AWK} -F/ '					\
			{						\
				release = $$1;				\
				arch = $$2; 				\
				pkg = $$3;				\
				gsub("\.tgz","", pkg);			\
				if (arch != "m68k") {			\
					if (arch in urls)		\
						urls[arch "/" pkg "/" release] = "<a href=\"${PKG_URL}/" release "/" arch "/${PKGREPOSITORYSUBDIR}/" pkg "${PKG_SUFX}\">" pkg "</a>, " urls[arch]; \
					else				\
						urls[arch "/" pkg "/" release] = "<a href=\"${PKG_URL}/" release "/" arch "/${PKGREPOSITORYSUBDIR}/" pkg "${PKG_SUFX}\">" pkg "</a> "; \
				}					\
			} 						\
			END { 						\
				for (av in urls) {			\
					split(av, ava, "/");		\
					arch=ava[1];			\
					pkg=ava[2];			\
					release=ava[3];			\
					print "<TR><TD><LI> " arch ": <TD>" urls[av] " <TD>(${OPSYS} " release ")"; \
				}					\
			} ' | sort					\
		;;							\
	esac
.endif

################################################################
# Everything after here are internal targets and really
# shouldn't be touched by anybody but the release engineers.
################################################################

# This target generates an index entry suitable for aggregation into
# a large index.  Format is:
#
# distribution-name|package-path|installation-prefix|comment| \
#  description-file|maintainer|categories|build deps|run deps|for arch
#
.if !target(describe)
describe:
	@${ECHO} -n "${PKGNAME}|${.CURDIR}|";				\
	${ECHO} -n "${PREFIX}|";					\
	if [ -f ${COMMENT} ]; then					\
		${ECHO} -n "`${CAT} ${COMMENT}`";			\
	else								\
		${ECHO} -n "** No Description";				\
	fi;								\
	if [ -f ${DESCR_SRC} ]; then					\
		${ECHO} -n "|${DESCR_SRC}";				\
	else								\
		${ECHO} -n "|/dev/null";				\
	fi;								\
	${ECHO} -n "|${MAINTAINER}|${CATEGORIES}|";			\
	case "A${BUILD_DEPENDS}B${DEPENDS}C" in	\
		ABC) ;;							\
		*) cd ${.CURDIR} && ${ECHO} -n `${MAKE} depends-list|sort -u`;; \
	esac;								\
	${ECHO} -n "|";							\
	case "A${RUN_DEPENDS}B${DEPENDS}C" in				\
		ABC) ;;							\
		*) cd ${.CURDIR} && ${ECHO} -n `${MAKE} package-depends PACKAGE_DEPENDS_WITH_PATTERNS=true|sort -u`;; \
	esac;								\
	${ECHO} -n "|";							\
	if [ "${ONLY_FOR_ARCHS}" = "" ]; then				\
		${ECHO} -n "any";					\
	else								\
		${ECHO} -n "${ONLY_FOR_ARCHS}";				\
	fi;								\
	${ECHO} -n "|";							\
	if [ "${NOT_FOR_OPSYS}" = "" ]; then				\
		${ECHO} -n "any";					\
	else								\
		${ECHO} -n "not ${NOT_FOR_OPSYS}";			\
	fi;								\
	${ECHO} ""
.endif

.if !target(readmes)
readmes:	readme
.endif

# This target is used to generate README.html files
.if !target(readme)
FTP_PKG_URL_HOST?=	ftp://ftp.netbsd.org
FTP_PKG_URL_DIR?=	/pub/NetBSD/packages

readme:
	@cd ${.CURDIR} && ${MAKE} README.html PKG_URL=${FTP_PKG_URL_HOST}${FTP_PKG_URL_DIR}
.endif

# This target is used to generate README.html files, very like "readme"
# However, a different target was used for ease of use.
.if !target(cdrom-readme)
CDROM_PKG_URL_HOST?=	file://localhost
CDROM_PKG_URL_DIR?=	/usr/pkgsrc/packages

cdrom-readme:
	@cd ${.CURDIR} && ${MAKE} README.html PKG_URL=${CDROM_PKG_URL_HOST}${CDROM_PKG_URL_DIR}
.endif

.if (${OPSYS} == "NetBSD")
README_NAME=	${TEMPLATES}/README.pkg
.elif (${OPSYS} == "SunOS")
README_NAME=	${TEMPLATES}/README.pkg
.else
README_NAME=	${TEMPLATES}/README.port
.endif

# set up the correct license information as a sed expression
.ifdef LICENSE
SED_LICENSE_EXPR=       -e 's|%%LICENSE%%|<p>Please note that this package has a ${LICENSE} license.</p>|'
.else
SED_LICENSE_EXPR=       -e 's|%%LICENSE%%||'
.endif

# set up the "more info URL" information as a sed expression
.ifdef HOMEPAGE
SED_HOMEPAGE_EXPR=       -e 's|%%HOMEPAGE%%|<p>This package has a home page at <a HREF="${HOMEPAGE}">${HOMEPAGE}</a>.</p>|'
.else
SED_HOMEPAGE_EXPR=       -e 's|%%HOMEPAGE%%||'
.endif

.PHONY: README.html
README.html: .PRECIOUS
	@${MAKE} depends-list PACKAGE_NAME_TYPE=html | sort -u >> $@.tmp1
	@[ -s $@.tmp1 ] || ${ECHO} "<I>(none)</I>" >> $@.tmp1
	@${MAKE} package-depends PACKAGE_NAME_TYPE=html | sort -u >> $@.tmp2
	@[ -s $@.tmp2 ] || ${ECHO} "<I>(none)</I>" >> $@.tmp2
	@${ECHO} ${PKGNAME} | ${HTMLIFY} >> $@.tmp3
	@${MAKE} binpkg-list  >> $@.tmp4
	@[ -s $@.tmp4 ] || ${ECHO} "<I>(no precompiled binaries available)</I>" >> $@.tmp4
	@${SED} -e 's|%%PORT%%|'"`${MAKE} package-path | ${HTMLIFY}`"'|g' \
		-e '/%%PKG%%/r $@.tmp3'					\
		-e '/%%PKG%%/d'						\
		${SED_LICENSE_EXPR}					\
		${SED_HOMEPAGE_EXPR}					\
		-e '/%%COMMENT%%/r ${PKGDIR}/COMMENT'			\
		-e '/%%COMMENT%%/d'					\
		-e '/%%BUILD_DEPENDS%%/r $@.tmp1'			\
		-e '/%%BUILD_DEPENDS%%/d'				\
		-e '/%%RUN_DEPENDS%%/r $@.tmp2'				\
		-e '/%%RUN_DEPENDS%%/d'					\
		-e '/%%BIN_PKGS%%/r $@.tmp4'				\
		-e '/%%BIN_PKGS%%/d'					\
		${README_NAME} >> $@.tmp
	@cmp -s $@.tmp $@ || 						\
		(${ECHO_MSG} "===>  Creating README.html for ${_THISDIR_}${PKGNAME}"; \
		${MV} -f $@.tmp $@)
	@${RM} -f $@.tmp $@.tmp1 $@.tmp2 $@.tmp3 $@.tmp4 $@.tmp5

.if !target(show-pkgtools-version)
show-pkgtools-version:
.if !exists(${IDENT})
	@echo ${PKGTOOLS_REQD}
.else
	@${IDENT} ${PKG_CREATE} ${PKG_DELETE} ${PKG_INFO} ${PKG_ADD} | ${AWK} '$$1 ~ /\$$NetBSD/ && $$2 !~ /^crt0/ { gsub("/", "", $$4); print $$4 }' | sort | ${TAIL} -n 1
.endif
.endif

# convenience target, to display make variables from command line
# i.e. "make show-var VARNAME=var", will print var's value
show-var:
	@${ECHO} "${${VARNAME}}"

.if !target(print-depends-list)
print-depends-list:
.if defined(BUILD_DEPENDS) || defined(DEPENDS)
	@${ECHO} -n 'This package requires package(s) "'
	@${ECHO} -n `${MAKE} depends-list | sort -u`
	@${ECHO} '" to build.'
.endif
.endif

.if !target(print-package-depends)
print-package-depends:
.if defined(RUN_DEPENDS) || defined(DEPENDS)
	@${ECHO} -n 'This package requires package(s) "'
	@${ECHO} -n "`${MAKE} package-depends | sort -u`"
	@${ECHO} '" to run.'
.endif
.endif


# Stat all the files of a pkg and sum the sizes up. If SIZEDEPENDS is
# set, also sum up all depending packages, giving a rough overview of
# what this package really needs to run. (When installed alone - 
# intersection of dependencies with other pkgs may result in less
# diskspace usage)
# 
# XXX This is intended to be run before pkg_create is called, so the
# existance of ${PLIST} can be assumed as granted.
print-pkg-size:
	@(								\
	${SHCOMMENT} "This pkg's files" ;				\
	${SED} -n							\
		-e 's,^[^@],${PREFIX}/&,'				\
		-e '/^\//p'						\
		<${PLIST} ;						\
	${SHCOMMENT} "Any depending pkgs' files" ;			\
	if [ "${SIZEDEPENDS}" != "" ]; then				\
		for p in ${DEPENDS:C/:.*//} ; do			\
			${SHCOMMENT} direct depends ;			\
			pkg_info -qL "$$p" ;				\
			${SHCOMMENT} "depends of depends (XXX complete!)"; \
			dps=`pkg_info -qf "$$p" | grep '@pkgdep' | awk '{ print $$2; }'` ; \
			for dp in $$dps ; do				\
				pkg_info -qL "$$dp" ;			\
			done ;						\
		done ;							\
	fi ;							 	\
	)								\
	| sort -u							\
	| xargs ls -ld							\
	| awk 'BEGIN { sum=0; }						\
	       { sum+=$$5; }						\
	       END { print sum; }'


# Fake installation of package so that user can pkg_delete it later.
# Also, make sure that an installed package is recognized correctly in
# accordance to the @pkgdep directive in the packing lists

.if !target(fake-pkg)
fake-pkg: ${PLIST} ${DESCR}
	${_PKG_SILENT}${_PKG_DEBUG}if [ ! -f ${PLIST} -o ! -f ${COMMENT} -o ! -f ${DESCR} ]; then \
		${ECHO} "** Missing package files for ${PKGNAME} - installation not recorded."; \
		exit 1;							\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}if [ ! -d ${PKG_DBDIR} ]; then	\
		${RM} -f ${PKG_DBDIR};					\
		${MKDIR} ${PKG_DBDIR};					\
	fi
.if defined(FORCE_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}${PKG_DELETE} -O ${PKGNAME}
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -rf ${PKG_DBDIR}/${PKGNAME}
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${BUILD_VERSION_FILE} ${BUILD_INFO_FILE}
.if ${PKGTOOLS_REQD} > 19990909
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${SIZE_PKG_FILE} ${SIZE_ALL_FILE}
.endif # ${PKGTOOLS_REQD} > 19990909
	${_PKG_SILENT}${_PKG_DEBUG}files="";				\
	for f in ${.CURDIR}/Makefile ${FILESDIR}/* ${PKGDIR}/*; do	\
		if [ -f $$f ]; then					\
			files="$$files $$f";				\
		fi;							\
	done;								\
	if [ -f ${PATCH_SUM_FILE} ]; then				\
		for f in `${AWK} '$$1 == "MD5" { gsub("[()]", "", $$2); print $$2 }' < ${PATCH_SUM_FILE}`; do \
			if [ -f $$f ]; then				\
				files="$$files ${PATCHDIR}/$$f";	\
			fi;						\
		done;							\
	fi;								\
	if [ -d ${PATCHDIR} ]; then					\
		for f in ${PATCHDIR}/patch-*; do			\
			case $$f in					\
			*.orig|*.rej|*~) ;;				\
			${PATCHDIR}/patch-local-*)			\
				files="$$files $$f" ;;			\
			esac;						\
		done;							\
	fi;								\
	pkgsrcdir=`(cd ../.. && /bin/pwd)`;				\
	${GREP} '\$$NetBSD' $$files | ${SED} -e 's|^'$$pkgsrcdir'/||' > ${BUILD_VERSION_FILE};
.for def in ${BUILD_DEFS}
	@${ECHO} "${def}=	${${def}}" | ${SED} -e 's|PATH=[^ 	]*|PATH=...|' >> ${BUILD_INFO_FILE}
.endfor
	@${ECHO} "CC=	${CC}-`${CC} --version`" >> ${BUILD_INFO_FILE}
.ifdef USE_PERL5
	@${ECHO} "PERL=	`${LOCALBASE}/bin/perl --version | ${GREP} version`" >> ${BUILD_INFO_FILE}
.endif
.ifdef USE_GMAKE
	@${ECHO} "GMAKE=	`${GMAKE} --version | ${GREP} version`" >> ${BUILD_INFO_FILE}
.endif
	@${ECHO} "_PKGTOOLS_VER= `${MAKE} show-pkgtools-version`" >> ${BUILD_INFO_FILE}
.if ${PKGTOOLS_REQD} > 19990909
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} print-pkg-size                       >${SIZE_PKG_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} print-pkg-size SIZEDEPENDS=yesplease >${SIZE_ALL_FILE}
.endif # ${PKGTOOLS_REQD} > 19990909
	${_PKG_SILENT}${_PKG_DEBUG}if [ ! -d ${PKG_DBDIR}/${PKGNAME} ]; then			\
		${ECHO_MSG} "===>  Registering installation for ${PKGNAME}"; \
		${MKDIR} ${PKG_DBDIR}/${PKGNAME};			\
		${PKG_CREATE} ${PKG_ARGS} -O ${PKGFILE} > ${PKG_DBDIR}/${PKGNAME}/+CONTENTS; \
		${CP} ${DESCR} ${PKG_DBDIR}/${PKGNAME}/+DESC;		\
		${CP} ${COMMENT} ${PKG_DBDIR}/${PKGNAME}/+COMMENT;	\
		${CP} ${BUILD_VERSION_FILE} ${PKG_DBDIR}/${PKGNAME}/+BUILD_VERSION; \
		${CP} ${BUILD_INFO_FILE} ${PKG_DBDIR}/${PKGNAME}/+BUILD_INFO; \
		if ${TEST} -e ${SIZE_PKG_FILE}; then \
			${CP} ${SIZE_PKG_FILE} ${PKG_DBDIR}/${PKGNAME}/+SIZE_PKG; \
		fi ; \
		if ${TEST} -e ${SIZE_ALL_FILE}; then \
			${CP} ${SIZE_ALL_FILE} ${PKG_DBDIR}/${PKGNAME}/+SIZE_ALL; \
		fi ; \
		if [ -n "${INSTALL_FILE}" ]; then			\
			if ${TEST} -e ${INSTALL_FILE}; then		\
				${CP} ${INSTALL_FILE} ${PKG_DBDIR}/${PKGNAME}/+INSTALL; \
			fi;						\
		fi;							\
		if [ -n "${DEINSTALL_FILE}" ]; then			\
			if ${TEST} -e ${DEINSTALL_FILE}; then		\
				${CP} ${DEINSTALL_FILE} ${PKG_DBDIR}/${PKGNAME}/+DEINSTALL; \
			fi;						\
		fi;							\
		if [ -n "${REQ_FILE}" ]; then				\
			if ${TEST} -e ${REQ_FILE}; then			\
				${CP} ${REQ_FILE} ${PKG_DBDIR}/${PKGNAME}/+REQUIRE; \
			fi;						\
		fi;							\
		if [ -n "${MESSAGE_FILE}" ]; then			\
			if ${TEST} -e ${MESSAGE_FILE}; then		\
				${CP} ${MESSAGE_FILE} ${PKG_DBDIR}/${PKGNAME}/+DISPLAY; \
			fi;						\
		fi;							\
		for dep in `${MAKE} package-depends PACKAGE_DEPENDS_WITH_PATTERNS=true ECHO_MSG=${TRUE} | sort -u`; do \
			realdep="`${PKG_INFO} -e \"$$dep\" || ${TRUE}`" ; \
			${ECHO} "a sanity check should be put in here to prevent some user having the pkg installed/registered twice somehow - HF" >/dev/null ; \
			if ${TEST} -z $$realdep; then			\
				${ECHO} "$$dep not installed - NOT registered" ; \
			elif [ -d ${PKG_DBDIR}/$$realdep ]; then	\
				if ${TEST} ! -e ${PKG_DBDIR}/$$realdep/+REQUIRED_BY; then \
					${TOUCH} ${PKG_DBDIR}/$$realdep/+REQUIRED_BY; \
				fi; 					\
				${AWK} 'BEGIN { found = 0; } 		\
					$$0 == "${PKGNAME}" { found = 1; } \
					{ print $$0; } 			\
					END { if (!found) { printf("%s\n", "${PKGNAME}"); }}' \
					< ${PKG_DBDIR}/$$realdep/+REQUIRED_BY > ${PKG_DBDIR}/$$realdep/reqby.$$$$; \
				${MV} ${PKG_DBDIR}/$$realdep/reqby.$$$$ ${PKG_DBDIR}/$$realdep/+REQUIRED_BY; \
				${ECHO} "${PKGNAME} requires installed package $$realdep"; \
			fi;						\
		done;							\
	fi
.endif

# Depend is generally meaningless for arbitrary packages, but if someone wants
# one they can override this.  This is just to catch people who've gotten into
# the habit of typing `${MAKE} depend all install' as a matter of course.
#
.if !target(depend)
depend:
.endif

# Same goes for tags
.if !target(tags)
tags:
.endif

# if automatic manual page compression is done by the package according
# to MANZ's value, set MANCOMPRESSED if MANZ is set
.if defined(MANCOMPRESSED_IF_MANZ) && defined(MANZ)
MANCOMPRESSED=	yes
.endif

# generate ${PLIST} from ${PLIST_SRC} by:
# - fixing list of man-pages according to MANCOMPRESSED/MANZ
#   (we don't take any notice of MANCOMPRESSED as many packages have .gz
#   pages in PLIST even when they install manpages without compressing them)
# - substituting by ${PLIST_SUBST}

.if ${OPSYS} == "NetBSD"
IMAKE_MAN_CMD=
.ifdef MANZ
MANZ_EXPRESSION= -e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}man[1-9ln]/.*[1-9ln]$$\)|\1.gz|' \
		-e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}cat[1-9ln]/.*[0-9ln]$$\)|\1.gz|'
.else
MANZ_EXPRESSION= -e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}man[1-9ln]/.*[1-9ln]\)\.gz$$|\1|' \
		-e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}cat[1-9ln]/.*[0-9ln]\)\.gz$$|\1|'
.endif # MANZ
MANZ_NAWK_CMD=
.elif ${OPSYS} == "SunOS"
.ifdef USE_IMAKE
IMAKE_MAN_CMD=	${AWK} '/^([^\/]*\/)*man\/([^\/]*\/)?cat[1-9ln]\/.*[0-9ln](\.gz)?$$/ { \
	sect = $$0; n = match(sect, "/cat[1-9ln]");			\
	sect = sprintf(".%sx", substr(sect, n + 4, 1));			\
	s = $$0; sub("/cat", "/man", s); sub("\.0(\.gz)?$$", sect, s);	\
	if (match($$0, "\.gz$$") > 0) { ext = ".gz";} else { ext = "";} \
	$$0 = sprintf("%s%s", s, ext);					\
	} { print $$0; }' |
.else
IMAKE_MAN_CMD=
.endif # USE_IMAKE
.ifdef MANZ
MANZ_NAWK_CMD=	${AWK} '/^([^\/]*\/)*man\/([^\/]*\/)?man[1-9ln]\/.*[1-9ln]\.gz$$/ { \
		$$0 = sprintf("%s.gz", $$0);				\
	}								\
	/^([^\/]*\/)*man\/([^\/]*\/)?cat[1-9ln]\/.*[0-9ln]\.gz$$/ {	\
		$$0 = sprintf("%s.gz", $$0);				\
	}								\
	{ print $$0; }' |
.else
MANZ_NAWK_CMD=	${AWK} '/^([^\/]*\/)*man\/([^\/]*\/)?man[1-9ln]\/.*[1-9ln]\.gz$$/ { \
		$$0 = substr($$0, 1, length($$0) - 3);			\
	}								\
	/^([^\/]*\/)*man\/([^\/]*\/)?cat[1-9ln]\/.*[0-9ln]\.gz$$/ {	\
		$$0 = substr($$0, 1, length($$0) - 3);			\
	}								\
	{ print $$0; }' |
.endif # MANZ
MANZ_EXPRESSION= 
.endif # SunOS

${PLIST}: ${PLIST_SRC}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -z "${PLIST_SRC}" ]; then					\
		${ECHO} "No ${PKGDIR}/PLIST or ${PKGDIR}/PLIST-{mi,md.shared,md.static}" ; \
		${ECHO} "Please set PLIST_SRC in the package Makefile.";\
	else								\
		${CAT} ${PLIST_SRC} |					\
			${MANZ_NAWK_CMD} 				\
			${IMAKE_MAN_CMD} 				\
			${SED} 	${MANZ_EXPRESSION}			\
				${PLIST_SUBST:S/=/}!/:S/$/!g/:S/^/ -e s!\\\${/}\
			> ${PLIST}; 					\
	fi

# generate ${DESCR} from ${DESCR_SRC} by:
# - Appending the homepage URL, if any

${DESCR}: ${DESCR_SRC}
	@${CAT} ${DESCR_SRC} > ${DESCR}
.if defined(HOMEPAGE)
	@(${ECHO} ; ${ECHO} "Homepage:" ; \
	${ECHO} '${HOMEPAGE}') >> ${DESCR}	
.endif
