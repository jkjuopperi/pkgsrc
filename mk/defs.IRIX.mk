# $NetBSD: defs.IRIX.mk,v 1.24 2003/04/15 05:29:47 grant Exp $
#
# Variable definitions for the IRIX operating system.

AWK?=		/usr/bin/awk
BASENAME?=	/sbin/basename
CAT?=		/sbin/cat
CHMOD?=		/sbin/chmod
CHOWN?=		/sbin/chown
CHGRP?=		/sbin/chgrp
CMP?=		/usr/bin/cmp
CP?=		/sbin/cp
CUT?=		/usr/bin/cut
DATE?=		/sbin/date
DC?=		/usr/bin/dc
DIRNAME?=	/usr/bin/dirname
ECHO?=		/sbin/echo
EGREP?=		/bin/grep
EXPR?=		/bin/expr
FALSE?=		/usr/bin/false
FGREP?=		/usr/bin/fgrep
FILE_CMD?=	/usr/bin/file
FIND?=		/sbin/find
.if exists(${LOCALBASE}/bin/gmake)
GMAKE?=		${LOCALBASE}/bin/gmake
.endif
GREP?=		/sbin/grep
.if exists(${LOCALBASE}/bin/tar)
GTAR?=		${LOCALBASE}/bin/tar
.else
GTAR?=		/sbin/tar
.endif
.if exists(${LOCALBASE}/bin/gzip)
GUNZIP_CMD?=	${LOCALBASE}/bin/gunzip -f
GZCAT?=		${LOCALBASE}/bin/zcat
GZIP?=		-9
GZIP_CMD?=	${LOCALBASE}/bin/gzip -nf ${GZIP}
.endif
LDCONFIG?=	/usr/bin/true
HEAD?=		/usr/bsd/head
HOSTNAME_CMD?=	/usr/bsd/hostname
ID?=		/usr/bin/id
LN?=		/sbin/ln
LS?=		/sbin/ls
M4?=		/usr/bin/m4
MKDIR?=		/sbin/mkdir -p
.if exists(${LOCALBASE}/sbin/mtree)
MTREE?=		${LOCALBASE}/sbin/mtree
.endif
MTREE?=		${LOCALBASE}/bin/mtree
MV?=		/sbin/mv
NICE?=		/sbin/nice
PATCH?=		/usr/sbin/patch -b
PAX?=		${LOCALBASE}/bin/pax
PERL5?=		${LOCALBASE}/bin/perl
PKGLOCALEDIR?=	share
PS?=		/sbin/ps
PWD_CMD?=	/bin/pwd	# needs to print physical path
RM?=		/sbin/rm
RMDIR?=		/usr/bin/rmdir
SED?=		/sbin/sed
SETENV?=	/sbin/env
SH?=		/bin/ksh
SHLOCK=		${LOCALBASE}/bin/shlock
SORT?=		/usr/bin/sort
SU?=		/sbin/su
TAIL?=		/usr/bin/tail
TEE?=		/usr/bin/tee
TEST?=		/sbin/test
TOUCH?=		/usr/bin/touch
TR?=		/usr/bin/tr
TRUE?=		/usr/bin/true
TSORT?=		/usr/bin/tsort
TYPE?=		/sbin/type
WC?=		/usr/bin/wc
XARGS?=		/sbin/xargs

CPP_PRECOMP_FLAGS?=	# unset
DEF_UMASK?=		022
DEFAULT_SERIAL_DEVICE?=	/dev/null
EXPORT_SYMBOLS_LDFLAGS?=		# Don't add symbols to the dynamic symbol table
GROUPADD?=		${FALSE}
MOTIF_TYPE_DEFAULT?=	dt		# default 2.0 compatible libs type
MOTIF12_TYPE_DEFAULT?=	dt		# default 1.2 compatible libs type
NOLOGIN?=		${FALSE}
ROOT_CMD?=		${SU} - root -c
ROOT_GROUP?=		sys
ROOT_USER?=		root
SERIAL_DEVICES?=	/dev/null
ULIMIT_CMD_datasize?=	ulimit -d `ulimit -H -d`
ULIMIT_CMD_stacksize?=	ulimit -s `ulimit -H -s`
ULIMIT_CMD_memorysize?=	ulimit -v `ulimit -H -v`
USERADD?=		${FALSE}

# imake installs manpages in weird places
# XXX: assume NetBSD defaults until somebody determines correct values
IMAKE_MAN_SOURCE_PATH=	man/cat
IMAKE_MAN_SUFFIX=	1
IMAKE_LIBMAN_SUFFIX=	3
IMAKE_FILEMAN_SUFFIX=	5
IMAKE_MAN_DIR=		${IMAKE_MAN_SOURCE_PATH}1
IMAKE_LIBMAN_DIR=	${IMAKE_MAN_SOURCE_PATH}3
IMAKE_FILEMAN_DIR=	${IMAKE_MAN_SOURCE_PATH}5
IMAKE_MANNEWSUFFIX=	0

_DO_SHLIB_CHECKS=	yes		# fixup PLIST for shared libs
_IMAKE_MAKE=		${MAKE}		# program which gets invoked by imake
_OPSYS_HAS_GMAKE=	no		# GNU make is not standard
.if exists(/usr/include/netinet6)
_OPSYS_HAS_INET6=	yes		# IPv6 is standard
.else
_OPSYS_HAS_INET6=	no		# IPv6 is not standard
.endif
_OPSYS_HAS_JAVA=	no		# Java is not standard
_OPSYS_HAS_MANZ=	no		# no MANZ for gzipping of man pages
_OPSYS_HAS_OSSAUDIO=	no		# libossaudio is available
_OPSYS_LIBTOOL_REQD=    1.4.20010614nb14 # base version of libtool required
_OPSYS_PERL_REQD=			# no base version of perl required
_OPSYS_RPATH_NAME=	-rpath,		# name of symbol in rpath directive to linker 
_PATCH_CAN_BACKUP=	no		# native patch(1) can make backups
_PREFORMATTED_MAN_DIR=	man		# directory where catman pages are
_USE_GNU_GETTEXT=	no		# Don't use GNU gettext
_USE_RPATH=		yes		# add rpath to LDFLAGS

# flags passed to the linker to extract all symbols from static archives.
# XXX values for IRIX absent!
#_OPSYS_WHOLE_ARCHIVE_FLAG=	-Wl,--whole-archive
#_OPSYS_NO_WHOLE_ARCHIVE_FLAG=	-Wl,--no-whole-archive

.if !defined(DEBUG_FLAGS)
_STRIPFLAG_CC?=		-s	# cc(1) option to strip
_STRIPFLAG_INSTALL?=	-s	# install(1) option to strip
.endif

LOCALBASE?=             ${DESTDIR}/usr/pkg
.if exists(${LOCALBASE}/sbin/pkg_info)
PKG_TOOLS_BIN?=		${LOCALBASE}/sbin
.endif
PKG_TOOLS_BIN?=		${LOCALBASE}/bin
