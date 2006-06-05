# $NetBSD: depends.mk,v 1.3 2006/06/05 22:49:44 jlam Exp $

_DEPENDS_FILE=		${WRKDIR}/.depends
_REDUCE_DEPENDS_CMD=	${SETENV} CAT=${CAT:Q}				\
				PKG_ADMIN=${PKG_ADMIN_CMD:Q}		\
				PWD_CMD=${PWD_CMD:Q} TEST=${TEST:Q}	\
			${AWK} -f ${PKGSRCDIR}/mk/flavor/pkg/reduce-depends.awk

# This command prints out the dependency patterns for all full (run-time)
# dependencies of the package.
#
_DEPENDS_PATTERNS_CMD=	\
	if ${TEST} -f ${_DEPENDS_COOKIE}; then				\
		${CAT} ${_DEPENDS_COOKIE} |				\
		${AWK} '/^full/ { print $$2 } { next }';		\
	fi

.PHONY: show-depends
show-depends:
	@case ${VARNAME:Q}"" in						\
	BUILD_DEPENDS)	${_REDUCE_DEPENDS_CMD} ${BUILD_DEPENDS:Q} ;;	\
	DEPENDS|*)	${_REDUCE_DEPENDS_CMD} ${DEPENDS:Q} ;;		\
	esac

######################################################################
### depends-cookie (PRIVATE, pkgsrc/mk/depends/bsd.depends.mk)
######################################################################
### depends-cookie creates the "depends" cookie file.
###
### The "depends" cookie file contains all of the dependency information
### for the package.  The format of each line of the cookie file is:
###
###    <depends_type>	<pattern>	<directory>
###
### Valid dependency types are "build" and "full".
###
.PHONY: depends-cookie
depends-cookie: ${_DEPENDS_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}${MV} -f ${_DEPENDS_FILE} ${_DEPENDS_COOKIE}

${_DEPENDS_FILE}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_ARGS} ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${_REDUCE_DEPENDS_CMD} ${BUILD_DEPENDS:Q} |			\
	while read dep; do						\
		pattern=`${ECHO} $$dep | ${SED} -e "s,:.*,,"`;		\
		dir=`${ECHO} $$dep | ${SED} -e "s,.*:,,"`;		\
		${TEST} -n "$$pattern" || exit 1;			\
		${TEST} -n "$$dir" || exit 1;				\
		${ECHO} "build	$$pattern	$$dir"			\
			>> ${.TARGET}.tmp;				\
	done
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${_REDUCE_DEPENDS_CMD} ${DEPENDS:Q} |				\
	while read dep; do						\
		pattern=`${ECHO} $$dep | ${SED} -e "s,:.*,,"`;		\
		dir=`${ECHO} $$dep | ${SED} -e "s,.*:,,"`;		\
		${TEST} -n "$$pattern" || exit 1;			\
		${TEST} -n "$$dir" || exit 1;				\
		${ECHO} "full	$$pattern	$$dir"			\
			>> ${.TARGET}.tmp;				\
	done
	${_PKG_SILENT}${_PKG_DEBUG}${MV} -f ${.TARGET}.tmp ${.TARGET}

######################################################################
### depends-install (PRIVATE, pkgsrc/mk/depends/depends.mk)
######################################################################
### depends-install installs any missing dependencies.
###
.PHONY: depends-install
depends-install: ${_DEPENDS_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}set -e;				\
	${CAT} ${_DEPENDS_FILE} |					\
	while read type pattern dir; do					\
		pkg=`${_PKG_BEST_EXISTS} "$$pattern" || ${TRUE}`;	\
		case "$$pkg" in						\
		"")							\
			${PHASE_MSG} "Required installed package $$pattern: NOT found"; \
			target=${DEPENDS_TARGET};			\
			${PHASE_MSG} "Verifying $$target for $$dir";	\
			if ${TEST} ! -d "$$dir"; then			\
				${ERROR_MSG} "[depends.mk] The directory \`\`$$dir'' does not exist."; \
				exit 1;					\
			fi;						\
			cd $$dir;					\
			${SETENV} _PKGSRC_DEPS=", ${PKGNAME}${_PKGSRC_DEPS}" PKGNAME_REQD="$$pattern" ${MAKE} ${MAKEFLAGS} _AUTOMATIC=yes $$target;	\
			pkg=`${_PKG_BEST_EXISTS} "$$pattern" || ${TRUE}`; \
			case "$$pkg" in					\
			"")	${ERROR_MSG} "[depends.mk] A package matching \`\`$$pattern'' should"; \
				${ERROR_MSG} "    be installed, but one cannot be found.  Perhaps there is a"; \
				${ERROR_MSG} "    stale work directory for $$dir?"; \
				exit 1;					\
			esac;						\
			${PHASE_MSG} "Returning to build of ${PKGNAME}"; \
			;;						\
		*)							\
			objfmt=`${PKG_INFO} -Q OBJECT_FMT "$$pkg"`;	\
			case "$$objfmt" in				\
			"")	${WARNING_MSG} "[depends.mk] Unknown object format for installed package $$pkg" ;; \
			${OBJECT_FMT})	;;				\
			*)	${ERROR_MSG} "[depends.mk] Installed package $$pkg has an"; \
				${ERROR_MSG} "    object format \`\`$$objfmt'' which differs from \`\`${OBJECT_FMT}''.  Please"; \
				${ERROR_MSG} "    update the $$pkg package to ${OBJECT_FMT}."; \
				exit 1;					\
				;;					\
			esac;						\
			${PHASE_MSG} "Required installed package $$pattern: $$pkg found"; \
			;;						\
		esac;							\
	done
