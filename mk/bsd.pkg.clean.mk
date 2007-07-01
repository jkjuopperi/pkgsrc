# $NetBSD: bsd.pkg.clean.mk,v 1.10 2007/07/01 00:06:40 adrianp Exp $
#
# This Makefile fragment is included to bsd.pkg.mk and defines the
# relevant variables and targets for the "clean" phase.
#
# The following variables may be set by the package Makefile and
# specify how cleaning happens:
#
#    CLEANDEPENDS specifies the whether "cleaning" will also clean
#	in all dependencies, implied and direct.  CLEANDEPENDS
#	defaults to "no".
#
# The following targets are defined by bsd.pkg.clean.mk:
#
#    clean-depends is the target which descends into dependencies'
#	package directories and invokes the "clean" action.
#
#    do-clean is the target that does the actual cleaning, which
#	involves removing the work directory and other temporary
#	files used by the package.
#
#    clean is the target that is invoked by the user to perform
#	the "clean" action.
#
#    cleandir is an alias for "clean".
#

CLEANDEPENDS?=	no

.if defined(PRIVILEGED_STAGE) && !empty(PRIVILEGED_STAGE:Mclean)
_MAKE_CLEAN_AS_ROOT=yes
.endif

.PHONY: clean-depends
clean-depends:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${_DEPENDS_WALK_CMD} ${PKGPATH} |				\
	while read dir; do						\
		cd ${.CURDIR}/../../$$dir &&				\
		${RECURSIVE_MAKE} ${MAKEFLAGS} CLEANDEPENDS=no clean;	\
	done

.PHONY: pre-clean
.if !target(pre-clean)
pre-clean:
	@${DO_NADA}
.endif

.PHONY: post-clean
.if !target(post-clean)
post-clean:
	@${DO_NADA}
.endif

.PHONY: do-clean
.if !target(do-clean)
.  if !empty(_MAKE_CLEAN_AS_ROOT:M[Yy][Ee][Ss])
do-clean: su-target
.  else
do-clean: su-do-clean
.  endif
.endif

su-do-clean:
	@${PHASE_MSG} "Cleaning for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if ${TEST} -d ${WRKDIR:Q}; then					\
		if ${TEST} -w ${WRKDIR:Q}; then				\
			${RM} -fr ${WRKDIR:Q};				\
		else							\
			${STEP_MSG} ${WRKDIR:Q}" not writable, skipping"; \
		fi;							\
        fi
.  if defined(WRKOBJDIR)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${RMDIR} ${BUILD_DIR} 2>/dev/null || ${TRUE};			\
	${RM} -f ${WRKDIR_BASENAME} 2>/dev/null || ${TRUE}
.  endif

_CLEAN_TARGETS+=	pre-clean
.if empty(CLEANDEPENDS:M[nN][oO])
_CLEAN_TARGETS+=	clean-depends
.endif
_CLEAN_TARGETS+=	do-clean
_CLEAN_TARGETS+=	post-clean

.PHONY: clean
.if !target(clean)
clean: ${_CLEAN_TARGETS}
.endif

.PHONY: cleandir
cleandir: clean
