# $NetBSD: buildlink.mk,v 1.1 2001/06/25 03:48:18 jlam Exp $
#
# This Makefile fragment is included by packages that use jade.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.jade to the dependency pattern
#     for the version of jade desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(JADE_BUILDLINK_MK)
JADE_BUILDLINK_MK=	# defined

BUILDLINK_DEPENDS.jade?=	jade>=1.2.1
DEPENDS+=	${BUILDLINK_DEPENDS.jade}:../../textproc/jade

BUILDLINK_PREFIX.jade=	${LOCALBASE}
BUILDLINK_FILES.jade=	include/sp/*
BUILDLINK_FILES.jade+=	lib/libgrove.*
BUILDLINK_FILES.jade+=	lib/libsp.*
BUILDLINK_FILES.jade+=	lib/libspgrove.*
BUILDLINK_FILES.jade+=	lib/libstyle.*

.include "../../devel/gettext-lib/buildlink.mk"

BUILDLINK_TARGETS.jade=	jade-buildlink
BUILDLINK_TARGETS+=	${BUILDLINK_TARGETS.jade}

pre-configure: ${BUILDLINK_TARGETS.jade}
jade-buildlink: _BUILDLINK_USE

.include "../../mk/bsd.buildlink.mk"

.endif	# JADE_BUILDLINK_MK
