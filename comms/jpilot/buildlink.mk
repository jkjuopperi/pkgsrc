# $NetBSD: buildlink.mk,v 1.3 2001/06/23 19:26:49 jlam Exp $
#
# This Makefile fragment is included by packages that use jpilot.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.jpilot to the dependency pattern
#     for the version of jpilot desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(JPILOT_BUILDLINK_MK)
JPILOT_BUILDLINK_MK=	# defined

BUILDLINK_DEPENDS.jpilot?=	jpilot>=0.99
BUILD_DEPENDS+=			${BUILDLINK_DEPENDS.jpilot}:../../comms/jpilot

BUILDLINK_PREFIX.jpilot=	${LOCALBASE}
BUILDLINK_FILES.jpilot=		include/jpilot/*

.include "../../x11/gtk/buildlink.mk"

BUILDLINK_TARGETS.jpilot=	jpilot-buildlink
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.jpilot}

pre-configure: ${BUILDLINK_TARGETS.jpilot}
jpilot-buildlink: _BUILDLINK_USE

.include "../../mk/bsd.buildlink.mk"

.endif	# JPILOT_BUILDLINK_MK
