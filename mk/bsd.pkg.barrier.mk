# $NetBSD: bsd.pkg.barrier.mk,v 1.3 2006/07/06 15:43:10 jlam Exp $

_BARRIER_COOKIE=	${WRKDIR}/.barrier_cookie

# _BARRIER_PRE_TARGETS is a list of the targets that must be built before
#	the "barrier" target invokes a new make.
#
_BARRIER_PRE_TARGETS=	patch

# _BARRIER_POST_TARGETS is a list of the targets that must be built after
#	the "barrier" target invokes a new make.  This list is specially
#	ordered so that if more than one is specified on the command-line,
#	then pkgsrc will still do the right thing.
#
_BARRIER_POST_TARGETS=	wrapper
_BARRIER_POST_TARGETS+=	configure
_BARRIER_POST_TARGETS+=	build
_BARRIER_POST_TARGETS+=	test
_BARRIER_POST_TARGETS+=	all
_BARRIER_POST_TARGETS+=	install
_BARRIER_POST_TARGETS+=	reinstall
_BARRIER_POST_TARGETS+=	package
_BARRIER_POST_TARGETS+=	repackage

# XXX This target should probably be handled specially.
_BARRIER_POST_TARGETS+=	replace

.for _target_ in ${_BARRIER_POST_TARGETS}
.  if make(${_target_})
_BARRIER_CMDLINE_TARGETS+=	${_target_}
.  endif
.endfor

######################################################################
### barrier (PRIVATE)
######################################################################
### barrier is a helper target that can be used to separate targets
### that should be built in a new make process from being built in
### the current one.  The targets that must be built after the "barrier"
### target invokes a new make should be listed in _BARRIER_POST_TARGETS,
### and should be of the form:
###
###	.if !exists(${_BARRIER_COOKIE})
###	foo: barrier
###	.else
###	foo: foo's real source dependencies
###	.endif
###
### Note that none of foo's real source dependencies should include
### targets that occur before the barrier.
###

.PHONY: barrier
barrier: ${_BARRIER_PRE_TARGETS} barrier-cookie
.if !exists(${_BARRIER_COOKIE})
.  if defined(PKG_VERBOSE)
	@${PHASE_MSG} "Invoking \`\`"${_BARRIER_CMDLINE_TARGETS:Q}"'' after barrier for ${PKGNAME}"
.  endif
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${BUILD_ENV} ${MAKE} ${MAKEFLAGS} ALLOW_VULNERABLE_PACKAGES= ${_BARRIER_CMDLINE_TARGETS}
.  if defined(PKG_VERBOSE)
	@${PHASE_MSG} "Leaving \`\`"${_BARRIER_CMDLINE_TARGETS:Q}"'' after barrier for ${PKGNAME}"
.  endif
.endif

######################################################################
### barrier-cookie (PRIVATE)
######################################################################
### barrier-cookie creates the "barrier" cookie file.
###
barrier-cookie:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${_BARRIER_COOKIE:H}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} ${PKGNAME} > ${_BARRIER_COOKIE}
