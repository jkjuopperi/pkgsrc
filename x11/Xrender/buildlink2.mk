# $NetBSD: buildlink2.mk,v 1.7 2004/02/05 07:06:15 jlam Exp $

.if !defined(XRENDER_BUILDLINK2_MK)
XRENDER_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.prefs.mk"

BUILDLINK_DEPENDS.Xrender?=	Xrender>=0.2
BUILDLINK_PKGSRCDIR.Xrender?=	../../x11/Xrender

# Check if we got Xrender distributed with XFree86 4.x or if we need to
# depend on the Xrender package.
#
_REQUIRE_BUILTIN_XRENDER?=	NO

_RENDER_H=		${X11BASE}/include/X11/extensions/render.h
_X11_TMPL=		${X11BASE}/lib/X11/config/X11.tmpl
.if exists(${_RENDER_H}) && exists(${_X11_TMPL})
_IS_BUILTIN_XRENDER!= ${GREP} -c BuildRenderLibrary ${_X11_TMPL} || ${TRUE}
.else
_IS_BUILTIN_XRENDER=	0
.endif

.if !empty(_REQUIRE_BUILTIN_XRENDER:M[yY][eE][sS])
_NEED_XRENDER=	NO
.else
.  if ${_IS_BUILTIN_XRENDER} == "0"
_NEED_XRENDER=	YES
.  else
#
# Create an appropriate Xrender package name for the built-in Xrender
# distributed with XFree86 4.x.  This package name can be used to check
# against BUILDLINK_DEPENDS.Xrender to see if we need to install the
# pkgsrc Xrender or if the built-in one is sufficient.
#
_XRENDER_MAJOR!= \
	${AWK} '/.*\#define.*RENDER_MAJOR/ { print $$3 }' ${_RENDER_H}
_XRENDER_MINOR!= \
	${AWK} '/.*\#define.*RENDER_MINOR/ { print "."$$3 }' ${_RENDER_H}
_XRENDER_VERSION=	${_XRENDER_MAJOR}${_XRENDER_MINOR}
_XRENDER_PKG=		Xrender-${_XRENDER_VERSION}
_XRENDER_DEPENDS=	${BUILDLINK_DEPENDS.Xrender}
_NEED_XRENDER!= \
	if ${PKG_ADMIN} pmatch '${_XRENDER_DEPENDS}' ${_XRENDER_PKG}; then \
		${ECHO} "NO";						\
	else								\
		${ECHO} "YES";						\
	fi
.  endif
.endif

BUILDLINK_FILES.Xrender=	include/X11/extensions/Xrender.h
BUILDLINK_FILES.Xrender+=	lib/libXrender.*

.if defined(PREFER_PKGSRC)
.  if empty(PREFER_PKGSRC) || !empty(PREFER_PKGSRC:M[yY][eE][sS]) || \
      !empty(PREFER_PKGSRC:MXrender)
_NEED_XRENDER=	YES
.  endif
.endif

.if ${_NEED_XRENDER} == "YES"
BUILDLINK_PACKAGES+=			Xrender
EVAL_PREFIX+=	BUILDLINK_PREFIX.Xrender=Xrender
BUILDLINK_PREFIX.Xrender_DEFAULT=	${X11PREFIX}
#
# If we depend on the package, depend on the latest version
# with a library minor bump.
#
BUILDLINK_DEPENDS.Xrender=	Xrender>=0.8.2

.include "../../x11/render/buildlink2.mk"
.else
BUILDLINK_PREFIX.Xrender=	${X11BASE}
BUILDLINK_FILES.Xrender+=	include/X11/extensions/extutil.h
BUILDLINK_FILES.Xrender+=	include/X11/extensions/region.h
BUILDLINK_FILES.Xrender+=	include/X11/extensions/render.h
BUILDLINK_FILES.Xrender+=	include/X11/extensions/renderproto.h
.endif

USE_X11=			# defined

BUILDLINK_TARGETS+=		Xrender-buildlink

Xrender-buildlink: _BUILDLINK_USE

.endif	# XRENDER_BUILDLINK2_MK
