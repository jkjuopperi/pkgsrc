# $NetBSD: buildlink.mk,v 1.2 2001/07/01 22:59:30 jlam Exp $
#
# This Makefile fragment is included by packages that use t1lib.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.t1lib to the dependency pattern
#     for the version of t1lib desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(T1LIB_BUILDLINK_MK)
T1LIB_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_DEPENDS.t1lib?=	t1lib>=1.0.1
DEPENDS+=	${BUILDLINK_DEPENDS.t1lib}:../../textproc/t1lib

BUILDLINK_PREFIX.t1lib=		${LOCALBASE}
BUILDLINK_FILES.t1lib=		include/t1lib.h
BUILDLINK_FILES.t1lib+=		include/t1libx.h
BUILDLINK_FILES.t1lib+=		lib/libt1.*
BUILDLINK_FILES.t1lib+=		lib/libt1x.*

BUILDLINK_TARGETS.t1lib=	t1lib-buildlink
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.t1lib}

pre-configure: ${BUILDLINK_TARGETS.t1lib}
t1lib-buildlink: _BUILDLINK_USE

.endif	# T1LIB_BUILDLINK_MK
