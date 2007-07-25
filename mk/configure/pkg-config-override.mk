# $NetBSD: pkg-config-override.mk,v 1.3 2007/07/25 18:07:34 rillig Exp $

# Package-settable variables:
#
# PKGCONFIG_OVERRIDE
#	The list of pkg-config files relative to WRKSRC in which the
#	compiler flags need to be adjusted.
#
# PKGCONFIG_OVERRIDE_STAGE
#	The stage in which the pkg-config files will be adjusted. By
#	default, this is pre-configure.
#

######################################################################
### pkg-config-override (PRIVATE)
######################################################################
### pkg-config-override inserts the compiler's "rpath" flag into
### pkg-config data files so that ``pkg-config --ldflags <module>'' will
### return the full set of compiler flags needed to find libraries at
### run-time.
###
.PHONY: pkg-config-override
pkg-config-override:
	@${DO_NADA}

.if defined(_USE_RPATH) && !empty(_USE_RPATH:M[yY][eE][sS])
pkg-config-override: subst-pkgconfig

PKGCONFIG_OVERRIDE_SED=	\
	'/^Libs:.*[ 	]/s|-L\([ 	]*[^ 	]*\)|${COMPILER_RPATH_FLAG}\1 -L\1|g'
PKGCONFIG_OVERRIDE_STAGE?=	pre-configure

SUBST_CLASSES+=			pkgconfig
.  if ${PKGCONFIG_OVERRIDE_STAGE} == "pre-configure"
SUBST_STAGE.pkgconfig=		do-configure-pre-hook
.  elif ${PKGCONFIG_OVERRIDE_STAGE} == "post-configure"
SUBST_STAGE.pkgconfig=		do-configure-post-hook
.  else
SUBST_STAGE.pkgconfig=		${PKGCONFIG_OVERRIDE_STAGE}
.  endif
SUBST_MESSAGE.pkgconfig=	Adding run-time search paths to pkg-config files.
SUBST_FILES.pkgconfig=		${PKGCONFIG_OVERRIDE:S/^${WRKSRC}\///}
SUBST_SED.pkgconfig=		${PKGCONFIG_OVERRIDE_SED}
.endif
