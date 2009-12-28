#	$NetBSD: gnustep.mk,v 1.20 2009/12/28 10:49:23 obache Exp $

.if !defined(GNUSTEP_MK)
GNUSTEP_MK=		#defined

.include "../../mk/bsd.prefs.mk"

GNUSTEP_SUBDIR=		share/GNUstep
GNUSTEP_ROOT=		${PREFIX}
GNUSTEP_LIB_DIR=	${GNUSTEP_ROOT}/lib/GNUstep
GNUSTEP_SYSTEM_ROOT=	${GNUSTEP_ROOT}/System
GNUSTEP_LOCAL_ROOT=	${GNUSTEP_ROOT}/Local
GNUSTEP_NETWORK_ROOT=	${GNUSTEP_ROOT}/Network
GNUSTEP_MAKEFILES=	${GNUSTEP_ROOT}/${GNUSTEP_SUBDIR}/Makefiles
GNUSTEP_HOST=		${MACHINE_GNU_PLATFORM}
GNUSTEP_HOST_CPU=	${MACHINE_GNU_ARCH:S/i386/ix86/}
GNUSTEP_HOST_VENDOR=	${LOWER_VENDOR}
GNUSTEP_HOST_OS=	${LOWER_OPSYS}
GNUSTEP_CONFIG_FILE=	${PKG_SYSCONFDIR}/GNUstep.conf

GNUSTEP_FLATTENED=	yes
GNUSTEP_IS_FLATTENED=	yes

REAL_GNUSTEP_USER_ROOT=	${PREFIX}/share/GNUstep
GNUSTEP_USER_ROOT=	${BUILDLINK_DIR}/share/GNUstep
GNUSTEP_PATHLIST=	${GNUSTEP_USER_ROOT}
GNUSTEP_PATH=		${GNUSTEP_USER_ROOT}/Tools:${GNUSTEP_USER_ROOT}/Tools/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS}
GUILE_LOAD_PATH=	${GNUSTEP_USER_ROOT}/Libraries/Guile:${GNUSTEP_USER_ROOT}/lib
GNUSTEP_LDIR=		lib
GNUSTEP_IDIR=		include
GNUSTEP_LFLAGS=		${GNUSTEP_ROOT:S/^/-L/}/${GNUSTEP_LDIR} ${REAL_GNUSTEP_USER_ROOT:S/^/-L/}/${GNUSTEP_LDIR}
GNUSTEP_IFLAGS=		${GNUSTEP_ROOT:S/^/-I/}/${GNUSTEP_IDIR} ${REAL_GNUSTEP_USER_ROOT:S/^/-I/}/${GNUSTEP_IDIR}
GNUSTEP_LDIRS=		${GNUSTEP_LFLAGS:S/-L//g}
GNUSTEP_IDIRS=		${GNUSTEP_IFLAGS:S/-I//g}
GNUSTEP_BLDIRS=		${GNUSTEP_LDIRS:S/${PREFIX}\///g}
GNUSTEP_BIDIRS=		${GNUSTEP_IDIRS:S/${PREFIX}\///g}
.if !empty(_USE_RPATH:M[yY][eE][sS])
GNUSTEP_RFLAGS=		${GNUSTEP_LFLAGS:S/-L/${COMPILER_RPATH_FLAG}/g}
.else
GNUSTEP_RFLAGS?=
.endif
GNUSTEP_LDFLAGS=	${GNUSTEP_LFLAGS} ${GNUSTEP_RFLAGS}

.if defined(FIX_GNUSTEP_INSTALLATION_DIR)
SUBST_CLASSES+=				gnustep_installation_dir
SUBST_STAGE.gnustep_installation_dir=	post-patch
SUBST_FILES.gnustep_installation_dir?=	GNUmakefile
SUBST_SED.gnustep_installation_dir+=	-e 's|GNUSTEP_INSTALLATION_DIR.*=.*..GNUSTEP_\(.*\)_ROOT.*|GNUSTEP_INSTALLATION_DOMAIN = \1|'
SUBST_SED.gnustep_installation_dir+=	-e 's|\$$(GNUSTEP_INSTALLATION_DIR)/Libraries|$${DESTDIR}${GNUSTEP_LIB_DIR}/Libraries/${PKGNAME_NOREV}|g'
SUBST_SED.gnustep_installation_dir+=	-e 's|\$$(GNUSTEP_INSTALLATION_DIR)/Library/Bundles|$${DESTDIR}${GNUSTEP_LIB_DIR}/Bundles|g'
SUBST_SED.gnustep_installation_dir+=	-e 's|\$$(GNUSTEP_INSTALLATION_DIR)/Library|$${DESTDIR}${GNUSTEP_ROOT}/${GNUSTEP_SUBDIR}/Library|g'
SUBST_SED.gnustep_installation_dir+=	-e 's|\$$(GNUSTEP_USER_ROOT)/Library|$${DESTDIR}${GNUSTEP_USER_ROOT}/${GNUSTEP_SUBDIR}/Library|g'
SUBST_SED.gnustep_installation_dir+=	-e 's|\$$(GNUSTEP_LOCAL_ROOT)/Library|$${DESTDIR}${GNUSTEP_LOCAL_ROOT}/${GNUSTEP_SUBDIR}/Library|g'
SUBST_SED.gnustep_installation_dir+=	-e 's|\$$(GNUSTEP_NETWORK_ROOT)/Library|$${DESTDIR}${GNUSTEP_NETWORK_ROOT}/${GNUSTEP_SUBDIR}/Library|g'
SUBST_SED.gnustep_installation_dir+=	-e 's|INSTALL_ROOT_DIR|DESTDIR|g'
.endif

GNUSTEP_FAKE_PRIVILEGED_BUILD?=	YES

.if !empty(GNUSTEP_FAKE_PRIVILEGED_BUILD:M[yY][eE][sS])
post-wrapper: create-gnustep-chown-links

create-gnustep-chown-links:
	${RUN}${ECHO}  > ${BUILDLINK_BINDIR}/chown '#!${SH:Q}'
	${RUN}${ECHO} >> ${BUILDLINK_BINDIR}/chown '${CHOWN:Q} "$$@" 2>/dev/null || \'
	${RUN}${ECHO} >> ${BUILDLINK_BINDIR}/chown '${TRUE}'
	${RUN}${ECHO}  > ${BUILDLINK_BINDIR}/chgrp '#!${SH:Q}'
	${RUN}${ECHO} >> ${BUILDLINK_BINDIR}/chgrp '${CHGRP:Q} "$$@" 2>/dev/null || \'
	${RUN}${ECHO} >> ${BUILDLINK_BINDIR}/chgrp '${TRUE}'
	${RUN}${ECHO}  > ${BUILDLINK_BINDIR}/install '#!${SH:Q}'
	${RUN}${ECHO} >> ${BUILDLINK_BINDIR}/install '${INSTALL:Q} "$$@" 2>/dev/null || \'
	${RUN}${ECHO} >> ${BUILDLINK_BINDIR}/install '${INSTALL:Q} `${ECHO} "$$@" | \
		${SED} -e "s/-[og][ 	]*[^ 	]*//g"`'
	${RUN}${CHMOD} +x ${BUILDLINK_BINDIR}/chown
	${RUN}${CHMOD} +x ${BUILDLINK_BINDIR}/chgrp
	${RUN}${CHMOD} +x ${BUILDLINK_BINDIR}/install

GNUSTEP_INSTALL=	${BUILDLINK_BINDIR}/install
GNUSTEP_INSTALL_DATA=	${INSTALL_DATA:S/${INSTALL}/${GNUSTEP_INSTALL}/}
GNUSTEP_INSTALL_PROGRAM=${INSTALL_PROGRAM:S/${INSTALL}/${GNUSTEP_INSTALL}/}
.else
GNUSTEP_INSTALL=	${INSTALL}
GNUSTEP_INSTALL_DATA=	${INSTALL_DATA}
GNUSTEP_INSTALL_PROGRAM=${INSTALL_PROGRAM}
.endif

GNUSTEP_OVERRIDE_INSTALL?=	YES

.if !empty(GNUSTEP_OVERRIDE_INSTALL:M[yY][eE][sS])
MAKE_ENV+=	INSTALL=${GNUSTEP_INSTALL:Q}
MAKE_ENV+=	INSTALL_DATA=${GNUSTEP_INSTALL_DATA:Q}
MAKE_ENV+=	INSTALL_PROGRAM=${GNUSTEP_INSTALL_PROGRAM:Q}
.endif

.if !defined(NO_GNUSTEP_ENV)

PATH:=		${GNUSTEP_PATH}:${PATH}

LDFLAGS+=	${GNUSTEP_LDFLAGS}
CPPFLAGS+=	${GNUSTEP_IFLAGS}
CFLAGS+=	${GNUSTEP_IFLAGS}

USE_TOOLS+=	gmake
.  if defined(GNUSTEP_MAKEFILE)
MAKE_FILE=	${GNUSTEP_MAKEFILE}
.  else
MAKE_FILE=	GNUmakefile
.  endif

.  if !defined(NO_CONFIGURE) && !defined(HAS_CONFIGURE)
GNU_CONFIGURE=	yes
.  endif

MAKE_ENV+=	GNUSTEP_ROOT=${GNUSTEP_ROOT:Q}
MAKE_ENV+=	GNUSTEP_MAKEFILES=${GNUSTEP_MAKEFILES:Q}
MAKE_ENV+=	GNUSTEP_HOST=${GNUSTEP_HOST:Q}
MAKE_ENV+=	GNUSTEP_HOST_CPU=${GNUSTEP_HOST_CPU:Q}
MAKE_ENV+=	GNUSTEP_HOST_VENDOR=${GNUSTEP_HOST_VENDOR:Q}
MAKE_ENV+=	GNUSTEP_HOST_OS=${GNUSTEP_HOST_OS:Q}
MAKE_ENV+=	GNUSTEP_PATHLIST=${GNUSTEP_PATHLIST:Q}
MAKE_ENV+=	GNUSTEP_FLATTENED=${GNUSTEP_FLATTENED:Q}
MAKE_ENV+=	GNUSTEP_IS_FLATTENED=${GNUSTEP_IS_FLATTENED:Q}
MAKE_ENV+=	GNUSTEP_USER_ROOT=${GNUSTEP_USER_ROOT:Q}
MAKE_ENV+=	GNUSTEP_CONFIG_FILE=${GNUSTEP_CONFIG_FILE:Q}

.  if defined(GNUSTEP_OBSOLETE_ENV)
MAKE_ENV+=	GNUSTEP_SYSTEM_ROOT=${GNUSTEP_SYSTEM_ROOT:Q}
MAKE_ENV+=	GNUSTEP_LOCAL_ROOT=${GNUSTEP_LOCAL_ROOT:Q}
MAKE_ENV+=	GNUSTEP_NETWORK_ROOT=${GNUSTEP_NETWORK_ROOT:Q}
MAKE_ENV+=	GUILE_LOAD_PATH=${GUILE_LOAD_PATH:Q}
.  endif	# GNUSTEP_OBSOLETE_ENV

.  if defined(GNU_CONFIGURE) || defined(HAS_CONFIGURE)
GNU_CONFIGURE_PREFIX?=	${GNUSTEP_ROOT}
CONFIGURE_ENV+=	GNUSTEP_ROOT=${GNUSTEP_ROOT:Q}
CONFIGURE_ENV+=	GNUSTEP_MAKEFILES=${GNUSTEP_MAKEFILES:Q}
CONFIGURE_ENV+=	GNUSTEP_HOST=${GNUSTEP_HOST:Q}
CONFIGURE_ENV+=	GNUSTEP_HOST_CPU=${GNUSTEP_HOST_CPU:Q}
CONFIGURE_ENV+=	GNUSTEP_HOST_VENDOR=${GNUSTEP_HOST_VENDOR:Q}
CONFIGURE_ENV+=	GNUSTEP_HOST_OS=${GNUSTEP_HOST_OS:Q}
CONFIGURE_ENV+=	GNUSTEP_PATHLIST=${GNUSTEP_PATHLIST:Q}
CONFIGURE_ENV+=	GNUSTEP_FLATTENED=${GNUSTEP_FLATTENED:Q}
CONFIGURE_ENV+=	GNUSTEP_IS_FLATTENED=${GNUSTEP_IS_FLATTENED:Q}
CONFIGURE_ENV+=	GNUSTEP_USER_ROOT=${GNUSTEP_USER_ROOT:Q}
CONFIGURE_ENV+=	GNUSTEP_CONFIG_FILE=${GNUSTEP_CONFIG_FILE:Q}

.    if defined(GNUSTEP_OBSOLETE_ENV)
CONFIGURE_ENV+=	GNUSTEP_SYSTEM_ROOT=${GNUSTEP_SYSTEM_ROOT:Q}
CONFIGURE_ENV+=	GNUSTEP_LOCAL_ROOT=${GNUSTEP_LOCAL_ROOT:Q}
CONFIGURE_ENV+=	GNUSTEP_NETWORK_ROOT=${GNUSTEP_NETWORK_ROOT:Q}
CONFIGURE_ENV+=	GUILE_LOAD_PATH=${GUILE_LOAD_PATH:Q}
.    endif	# GNUSTEP_OBSOLETE_ENV
.  endif	# GNU_CONFIGURE
.endif	# !NO_GNUSTEP_ENV

.endif	# !defined(GNUSTEP_MK)
